# Installing VibeMastery Toolkit for Codex

This guide installs toolkit skills and Codex multi-agent role configs.

## Prerequisites

- Codex installed
- Git installed

## 1) Clone the toolkit

```bash
git clone https://github.com/vibemastery/toolkit.git ~/.codex/vibemastery-toolkit
```

## 2) Link skills into Codex global skills directory

```bash
mkdir -p ~/.agents/skills
rm -rf ~/.agents/skills/vibemastery-toolkit
ln -s ~/.codex/vibemastery-toolkit/skills ~/.agents/skills/vibemastery-toolkit
```

## 3) Install Codex role config files

Codex multi-agent roles load from `~/.codex/agents/*.toml`.

```bash
mkdir -p ~/.codex/agents
cp -R ~/.codex/vibemastery-toolkit/.codex/agents/. ~/.codex/agents/
```

## 4) Register role definitions in `~/.codex/config.toml`

Copy the snippet from:

`~/.codex/vibemastery-toolkit/.codex/config.roles.example.toml`

and merge it into your `~/.codex/config.toml`.

This enables `multi_agent = true` and registers:

- `laravel-architect`
- `laravel-security-reviewer`
- `pest-tdd-expert`
- `pest-browser-testing`

## 5) Restart Codex

Restart Codex so new skills and roles are discovered.

## 6) Verify

In a new Codex session, ask:

```text
run brainstorming
```

Then verify role-based multi-agent usage:

```text
Spawn one laravel-architect agent to review this Laravel design and summarize recommendations.
```

If this works, Codex role setup is complete.

## Update later

> **Note:** Skills are symlinked, so a `git pull` updates them automatically. However, Codex role config files are _copied_, not symlinked — you must re-copy them after each update.

```bash
cd ~/.codex/vibemastery-toolkit && git pull
cp -R .codex/agents/. ~/.codex/agents/
```

Run both lines together every time you update.
