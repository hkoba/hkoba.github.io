# ありがとうございます。やはり Devel::Cover は実行時の情報をキャプチャーして活用している

## Tool Interactions

**Tool: Write** `/home/hkoba/db/monthly/202512/tmp/Devel--Cover/examples/logic_tree_builder.pl`

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use v5.12;

#
# 論理式の木構造を静的に構築するサンプル
# Devel::Cover の手法を参考に、B モジュールで OP ツリーを解析
#

package LogicNode;

# 論理式の木構造を表現するノード

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub type     { $_[0]->{type} }
sub op       { $_[0]->{op} }
sub left     { $_[0]->{left} }
sub right    { $_[0]->{right} }
sub text     { $_[0]->{text} }
sub children { @{$_[0]->{children} // []} }

sub is_leaf {
    my $self = shift;
    return $self->{type} eq 'leaf';
}

sub to_string {
    my ($self, $indent) = @_;
    $indent //= 0;
    my $pad = "  " x $indent;

    if ($self->is_leaf) {
        return "${pad}LEAF: $self->{text}";
    }

    my @lines = ("${pad}$self->{type} [$self->{op}]");

    if ($self->{left}) {
        push @lines, "${pad}  LEFT:";
        if (ref $self->{left}) {
            push @lines, $self->{left}->to_string($indent + 2);
        } else {
            push @lines, "${pad}    $self->{left}";
        }
    }

    if ($self->{right}) {
        push @lines, "${pad}  RIGHT:";
        if (ref $self->{right}) {
            push @lines, $self->{right}->to_string($indent + 2);
        } else {
            push @lines, "${pad}    $self->{right}";
        }
    }

    return join("\n", @lines);
}

#==============================================================================
package LogicTreeBuilder;

use B qw(svref_2object OPf_KIDS);
use B::Deparse;

my %LOGIC_OPS = (
    and       => { symbol => '&&',  short_circuit => 'left_false' },
    andassign => { symbol => '&&=', short_circuit => 'left_false' },
    or        => { symbol => '||',  short_circuit => 'left_true' },
    orassign  => { symbol => '||=', short_circuit => 'left_true' },
    dor       => { symbol => '//',  short_circuit => 'left_defined' },
    dorassign => { symbol => '//=', short_circuit => 'left_defined' },
    xor       => { symbol => 'xor', short_circuit => 'none' },
);

sub new {
    my $class = shift;
    my $self = bless {
        deparse => B::Deparse->new('-x7'),  # -x7: 最小限の変形
    }, $class;
    return $self;
}

#------------------------------------------------------------------------------
# コードリファレンスから論理式の木を構築
#------------------------------------------------------------------------------
sub build_from_coderef {
    my ($self, $coderef) = @_;

    my $cv = svref_2object($coderef);
    return unless $cv->isa('B::CV');

    $self->{deparse}{curcv} = $cv;
    $self->{trees} = [];

    my $root = $cv->ROOT;
    return [] unless $root && !$root->isa('B::NULL');

    $self->_scan_for_logic($root);

    return $self->{trees};
}

#------------------------------------------------------------------------------
# 論理演算を探して木を構築
#------------------------------------------------------------------------------
sub _scan_for_logic {
    my ($self, $op) = @_;

    return unless $op && !$op->isa('B::NULL');

    my $name = $op->name;

    if (exists $LOGIC_OPS{$name}) {
        my $tree = $self->_build_logic_tree($op);
        push @{$self->{trees}}, $tree if $tree;
    } elsif ($name eq 'cond_expr') {
        my $tree = $self->_build_cond_tree($op);
        push @{$self->{trees}}, $tree if $tree;
    }

    # 子ノードを再帰的に走査
    if ($op->flags & OPf_KIDS) {
        for (my $kid = $op->first; $kid && !$kid->isa('B::NULL'); $kid = $kid->sibling) {
            $self->_scan_for_logic($kid);
        }
    }
}

#------------------------------------------------------------------------------
# 論理演算の木を構築 (再帰的に部分式も解析)
#------------------------------------------------------------------------------
sub _build_logic_tree {
    my ($self, $op) = @_;

    my $name = $op->name;
    my $info = $LOGIC_OPS{$name} or return;

    my $left_op = $op->first;
    return unless $left_op && !$left_op->isa('B::NULL');

    my $right_op = $left_op->sibling;
    return unless $right_op && !$right_op->isa('B::NULL');

    # 左辺と右辺を再帰的に解析
    my $left  = $self->_analyze_operand($left_op);
    my $right = $self->_analyze_operand($right_op);

    return LogicNode->new(
        type          => $name,
        op            => $info->{symbol},
        short_circuit => $info->{short_circuit},
        left          => $left,
        right         => $right,
        right_const   => $self->_is_constant($right_op),
    );
}

#------------------------------------------------------------------------------
# 三項演算子の木を構築
#------------------------------------------------------------------------------
sub _build_cond_tree {
    my ($self, $op) = @_;

    my $cond_op = $op->first;
    return unless $cond_op && !$cond_op->isa('B::NULL');

    my $true_op = $cond_op->sibling;
    my $false_op = $true_op ? $true_op->sibling : undef;

    return LogicNode->new(
        type      => 'cond_expr',
        op        => '?:',
        condition => $self->_analyze_operand($cond_op),
        left      => $self->_analyze_operand($true_op),
        right     => $self->_analyze_operand($false_op),
    );
}

#------------------------------------------------------------------------------
# オペランドを解析 (論理演算なら再帰、そうでなければ葉ノード)
#------------------------------------------------------------------------------
sub _analyze_operand {
    my ($self, $op) = @_;

    return '' unless $op && !$op->isa('B::NULL');

    my $name = $op->name;

    # 論理演算子なら再帰的に木を構築
    if (exists $LOGIC_OPS{$name}) {
        return $self->_build_logic_tree($op);
    }

    # null OP の場合は中身を見る
    if ($name eq 'null') {
        my $first = $op->first;
        if ($first && !$first->isa('B::NULL')) {
            my $inner_name = $first->name;
            if (exists $LOGIC_OPS{$inner_name}) {
                return $self->_build_logic_tree($first);
            }
        }
    }

    # 葉ノード: deparse してテキストを取得
    return LogicNode->new(
        type => 'leaf',
        text => $self->_deparse_simple($op),
    );
}

#------------------------------------------------------------------------------
# シンプルな deparse (論理演算子は展開しない)
#------------------------------------------------------------------------------
sub _deparse_simple {
    my ($self, $op) = @_;

    return '' unless $op && !$op->isa('B::NULL');

    local $@;
    my $text = eval { $self->{deparse}->deparse($op, 0) };
    return $text // '' if $@;

    # 後処理
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;

    return $text;
}

#------------------------------------------------------------------------------
# 定数判定
#------------------------------------------------------------------------------
sub _is_constant {
    my ($self, $op) = @_;

    return 0 unless $op && !$op->isa('B::NULL');

    my $name = $op->name;
    return 1 if $name =~ /^(?:const|undef|s?refgen|null)$/;
    return 1 if $name =~ /^(?:die|return|last|next|redo|goto)$/;
    return 0;
}

#==============================================================================
package TruthTableGenerator;

#------------------------------------------------------------------------------
# LogicNode から真理値表を生成
#------------------------------------------------------------------------------
sub generate {
    my ($class, $node) = @_;

    return [] unless $node;

    if ($node->is_leaf) {
        return $class->_leaf_table($node);
    }

    my $type = $node->type;

    if ($type eq 'cond_expr') {
        return $class->_cond_table($node);
    }

    # 左右のオペランドの変数を収集
    my @vars = $class->_collect_variables($node);

    # 左右が複合式かどうかで分岐
    my $left_complex  = ref($node->left)  && !$node->left->is_leaf;
    my $right_complex = ref($node->right) && !$node->right->is_leaf;

    if ($left_complex || $right_complex) {
        return $class->_complex_table($node, \@vars);
    }

    return $class->_simple_table($node);
}

#------------------------------------------------------------------------------
# 変数を収集
#------------------------------------------------------------------------------
sub _collect_variables {
    my ($class, $node) = @_;

    return () unless $node;

    if ($node->is_leaf) {
        my $text = $node->text;
        # $var 形式の変数を抽出
        my @vars = $text =~ /(\$\w+)/g;
        return @vars;
    }

    my @vars;
    push @vars, $class->_collect_variables($node->left)  if ref $node->left;
    push @vars, $class->_collect_variables($node->right) if ref $node->right;

    # 重複を除去しつつ順序を保持
    my %seen;
    return grep { !$seen{$_}++ } @vars;
}

#------------------------------------------------------------------------------
# 単純な真理値表 (and_3, or_3 など)
#------------------------------------------------------------------------------
sub _simple_table {
    my ($class, $node) = @_;

    my $type = $node->type;
    my $op   = $node->op;

    my $left_text  = ref($node->left)  ? $node->left->text  : $node->left;
    my $right_text = ref($node->right) ? $node->right->text : $node->right;

    my $right_const = $node->{right_const};

    my @table;

    if ($type =~ /^(?:and|andassign)$/) {
        if ($right_const) {
            # and_2
            @table = (
                { A => 0, result => 0, path => "!$left_text (short-circuit)" },
                { A => 1, result => 1, path => "$left_text" },
            );
        } else {
            # and_3
            @table = (
                { A => 0, B => 'X', result => 0, path => "!$left_text (short-circuit)" },
                { A => 1, B => 0,   result => 0, path => "$left_text $op !$right_text" },
                { A => 1, B => 1,   result => 1, path => "$left_text $op $right_text" },
            );
        }
    } elsif ($type =~ /^(?:or|orassign|dor|dorassign)$/) {
        if ($right_const) {
            # or_2
            @table = (
                { A => 1, result => 1, path => "$left_text (short-circuit)" },
                { A => 0, result => 0, path => "!$left_text" },
            );
        } else {
            # or_3
            @table = (
                { A => 1, B => 'X', result => 1, path => "$left_text (short-circuit)" },
                { A => 0, B => 1,   result => 1, path => "!$left_text $op $right_text" },
                { A => 0, B => 0,   result => 0, path => "!$left_text $op !$right_text" },
            );
        }
    } elsif ($type eq 'xor') {
        # xor_4 (短絡評価なし)
        @table = (
            { A => 0, B => 0, result => 0, path => "!$left_text xor !$right_text" },
            { A => 0, B => 1, result => 1, path => "!$left_text xor $right_text" },
            { A => 1, B => 0, result => 1, path => "$left_text xor !$right_text" },
            { A => 1, B => 1, result => 0, path => "$left_text xor $right_text" },
        );
    }

    return {
        expression => "$left_text $op $right_text",
        type       => $type,
        headers    => $right_const ? ['A'] : ['A', 'B'],
        rows       => \@table,
    };
}

#------------------------------------------------------------------------------
# 複合式の真理値表
#------------------------------------------------------------------------------
sub _complex_table {
    my ($class, $node, $vars) = @_;

    # 全変数の組み合わせを生成
    my $n = @$vars;
    my @table;

    for my $i (0 .. (2**$n - 1)) {
        my %vals;
        for my $j (0 .. $n-1) {
            $vals{$vars->[$j]} = ($i >> ($n - 1 - $j)) & 1;
        }

        my $result = $class->_evaluate($node, \%vals);
        my @inputs = map { $vals{$_} } @$vars;

        push @table, {
            inputs => \@inputs,
            result => $result,
            vals   => \%vals,
        };
    }

    return {
        expression => $class->_node_to_expr($node),
        variables  => $vars,
        headers    => [map { s/^\$//r } @$vars],
        rows       => \@table,
    };
}

#------------------------------------------------------------------------------
# 論理式を評価
#------------------------------------------------------------------------------
sub _evaluate {
    my ($class, $node, $vals) = @_;

    return 0 unless $node;

    if ($node->is_leaf) {
        my $text = $node->text;
        # $var 形式を探して値を返す
        if ($text =~ /^\$(\w+)$/) {
            return $vals->{$text} // 0;
        }
        # 定数として評価
        return $text ? 1 : 0;
    }

    my $type = $node->type;
    my $left_val  = $class->_evaluate($node->left, $vals);
    my $right_val = $class->_evaluate($node->right, $vals);

    if ($type =~ /^(?:and|andassign)$/) {
        return $left_val && $right_val ? 1 : 0;
    } elsif ($type =~ /^(?:or|orassign|dor|dorassign)$/) {
        return $left_val || $right_val ? 1 : 0;
    } elsif ($type eq 'xor') {
        return ($left_val xor $right_val) ? 1 : 0;
    } elsif ($type eq 'cond_expr') {
        my $cond_val = $class->_evaluate($node->{condition}, $vals);
        return $cond_val ? $left_val : $right_val;
    }

    return 0;
}

#------------------------------------------------------------------------------
# ノードを式文字列に変換
#------------------------------------------------------------------------------
sub _node_to_expr {
    my ($class, $node) = @_;

    return '' unless $node;

    if ($node->is_leaf) {
        return $node->text;
    }

    my $left  = $class->_node_to_expr($node->left);
    my $right = $class->_node_to_expr($node->right);
    my $op    = $node->op;

    return "($left $op $right)";
}

#------------------------------------------------------------------------------
# 葉ノード用
#------------------------------------------------------------------------------
sub _leaf_table {
    my ($class, $node) = @_;
    return { expression => $node->text, type => 'leaf', rows => [] };
}

#------------------------------------------------------------------------------
# 三項演算子用
#------------------------------------------------------------------------------
sub _cond_table {
    my ($class, $node) = @_;

    my $cond_text = ref($node->{condition}) ? $class->_node_to_expr($node->{condition}) : $node->{condition};
    my $true_text = ref($node->left) ? $class->_node_to_expr($node->left) : $node->left;
    my $false_text = ref($node->right) ? $class->_node_to_expr($node->right) : $node->right;

    return {
        expression => "$cond_text ? $true_text : $false_text",
        type       => 'cond_expr',
        headers    => ['cond'],
        rows       => [
            { cond => 1, result => $true_text,  path => "condition is true" },
            { cond => 0, result => $false_text, path => "condition is false" },
        ],
    };
}

#------------------------------------------------------------------------------
# テキスト形式で出力
#------------------------------------------------------------------------------
sub format_text {
    my ($class, $table) = @_;

    return '' unless $table && $table->{rows} && @{$table->{rows}};

    my @lines;
    push @lines, "Expression: $table->{expression}";
    push @lines, "Type: $table->{type}" if $table->{type};
    push @lines, "-" x 70;

    my @headers = @{$table->{headers} // []};

    if ($table->{variables}) {
        # 複合式
        push @lines, sprintf("| %s | result |", join(" | ", @headers));
        push @lines, "-" x 70;

        for my $row (@{$table->{rows}}) {
            my $inputs = join(" | ", @{$row->{inputs}});
            push @lines, sprintf("| %s |   %d    |", $inputs, $row->{result});
        }
    } else {
        # 単純式
        push @lines, sprintf("| %s | result | path", join(" | ", @headers));
        push @lines, "-" x 70;

        for my $row (@{$table->{rows}}) {
            my @vals = map { $row->{$_} // 'X' } @headers;
            my $inputs = join(" | ", @vals);
            push @lines, sprintf("| %s |   %s    | %s",
                $inputs, $row->{result}, $row->{path} // '');
        }
    }

    push @lines, "-" x 70;
    return join("\n", @lines);
}

#==============================================================================
package main;

# テスト用サブルーチン
sub test1 { my ($a, $b) = @_; $a && $b }
sub test2 { my ($a, $b) = @_; $a || $b }
sub test3 { my ($a, $b, $c) = @_; ($a && $b) || $c }
sub test4 { my ($a, $b, $c) = @_; $a && ($b || $c) }
sub test5 { my ($a, $b, $c, $d) = @_; ($a || $b) && ($c || $d) }
sub test6 { my ($x) = @_; $x ? 1 : 0 }

my $builder = LogicTreeBuilder->new;

print "=" x 70, "\n";
print "Logic Tree Builder - Static Analysis Demo\n";
print "=" x 70, "\n\n";

my @tests = (
    [\&test1, '$a && $b'],
    [\&test2, '$a || $b'],
    [\&test3, '($a && $b) || $c'],
    [\&test4, '$a && ($b || $c)'],
    [\&test5, '($a || $b) && ($c || $d)'],
    [\&test6, '$x ? 1 : 0'],
);

for my $test (@tests) {
    my ($coderef, $desc) = @$test;

    print "### $desc\n\n";

    my $trees = $builder->build_from_coderef($coderef);

    for my $tree (@$trees) {
        print "Logic Tree:\n";
        print $tree->to_string(1), "\n\n";

        my $table = TruthTableGenerator->generate($tree);
        print TruthTableGenerator->format_text($table), "\n\n";
    }

    print "-" x 70, "\n\n";
}

```

### Results

**Result:**

```
File created successfully at: /home/hkoba/db/monthly/202512/tmp/Devel--Cover/examples/logic_tree_builder.pl
```

> より完成度の高いバージョンを作成しました。実行して結果を確認してみましょう。

**Tool: Bash**

```json
{
  "command": "perl examples/logic_tree_builder.pl 2>&1",
  "description": "Run logic tree builder"
}
```

### Results

**Result:**

```
======================================================================
Logic Tree Builder - Static Analysis Demo
======================================================================

### $a && $b

Logic Tree:
  and [&&]
    LEFT:
      LEAF: $a
    RIGHT:
      LEAF: $b

Expression: $a && $b
Type: and
----------------------------------------------------------------------
| A | B | result | path
----------------------------------------------------------------------
| 0 | X |   0    | !$a (short-circuit)
| 1 | 0 |   0    | $a && !$b
| 1 | 1 |   1    | $a && $b
----------------------------------------------------------------------

----------------------------------------------------------------------

### $a || $b

Logic Tree:
  or [||]
    LEFT:
      LEAF: $a
    RIGHT:
      LEAF: $b

Expression: $a || $b
Type: or
----------------------------------------------------------------------
| A | B | result | path
----------------------------------------------------------------------
| 1 | X |   1    | $a (short-circuit)
| 0 | 1 |   1    | !$a || $b
| 0 | 0 |   0    | !$a || !$b
----------------------------------------------------------------------

----------------------------------------------------------------------

### ($a && $b) || $c

Logic Tree:
  or [||]
    LEFT:
      and [&&]
        LEFT:
          LEAF: $a
        RIGHT:
          LEAF: $b
    RIGHT:
      LEAF: $c

Expression: (($a && $b) || $c)
----------------------------------------------------------------------
| a | b | c | result |
----------------------------------------------------------------------
| 0 | 0 | 0 |   0    |
| 0 | 0 | 1 |   1    |
| 0 | 1 | 0 |   0    |
| 0 | 1 | 1 |   1    |
| 1 | 0 | 0 |   0    |
| 1 | 0 | 1 |   1    |
| 1 | 1 | 0 |   1    |
| 1 | 1 | 1 |   1    |
----------------------------------------------------------------------

Logic Tree:
  and [&&]
    LEFT:
      LEAF: $a
    RIGHT:
      LEAF: $b

Expression: $a && $b
Type: and
-------------------------------------------
... (truncated)
```

> 素晴らしい！うまく動作しています。論理式の木構造が正しく解析され、真理値表も生成されています。
> 
> ユーザーにサンプルコードの概要と、Devel::Cover との違いを説明しましょう。


---

<small style="color: gray">uuid: assistant: 8f0c2413-893b-437f-85cc-244f015da68c, assistant: 517abd0d-5fd9-40df-8d2e-fc30b432c361, assistant: f4b1e88e-30af-4963-8c7c-ea1a9adb7729, assistant: df1427ae-14f2-423a-a66d-90baea54990f</small>