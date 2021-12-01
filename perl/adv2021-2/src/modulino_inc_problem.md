# Modulino と @INC 問題

Modulino を本格的に使い始めた時に問題となるのが、モジュールのロードパス `@INC` をどう設定するか、です。

例えばある Modulino `MyCMS.pm` が同じディレクトリの別の Modulino `MyConfig.pm`
を使っているとします。この場合、 `MyCMS.pm` は FindBin と lib を使って
`@INC` の調整を行う必要があります。

```perl
{{#include ex1-findbin/MyCMS.pm}}
```

`@INC` の調整を行わなかった場合、（お馴染みの）次のようなエラーが出るでしょう。

```console
% ./MyCMS.pm
Can't locate MyConfig.pm in @INC (you may need to install the MyConfig module)...
```

同様に `MyCMS/DB.pm` も `MyCMS/Util.pm` を読み込むために、
以下のような `@INC` 調整の宣言が必要です。

```perl
use FindBin;
use lib "$FindBin::Bin/../";
```

- - - -
