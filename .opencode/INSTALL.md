# Installing VibeMastery Toolkit for OpenCode

This guide installs toolkit skills globally and installs Laravel validation subagents for OpenCode.

## Prerequisites

- OpenCode installed
- Git installed

## 1) Clone the toolkit

```bash
git clone https://github.com/vibemastery/toolkit.git ~/.config/opencode/vibemastery-toolkit
```

## 2) Link skills into OpenCode global skills directory

```bash
mkdir -p ~/.config/opencode/skills
rm -rf ~/.config/opencode/skills/vibemastery-toolkit
ln -s ~/.config/opencode/vibemastery-toolkit/skills ~/.config/opencode/skills/vibemastery-toolkit
```

## 3) Install OpenCode subagents (markdown agents)

OpenCode discovers markdown agents from `~/.config/opencode/agents/` (global) or `.opencode/agents/` (project).

Global install (recommended):

```bash
mkdir -p ~/.config/opencode/agents
cp -R ~/.config/opencode/vibemastery-toolkit/.opencode/agents/. ~/.config/opencode/agents/
```

Project-only install (optional):

```bash
mkdir -p ./.opencode/agents
cp -R ~/.config/opencode/vibemastery-toolkit/.opencode/agents/. ./.opencode/agents/
```

## 4) Restart OpenCode

Restart OpenCode so the newly linked skills are discovered.

## 5) Verify

In a new OpenCode session, ask:

```text
run brainstorming
```

And verify direct subagent invocation:

```text
@laravel-architect review this design idea
```

If this runs, markdown subagent loading is working.

## Update later

```bash
cd ~/.config/opencode/vibemastery-toolkit
git pull
```
