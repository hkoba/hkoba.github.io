---
marp: true
---

### (Perl API に絞って)
# C のマクロから Rust への変換器を
## Claude Code に書かせてみました


by [@hkoba](https://github.com/hkoba/) ![](img/myfistrect.jpg)

---

# 背景
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
- Perl の内部 APIからも生成できた
  - <small>詳細は [→ YAPC::名古屋2019](https://hkoba.github.io/slides/yapcjapan2019nagoya/#/)</small>

---

## 問題：生成コードが Perl のバージョンやビルドフラグに依存

- 5.20 用に書いた rust コードが 5.22 でビルドできなくなる

- 5.36 用に…

---

## 原因

C で書いたライブラリなら、互換性を維持するためのマクロが利用できる

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

---

## Cのマクロも Rust 化したい！

Perl の API ヘッダー専用なら、行けるんじゃぁ…

- Perl の SV 構造体（基本となる Variant）
  - SV, AV, HV, CV, GV, ... 基本構造は同じだけど、細かいメンバーが違う

- マクロの中の式が使っているメンバー名から、期待する構造体が分かる
   ```c
   #define HvAUX(hv)       (&(((struct xpvhv_with_aux*)  SvANY(hv))->xhv_aux))
   ```
  - `xhv_aux` があるのは `struct HV` だけ。→なら引数 hv は `HV*` よね

- `HvNAME_get(hv)` は `HvAUX(hv)` を呼び出してるので、この引数 hv も `HV*`

---

## apidoc というのがある

---

# マクロ展開


---

```rust
pub unsafe fn HvNAME_get(hv: *const SV) -> *mut c_char {
    unsafe {
        if SvOOK (hv) != 0 && ! (* HvAUX (hv)) . xhv_name_u . xhvnameu_name . is_null () && ! HvNAME_HEK_NN (hv) . is_null () { HEK_KEY (HvNAME_HEK_NN (hv)) } else { std :: ptr :: null_mut () }
    }
}
```

```rust
pub unsafe fn HvNAME_get(hv: *const HV) -> *mut c_char {
    unsafe {
        if HvHasNAME (hv as * const SV) { HEK_KEY (HvNAME_HEK_NN (hv as * const SV)) } else { std :: ptr :: null_mut () }
    }
}
```
