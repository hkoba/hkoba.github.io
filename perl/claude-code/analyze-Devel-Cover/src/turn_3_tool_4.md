# ありがとうございます。やはり Devel::Cover は実行時の情報をキャプチャーして活用している

## Tool Interactions

**Tool: Write** `/home/hkoba/db/monthly/202512/tmp/Devel--Cover/examples/static_logic_analyzer.pl`

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use v5.12;

#
# 静的にPerlコードの論理構造を解析し、真理値表を生成するサンプル
# Devel::Cover の手法を参考に、実行せずに B::Deparse で解析
#

package LogicAnalyzer;

use B qw(main_cv svref_2object OPf_KIDS);
use B::Deparse;

# 論理演算子の OP 名
my %LOGIC_OPS = map { $_ => 1 } qw(and or dor xor andassign orassign dorassign cond_expr);

sub new {
    my $class = shift;
    my $self = bless {
        deparse   => B::Deparse->new,
        conditions => [],  # 検出した条件式
    }, $class;
    return $self;
}

#------------------------------------------------------------------------------
# サブルーチンを解析
#------------------------------------------------------------------------------
sub analyze_sub {
    my ($self, $coderef) = @_;

    my $cv = svref_2object($coderef);
    return unless $cv->isa('B::CV');

    $self->{deparse}{curcv} = $cv;
    $self->{conditions} = [];

    my $root = $cv->ROOT;
    return unless $root && !$root->isa('B::NULL');

    $self->_walk_op($root);

    return $self->{conditions};
}

#------------------------------------------------------------------------------
# OP ツリーを再帰的に走査
#------------------------------------------------------------------------------
sub _walk_op {
    my ($self, $op) = @_;

    return unless $op && !$op->isa('B::NULL');

    my $name = $op->name;

    # 論理演算子を検出
    if ($LOGIC_OPS{$name}) {
        my $info = $self->_analyze_logop($op);
        push @{$self->{conditions}}, $info if $info;
    }

    # 子ノードを再帰的に走査
    if ($op->flags & OPf_KIDS) {
        for (my $kid = $op->first; $kid && !$kid->isa('B::NULL'); $kid = $kid->sibling) {
            $self->_walk_op($kid);
        }
    }
}

#------------------------------------------------------------------------------
# 論理演算子を解析
#------------------------------------------------------------------------------
sub _analyze_logop {
    my ($self, $op) = @_;

    my $name = $op->name;
    my $left_op = $op->first;

    return unless $left_op && !$left_op->isa('B::NULL');

    my $right_op;
    if ($name eq 'cond_expr') {
        # 三項演算子: cond ? true : false
        my $cond_op = $left_op;
        my $true_op = $cond_op->sibling;
        my $false_op = $true_op ? $true_op->sibling : undef;

        return {
            type      => 'cond_expr',
            op        => '?:',
            condition => $self->_deparse_op($cond_op),
            true_branch  => $self->_deparse_op($true_op),
            false_branch => $self->_deparse_op($false_op),
            line      => $self->_get_line($op),
        };
    }

    $right_op = $left_op->sibling;
    return unless $right_op && !$right_op->isa('B::NULL');

    my $op_symbol = $self->_op_to_symbol($name);
    my $left_text  = $self->_deparse_op($left_op);
    my $right_text = $self->_deparse_op($right_op);

    # 右辺が定数かどうか判定
    my $right_is_const = $self->_is_constant($right_op);

    return {
        type       => $name,
        op         => $op_symbol,
        left       => $left_text,
        right      => $right_text,
        right_const => $right_is_const,
        line       => $self->_get_line($op),
        # 真理値表のタイプを決定
        tt_type    => $self->_determine_tt_type($name, $right_is_const),
    };
}

#------------------------------------------------------------------------------
# OP をテキストに変換
#------------------------------------------------------------------------------
sub _deparse_op {
    my ($self, $op) = @_;

    return '' unless $op && !$op->isa('B::NULL');

    local $@;
    my $text = eval { $self->{deparse}->deparse($op, 0) };
    return '' if $@;

    # 前後の空白を除去
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;

    return $text;
}

#------------------------------------------------------------------------------
# OP 名からシンボルへ
#------------------------------------------------------------------------------
sub _op_to_symbol {
    my ($self, $name) = @_;

    my %symbols = (
        and       => '&&',
        andassign => '&&=',
        or        => '||',
        orassign  => '||=',
        dor       => '//',
        dorassign => '//=',
        xor       => 'xor',
    );

    return $symbols{$name} // $name;
}

