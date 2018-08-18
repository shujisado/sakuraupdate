# sakuraupdate
Sakura-Editor Update Plugin (alpha version)

プラグインでサクラエディタのバージョンアップ機能を実装してみる

## 機能目標
* 更新対象は、サクラエディタ本体、ヘルプファイル、正規表現ライブラリの3つのみ
* サクラエディタはVer2以降の32bit版
* 動作OSは、XP以降
* C:\Program Files配下へのコピー時は管理者モードでコピー
* SourceForgeとGithubのどちらでもダウンロード可能とする。

## 仕様メモ

* サクラエディタのダウンロードは、SFとGitHubの2種類から選べる
* ヘルプファイルは現状SFのみだが、将来GitHubにリリースされれば取得可能とする。
* ヘルプファイル自身にバージョン情報が無いためタイムスタンプで判定
* ネットからのダウンロードは、MSXMLを使わずcURLで取得。（環境依存の回避)
* zip展開は、7zのコマンドライン版を使用。(これも環境依存の回避)

## ToDo

* vbsをjsに移行したい

