Let's try out [Roc](https://github.com/roc-lang/roc)!

The language is still super experimental so there's a bit of manual setup steps needed.
The version I'm using is roc_nightly-linux_x86_64-2022-12-30-ea53a50.
I'm still running this on a Windows machine though, so this needs to go through WSL.

Here's the steps I used, for future reference:
- Download the roc nightly build, extract it somewhere.
- Copy the cli platform from https://github.com/roc-lang/roc/tree/main/examples, put it in this folder.
- Set up a custom [sublime build system for roc](roc-wsl.sublime-build),
although it's nicer to run it directly from WSL because of the compiler output.
