---
name: superset-worktree
description: Create a new git worktree for the current repo via the superset.sh CLI so it appears in the Superset desktop app. Use when the user asks to start a new worktree, workspace, or parallel branch to work on.
---

# superset-worktree

Create a worktree through the **superset.sh CLI** (not `git worktree`) so it registers as a workspace in the Superset desktop app. The CLI creates a branch-scoped git worktree on this host and surfaces it in the app.

## Prerequisites
- `superset` CLI on PATH (installed at `~/.superset/bin/superset`). If `superset` isn't found, prefix commands with `~/.superset/bin/superset`.
- Logged in: if any command errors with auth, tell the user to run `superset auth login` (interactive — they run it, you can't).
- The current repo must be registered as a Superset **project**.

## Inputs to gather
- **branch** — the git branch for the worktree (required). Ask if not given.
- **name** — workspace name shown in the app (default: the branch name).
- **base branch** — only if creating a new branch that doesn't exist yet (defaults to the project's default branch).
- **agent** (optional) — if the user wants an agent to start in it (`claude`, `codex`, …); requires a `--prompt`.

## Steps

### 1. Find the project ID for this repo
```bash
superset projects list --json
```
Parse the JSON. Match the entry whose repo/path corresponds to the current working directory (compare the repo remote or the local path). Take its `id`.

- If no project matches the current repo: the repo isn't registered with Superset. Stop and tell the user to add the project in the Superset app (or via the CLI if available), then re-run. Do NOT invent a project id.
- If multiple plausible matches, show them and ask which.

### 2. Create the workspace (worktree) on this machine
```bash
superset workspaces create \
  --project <projectId> \
  --name "<name>" \
  --branch <branch> \
  --local \
  --json
```
- Add `--base-branch <base>` only when `<branch>` does not exist yet and should fork from a non-default base.
- To start an agent in it, add `--agent <id> --prompt "<initial prompt>"` (prompt is required when `--agent` is set).
- Capture the returned workspace `id` from the JSON.

### 3. Open it in the app
```bash
superset workspaces open <workspace-id>
```
Use `--print` instead to just emit the deep link without focusing the app.

### 4. Report back
Tell the user: branch, workspace name, workspace id, and that it's now visible in Superset. If you opened it, say so.

## Notes
- `--local` targets this machine. To create on a remote host instead, use `--host <machineId>` (list hosts with `superset hosts list --json`).
- Prefer `--json` on every command and parse it — output is structured and stable.
- Never fall back to raw `git worktree add` for this skill — that creates a worktree Superset doesn't know about, defeating the purpose. If the CLI fails, surface the error and stop.
