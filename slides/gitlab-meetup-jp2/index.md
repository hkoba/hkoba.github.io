### Gitea, Redmine, CVSTrac から GitLab への
### import で得た知見を駆け足で

<img src="img/myfistrect.jpg" style="width: 64px; height: 64px">
**@hkoba** [hkoba.github.io](https://hkoba.github.io/)
→ [`GitLab Meetup JP` `#2`](https://hkoba.github.io/slides/gitlab-meetup-jp2/)

---

### 自己紹介

* <small>(名ばかりの)</small>フリーランス・プログラマ
  * 普段は Perl, TclTk, Zsh, Emacs Lisp

---

<!-- .slide: class="small" -->

### 私の Issue Tracker 遍歴

- [CVSTrac](http://www.cvstrac.org/home/doc/trunk/www/index.html)<small>（[SQLite](https://www.sqlite.org/index.html) の [drh](https://en.wikipedia.org/wiki/D._Richard_Hipp) が自分のために作った）</small>
- [Redmine](https://redmine.jp/)
- GitHub <small>(これのみ SaaS)</small>
- [Phabricator](https://www.phacility.com/phabricator/)
- [Gitea](https://gitea.io/en-us/)


…そして GitLab へ

---

<!-- .slide: class="small" -->

### なぜ GitLab に?

- グループ機能
  - ex. `チーム/プロジェクト/リポジトリ`
    - git submodule の相対URIで重要
    - issue 参照も ex. `X/Y/Z#番号`
  - 可視性・グループ参加可否の制御<small>（の階層化）</small>
- Self host で始められる
  - [IAP](https://cloud.google.com/iap) で守ってゼロトラスト化<small>(public でも安全 →全社 DX向き)</small>
  - 無課金スタート→実績積み

---

## import どうだった？

---

<!-- .slide: class="tiny" -->

### Gitea からの import

[公式機能あり](https://docs.gitlab.com/ee/user/project/import/gitea.html#import-your-project-from-gitea-to-gitlab)

- プロジェクト数が多いとWeb 画面の操作が大変

- 正常
  - リポジトリ
- 問題あり
  - issue が増えると取りこぼす<small>（gitea の API を叩くクライアントのページャのバグ）</small>
- 未対応
  - PR 上のコメント
  - Commit メッセージと issue のリンク
  - プロジェクト Wiki

---

### どう解決したか

- GitLab のソースを読み解き切り貼り  
  gitlab-rails runner で動く gitea importer を書く
- それを呼び出す ruby スクリプトを Gitea 側の DB データから生成
- gitlab-rails runner に食わせる


<small>余談：出来た gitea importer を公開する時のライセンスはどうすれば？  
（アドバイス求む）</small>

___

### 生成されたコードの例

```ruby
puts "Importing repo devteam/NRA2/yllib1"
imp = GiteaImport::ProjectImporter.new(clnt, root, {
    import_source: 'devteam/yllib1', 
    target_namespace: 'devteam/NRA2', 
    new_name: 'yllib1',
})
imp.execute

proj15 = imp.project
```

___

```ruby
review5 = Review.create!(
  author: (User.find_by_email 'rkodama@ssri.com'), 
  project: proj15, 
  merge_request: MergeRequest.find_by(project: proj15, iid: 2), 
  created_at: '2021-05-28T03:54:40Z')
mr5 = MergeRequest.find_by(project: proj15, iid: 2)
```

___


```ruby
origPos5 = Gitlab::Diff::Position.new(
  new_path: 'lib/Survey2.pm', 
  head_sha: '012286ff7ccbac5a01ae47c89ce282d80e225252', 
  start_sha: '7b7601ae0d141ccfd347b5f8755bc1f2f7e7c09c', 
  new_line: 503, 
  base_sha: '7b7601ae0d141ccfd347b5f8755bc1f2f7e7c09c', 
  position_type: 'text', old_path: 'lib/Survey2.pm')
print "diff_file => "; puts origPos5.diff_file(mr5)

origPos5.define_singleton_method(:find_diff_file_from) do |noteable| origPos5.diff_file(noteable) end

print "find_diff_file_from => "; puts origPos5.find_diff_file_from(mr5)
```

___

<!-- .slide: class="tiny" -->

```ruby
reviewComment5 = Note.create!(
  importing: true,
  noteable_type: "Commit",
  author: (User.find_by_email 'rkodama@ssri.com'),
  project: (Project.find_by_full_path 'devteam/NRA2/yllib1'),
  position: Gitlab::Diff::Position.new(..),
  type: 'DiffNote',
  note: 'このコードは…',
  review: review5,
  noteable: mr5,
  original_position: origPos5)
```

___


```ruby
unless origPos5.diff_file(mr5).line_for_position(origPos5)
  puts "  line_for_position is empty, monkey patching Note.create_diff_file..."
  reviewComment5.define_singleton_method(:create_diff_file) do end
end
reviewComment5.save
```


---

### Redmine からの import

