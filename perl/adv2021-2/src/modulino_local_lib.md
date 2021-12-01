# Modulino に FindBin を使う限界

もし Modulino とそれが使う他のモジュールが同一のディレクトリツリー（もしくはサイトのデフォルトライブラリパス）に存在する場合は、FindBin だけでも対応は可能です。

しかし、ライブラリディレクトリが複数存在する状況では、
FindBin だけでは全ての Modulino の
`@INC` を矛盾なく調整しきれない場合があります。

以下に具体例を挙げます。

```console
% tree 
.
├── libA
│   └── my_A.pm
└── subproject
    ├── libB
    │   └── my_B.pm
    └── libC
        └── my_C.pm    <-- これが後から加わった
```

最初に toplevel のプロジェクトのライブラリディレクトリ `libA` と、
subproject のライブラリディレクトリ `libB` があるとします。

２つの modulino, `my_A` と `my_B` は、最初は
モジュールとしてもコマンドとしても問題なく動きます。
しかし、後から `my_B` で `libC/my_C.pm` を use した途端に、
**最初の `my_A`** が、ロードも実行も失敗するようになります。

#### my_A.pm
```perl
{{#include ex2-multi-libdir/libA/my_A.pm}}
```

#### my_B.pm
```perl
{{#include ex2-multi-libdir/subproject/libB/my_B.pm}}
```


## 原因

この問題の原因は、FindBin が `$0` の値に依存しているからです。

つまり、 `my_A.pm` を起動した時、`$FindBin::Bin` は `libA` を指します。
この状態で `my_B.pm` の中で

```perl
use lib "$FindBin::Bin/../libC";
```

と宣言しても、足されるパスは `./libC` となり、期待した `subproject/libC` にはならないのです。
