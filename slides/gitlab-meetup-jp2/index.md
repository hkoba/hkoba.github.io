---
marp: true
title: Gitea, Redmine, CVSTrac から GitLab へのデータ移行で得た個人的知見を駆け足で
image: https://hkoba.github.io/slides/gitlab-meetup-jp2/index.png
---

## Gitea, Redmine, CVSTrac から

## GitLab へのデータ移行で得た**個人的**知見を駆け足で

![w:64px h:64px](img/myfistrect.jpg) **@hkoba**

<!-- 
hkoba と申します。名ばかりのフリーランスプログラマです。
今日は
〜お話しさせて頂きます。
-->
---

# お断り

- あくまで個人的な成功事例


  - 今後も使える？→不明
  - YMMV


<!--
はじめにお断りです。この話はあくまで個人的な成功事例です。

同じ方法が今後もうまく行くとは保証できません。ご了承下さい。
-->
---

## 私の Issue Tracker 運用歴(self host)

|システム|利用開始|状況|
|-|-|-|
|[CVSTrac](http://www.cvstrac.org/home/doc/trunk/www/index.html)|2005〜|今はIssue管理とWikiのみ、ただし最重要コードベース<br>移行手順の構築途上|
|[Redmine](https://redmine.org/)|2012〜|一部残存|
|[Phabricator](https://www.phacility.com/phabricator/)|2019〜|廃止|
|[Gitea](https://gitea.io/en-us/)|2020〜|廃止|
|…そして **GitLab** |2021〜||

<!-- 
さて、私が初めて運用した Issue Tracker は CVSTrac でした。本当は早く廃止したいのですが、今も最重要なコードの Issue 管理を担っています。

脱出先の候補として、様々な Issue Tracker をサイドプロジェクト用に試して来ました。その末に、たどり着いたのが GitLab というわけです。
-->
---
# Gitea からのデータ移行、どうだった？

<!--で実際、〜どうだったかですが、 -->
---

## 最初は[公式機能](https://docs.gitlab.com/ee/user/project/import/gitea.html#import-your-project-from-gitea-to-gitlab)を試した

- Web 画面から gitea の API token を入れるだけで動く
  * プロジェクト数が多いとWeb 画面の操作が大変

* リポジトリ → OK
* issue → 多いと取りこぼす  
 <small>（github API 用のコードを gitea にも転用しているため、ページャの仕様違いで問題発生）</small>
* 未対応？
  - PR 上のコードレビューのコメント
  - Commit からの issue 参照が、issue 側に反映されない

<!--
最初は公式機能を試しました。

Web画面をプチプチするだけで使えます。
数が多いと手間ですが。

で、リポジトリの移行はうまく行ったのですが、

issue は、数が多いと取りこぼされる、

Pull Request 上のコードレビューコメントが捨てられる
Commit メッセージで issue 参照を書いても、issue 側からは commit が見えない

など、不満がありました。
-->
---

# 取りこぼしデータは諦める？ …は嫌！

- データは、システムよりも大事！


  - 新人教育のコードレビューのやり取りが失われるとか、全力で回避したい


<!--
じゃぁ、データの取りこぼしが有っても（今動いている gitea を捨てて）強引に GitLab に移行するの？
というと、それは私は嫌でした。

この時の gitea は新人教育プロジェクトで用いていたので、（単に GitLab 使いたいからで）新人さんにユーザーデータを捨てるところを見せたくなかったのです。

システムファーストじゃなく、顧客データファーストの姿勢を見せたかった
-->
---

# →ならば、自力救済だ

* <small>（巨大であっても）</small> GitLab は結局 Rails アプリ

* gitlab-rails console で対話的に実験できる
  - ActiveRecord ベースのモデル群
  - API Client
* <small>※起動に40秒ほど必要</small>

<!--
よろしい、ならば自力救済だ！

（どれだけ巨大であっても）GitLab は結局 Rails アプリには違いない

rails console で対話的に実験できるので、

中のモデル群、サービスクラス、APIクライアントを叩いて、

正しい使い方を学ぶことが出来る

それは今後の運用にも役立つ知識になるだろう
-->
---

## メインの仕事の合間に rails console

## gitlab から切り出したコード断片をチマチマ投入実験

## 〜16週間

* （rubyは業務で初）

<!--
というわけで、〜〜

ということを16週間ほどかけて行いました
-->
---

## 余談：アドバイス求む

gitlab公式から切り貼りして出来たコード、仮に公開するなら

- 適切な場は？
- ライセンスはどうすれば？  

---

## どう解決したか(1/4)

- ページャの問題を修正した API Client を定義
- importer の定義も切り貼り 

```ruby
module GiteaImport
  class Client < Gitlab::LegacyGithubImport::Client
    def request(method, *args, &block)
    def each_response_page(method, args, last_response)

  class ProjectImporter
    def execute
```


---

## どう解決したか(2/4)

```ruby
puts "Importing repo ourteam/FOO/bar"
imp = GiteaImport::ProjectImporter.new(clnt, root, {
    import_source: 'ourteam/bar', 
    target_namespace: 'ourteam/FOO', 
    new_name: 'bar',
})
imp.execute
```

- 足りない機能は ActiveRecord を直接叩く…

```ruby
proj15 = imp.project

review5 = Review.create!(
  author: (User.find_by_email 'foobar@example.com'), 
  project: proj15, 
  merge_request: MergeRequest.find_by(project: proj15, iid: 2), 
  created_at: '2021-05-28T03:54:40Z')
```
---
## どう解決したか(3/4)

…そんなスクリプトをプログラムで生成し…

```sh
./GiteaQuery.pm generate_repo_importer \
  $mygroup > importer.rb

# 生成ツールの中身は perl なので自粛
```

---

## どう解決したか(4/4)

… gitlab-rails runner に食わせる

```sh
sudo gitlab-rails runner $PWD/impoter.rb
```

<small>もちろん、最初は gitlab-rails console から `load` で少しずつ結果を確認しながら合わせ込み</small>

---

# 次：Redmine からのデータ移行、どうだった？

---

## 普通なら既存のツールを使うほうが良さそう

[![h:30%](img/redmine-to-gitlab-migrator-top2.png)](https://github.com/redmine-gitlab-migrator/redmine-gitlab-migrator)

---

## 今回は、ネットワーク的に使いづらい事情があった

- redmine は社内ネットワーク
  - パンデミック下で出社したくない
- うちの GitLab はゼロトラスト化のため GCP 上の Identity-Aware Proxy 保護下

## 加えて

* 後の CVSTrac 移行のためにも、自力で直接モデルを叩く方法を実験したかった
---
## どう解決したか

redmine の SQLite の db だけ持ち帰り、gitea の時と同じように、import用 ruby スクリプトを生成

### issue とコメント
```ruby
issue10 = Issue.create!(author: User.find_by_email('foobar@example.com') || User.find(1),
 project: Project.find_by_full_path('foobar/issues'),
 closed_at: '2019-11-08T08:49:04Z',
 iid: 10,
 state: :closed,
 created_at: '2019-05-17T06:08:51Z',
 title: 'アンケート本体の全体タスク',
 description: '',
 updated_at: '2019-11-08T08:49:04Z')

Note.create!(project: (Project.find_by_full_path 'foobar/issues'),
 noteable: issue10,
 author: User.find_by_email('foobar@example.com') || User.find(1),
 created_at: '2019-11-08T08:49:04Z',
 note: '分類を変えたので、閉じます。')
```
---

### issue 同士の親子関係
```ruby
prj = Project.find_by_full_path 'foobar/issues'

IssueLink.create!(source: prj.issues.find_by_iid(1),
 target: prj.issues.find_by_iid(3),
 created_at: '2019-05-17T06:08:50Z')
IssueLink.create!(source: prj.issues.find_by_iid(2),
 target: prj.issues.find_by_iid(3),
 created_at: '2019-05-17T06:08:50Z')
```

### グループ全体の issue 数が狂うのでキャッシュを再計算
```ruby
prj = Project.find_by_full_path 'foobar/issues'
o = Projects::OpenIssuesCountService.new(prj)
o.count
o.refresh_cache
o.count
```

---

# 最後：CVSTrac からのデータ移行

- Issue, Note, IssueLink ... を作る
- 時系列の通りに create する必要があるぽい
* （以下略
---

## まとめ

- データはプログラムよりも重く尊い
  - ならば手段は泥臭くても良い

- LL で記述された CMS は import ターゲット向き
  - REPL （rails console）上で実験
- プログラムとして export し、実行で import


---

# おまけ

---

## なぜ GitLab を選んだ?

- グループ機能
  - ex. `チーム/プロジェクト/リポジトリ`
    - git submodule の相対URIで重要
    - issue 参照も ex. `X/Y/Z#番号`
  - 可視性・グループ参加可否の制御<small>（の階層化・権限委譲）</small>
- Self host で始められる
  - [Identity-Aware Proxy](https://cloud.google.com/iap) の背後に設置<small>（public でも安全→全社DX基盤化）</small>
  - 無課金スタート→実績積み

---

## rails console で実験、の例

```
irb(main):001:0> n = Note.find(12575)
=> #<Note id: 12575, note: [FILTERED], noteable_type: "Issue", author_id: 5, created_at: "2022-02-18 14:01:22.494215000 +0900",...
irb(main):002:0> n.note
=> "コメントですよあああ"
irb(main):003:0> n.note + 'foobar'
=> "コメントですよあああfoobar"
irb(main):004:0> n.update!(note: n.note + ' いいいい')
=> true
irb(main):005:0> 
```
