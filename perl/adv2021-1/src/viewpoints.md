# Modulino を理解するための、２つの視点

モジュール兼コマンドとなるプログラムを考えた時、それを２つの立場・視点から
捉えることが出来ます。

1. CLI コマンドが、モジュールを兼ねている
    ```console
    % myscript.pl 引数...
    ```
    ↓
    ```console
    % MyScript.pm 引数...
    ```

1. モジュールが、CLI コマンドを兼ねている
    ```perl
    use MyCMS;
    my $cms = MyCMS->new(MyCMS->parse_options(\@ARGV));
    print $cms->list_blogs(@ARGV);
    ```
     ↓
    ```console
    % ./MyCMS.pm --dbname=var/cms.db list_blogs
    ```

- - - -
