---
marp: true
---

## Gitea, Redmine, CVSTrac から GitLab への
## import で得た **個人的な** 知見を駆け足で

![w:64px h:64px](img/myfistrect.jpg) **@hkoba** [hkoba.github.io](https://hkoba.github.io/)
→ [`GitLab Meetup JP` `#2`](https://hkoba.github.io/slides/gitlab-meetup-jp2/)

* <small>(名ばかりの)</small>フリーランス・プログラマ
  * 普段は Perl, TclTk, Zsh, Emacs Lisp

---

## 私の Issue Tracker 遍歴

- [CVSTrac](http://www.cvstrac.org/home/doc/trunk/www/index.html)<small>（[SQLite](https://www.sqlite.org/index.html) の [drh](https://en.wikipedia.org/wiki/D._Richard_Hipp) が自分のために作った）</small>
- [Redmine](https://redmine.jp/)
- GitHub <small>(これのみ SaaS)</small>
- [Phabricator](https://www.phacility.com/phabricator/)
- [Gitea](https://gitea.io/en-us/)


…そして GitLab へ

---

## なぜ GitLab を選んだ?

- グループ機能
  - ex. `チーム/プロジェクト/リポジトリ`
    - git submodule の相対URIで重要
    - issue 参照も ex. `X/Y/Z#番号`
  - 可視性・グループ参加可否の制御<small>（の階層化・権限委譲）</small>
- Self host で始められる
  - [IAP](https://cloud.google.com/iap) で守ってゼロトラスト化<small>(public でも安全 →全社 DX向き)</small>
  - 無課金スタート→実績積み

---
# Gitea からの import、どうだった？

---

## 最初は[公式機能](https://docs.gitlab.com/ee/user/project/import/gitea.html#import-your-project-from-gitea-to-gitlab)を試した

- Web 画面から gitea の API token を入れるだけで動く、お手軽
  - プロジェクト数が多いとWeb 画面の操作が大変
- リポジトリ → OK
- issue → 多いと取りこぼす<small>（gitea の API を叩くクライアントのページャの問題）</small>
- 未対応？
  - PR 上のコメント
  - Commit からの issue 参照が、issue 側に反映されない

---

## どう解決したか(1/4)

→公式の Importer を継承してページャを差し替え、問題を修正

```ruby
module GiteaImport
  class Client < Gitlab::LegacyGithubImport::Client
    def request(method, *args, &block)
    def each_response_page(method, args, last_response)

  class ProjectImporter
    def execute
```

<small>余談：gitlab公式から切り貼りして出来たコード、仮に公開するなら適切な場は？
ライセンスはどうすれば？  
（アドバイス求む）（なお業務で初ruby）</small>

---

## どう解決したか(2/4)

```ruby
puts "Importing repo devteam/NRA2/yllib1"
imp = GiteaImport::ProjectImporter.new(clnt, root, {
    import_source: 'devteam/yllib1', 
    target_namespace: 'devteam/NRA2', 
    new_name: 'yllib1',
})
imp.execute
```

→足りない機能は ActiveRecord を直接叩く

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

→ それを呼び出す ruby スクリプトを Gitea 側の DB データから生成

```sh
./GiteaQuery.pm generate_repo_importer \
  $mygroup > importer.rb

# 生成ツールの中身は perl なので自粛
```

---

## どう解決したか(4/4)

gitlab-rails runner に食わせる

```sh
sudo gitlab-rails runner $PWD/impoter.rb
```

<small>もちろん、最初は gitlab-rails console から `load` で少しずつ結果を確認しながら合わせ込み</small>

---

# Redmine からの import、どうだった？

---

## 普通なら既存のツールを使うほうが良さそう

[![h:30%](img/redmine-to-gitlab-migrator-top2.png)](https://github.com/redmine-gitlab-migrator/redmine-gitlab-migrator)

---

## 今回は、ネットワーク的に使いづらい事情があった

- redmine は社内ネットワーク
  - パンデミック下で出社したくない
- gitlab は GCP 上の IAP 保護下
## → ならば

- redmine の SQLite の db だけ持ち帰り
- gitea の時と同じように、import用 ruby スクリプトを生成

---

## どう解決したか