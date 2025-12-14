# ありがとうございます。やはり Devel::Cover は実行時の情報をキャプチャーして活用している

## Tool Interactions

**Tool: Write**

```json
{
  "file_path": "/home/hkoba/db/monthly/202512/tmp/Devel--Cover/examples/logic_tree_builder.pl",
  "content": "#!/usr/bin/env perl\nuse strict;\nuse warnings;\nuse v5.12;\n\n#\n# 論理式の木構造を静的に構築するサンプル\n# Devel::Cover の手法を参考に、B モジュールで OP ツリーを解析\n#\n\npackage LogicNode;\n\n# 論理式の木構造を表現するノード\n\nsub new {\n    my ($class, %args) = @_;\n    return bless \\%args, $class;\n}\n\nsub type     { $_[0]->{type} }\nsub op       { $_[0]->{op} }\nsub left     { $_[0]->{left} }\nsub right    { $_[0]->{right} }\nsub text     { $_[0]->{text} }\nsub children { @{$_[0]->{children} // []} }\n\nsub is_leaf {\n    my $self = shift;\n    return $self->{type} eq 'leaf';\n}\n\nsub to_string {\n    my ($self, $indent) = @_;\n    $indent //= 0;\n    my $pad = \"  \" x $indent;\n\n    if ($self->is_leaf) {\n        return \"${pad}LEAF: $self->{text}\";\n    }\n\n    my @lines = (\"${pad}$self->{type} [$self->{op}]\");\n\n    if ($self->{left}) {\n        push @lines, \"${pad}  LEFT:\";\n        if (ref $self->{left}) {\n            push @lines, $self->{left}->to_string($indent + 2);\n        } else {\n            push @lines, \"${pad}    $self->{left}\";\n        }\n    }\n\n    if ($self->{right}) {\n        push @lines, \"${pad}  RIGHT:\";\n        if (ref $self->{right}) {\n            push @lines, $self->{right}->to_string($indent + 2);\n        } else {\n            push @lines, \"${pad}    $self->{right}\";\n        }\n    }\n\n    return join(\"\\n\", @lines);\n}\n\n#==============================================================================\npackage LogicTreeBuilder;\n\nuse B qw(svref_2object OPf_KIDS);\nuse B::Deparse;\n\nmy %LOGIC_OPS = (\n    and       => { symbol => '&&',  short_circuit => 'left_false' },\n    andassign => { symbol => '&&=', short_circuit => 'left_false' },\n    or        => { symbol => '||',  short_circuit => 'left_true' },\n    orassign  => { symbol => '||=', short_circuit => 'left_true' },\n    dor       => { symbol => '//',  short_circuit => 'left_defined' },\n    dorassign => { symbol => '//=', short_circuit => 'left_defined' },\n    xor       => { symbol => 'xor', short_circuit => 'none' },\n);\n\nsub new {\n    my $class = shift;\n    my $self = bless {\n        deparse => B::Deparse->new('-x7'),  # -x7: 最小限の変形\n    }, $class;\n    return $self;\n}\n\n#------------------------------------------------------------------------------\n# コードリファレンスから論理式の木を構築\n#------------------------------------------------------------------------------\nsub build_from_coderef {\n    my ($self, $coderef) = @_;\n\n    my $cv = svref_2object($coderef);\n    return unless $cv->isa('B::CV');\n\n    $self->{deparse}{curcv} = $cv;\n    $self->{trees} = [];\n\n    my $root = $cv->ROOT;\n    return [] unless $root && !$root->isa('B::NULL');\n\n    $self->_scan_for_logic($root);\n\n    return $self->{trees};\n}\n\n#------------------------------------------------------------------------------\n# 論理演算を探して木を構築\n#------------------------------------------------------------------------------\nsub _scan_for_logic {\n    my ($self, $op) = @_;\n\n    return unless $op && !$op->isa('B::NULL');\n\n    my $name = $op->name;\n\n    if (exists $LOGIC_OPS{$name}) {\n        my $tree = $self->_build_logic_tree($op);\n        push @{$self->{trees}}, $tree if $tree;\n    } elsif ($name eq 'cond_expr') {\n        my $tree = $self->_build_cond_tree($op);\n        push @{$self->{trees}}, $tree if $tree;\n    }\n\n    # 子ノードを再帰的に走査\n    if ($op->flags & OPf_KIDS) {\n        for (my $kid = $op->first; $kid && !$kid->isa('B::NULL'); $kid = $kid->sibling) {\n            $self->_scan_for_logic($kid);\n        }\n    }\n}\n\n#------------------------------------------------------------------------------\n# 論理演算の木を構築 (再帰的に部分式も解析)\n#------------------------------------------------------------------------------\nsub _build_logic_tree {\n    my ($self, $op) = @_;\n\n    my $name = $op->name;\n    my $info = $LOGIC_OPS{$name} or return;\n\n    my $left_op = $op->first;\n    return unless $left_op && !$left_op->isa('B::NULL');\n\n    my $right_op = $left_op->sibling;\n    return unless $right_op && !$right_op->isa('B::NULL');\n\n    # 左辺と右辺を再帰的に解析\n    my $left  = $self->_analyze_operand($left_op);\n    my $right = $self->_analyze_operand($right_op);\n\n    return LogicNode->new(\n        type          => $name,\n        op            => $info->{symbol},\n        short_circuit => $info->{short_circuit},\n        left          => $left,\n        right         => $right,\n        right_const   => $self->_is_constant($right_op),\n    );\n}\n\n#------------------------------------------------------------------------------\n# 三項演算子の木を構築\n#------------------------------------------------------------------------------\nsub _build_cond_tree {\n    my ($self, $op) = @_;\n\n    my $cond_op = $op->first;\n    return unless $cond_op && !$cond_op->isa('B::NULL');\n\n    my $true_op = $cond_op->sibling;\n    my $false_op = $true_op ? $true_op->sibling : undef;\n\n    return LogicNode->new(\n        type      => 'cond_expr',\n        op        => '?:',\n        condition => $self->_analyze_operand($cond_op),\n        left      => $self->_analyze_operand($true_op),\n        right     => $self->_analyze_operand($false_op),\n    );\n}\n\n#------------------------------------------------------------------------------\n# オペランドを解析 (論理演算なら再帰、そうでなければ葉ノード)\n#------------------------------------------------------------------------------\nsub _analyze_operand {\n    my ($self, $op) = @_;\n\n    return '' unless $op && !$op->isa('B::NULL');\n\n    my $name = $op->name;\n\n    # 論理演算子なら再帰的に木を構築\n    if (exists $LOGIC_OPS{$name}) {\n        return $self->_build_logic_tree($op);\n    }\n\n    # null OP の場合は中身を見る\n    if ($name eq 'null') {\n        my $first = $op->first;\n        if ($first && !$first->isa('B::NULL')) {\n            my $inner_name = $first->name;\n            if (exists $LOGIC_OPS{$inner_name}) {\n                return $self->_build_logic_tree($first);\n            }\n        }\n    }\n\n    # 葉ノード: deparse してテキストを取得\n    return LogicNode->new(\n        type => 'leaf',\n        text => $self->_deparse_simple($op),\n    );\n}\n\n#------------------------------------------------------------------------------\n# シンプルな deparse (論理演算子は展開しない)\n#------------------------------------------------------------------------------\nsub _deparse_simple {\n    my ($self, $op) = @_;\n\n    return '' unless $op && !$op->isa('B::NULL');\n\n    local $@;\n    my $text = eval { $self->{deparse}->deparse($op, 0) };\n    return $text // '' if $@;\n\n    # 後処理\n    $text =~ s/^\\s+//;\n    $text =~ s/\\s+$//;\n\n    return $text;\n}\n\n#------------------------------------------------------------------------------\n# 定数判定\n#------------------------------------------------------------------------------\nsub _is_constant {\n    my ($self, $op) = @_;\n\n    return 0 unless $op && !$op->isa('B::NULL');\n\n    my $name = $op->name;\n    return 1 if $name =~ /^(?:const|undef|s?refgen|null)$/;\n    return 1 if $name =~ /^(?:die|return|last|next|redo|goto)$/;\n    return 0;\n}\n\n#==============================================================================\npackage TruthTableGenerator;\n\n#------------------------------------------------------------------------------\n# LogicNode から真理値表を生成\n#------------------------------------------------------------------------------\nsub generate {\n    my ($class, $node) = @_;\n\n    return [] unless $node;\n\n    if ($node->is_leaf) {\n        return $class->_leaf_table($node);\n    }\n\n    my $type = $node->type;\n\n    if ($type eq 'cond_expr') {\n        return $class->_cond_table($node);\n    }\n\n    # 左右のオペランドの変数を収集\n    my @vars = $class->_collect_variables($node);\n\n    # 左右が複合式かどうかで分岐\n    my $left_complex  = ref($node->left)  && !$node->left->is_leaf;\n    my $right_complex = ref($node->right) && !$node->right->is_leaf;\n\n    if ($left_complex || $right_complex) {\n        return $class->_complex_table($node, \\@vars);\n    }\n\n    return $class->_simple_table($node);\n}\n\n#------------------------------------------------------------------------------\n# 変数を収集\n#------------------------------------------------------------------------------\nsub _collect_variables {\n    my ($class, $node) = @_;\n\n    return () unless $node;\n\n    if ($node->is_leaf) {\n        my $text = $node->text;\n        # $var 形式の変数を抽出\n        my @vars = $text =~ /(\\$\\w+)/g;\n        return @vars;\n    }\n\n    my @vars;\n    push @vars, $class->_collect_variables($node->left)  if ref $node->left;\n    push @vars, $class->_collect_variables($node->right) if ref $node->right;\n\n    # 重複を除去しつつ順序を保持\n    my %seen;\n    return grep { !$seen{$_}++ } @vars;\n}\n\n#------------------------------------------------------------------------------\n# 単純な真理値表 (and_3, or_3 など)\n#------------------------------------------------------------------------------\nsub _simple_table {\n    my ($class, $node) = @_;\n\n    my $type = $node->type;\n    my $op   = $node->op;\n\n    my $left_text  = ref($node->left)  ? $node->left->text  : $node->left;\n    my $right_text = ref($node->right) ? $node->right->text : $node->right;\n\n    my $right_const = $node->{right_const};\n\n    my @table;\n\n    if ($type =~ /^(?:and|andassign)$/) {\n        if ($right_const) {\n            # and_2\n            @table = (\n                { A => 0, result => 0, path => \"!$left_text (short-circuit)\" },\n                { A => 1, result => 1, path => \"$left_text\" },\n            );\n        } else {\n            # and_3\n            @table = (\n                { A => 0, B => 'X', result => 0, path => \"!$left_text (short-circuit)\" },\n                { A => 1, B => 0,   result => 0, path => \"$left_text $op !$right_text\" },\n                { A => 1, B => 1,   result => 1, path => \"$left_text $op $right_text\" },\n            );\n        }\n    } elsif ($type =~ /^(?:or|orassign|dor|dorassign)$/) {\n        if ($right_const) {\n            # or_2\n            @table = (\n                { A => 1, result => 1, path => \"$left_text (short-circuit)\" },\n                { A => 0, result => 0, path => \"!$left_text\" },\n            );\n        } else {\n            # or_3\n            @table = (\n                { A => 1, B => 'X', result => 1, path => \"$left_text (short-circuit)\" },\n                { A => 0, B => 1,   result => 1, path => \"!$left_text $op $right_text\" },\n                { A => 0, B => 0,   result => 0, path => \"!$left_text $op !$right_text\" },\n            );\n        }\n    } elsif ($type eq 'xor') {\n        # xor_4 (短絡評価なし)\n        @table = (\n            { A => 0, B => 0, result => 0, path => \"!$left_text xor !$right_text\" },\n            { A => 0, B => 1, result => 1, path => \"!$left_text xor $right_text\" },\n            { A => 1, B => 0, result => 1, path => \"$left_text xor !$right_text\" },\n            { A => 1, B => 1, result => 0, path => \"$left_text xor $right_text\" },\n        );\n    }\n\n    return {\n        expression => \"$left_text $op $right_text\",\n        type       => $type,\n        headers    => $right_const ? ['A'] : ['A', 'B'],\n        rows       => \\@table,\n    };\n}\n\n#------------------------------------------------------------------------------\n# 複合式の真理値表\n#------------------------------------------------------------------------------\nsub _complex_table {\n    my ($class, $node, $vars) = @_;\n\n    # 全変数の組み合わせを生成\n    my $n = @$vars;\n    my @table;\n\n    for my $i (0 .. (2**$n - 1)) {\n        my %vals;\n        for my $j (0 .. $n-1) {\n            $vals{$vars->[$j]} = ($i >> ($n - 1 - $j)) & 1;\n        }\n\n        my $result = $class->_evaluate($node, \\%vals);\n        my @inputs = map { $vals{$_} } @$vars;\n\n        push @table, {\n            inputs => \\@inputs,\n            result => $result,\n            vals   => \\%vals,\n        };\n    }\n\n    return {\n        expression => $class->_node_to_expr($node),\n        variables  => $vars,\n        headers    => [map { s/^\\$//r } @$vars],\n        rows       => \\@table,\n    };\n}\n\n#------------------------------------------------------------------------------\n# 論理式を評価\n#------------------------------------------------------------------------------\nsub _evaluate {\n    my ($class, $node, $vals) = @_;\n\n    return 0 unless $node;\n\n    if ($node->is_leaf) {\n        my $text = $node->text;\n        # $var 形式を探して値を返す\n        if ($text =~ /^\\$(\\w+)$/) {\n            return $vals->{$text} // 0;\n        }\n        # 定数として評価\n        return $text ? 1 : 0;\n    }\n\n    my $type = $node->type;\n    my $left_val  = $class->_evaluate($node->left, $vals);\n    my $right_val = $class->_evaluate($node->right, $vals);\n\n    if ($type =~ /^(?:and|andassign)$/) {\n        return $left_val && $right_val ? 1 : 0;\n    } elsif ($type =~ /^(?:or|orassign|dor|dorassign)$/) {\n        return $left_val || $right_val ? 1 : 0;\n    } elsif ($type eq 'xor') {\n        return ($left_val xor $right_val) ? 1 : 0;\n    } elsif ($type eq 'cond_expr') {\n        my $cond_val = $class->_evaluate($node->{condition}, $vals);\n        return $cond_val ? $left_val : $right_val;\n    }\n\n    return 0;\n}\n\n#------------------------------------------------------------------------------\n# ノードを式文字列に変換\n#------------------------------------------------------------------------------\nsub _node_to_expr {\n    my ($class, $node) = @_;\n\n    return '' unless $node;\n\n    if ($node->is_leaf) {\n        return $node->text;\n    }\n\n    my $left  = $class->_node_to_expr($node->left);\n    my $right = $class->_node_to_expr($node->right);\n    my $op    = $node->op;\n\n    return \"($left $op $right)\";\n}\n\n#------------------------------------------------------------------------------\n# 葉ノード用\n#------------------------------------------------------------------------------\nsub _leaf_table {\n    my ($class, $node) = @_;\n    return { expression => $node->text, type => 'leaf', rows => [] };\n}\n\n#------------------------------------------------------------------------------\n# 三項演算子用\n#------------------------------------------------------------------------------\nsub _cond_table {\n    my ($class, $node) = @_;\n\n    my $cond_text = ref($node->{condition}) ? $class->_node_to_expr($node->{condition}) : $node->{condition};\n    my $true_text = ref($node->left) ? $class->_node_to_expr($node->left) : $node->left;\n    my $false_text = ref($node->right) ? $class->_node_to_expr($node->right) : $node->right;\n\n    return {\n        expression => \"$cond_text ? $true_text : $false_text\",\n        type       => 'cond_expr',\n        headers    => ['cond'],\n        rows       => [\n            { cond => 1, result => $true_text,  path => \"condition is true\" },\n            { cond => 0, result => $false_text, path => \"condition is false\" },\n        ],\n    };\n}\n\n#------------------------------------------------------------------------------\n# テキスト形式で出力\n#------------------------------------------------------------------------------\nsub format_text {\n    my ($class, $table) = @_;\n\n    return '' unless $table && $table->{rows} && @{$table->{rows}};\n\n    my @lines;\n    push @lines, \"Expression: $table->{expression}\";\n    push @lines, \"Type: $table->{type}\" if $table->{type};\n    push @lines, \"-\" x 70;\n\n    my @headers = @{$table->{headers} // []};\n\n    if ($table->{variables}) {\n        # 複合式\n        push @lines, sprintf(\"| %s | result |\", join(\" | \", @headers));\n        push @lines, \"-\" x 70;\n\n        for my $row (@{$table->{rows}}) {\n            my $inputs = join(\" | \", @{$row->{inputs}});\n            push @lines, sprintf(\"| %s |   %d    |\", $inputs, $row->{result});\n        }\n    } else {\n        # 単純式\n        push @lines, sprintf(\"| %s | result | path\", join(\" | \", @headers));\n        push @lines, \"-\" x 70;\n\n        for my $row (@{$table->{rows}}) {\n            my @vals = map { $row->{$_} // 'X' } @headers;\n            my $inputs = join(\" | \", @vals);\n            push @lines, sprintf(\"| %s |   %s    | %s\",\n                $inputs, $row->{result}, $row->{path} // '');\n        }\n    }\n\n    push @lines, \"-\" x 70;\n    return join(\"\\n\", @lines);\n}\n\n#==============================================================================\npackage main;\n\n# テスト用サブルーチン\nsub test1 { my ($a, $b) = @_; $a && $b }\nsub test2 { my ($a, $b) = @_; $a || $b }\nsub test3 { my ($a, $b, $c) = @_; ($a && $b) || $c }\nsub test4 { my ($a, $b, $c) = @_; $a && ($b || $c) }\nsub test5 { my ($a, $b, $c, $d) = @_; ($a || $b) && ($c || $d) }\nsub test6 { my ($x) = @_; $x ? 1 : 0 }\n\nmy $builder = LogicTreeBuilder->new;\n\nprint \"=\" x 70, \"\\n\";\nprint \"Logic Tree Builder - Static Analysis Demo\\n\";\nprint \"=\" x 70, \"\\n\\n\";\n\nmy @tests = (\n    [\\&test1, '$a && $b'],\n    [\\&test2, '$a || $b'],\n    [\\&test3, '($a && $b) || $c'],\n    [\\&test4, '$a && ($b || $c)'],\n    [\\&test5, '($a || $b) && ($c || $d)'],\n    [\\&test6, '$x ? 1 : 0'],\n);\n\nfor my $test (@tests) {\n    my ($coderef, $desc) = @$test;\n\n    print \"### $desc\\n\\n\";\n\n    my $trees = $builder->build_from_coderef($coderef);\n\n    for my $tree (@$trees) {\n        print \"Logic Tree:\\n\";\n        print $tree->to_string(1), \"\\n\\n\";\n\n        my $table = TruthTableGenerator->generate($tree);\n        print TruthTableGenerator->format_text($table), \"\\n\\n\";\n    }\n\n    print \"-\" x 70, \"\\n\\n\";\n}\n"
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