#------------------------------------------------------------------------------
# 定数かどうか判定
#------------------------------------------------------------------------------
sub _is_constant {
    my ($self, $op) = @_;

    return 0 unless $op && !$op->isa('B::NULL');

    my $name = $op->name;

    # const, undef, refgen などは定数扱い
    return 1 if $name =~ /^(?:const|undef|s?refgen|null)$/;

    # die, return, last, next, redo, goto も「評価されない」扱い
    return 1 if $name =~ /^(?:die|return|last|next|redo|goto)$/;

    return 0;
}

#------------------------------------------------------------------------------
# 真理値表タイプを決定
#------------------------------------------------------------------------------
sub _determine_tt_type {
    my ($self, $op_name, $right_is_const) = @_;

    if ($op_name eq 'xor') {
        return 'xor_4';
    } elsif ($op_name =~ /^(?:and|andassign)$/) {
        return $right_is_const ? 'and_2' : 'and_3';
    } elsif ($op_name =~ /^(?:or|orassign|dor|dorassign)$/) {
        return $right_is_const ? 'or_2' : 'or_3';
    }

    return 'unknown';
}

#------------------------------------------------------------------------------
# 行番号を取得
#------------------------------------------------------------------------------
sub _get_line {
    my ($self, $op) = @_;

    # COP (statement) から行番号を取得するのは複雑なので、簡易版
    return 0;  # 実際にはより複雑な処理が必要
}

#==============================================================================
# 真理値表生成
#==============================================================================
package TruthTable;

sub new {
    my ($class, $condition) = @_;
    return bless { condition => $condition }, $class;
}

sub generate {
    my ($self) = @_;

    my $cond = $self->{condition};
    my $type = $cond->{tt_type} // '';

    if ($type eq 'and_3') {
        return $self->_and_3_table($cond);
    } elsif ($type eq 'and_2') {
        return $self->_and_2_table($cond);
    } elsif ($type eq 'or_3') {
        return $self->_or_3_table($cond);
    } elsif ($type eq 'or_2') {
        return $self->_or_2_table($cond);
    } elsif ($type eq 'xor_4') {
        return $self->_xor_4_table($cond);
    } elsif ($cond->{type} eq 'cond_expr') {
        return $self->_cond_expr_table($cond);
    }

    return [];
}

sub _and_3_table {
    my ($self, $cond) = @_;
    my ($l, $r, $op) = @{$cond}{qw(left right op)};

    return [
        { inputs => [0, 'X'], result => 0, desc => "!($l)" },
        { inputs => [1, 0],   result => 0, desc => "($l) $op !($r)" },
        { inputs => [1, 1],   result => 1, desc => "($l) $op ($r)" },
    ];
}

sub _and_2_table {
    my ($self, $cond) = @_;
    my ($l, $op) = @{$cond}{qw(left op)};

    return [
        { inputs => [0], result => 0, desc => "!($l)" },
        { inputs => [1], result => 1, desc => "($l)" },
    ];
}

sub _or_3_table {
    my ($self, $cond) = @_;
    my ($l, $r, $op) = @{$cond}{qw(left right op)};

    return [
        { inputs => [1, 'X'], result => 1, desc => "($l)" },
        { inputs => [0, 1],   result => 1, desc => "!($l) $op ($r)" },
        { inputs => [0, 0],   result => 0, desc => "!($l) $op !($r)" },
    ];
}

sub _or_2_table {
    my ($self, $cond) = @_;
    my ($l, $op) = @{$cond}{qw(left op)};

    return [
        { inputs => [1], result => 1, desc => "($l)" },
        { inputs => [0], result => 0, desc => "!($l)" },
    ];
}

sub _xor_4_table {
    my ($self, $cond) = @_;
    my ($l, $r) = @{$cond}{qw(left right)};

    return [
        { inputs => [0, 0], result => 0, desc => "!($l) xor !($r)" },
        { inputs => [0, 1], result => 1, desc => "!($l) xor ($r)" },
        { inputs => [1, 0], result => 1, desc => "($l) xor !($r)" },
        { inputs => [1, 1], result => 0, desc => "($l) xor ($r)" },
    ];
}

