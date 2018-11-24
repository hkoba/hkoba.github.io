### <small>(天才以外の)</small>人に
## エディタは
## エラーを
### いつ、どう伝えるべきか？


#### 八王子pm74, 2018-11-24

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](http://hkoba.github.io/)

---

### 極めて個人的な、好みの話です

---

今日のサンプルコード

<small>
出典 https://www.typescriptlang.org/docs/handbook/namespaces.html
</small>

![](img/samplecode.png)

<small>与えられた文字列が、アルファベットのみか否かを検査</small>

---

<!-- .slide: class="small" -->

![](img/samplecode.png)

* Emacs
* ＋ flycheck
* ＋ lsp-mode (Language Server Protocol)

---

#### <small>さて</small>

### メソッド名を、typo した

#### <small>とします</small>

---

### flycheck + lsp のエラー通知画面

![](img/flycheck-error-default.png)

<small>**素人さんは、気づかないのでは？**</small><!-- .element: class="fragment" -->

---

![](img/flycheck-error-default.png)

* 小さすぎる
* 壊れている、のに書き進められる<!-- .element: class="fragment" -->

---

### 壊れたまま
#### 書き進めても大丈夫なのは
## 天才だけなのでは？

---

#### <small>みなさんは</small>

### 素人さんが
### 壊したコードを
### 尻拭いで直した経験は
### ありませんか？

<small>**あれ辛くないですか？**</small><!-- .element: class="fragment" -->

---

#### 壊したら、壊した時点で
## **エディタに**<!-- .element: class="fragment" -->
## 止めて欲しい<!-- .element: class="fragment" -->

---

少なくとも、素人さんに渡す道具には、

#### 壊れた時点で、<!-- .element: class="fragment" -->
#### それ以上壊さないよう<!-- .element: class="fragment" -->
## 今すぐ直せと<!-- .element: class="fragment" -->
#### 指示を出す機能が欲しい<!-- .element: class="fragment" -->

---

#### 指示を出すとして、

## いつ？<!-- .element: class="fragment" -->

書いてる最中は、壊れている瞬間をゼロに出来ない<!-- .element: class="fragment" -->

---

#### プログラマーが
#### エディタに<!-- .element: class="fragment" -->
### これで正しいはず！<!-- .element: class="fragment" -->
#### と伝える仕組みが有れば良い<!-- .element: class="fragment" -->

---

#### <small>それには</small>
## ファイル保存<!-- .element: class="fragment" -->
#### というアクションが、好適では？<!-- .element: class="fragment" -->

---

<small>具体的には</small>

* エディタの保存時に<!-- .element: class="fragment" -->
* コードが壊れていたら<!-- .element: class="fragment" -->
* 最初のエラーの行へ<!-- .element: class="fragment" -->
* カーソルを強制で飛ばす<!-- .element: class="fragment" -->

---

* 画面も警告色に変える
  * 直すまで色が消えないようにする<!-- .element: class="fragment" -->
  
### 大昔の TurboPascal みたいな感じ？<!-- .element: class="fragment" -->

---

#### そんな elisp を書いてました

![](img/flycheck-lsp-jmp2err-on-save.png)

<small>https://github.com/hkoba/emacs-on-save-jump-to-lsp-error</small>

---

マメに保存＝マメに検査

## とても良い<!-- .element: class="fragment" -->

---

* VS Code でも同じことをしたいので、設定ご存知な方、教えて頂けると嬉しいです

- - - - -

### おしまい
