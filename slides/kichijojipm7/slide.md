## Why %FIELDS and how.

Perl の use strict をもっと活かすための,  
fields、保存時検査、そして import の使い方

## kichijoji.pm #7

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** 

---

## Who am I

* Freelance programmer
* `@hkoba` (in CPAN, GitHub, Twitter)
* My Modules: `YATT::Lite`, `App::perlminlint`, `MOP4Import::Declare`
* Writes: Perl, Tcl/Tk, Zsh, Emacs Lisp and C/C++.


---

## Demo 1.

---

## I will talk about:

* `perl -wc` and `use strict`
   * So, **When** to _perl -wc_?  
   (いつ _perl -wc_ を呼ぶべきか)
* `use fields` and `%FIELDS`

See [MOP4Import-Declare/whyfields](https://metacpan.org/pod/distribution/MOP4Import-Declare/whyfields.pod) for this talk.

---

# Demo 1



---

## Question!

When do you run `perl -wc` for your program?  
(どんな時、 `perl -wc` してますか？)

1. Never (全然)
2. Occationary (気が向いた時)
2. Every releasing (リリース時)
3. Every testing (テスト時)
4. <span class="fragment highlight-blue">Every editing (編集する度)</span>


---


## Why we love `use strict` ?

* Finds **TYPOs** of variable names.
* **Before** it runs.

---

# "Before"

Really?

