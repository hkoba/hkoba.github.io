# このプロジェクトは pjcj さんの作った Perl モジュール Devel::Cover のプロジ

## Assistant

Devel::Cover のソースコードを把握しました。以下が概要です：

## プロジェクト構造

### コアコンポーネント
- **Cover.xs** (約1600行) - XS/C によるカバレッジ計測エンジン
- **lib/Devel/Cover.pm** (約1900行) - メインモジュール、B::Deparse を活用
- **lib/Devel/Cover/DB.pm** - カバレッジデータベース管理

### カバレッジ計測の仕組み

**2つの動作モード:**
1. **ppaddr 置換モード (デフォルト、高速)** - `PL_ppaddr` テーブルを置換
2. **runops 置換モード (レガシー)** - `PL_runops` を独自実装に置換

**計測対象:**
- Statement (文)
- Branch (分岐)
- Condition (条件 - `&&`, `||`, `//`, `xor`)
- Subroutine (サブルーチン)
- Pod (ドキュメント)
- Time (時間プロファイリング)

### 特徴的な実装技法
- **B::Deparse のカスタマイズ** - OP ツリーからソースコード形式を復元
- **FNV-1a ハッシュ** - OP の一意識別キー生成
- **複数シリアライザ対応** - Sereal > JSON > Storable の優先順位
- **3段階ファイルフィルタ** - @Inc, @Ignore, @Select

### その他
- 93個の E2E テスト (`tests/` ディレクトリ)
- 複数のレポート形式 (HTML, Text, JSON, Vim/Nvim 統合)
- `cover` コマンドによるレポート生成

どの部分について詳しく質問されますか？

---

<small style="color: gray">uuid: bdc41882-c47f-4acb-b69e-0d7ded832330</small>