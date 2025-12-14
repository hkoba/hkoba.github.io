# ありがとうございます。私の最終的な目的は、（カバレッジを取ることではなく）Perl のソースコードか

## Assistant

全体像が把握できました。真理値表生成の観点から Devel::Cover の仕組みを解説します。

---

## Devel::Cover が真理値表を生成する仕組み

### 1. 全体の流れ

```
[実行時] XS層 (Cover.xs)     [事後解析] Perl層 (Cover.pm)     [表示] Truth_Table.pm
        ↓                            ↓                              ↓
  OP 実行を監視              B::Deparse でコード復元          真理値表を構築
  条件の結果を収集           条件式のテキスト取得             複合式をマージ
```

---

### 2. XS層: 条件の実行結果を収集 (`Cover.xs`)

#### 2.1 条件配列の構造 (行 511-526)

```c
/*
 * 条件配列は6要素で構成:
 * 0 - XOR で最初のオペランドが true だったフラグ
 * 1 - 短絡せず、第2オペランドが false
 * 2 - 短絡せず、第2オペランドが true
 * 3 - 短絡した (または XOR で第2オペランドが false)
 * 4 - XOR で第2オペランドが true
 * 5 - void context フラグ
 */
```

#### 2.2 論理演算の追跡 (`cover_logop()` 行 786-972)

核心となるトリック: **次のOPの `op_ppaddr` を一時的に `get_condition()` に置き換える**

```c
static void cover_logop(pTHX) {
    // スタックから左辺の値を取得
    int leftval_true_ish = SvTRUE(TOPs);
    
    if ((PL_op->op_type == OP_AND && leftval_true_ish) ||  // AND: 左が true → 右へ
        (PL_op->op_type == OP_OR && !leftval_true_ish)) {  // OR: 左が false → 右へ
        // 短絡しない場合
        
        OP *next = right->op_next;  // 右辺実行後の次のOP
        
        // 次のOPの実行関数を get_condition() に置き換え
        next->op_ppaddr = get_condition;
        
        // Pending_conditionals ハッシュに記録
        av_push(conds, newSViv(PTR2IV(PL_op)));
    } else {
        // 短絡した場合
        add_conditional(aTHX_ PL_op, 3);  // インデックス3に記録
    }
}
```

#### 2.3 条件の結果を取得 (`get_condition()` 行 707-728)

```c
static OP *get_condition(pTHX) {
    // スタックから第2オペランドの結果を取得
    int true_ish = SvTRUE(TOPs);
    
    // インデックス: 1=false, 2=true
    add_condition(aTHX_ *pc, true_ish ? 2 : 1);
    
    // 元の ppaddr を復元して実行
    return PL_op;
}
```

---

### 3. Perl層: 条件式のテキストを取得 (`Devel::Cover.pm`)

#### 3.1 B::Deparse のフック (行 1124-1170)

```perl
# 元の関数を保存
BEGIN {
    $Original{logop} = \&B::Deparse::logop;
}

# カスタム版で置き換え
sub logop {
    my $self = shift;
    my ($op, $cx, $lowop, $lowprec, $highop, $highprec, $blockname) = @_;
    
    my $left  = $op->first;           # 左辺のOP
    my $right = $op->first->sibling;  # 右辺のOP
    
    # 左辺と右辺をテキストに変換
    $left  = $self->deparse_binop_left($op, $left, $highprec);
    $right = $self->deparse_binop_right($op, $right, $highprec);
    
    # 条件カバレッジを記録
    add_condition_cover($op, $highop, $left, $right);
    # 例: add_condition_cover($op, "&&", "$a", "$b")
}
```

#### 3.2 条件の構造化 (`add_condition_cover()` 行 906-966)

```perl
sub add_condition_cover {
    my ($op, $strop, $left, $right) = @_;
    
    my $type = $op->name;  # "and", "or", "xor"
    my $c = $Coverage->{condition}{$key};  # XS から収集したデータ
    
    # 条件タイプを決定
    if ($type eq "or" || $type eq "and") {
        if ($c->[5] || $name =~ $Const_right) {
            # 右辺が定数 → 2パス
            $count = 2;
        } else {
            # 通常 → 3パス
            $count = 3;
            @$c = @{$c}[$type eq "or" ? (3, 2, 1) : (3, 1, 2)];
        }
    } elsif ($type eq "xor") {
        # XOR → 4パス
        @$c = @{$c}[3, 2, 4, 1];  # !l&&!r, l&&!r, l&&r, !l&&r
        $count = 4;
    }
    
    # 構造を保存
    my $structure = {
        type  => "${type}_${count}",  # "and_3", "or_3", "xor_4" など
        op    => $strop,              # "&&", "||", "xor"
        left  => $left,               # "$a"
        right => $right,              # "$b"
    };
}
```

