# 実装の例

私が業務で 2016年頃から用いてきたスクリプト群を手直しし、テンプレート化したものを
github に置きました。(fedora:latest コンテナ内で動作確認済みです)

[github.com/hkoba/usr-local-perl5-template](https://github.com/hkoba/usr-local-perl5-template)

- 一部のスクリプト※が Fedora, CentOS Stream などの RedHat 系を前提にしています。  
Debian, Ubuntu 系で用いたい場合は、代わりのものを実装して下さい。

- `*.zsh` とあるスクリプトは実行に zsh が必要です

---
<small>※ dnf-install.zsh</small>

## 使い方

- clone して `cpanfile` に欲しいモジュールを追記し、`run-cpm.zsh` を
実行して下さい。
   ```sh
   dnf install zsh perl git
   
   cd /usr/local

   git clone https://github.com/hkoba/usr-local-perl5-template.git perl5
   
   cd $_
   
   # EDIT cpanfile and dnf-install-perlmodules.lst
   
   # Then
   
   ./run-cpm.zsh
   ```

- 例えばシステムの openssl に依存するもののように、OS のパッケージ管理でインストールしたほうが簡単な CPAN モジュールも有るでしょう。そういうものは
下記のファイルにモジュール名を列挙して下さい。
   ```
   dnf-install-perlmodules.lst
   ```

- 別マシンでインストール結果を再現したい場合は、git clone 後に以下のコマンドで symlink を作成して下さい
    ```sh
    ./dnf-install.zsh
    ./make-symlink.zsh
    ```

## おしまい

最後まで読んで下さり、ありがとうございました！
