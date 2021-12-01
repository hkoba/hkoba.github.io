# File::AddInc - `__FILE__` ベースの FindBin + lib

前節で述べた FindBin の問題を抜本的に解決するには、
ライブラリパスを追加する時に、 `$0` からではなく、
Perl の現在のファイル名 `__FILE__` に基づいて
ライブラリパスを導出する方法が考えられます。

この考えに基づき hkoba が開発したのが [File::AddInc](https://metacpan.org/dist/File-AddInc/view/lib/File/AddInc.pod)です。これを使って FindBin + lib を
書き換えると以下のようになります。

```perl
use FindBin;
use lib $FindBin::Bin;

# ↓↓

use File::AddInc;
```

[cpm](https://metacpan.org/dist/App-cpm/view/script/cpm) などが作る `local/perl5` を直接サポートするオプションもあります。

```perl
use FindBin;
use lib $FindBin::Bin, "$FindBin::Bin/../local/perl5";

# ↓↓

use File::AddInc -local_lib;
```

前節で取り上げた FindBin で問題が出るケースについても、
より安全な `$FindBin::Bin` の代用となる変数を定義する機能が利用可能です。

```perl
use FindBin;
use lib "$FindBin::Bin/../subproject/libB";

# ↓↓

use File::AddInc qw($libdir);
use lib "$libdir/../subproject/libB";
```
