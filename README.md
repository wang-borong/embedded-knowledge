# 嵌入式知识体系总结

该仓库用于存放《嵌入式知识体系总结》源码，该文档通过 Latex 源码构建。
文档源码以 GPLv3 License 开源，所生成的文档暂以 CC BY-NC-SA License 发行。

本文档可以自由修改发行，但是需要以同样的 License 发行，并且不能用于商业用途，详参 [CC BY-NC-SA License](https://creativecommons.org/licenses/by-nc-sa/4.0/)。

## 写作因由

有许多朋友问我嵌入式该怎么学？
如何入门？
有没有一个可以快速入门，快速学习的路线？

从接触嵌入式开始，这些问题也困扰我良久。
在不断的学习摸索中，我对这个领域也有了一些见解，头脑中的嵌入式知识体系也逐渐清晰。
我想，在这个领域这么多年的积累，也许微不足道，但是不把它们梳理出来，实在浪费。
如果我把个人的认知梳理出来，或许还能帮助到一些朋友，实乃万幸。
于是，我便下定决心在我业余时间将嵌入式知识体系整理成册。

## 如何增加文档内容

1. Latex 写作

   如果您知道如何使用 Latex，那么我建议您使用 Latex 书写文档内容。
   文档中的要素不超过 20 个，如标题、正文、加粗、斜体、字体颜色、公式、表格和图片等等。
   只要掌握这些语法即可。
   其中，表格、图片和 tcolorbox 等有更加简洁的封装命令。
   所以，书写不会困难，您只需要向 tex 目录下添加文章即可。

2. Markdown 写作

   许多朋友可能并没有用过 Latex，但是不少朋友应该都用过 Markdown。
   如果您不知道如何使用 Latex，那么我建议使用 Markdown 即可。
   排版固然重要，但是内容更加珍贵，有了内容，再锦上添花也不迟。
   所以，如果您想要向该文档添加 Markdown 文章，那么您可以向 md 目录添加文章。

3. 其它格式写作

   当然，有些朋友即没用过 Latex，又嫌 Markdown 语法太少，那么这种情况该怎么办呢？
   我想这些朋友可能有自己心属的写作语法，如 rst 等。
   我们鼓励您在仓库根目录创建相关的目录，将您的文章放在其中。
   如，创建 rst 目录，然后将您的文章排列进去。

除了 Latex 外的格式如果需要排版，那么我建议您将相关文档的格式转成 Latex。
然后将您的文档插入进主文档的相关章节即可。

### Git 分支

该文档源码使用 writing 分支（可以认为是写作的临时分支），添加新内容。
检阅文档使用 review 分支（检阅的临时分支）。
为了覆盖性的 review 文档，并且尽可能减少重复工作。
我的 review 建议是基于 writing 分支中的 commit 进行 review。

如何基于 commit 进行 review 呢？

1. 首先切换到 writing 分支，查看所提交的 commit。
2. 确定了需要 review 的 commit 后，创建 review 分支。
   ```bash
   git checkout <commit> -b review/<commit>
   ```
3. 确定您 review 的 commit 之前有多少个 commit 没有 review 过。

   可以从 main 分支的合并记录获取到上次 review 过的 commit。
   然后，使用 `git diff` 命令去查看两个 commit 之间提交的内容。
   我们只需要 review 这些内容即可。

   **注意：如果第一次基于 commit 进行 review，那么我们需要将选择的 commit 与初始 commit 进行比对。**

   ```bash
   git diff <commit> <base-commit>
   # 如果修改了文档
   git add <...>
   git commit
   ```

4. 合并 review 到 main。

   review 过程中可能会修改原先的内容，也可能不需要修改。
   如果修改了原先的内容，那么就提交 commit 到 review 分支。
   最后，我们使用 `no-ff` 合并类型将 review 分支合并到 main 分支。

   ```bash
   git checkout main
   git merge -no-ff review/<commit>
   git branch -d review/<commit>
   ```

经过以上的闭环书写，尽可能的保证文档的内容经过一次 review 过程。
如果在后续阅读文档的过程中仍然发现了一些需要修改的地方，那么就从 main 分支切换一个 review 分支进行修改，然后提交，最后再合并到 main 分支。

## 如何构建文档（PDF）

当您按照文档层次编写好 Latex 文档时，您可以使用 make 命令编译。

本仓库也将独立的章节梳理出来了，文档入口是在 `tex/submain` 目录。
如果想要将独立的章节构建成文档那么只需要运行 `latexmk tex/submain/<xxx>.tex`。

## 后续计划

1. 完善内容
2. 添加 epub 电子书格式
3. 优化文档排版
