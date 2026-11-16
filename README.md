# rex-worktrunk

A [Rex](https://www.superlogical.com/rex) plugin that opens the [Worktrunk](https://worktrunk.dev) worktree picker in a floating pane. The worktree you pick opens in a new tab of the current session, named after its branch.

![The Worktrees picker listing branches with a diff preview](screenshot.png)

## Requirements

- Rex, tested with 0.1.0-preview.19
- the `rex` CLI on your `PATH`, because the picker calls `rex window new` to open the tab
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

Press the key, or pick "Worktrees…" in the command palette. The picker runs `wt switch --branches` in the focused pane's folder, so it lists that repo's worktrees and its local branches that have none yet.

| Key | Action |
| --- | --- |
| Enter | Open the selected worktree in a new tab |
| Alt-c | Create a worktree named after the text you typed |
| Alt-x | Remove the selected worktree |
| Esc | Close the picker |

These are Worktrunk's own picker keys. `wt switch --help` lists the rest.

To start the picker in another repo, pass its path:

```sh
rex do worktrunk cwd=$HOME/code/my-app
```

## License

MIT
