-- Worktrunk picker in a floating Rex pane. Enter opens the worktree in a new
-- tab, Alt-c creates one from the typed text, Alt-x removes the selected one.
local terminal = "com.superlogical.terminal"

local function focused_cwd(block_id)
  local pwd = rex.block.call(terminal, "pwd", { block_id = block_id })
  if pwd and pwd.path then return pwd.path end
  -- shells without OSC 7 report no pwd; the foreground process cwd is close enough
  local p = rex.block.call(terminal, "process", { block_id = block_id })
  return p and p.foreground and p.foreground.cwd
end

rex.action{
  name     = "worktrunk",
  title    = "Worktrees…",
  keywords = "wt worktree branch git",
  args     = { cwd = "string?" },
  run      = function(ctx, args)
    local cwd = args.cwd or (ctx.block_id and focused_cwd(ctx.block_id))
    local _, err = rex.session.new_layer{
      bounds = { 0.1, 0.1, 0.8, 0.8 },
      focus  = true,
      layout = rex.layout.block{
        flavor  = terminal .. ".shell",
        options = {
          cwd     = cwd,
          command = {
            "wt", "switch", "--branches", "--no-cd", "-x", "rex", "--",
            "window", "new", "-s", ctx.session_id, "{{ branch }}",
            "-c", "{{ worktree_path }}",
          },
        },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}
