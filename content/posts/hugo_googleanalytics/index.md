---
title: "hugoのconfigに書いただけではGoogleAnalyticsが動かないテンプレートがある"
date: 2022-06-19
tags: ["hugo"]
draft: false
---

これまでブログはhatenaでやっていたのですが，ポートフォリオなどいろいろと付け足すと使い勝手が悪かったので，hugoで新築しました．
その際にGoogleAnalyticsを設定しようとしたのですが，一発でうまく動作しませんでしたので，トラブルシュートの記録です．

HugoにはデフォルトでGoogleAnalyticsを簡単に設定するためのテンプレートが組み込まれています．
google_analytics_async.html と google_analytics.htmlの2種類が用意されています．

config.tomlにGoogleAnalyticsのトラッキングコードを書くことでトラッキング用の
Javascriptを読み込んでいい感じにしてくれるのですが，google_analytics_async.htmlの方では，GoogleAnalytics 4に対応していないので，google_analytics.htmlを使う必要があります．
使っていたテーマの[hugo-theme-mini](https://github.com/nodejh/hugo-theme-mini)では，head.htmlでansyncの方を読み込んでいたので，タグをconfig.tomlに書いてもうまく動作しませんでした．

`/themes/mini/layout/partials/head.html`を
`/layouts/partial/head.html`にコピーして，google_analytics_async.htmlを読み込んでいる部分をgoogle_analytics.html書き換えればうごきます．

このテンプレートは，[ここ](https://github.com/gohugoio/hugo/blob/master/tpl/tplimpl/embedded/templates/google_analytics.html)で見れます．
タグのprefixでGoogleAnalyticsのバージョンを判別できるようで，prefixがUAかGかで読み込むスクリプトを変更するようになっていました．


