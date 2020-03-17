#!/bin/bash
echo 生成静态页
gitbook build

echo 将 _book 目录推送到 GitHub 仓库的 gh-pages 分支
git subtree push --prefix=_book origin gh-pages

git subtree push --prefix=_book github gh-pages
