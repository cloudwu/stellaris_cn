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
git remote add cloudwu https://github.com/cloudwu/stellaris_cn.git	# 添加远程仓库
git fetch cloudwu	# 将远程仓库取到本地
git checkout -b cloudwu cloudwu/master	# 创建一个本地分支跟踪远程仓库
```

4. 在自己的仓库修改提交
```
git checkout master	# 切换到自己的分支
...
git commit 
git push
```

5. 同步上游仓库
```
git checkout cloudwu	# 切换到上游跟踪分支
git pull	# 拉取上游仓库
git checkout master	# 切换到自己的分支
git rebase cloudwu	# 和上游仓库合并, 注意 rebase 之后可能需要 push -f
```

6. 合并上游仓库（可选）

如果你确定自己的仓库和上游原始仓库内容完全相同，只是因为合并提交等原因有差异。
为了减少 rebase 过程中的冲突，可以在每次基于上游版本做翻译前（确定你之前的 pr 已经被合并，或已放在独立分支）使用：
```
git checkout cloudwu
git pull
git checkout master
git reset cloudwu
git push -f
```
这样可以直接和原始仓库分支保持严格一致。但注意，这样会丢失你的本地提交。如果误操作，可以通过 git reflog 查询历史版本，再 git reset 恢复。


----

在第四步骤做修改时，可以随时进行第五步同步上游。第五步最后的 rebase 阶段，如果发生冲突，git 会有提示，手工解决冲突后可回到第四步继续。


