-- Worktrunk worktrees in the command palette. Picking one opens it in a new
-- tab; typing a new name creates the branch and its worktree first.
-- "Remove Worktrees…" removes the ones you tick.
local terminal = "com.superlogical.terminal"
local home = os.getenv("HOME")

local function focused_cwd(block_id)
  local pwd = rex.block.call(terminal, "pwd", { block_id = block_id })
  if pwd and pwd.path then return pwd.path end
  -- shells without OSC 7 report no pwd; the foreground process cwd is close enough
  local p = rex.block.call(terminal, "process", { block_id = block_id })
  return p and p.foreground and p.foreground.cwd
end

local function repo_cwd(ctx, args)
  return args.cwd or (ctx.block_id and focused_cwd(ctx.block_id))
end

-- The server's PATH lacks Homebrew and friends, so wt runs through the login
-- shell, which gives it the same PATH a pane gets.
local shell = os.getenv("SHELL") or "/bin/zsh"

local function wt(args, cwd)
  local r = rex.exec({ shell, "-lc", 'exec wt "$@"', "wt", unpack(args) }, { cwd = cwd })
  if not r.ok then error(r.stderr ~= "" and r.stderr or "wt " .. args[1] .. " failed", 0) end
  return r.stdout
end

local function rows(cwd)
  local out = {}
  for _, row in ipairs(rex.json.decode(wt({ "list", "--format=json", "--branches" }, cwd)).items) do
    -- a detached worktree has no branch to switch to
    if row.branch then out[#out + 1] = row end
  end
  return out
end

local function item(row)
  local path = row.worktree and row.worktree.path
  return {
    id       = row.branch,
    subtitle = path and (path:sub(1, #home) == home and "~" .. path:sub(#home + 1) or path) or "no worktree",
    detail   = row.display and row.display.symbols,
    icon     = "branch",
  }
end

rex.action{
  name     = "worktrunk",
  title    = "Worktrees…",
  keywords = "wt worktree branch git switch create",
  args     = { cwd = "string?" },
  run      = function(ctx, args)
    local cwd = repo_cwd(ctx, args)
    local items, paths = {}, {}
    for i, row in ipairs(rows(cwd)) do
      items[i] = item(row)
      paths[row.branch] = row.worktree and row.worktree.path
    end

    local branch = rex.ui.pick{
      title       = "Worktrees",
      placeholder = "Branch, or a new name to create",
      confirm     = "Open",
      items       = items,
      allow_other = true,
    }
    if branch == nil then return end
    local create = type(branch) == "table"
    if create then branch = branch.text end

    if paths[branch] then
      local _, err = rex.session.new_window{
        window_label = branch,
        layout = rex.layout.block{ flavor = terminal .. ".shell", options = { cwd = paths[branch] } },
      }
      if err ~= nil then error(err, 0) end
      return
    end

    -- Creating a worktree runs pre-start hooks (yarn install…) that can outlast
    -- an action, so wt runs in a float that shows them, then opens the tab.
    local cmd = { "wt", "switch", branch, "--no-cd", "-x", "sh", "--", "-c",
      -- detach first; closing the focused layer would refocus the old tab
      [[rex api call -s "$0" session.detach_block "{\"block_id\":\"$REX_BLOCK\"}" >/dev/null
        exec rex window new -s "$0" "$1" -c "$2"]],
      ctx.session_id, "{{ branch }}", "{{ worktree_path }}" }
    if create then table.insert(cmd, 3, "--create") end
    local _, err = rex.session.new_layer{
      bounds = { 0.1, 0.1, 0.8, 0.8 },
      focus  = true,
      layout = rex.layout.block{ flavor = terminal .. ".shell", options = { cwd = cwd, command = cmd } },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.action{
  name     = "worktrunk_remove",
  title    = "Remove Worktrees…",
  keywords = "wt worktree branch git remove delete clean",
  args     = { cwd = "string?" },
  run      = function(ctx, args)
    local cwd = repo_cwd(ctx, args)
    local items = {}
    for _, row in ipairs(rows(cwd)) do
      if row.worktree and not row.worktree.main then items[#items + 1] = item(row) end
    end
    if #items == 0 then error("no worktrees to remove", 0) end

    local branches = rex.ui.pick{
      title       = "Remove worktrees",
      placeholder = "Filter worktrees",
      confirm     = "Remove",
      multiple    = true,
      items       = items,
    }
    if branches == nil or #branches == 0 then return end
    wt({ "remove", unpack(branches) }, cwd)
    return "Removed " .. table.concat(branches, ", ")
  end,
}
