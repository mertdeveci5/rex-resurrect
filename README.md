# rex resurrect

Save the Claude Code, Codex and Pi conversations open in your [Rex](https://www.superlogical.com/rex) panes, and resume every one of them, each in its own pane, after Rex or your Mac restarts.

Rex brings back your sessions, tabs and splits after a server restart, but as fresh shells: the agents that were running in them are gone. `rex resurrect` puts them back.

```sh
rex resurrect save    # before restarting Rex
rex resurrect         # after it comes back
```

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/mertdeveci5/rex-resurrect/main/install.sh | sh
```

Then open a new Rex pane. The installer:

1. Copies `rex-resurrect` to `~/.local/bin`.
2. Adds the Pi extension to `~/.pi/agent/extensions` if you use Pi.
3. Adds a small `rex` shell function to `~/.zshrc` or `~/.bashrc`, so `rex resurrect ...` runs this tool and every other `rex` command is unchanged.

Requirements: macOS, Rex, and `python3` (no other dependencies). Running the installer again updates it. To remove it: `curl -fsSL https://raw.githubusercontent.com/mertdeveci5/rex-resurrect/main/uninstall.sh | sh` (add `-s -- --purge` to also delete your saves).

## Commands

| Command | What it does |
|---|---|
| `rex resurrect save` | Record every agent pane and its conversation |
| `rex resurrect` | Resume every recorded agent and check each one came back |
| `rex resurrect --dry-run` | Show what a restore would do, change nothing |
| `rex resurrect show` | Print the saved panes and their resume commands |
| `rex resurrect --again` | Restore the last save again |
| `rex resurrect --from FILE` | Restore an older save from `~/.local/state/rex-resurrect/history/` |
| `rex resurrect save --force` | Save even though the last save was never restored |

## How a restore works

For each saved pane, `rex resurrect` waits for the shell prompt, types `cd <folder> && <resume command>`, and checks for up to two minutes that the agent is running the saved conversation. It ends with `N of N back`.

- **Lost panes are rebuilt:** as a split in their tab, else a new tab in their session, else a new session with the saved name.
- **Never opened twice:** a conversation already open anywhere, in any pane or any Claude or Pi process, is skipped. Running it twice is safe.
- **Busy panes are left alone:** a pane running something else is reported, with the exact command to run by hand.
- **A save is used once:** after a full restore it moves to `snapshot.restored.json`, so an old save never reopens panes you closed since. If a pane failed, running `rex resurrect` again retries only the panes that aren't back.
- **It never starts or stops a Rex server.**

Launch flags such as `--model` or `--dangerously-skip-permissions` are replayed, and so are the environment variables that choose where an agent keeps its conversations (`CLAUDE_CONFIG_DIR`, `CODEX_HOME`, `PI_CODING_AGENT_DIR`) or which endpoint it uses. Keys and tokens never are.

## How each conversation is found

| Agent | Source, most exact first |
|---|---|
| Claude Code | `~/.claude/sessions/<pid>.json`, which Claude keeps current through `/clear` and `/resume` |
| Codex | The open rollout file whose conversation name matches the pane title Codex sets |
| Pi | A record the bundled Pi extension writes at every session start |

When the exact source is missing, the conversation is worked out by elimination and the save marks it "guessed".

## Restarting Rex for a demo

Quitting the Rex app does not restart anything: the server keeps running in the background with your agents, so there is nothing to resurrect. A server restart (a Mac reboot, a Rex update, or **Restart Server…** in the app) is what ends them.

Known Rex issue: with many agents open, **Restart Server…** can hang on "Connecting to Rex Server… Waiting for the local control API", because the server takes longer to shut down than the app waits. Press Cmd+Q, reopen Rex, then run `rex resurrect`. Avoid `rex server stop` unless you mean to end every session.

## Files

- `~/.local/bin/rex-resurrect`: the tool (one Python file, standard library only)
- `~/.local/state/rex-resurrect/`: `snapshot.json`, `snapshot.restored.json`, and `history/` (the last 50 saves). `REX_RESURRECT_STATE` overrides the folder.
- `~/.local/state/rex-resurrect/pi/`: one record per running Pi process

## License

MIT
