Let's try out [Roc](https://github.com/roc-lang/roc)!

The language is still super experimental so there's a bit of manual setup steps needed.

Here's the steps used, for future reference:
- Download the roc nightly build, extract it somewhere. I'm using this version roc_nightly-linux_x86_64-2022-12-30-ea53a50. (This is a Windows machine but we can run via WSL)
- Copy the cli platform from https://github.com/roc-lang/roc/tree/main/examples, put it in this folder.
- Set up a custom [sublime build system for roc](roc-wsl.sublime-build),
although it's nicer to run it directly from WSL because of the compiler output.
