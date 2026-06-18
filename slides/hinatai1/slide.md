---
marp: true
theme: beamer
---

# ひなたい1 LT

### (Perl API に絞って)
# C のマクロから Rust への変換器を
## Claude Code に書かせてみました


by [@hkoba](https://github.com/hkoba/) ![](img/myfistrect.jpg)

---

# 背景・動機（ちょっと嘘）
- Perl の人口減少…

* ライブラリーのサポートが減ってきた

* Rust 版のライブラリを使えたら？！


---

# 従来やってたこと

- Rust には [bindgen](https://rust-lang.github.io/rust-bindgen/) がある
  - C の宣言を元に、Rust の宣言を生成する仕組み
     ```c
     void cool_function(int i, char c, CoolStruct* cs);
     ```
    ↓
     ```rust
     extern "C" {
         pub fn cool_function(i: ::std::os::raw::c_int,
                              c: ::std::os::raw::c_char,
                              cs: *mut CoolStruct);
     }
     ```
- Perl の内部 APIも Rust から呼べるようになった
  - <small>詳細は [→ YAPC::名古屋2019](https://hkoba.github.io/slides/yapcjapan2019nagoya/#/)</small>

---

# 問題

## 生成コードが Perl のバージョンやビルドフラグに依存！

- 5.20 用に書いた rust コードが 5.22 でビルドできなくなる

- マルチスレッド版 Perl とシングルスレッド版で、APIの引数が違う

---

# 原因

C で書いたライブラリなら、バージョン互換のためのマクロが利用できる

- perl5.38 より前
   ```c
   #define HvNAME_get(hv) \
           ((SvOOK(hv) && HvAUX(hv)->xhv_name_u.xhvnameu_name && HvNAME_HEK_NN(hv)) \
                            ? HEK_KEY(HvNAME_HEK_NN(hv)) : NULL)
   ```

* perl5.38 以後
   ```c
   #define HvNAME_get(hv) \
           (HvHasNAME(hv) ? HEK_KEY(HvNAME_HEK_NN(hv)) : NULL)
   ```

* Rust では `HvNAME_get` は生成されない（bindgen はマクロに非対応）
  - 困ったぞ

---

# 目標

## C のマクロも Rust 化したい！

```c
#define AvARRAY(av)     ((av)->sv_u.svu_array)
```

* マクロには型宣言が付いてない！ Rust に変換する時に型を付けられない

* けど `svu_array` は `struct AV` のメンバー → なら av は `AV*` では？

* Perl の内部に関する知識に基づいた型推論を作れば、ワンチャン行けるのでは…

---

# もくろみ

- Perl にしか使えないコンパイラを作るなんて、**人間はやりたくない！**

* けど、Claude Code は **体力お化け**

  * 文句を言わずにやってくれるのでは…

---

# 構想

- 既存の Cコンパイラをベースに、Perl API 専用の C→ Rust トランスパイラーを作る
  - プリプロセッサ
  - 意味解析
  - 生成ターゲットは Rust

- ベースは [TinyCC](https://ja.wikipedia.org/wiki/Tiny_C_Compiler) を採用

  - 元のライセンスを尊重するため、トランスパイラーだけ別プロジェクト(macrogen)に隔離

---

# 最初のプロンプト(1/2)

<small>
このプロジェクトは `./tinycc` のソースコードを元に、C から rust へのソースコード変換ツールを rust で作成する実験です。

このプロジェクトでは、tinycc がコンパイルできた全てのソースコードを受理できるようにしたいので、これから作成する rust 版のコードも出来るだけオリジナルの tinycc と同じ設計にしたいと考えています。

ですので、まず最初に、オリジナルの tinycc の preprocessor と、 compiler の意味解析までの範囲の、全ての関数の呼び出し関係・役割分担を把握し、リストアップして下さい。

その上で、そのリストに対して、rust への移植の際に改善できる点があれば、提案して下さい。
</small>

---

# プロンプト(2/2)

なお、データ構造に関して rust の標準データ構造を利用できそうな箇所は、それに置き換える方向で考えて下さい。

また、このプログラムが最終的に出力対象とするのは、特定のディレクトリに置かれたヘッダーファイルで定義された C の inline static 関数と C のプリプロセッサマクロを予定しています。ですので、その関数やマクロがどのファイルで定義されたかを記録しておくようにして下さい。

---

# どうなった

期間：2025/12/24 〜 2026/05/09

- Opus 4.5 → 4.6 → 4.7

- うち、トランスパイラーに約120日(〜04/25)

* 楽ちんじゃ、なかった…

---

# 出力の例：5.36

```rust
pub unsafe fn HvNAME_get(hv: *const SV) -> *mut c_char {
    unsafe {
        if SvOOK (hv) != 0 
          && ! (* HvAUX (hv)) . xhv_name_u . xhvnameu_name . is_null () 
          && ! HvNAME_HEK_NN (hv) . is_null () { 
            HEK_KEY (HvNAME_HEK_NN (hv)) 
         } else { 
            std :: ptr :: null_mut () 
         }
    }
}
```

---

# 出力の例：5.38

```rust
pub unsafe fn HvNAME_get(hv: *const HV) -> *mut c_char {
    unsafe {
        if HvHasNAME (hv as * const SV) { 
          HEK_KEY (HvNAME_HEK_NN (hv as * const SV)) 
        } else { 
          std :: ptr :: null_mut () 
        }
    }
}
```

---

# まとめ：得られた知見

- 既存の OSS の部分移植は、コーディングエージェントで実用段階に

  - 興味のある OSS を、自分の得意な言語 X で実装し直してもらう

  - ライセンスの尊重は前提

- モデルが進化する度に、中断やターン単位の細かい指示の必要が減った

  - 代わりに plan mode での計画・議論が大事になった感

- 研究室の同僚か、外注さんみたいに接するのが良さそう？

---

# 真の背景・動機

- 静的解析の強い言語、羨ましい、**それに比べて Perl は…**

* Perl の AST (OP Tree) を解析するツールを作りたい、
  - けどパターンマッチ抜きで AST スキャンのコードを書くのは骨が折れそう

* Rust から Perl の AST をアクセスできれば良いのでは？