sub _cond_expr_table {
    my ($self, $cond) = @_;
    my ($c, $t, $f) = @{$cond}{qw(condition true_branch false_branch)};

    return [
        { inputs => [1], result => $t, desc => "($c) ? $t : ..." },
        { inputs => [0], result => $f, desc => "!($c) ? ... : $f" },
    ];
}

sub format_text {
    my ($self) = @_;

    my $table = $self->generate;
    return '' unless @$table;

    my $cond = $self->{condition};
    my @lines;

    # ヘッダー
    my $expr = $cond->{type} eq 'cond_expr'
        ? "$cond->{condition} ? $cond->{true_branch} : $cond->{false_branch}"
        : "$cond->{left} $cond->{op} $cond->{right}";

    push @lines, "Expression: $expr";
    push @lines, "Type: $cond->{tt_type}" if $cond->{tt_type};
    push @lines, "-" x 60;

    # 入力ヘッダー
    my $n_inputs = @{$table->[0]{inputs}};
    my @headers = map { chr(ord('A') + $_) } 0 .. $n_inputs - 1;
    push @lines, sprintf("| %s | Result | Description", join(" | ", @headers));
    push @lines, "-" x 60;

    # 各行
    for my $row (@$table) {
        my $inputs = join(" | ", map { $_ eq 'X' ? 'X' : $_ } @{$row->{inputs}});
        push @lines, sprintf("| %s |   %s    | %s", $inputs, $row->{result}, $row->{desc});
    }

    push @lines, "-" x 60;

    return join("\n", @lines);
}

#==============================================================================
# メイン
#==============================================================================
package main;

# テスト用サブルーチン
sub test_simple_and {
    my ($a, $b) = @_;
    return $a && $b;
}

sub test_simple_or {
    my ($a, $b) = @_;
    return $a || $b;
}

sub test_or_with_const {
    my ($a) = @_;
    return $a || die "error";
}

sub test_complex {
    my ($a, $b, $c) = @_;
    return ($a || $b) && $c;
}

sub test_ternary {
    my ($x) = @_;
    return $x ? "yes" : "no";
}

sub test_xor {
    my ($a, $b) = @_;
    return $a xor $b;
}

sub test_dor {
    my ($a, $b) = @_;
    return $a // $b;
}

# 解析実行
my $analyzer = LogicAnalyzer->new;

print "=" x 60, "\n";
print "Static Logic Structure Analyzer\n";
print "=" x 60, "\n\n";

my @test_subs = (
    [\&test_simple_and,    'test_simple_and:    $a && $b'],
    [\&test_simple_or,     'test_simple_or:     $a || $b'],
    [\&test_or_with_const, 'test_or_with_const: $a || die'],
    [\&test_complex,       'test_complex:       ($a || $b) && $c'],
    [\&test_ternary,       'test_ternary:       $x ? "yes" : "no"'],
    [\&test_xor,           'test_xor:           $a xor $b'],
    [\&test_dor,           'test_dor:           $a // $b'],
);

for my $test (@test_subs) {
    my ($coderef, $name) = @$test;

    print "### $name\n\n";

    my $conditions = $analyzer->analyze_sub($coderef);

    if (@$conditions) {
        for my $cond (@$conditions) {
            my $tt = TruthTable->new($cond);
            print $tt->format_text, "\n\n";
        }
    } else {
        print "(No logical conditions found)\n\n";
    }
}

# 文字列からコードを解析するデモ
print "=" x 60, "\n";
print "Analyzing code from string\n";
print "=" x 60, "\n\n";

my $code = q{
    sub complex_logic {
        my ($x, $y, $z) = @_;
        if ($x && $y || $z) {
            return 1;
        }
        return 0;
    }
};

print "Source code:\n$code\n";

# eval でコードをコンパイル (実行はしない)
eval $code;
if ($@) {
    die "Compile error: $@";
}

my $conditions = $analyzer->analyze_sub(\&complex_logic);
for my $cond (@$conditions) {
    my $tt = TruthTable->new($cond);
    print $tt->format_text, "\n\n";
}

```

### Results

**Result:**

```
File created successfully at: /home/hkoba/db/monthly/202512/tmp/Devel--Cover/examples/static_logic_analyzer.pl
```

> サンプルコードを書きました。実行して結果を確認してみましょう。


---

<small style="color: gray">uuid: assistant: f0d2a0ce-018f-4539-8449-18d2c54af0c0, assistant: af324036-ebe7-467e-8151-8f6ec15feccd</small>