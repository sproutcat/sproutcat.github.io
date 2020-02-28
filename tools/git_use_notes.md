Git 使用笔记（命令行）
================================

参考文章
--------------------------------

* [GIT BOOK](https://git-scm.com/book/zh/v2)
* [git - 简明指南](http://rogerdudler.github.io/git-guide/index.zh.html)
* [一篇文章，教你学会Git](https://juejin.im/post/599e14875188251240632702)
* [Git飞行规则 (Flight Rules)](https://github.com/k88hudson/git-flight-rules/blob/master/README_zh-CN.md)


 标签（tag）
--------------------------------

列出现有标签的命令：

```bash
git tag
```

列出特定标签的命令：

```bash
git tag -l 'v1.4.2.*'
```

打标签的命令

```bash
git tag -a tagName -m 'my version 1.4'
```

推送指定标签的命令：

```bash
git push origin tagName
```

推送所有本地标签的命令：

```bash
git push origin --tags	
```

删除本地标签的命令：

```bash
git tag -d tagName
```

删除远程标签的命令：

```bash
git push origin :refs/tags/tagName
```

 添加版本控制（add）
--------------------------------

添加一个文件的版本控制

```bash
git add filename.txt
```

 提交（commit）
--------------------------------

提交一个文件

```bash
git commit filename.txt -m 提交一个文件
```





