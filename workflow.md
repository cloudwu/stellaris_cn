鉴于不少同学对 github 上的合作方法不清楚，我列出我自己的工作流。需要使用 git 命令行。github desktop 等图形工具怎样使用请懂的同学补充。


协作工作流
==========

1. 去 github 页面上点 fork 创建一个自己 (假设你的用户名叫 username) 的分支仓库用于修改。

2. 在本地 clone 你的仓库：
```
git clone git@github.com:username/stellaris_cn.git
```

3. 加一个本地分支跟踪原始仓库：
```
git remote add cloudwu https://github.com/cloudwu/stellaris_cn.git
git checkout -b cloudwu cloudwu/master
```

4. 在自己的仓库修改提交
```
git checkout master	# 切换到自己的分支
...
git commit 
git push
```

5. 同步原始仓库
```
git checkout cloudwu	# 切换到上游跟踪分支
git pull	# 拉取上游仓库
git checkout master	# 切换到自己的分支
git merge cloudwu	# 和上游仓库合并

----

在第四步骤做修改时，可以随时进行第五步同步上游。
