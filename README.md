# rex-worktrunk

A [Rex](https://www.superlogical.com/rex) plugin that opens the [Worktrunk](https://worktrunk.dev) worktree picker in a floating pane. It opens the worktree you pick in a new tab of the current session and names the tab after the branch.

![The Worktrees picker listing branches with a diff preview](screenshot.png)

## Requirements

- Rex, tested with 0.1.0-preview.19
- the `rex` CLI on your `PATH`, because Worktrunk runs `rex window new` to open the tab
- [Worktrunk](https://worktrunk.dev) (`wt`), tested with 0.81.0. Install it with `brew install worktrunk`.

## Install

Clone the repo into your Rex config folder:

```sh
git clone https://github.com/astwys/rex-worktrunk ~/.config/rex/rex-worktrunk
```

Load it from `~/.config/rex/init.lua` and bind a key to the `worktrunk` action:

```lua
require("rex-worktrunk")
rex.bind("ctrl+a>w", "worktrunk")
```

Then run `rex config reload`.

## Usage

Press the key, or pick "Worktrees…" in the command palette. The plugin runs `wt switch --branches` in the focused pane's folder. The picker lists that repo's worktrees and the local branches that don't have one yet.

| Key | Action |
| --- | --- |
| Enter | Open the selected worktree in a new tab. For a branch without a worktree, Worktrunk creates one first. |
| Alt-c | Create a worktree for a new branch named after the text you typed |
| Alt-x | Remove the selected worktree |
| Esc | Close the picker |

These are Worktrunk's own picker keys. `wt switch --help` lists the rest.

To start the picker in another repo, pass its path:

```sh
rex do worktrunk cwd=$HOME/code/my-app
```

## License

MIT
