# Claude Code Statusline

A tiny status line for Claude Code that tells you what model you're on, where you are, and how much context you've burned through, before you find out the hard way.

![prompt_example](./res/prompt_example.png)

## What you get

```
Model:    [Opus 5]
Project:  your_project (main)
Context:  ████░░░░░░ 42%
Tokens:   38.1k (31.5k in / 6.6k out)
Time:     12m 07s
```

- **Context bar** that goes green → yellow (70%) → red (90%), so you can panic on schedule
- **Git branch** of the current project, in case you forgot again
- **Token counts** split in/out
- **Session timer**, plus an optional cost readout (commented out at the bottom of `statusline.sh` - uncomment if you want to know)

## Install

Requires `jq`.

1. Copy `statusline.sh` to `~/.claude/`
2. Add the config from `settings.json` to your `~/.claude/settings.json`
3. Restart the Claude Code CLI

That's it. Enjoy your new tiny dashboard.
