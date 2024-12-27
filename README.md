# 'Git MV' plugin for [ViFM](https://github.com/vifm/vifm)

This is a plugin for ViFM (Vim-like file manager) which replaces `mv` operations with `git mv` operations inside git-enabled repositories.

## Install and Configuration

> Requires `ViFM` version `0.13` and greater.

To install, you may:

```shell
mkdir -p ~/.config/vifm/plugins/git-mv
```

then download `init.lua` from this repo and place it into `git-mv` directory.

This plugin is enabled by default on start, to disable it, run the following command in `ViFM`:

```shell
:toggleGitMv
```

## Why

When you move files inside a git repository with any file manager, git may not always detect file rename. This is particularly noticable inside [git-annex]()-enabled repositores because git annex should detect symlink change on each `git add -A` which may be relatively slow due to additional lookup operation which git annex performs in background.

With this plugin, this is no longer an issue, and it allows to avoid using `git add -A` while moving files withing repository boundaries because `git mv` automatically stages such files and marks them as renamed.

## Notes

- For now it's in a "proof of concept state" and most likely has bugs.
- Most likely doesn't work on Windows (only Linux for now).
- Most likely messes up with "undo/redo" - do not install this plugin if you rely on those operations.
- The implementation is not optimal due to ViFM lua api limitations.
- Many thanks to [xaizek](https://q2a.vifm.info/user/xaizek) for the initial help in [this thread](https://q2a.vifm.info/1948/is-it-possible-to-override-copy-paste-behavior-for-symlinks).
