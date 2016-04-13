;; -*- coding: utf-8 -*-
;; emslide.el --- Create/Replay a slide of editing session in Emacs.

;; Copyright (C) 2008
;; KOBAYASI Hiroaki <hkoba@cpan.org>

(require 'cl)
(require 'derived)

(defvar emslide-target-buffer nil
  "Primary target buffer for emslide")
(defvar emslide-target-window nil
  "Primary target frame for emslide")
(defvar emslide-target-frame nil
  "Primary target frame for emslide")

(defvar emslide-is-active t
  "If nil, action is not invoked.")

(defvar emslide-key-rate 0.1
  "text insertion speed")

(defun emslide (file)
  (interactive "f")
  (find-file file)
  (emslide-buffer (current-buffer)))

(defun emslide-buffer (buffer)
  (interactive "b")
  ;; 別窓で、control を開く…
  ;; ファイルを開いて
  (emslide-mode)
  (let* ((upwin (selected-window))
	 (lowwin (split-window))
	 (target (current-buffer))
	 (control
	  (get-buffer-create (concat "*Control " (buffer-name buffer)))))
    (progn
      (select-window upwin)
      (switch-to-buffer control)
      (emslide-control-for target))
    (progn
      (select-window lowwin))))


(define-derived-mode emslide-mode
  lisp-mode "EmSlide"
  "Slide in Emacs"

  (mapcar (lambda (sym)
	    (make-variable-buffer-local sym))
	  '(emslide-target-buffer
	    emslide-target-window
	    emslide-target-frame
	    emslide-is-active
	    ))

  (setq emslide-is-active t
	truncate-lines t)
  (delete-other-windows))

;; emslide-mode (slide バッファ) でのみ呼び出すこと。

(defun emslide-read (buffer)
  (let ((result (read buffer))
	(ws "[[:space:]\n]+"))
    (if (looking-at ws)
	(re-search-forward ws))
    (lisp-indent-line)
    result))

(defun emslide-get (dict key)
  (let ((entry (assoc key dict)))
    (when entry
      (if (list (cdr entry))
	  (cadr entry)
	(cdr entry)))))

(defun emslide-page-enter ()
  (interactive)
  ;; XXX: slide バッファ以外で呼び出したらエラー、にするべきか。
  (down-list)
  (emslide-read (current-buffer));; (page)
  (let* ((slide (current-buffer))
	 (page-desc  (emslide-read slide))
	 (page-title (car page-desc))
	 (page-dict  (cdr page-desc))
	 file buffer window frame)
    (when emslide-is-active
      (multiple-value-setq (buffer window frame)
	(cond ((setq file (emslide-get page-dict 'file))
	       ;; file is specified
	       (emslide-page-enter-file file page-dict
					emslide-target-frame))
	      (t
	       ;; otherwise
	       (emslide-page-enter-any emslide-target-frame))))
      ;;
      (setq emslide-target-buffer buffer)
      (when window
	(setq emslide-target-window window)
	(delete-other-windows window))
      (when frame
	(setq emslide-target-frame frame)
	(setf (frame-parameter frame 'title) page-title)))))

(defun emslide-page-enter-any (&optional frame)
  (interactive)
  (let ((frame (or frame emslide-target-frame (make-frame)))
	buffer window)
    (with-selected-window (setq window (frame-first-window frame))
      (switch-to-buffer
       (setq buffer (generate-new-buffer "emslide-target"))))
    (list buffer window frame)))

(defun emslide-page-enter-file (file dict &optional frame)
  (interactive "f")
  (let ((frame (or frame emslide-target-frame))
	(dir (emslide-get dict 'workdir))
	buffer window)
    (save-current-buffer
      ;; 同じファイルが複数回指定されたとき、開き直すべきか否か。
      ;; undo navigation を考えるなら、バッファを消したくない。
      (setq buffer (find-file-noselect file))
      (cond ((and frame (frame-live-p frame))
	     (select-window (setq window (frame-first-window frame)))
	     (switch-to-buffer buffer))
	    (t
	     (switch-to-buffer-other-frame buffer)
	     (setq window (selected-window)
		   frame (selected-frame))))
      (when dir
	(setq default-directory (concat default-directory dir "/"))
	(write-file (concat default-directory file)))
      (list buffer window frame))))

(defun emslide-page-forward (&rest ignore)
  (interactive)
  (unless (eq (current-column) 0)
    (end-of-defun))
  (if (eobp)
      (message "End of buffer")
    (emslide-page-enter)))

(defun emslide-action-forward (&rest ignore)
  (interactive)
  (skip-syntax-forward "->");; space + comment-ender
  (lisp-indent-line)
  (cond ((eobp)
	 (message "End of buffer"))
	((eq (current-column) 0)
	 (emslide-page-enter))
	(t
	 (cond ((looking-at "[[:space:]\n]*)")
		(emslide-page-forward))
	       ((not (eobp))
		(emslide-invoke (emslide-read (current-buffer))))))))

(defun emslide-invoke (desc)
  (when emslide-is-active
    (let* ((dtype (car desc))
	   (fname (concat "emslide-handle-" (symbol-name dtype)))
	   (rest  (cdr desc))
	   (slide (current-buffer))
	   (buffer emslide-target-buffer)
	   (window emslide-target-window)
	   (frame  emslide-target-frame)
	   sym handler)
      (cond
       ((and (fboundp (setq sym (intern fname)))
	     (setq handler (symbol-function sym)))
	;; generic call
	(select-frame-set-input-focus frame)
	(select-window (frame-selected-window frame))
	(apply handler (cons slide rest))
	(setq emslide-target-window (selected-window))
	(select-frame-set-input-focus
	 (window-frame (get-buffer-window slide t))))
       
       (t
	(message "nop for %s" desc)
	)))))

;;========================================
;; ターゲットバッファ・window の中で実行される

(defun emslide-handle-save (slide)
  (save-buffer))

(defun emslide-handle-file (slide file)
  ;; こっちは、もう一つファイルを開けるケースだ。
  ;; other-window じゃない？
  (let ((buf (find-file-other-window file)) window frame)
    (select-window (get-buffer-window buf))))

(defun emslide-handle-quick (slide message)
  (insert message))

(defun emslide-handle-text (slide message)
  (let ((pos 0))
    (while (< pos (length message))
      (insert-char (aref message pos) 1)
      (sit-for emslide-key-rate)
      (incf pos))))

(defun emslide-handle-macro (slide macro)
  (execute-kbd-macro (read-kbd-macro macro)))

(defun emslide-handle-clipboard (slide text)
  (x-set-selection 'PRIMARY text)
  (message "set-clipboard(%s)" text))

(defun emslide-handle-web (slide url)
  (browse-url url))

;;; ========================================
;;; generic な関数

(defun emslide-is-mouse-event (ev)
  (and (listp ev)
       (member (car ev) '(down-mouse-1 mouse-1 mouse-2 mouse-3
				       switch-frame))))

(defun emslide-purify-macro (macro)
  (let (ev
	new
	(ok 0)
	(pos 0))
    (while (< pos (length macro))
      (setq ev (aref macro pos))
      (unless (emslide-is-mouse-event ev)
	(incf ok))
      (incf pos))
    (setq new (make-vector ok nil))
    (setq pos 0 ok 0)
    (while (< pos (length macro))
      (setq ev (aref macro pos))
      (unless (emslide-is-mouse-event ev)
	(aset new ok (aref macro pos))
	(incf ok))
      (incf pos))
    new))

;;;========================================

(require 'widget)

(eval-when-compile
  (require 'wid-edit))

(defvar emslide-control-source-buffer nil
  "Source slide of current control for emslide.")

(defun emslide-control-for (buffer)
  (emslide-control-mode)
  (setq emslide-control-source-buffer buffer))
  
(define-derived-mode emslide-control-mode fundamental-mode
  "EmSlide Control" "Control panel for EmSlide"
  
  (mapcar (lambda (sym) (make-variable-buffer-local sym))
	  '(emslide-control-source-buffer))
	  
  (let ((inhibit-read-only t))
    (erase-buffer))
  (remove-overlays)

  ;;========================================
  (widget-insert "\t\t\tRecord")
  (widget-insert "\n")
  ;;========================================
  (widget-insert "Action\t")
  (widget-create 'push-button
		 :notify (lambda (&rest ignore) (message "hello<<"))
		 "<")
  (widget-insert "\t")
  (widget-create 'push-button
		 :notify (lambda (&rest args)
			   (emslide-control-run
			    'emslide-action-forward args))
		 ">")

  (widget-insert "\t")
  (widget-create 'toggle
		 :notify 'emslide-control-record-toggle
		 :value nil
		 :on "Stop"
		 :off "Start")

  ;;========================================
  (widget-insert "\n")
  ;;========================================
  (widget-insert "Page\t")
  (widget-create 'push-button
		 :notify (lambda (&rest ignore) (message "hello>"))
		 "<")
  (widget-insert "\t")
  (widget-create 'push-button
		 :notify (lambda (&rest args)
			   (emslide-control-run
			    'emslide-page-forward args))
		 ">")
  (widget-insert "\t")
  (widget-create 'push-button
		 :notify 'emslide-control-exit
		 "Exit")

  (widget-insert "\n")
  ;;========================================
  (widget-create 'push-button
		 :notify 'emslide-test
		 "Test")
  (widget-insert "\t")
  (widget-create 'toggle
		 :notify (lambda (widget &rest ignore)
			   (with-current-buffer emslide-control-source-buffer
			     (setq emslide-is-active
				   (widget-value widget))))
		 :value t
		 :on "Active"
		 :off "Motion only")

  (widget-insert "\n")
  ;;========================================

  (use-local-map widget-keymap)
  (widget-setup)
  (fit-window-to-buffer)
  (setq buffer-read-only t))

(defun emslide-test (widget &rest ignore)
  (interactive)
)

(defun emslide-control-run (symbol args)
  ;; with-current-buffer だと、point が戻ってしまう??
  ;; multiple-window の時は、そういうものらしい…

  ;; focus が、相手側に行ってしまう。連打が使えない！
  ;; with-current-buffer 単体だと、画面上で cursor が更新されない。
  (let ((oldwin (selected-window))
	(window (get-buffer-window emslide-control-source-buffer)))
    (unwind-protect
	(progn
	  (select-window window)
	  (apply symbol args))
      (select-window oldwin))))
;; (with-selected-window) だと、handler 内の select-window まで
;; undo される？？

(defun emslide-control-exit (&rest ignore)
  (let ((control (current-buffer)))
    (with-current-buffer emslide-control-source-buffer
      (kill-buffer-and-window))
    (kill-buffer control)))

(defun emslide-control-record-toggle (widget &rest ignore)
  (let* ((slide emslide-control-source-buffer)
	 (target (with-current-buffer slide emslide-target-buffer)))
    (with-current-buffer target
      (cond ((widget-value widget)
	     (message "record start")
	     (kmacro-start-macro nil))
	    (t
	     (message "record stop")
	     (kmacro-end-macro nil)
	     ;;
	     (emslide-print slide
			    (list 'macro
				  (format-kbd-macro
				   (emslide-purify-macro last-kbd-macro))))
	     )))))

(defun emslide-print (slide list)
  (save-current-buffer
    (set-buffer slide)
    (prin1 list slide)
    (insert "\n")
    (lisp-indent-line)))

(provide 'emslide)