---

### 4. 真理値表の生成 (`Truth_Table.pm`)

#### 4.1 条件タイプと真理値表

| タイプ | 演算子 | パス数 | ヘッダー |
|--------|--------|--------|----------|
| `and_3` | `&&` | 3 | `!l`, `l&&!r`, `l&&r` |
| `or_3` | `||` | 3 | `l`, `!l&&r`, `!l&&!r` |
| `and_2` | `&&` (右が定数) | 2 | `l`, `!l` |
| `or_2` | `||` (右が定数) | 2 | `l`, `!l` |
| `xor_4` | `xor` | 4 | `l&&r`, `l&&!r`, `!l&&r`, `!l&&!r` |

#### 4.2 基本真理値表の生成 (行 257-287)

```perl
# $a && $b の真理値表
sub and_tt {
    return (
        # inputs,   result, covered
        Row->new([ 0, 'X' ], 0, shift),  # $a=false → 短絡、結果=false
        Row->new([ 1, 0 ],   0, shift),  # $a=true, $b=false → 結果=false
        Row->new([ 1, 1 ],   1, shift),  # $a=true, $b=true → 結果=true
    );
}

# $a || $b の真理値表
sub or_tt {
    return (
        Row->new([ 0, 0 ],   0, shift),  # $a=false, $b=false → 結果=false
        Row->new([ 0, 1 ],   1, shift),  # $a=false, $b=true → 結果=true
        Row->new([ 1, 'X' ], 1, shift),  # $a=true → 短絡、結果=true
    );
}

# $a xor $b の真理値表 (短絡評価なし)
sub xor_tt {
    return (
        Row->new([ 0, 0 ], 0, shift),  # false xor false = false
        Row->new([ 0, 1 ], 1, shift),  # false xor true = true
        Row->new([ 1, 0 ], 1, shift),  # true xor false = true
        Row->new([ 1, 1 ], 0, shift),  # true xor true = false
    );
}
```

**`X` は "don't care"** = 短絡評価により右辺が評価されなかった

#### 4.3 複合式のマージ (行 352-474)

例: `($a || $b) && $c` を構築

```perl
# Step 1: 基本テーブル
#   A:  $a || $b          B:  b1 && $c (b1 = $a || $b)
#   a  b | a||b           b1  c | b1&&c
#   0  0 |  0              0  X |   0
#   0  1 |  1              1  0 |   0  
#   1  X |  1              1  1 |   1

# Step 2: B の b1 を A で展開
# b1=0 の行 → A から a||b=0 の行 (0,0) を代入
# b1=1 の行 → A から a||b=1 の行 (0,1), (1,X) を代入

# 結果:
#   a  b  c | (a||b)&&c
#   0  0  X |    0       # 短絡
#   0  1  0 |    0
#   1  X  0 |    0
#   0  1  1 |    1
#   1  X  1 |    1
```

---

### 5. 真理値表生成に参考になる箇所まとめ

| ファイル | 行 | 内容 |
|----------|-----|------|
| `Cover.xs` | 511-526 | 条件配列の構造定義 |
| `Cover.xs` | 786-972 | `cover_logop()` - 論理演算の追跡 |
| `Cover.xs` | 707-728 | `get_condition()` - ppaddr置換トリック |
| `Cover.pm` | 906-966 | `add_condition_cover()` - タイプ決定 |
| `Cover.pm` | 1124-1170 | `logop()` - B::Deparse フック |
| `Truth_Table.pm` | 257-287 | `and_tt()`, `or_tt()`, `xor_tt()` |
| `Truth_Table.pm` | 409-474 | `left_merge()`, `right_merge()` |
| `Condition_*.pm` | 全体 | 各条件タイプの定義 |

---

### あなたの目的（真理値表生成）へのヒント

1. **B::Deparse の活用** - OP ツリーからソースコードのテキスト表現を復元
2. **OP の走査** - `$op->first`, `$op->sibling` で論理式の構造を把握
3. **短絡評価の考慮** - `X` (don't care) で到達しないパスを表現
4. **マージアルゴリズム** - 複合式を部分式から構築

何か特定の部分について詳しく知りたい点はありますか？

---

<small style="color: gray">uuid: 3f86aa51-21d7-4eea-9828-89637dcca83c</small>