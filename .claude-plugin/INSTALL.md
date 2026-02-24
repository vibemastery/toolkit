# Installing VibeMastery Toolkit for Claude Code

This guide installs all toolkit skills globally and makes Laravel validation agents available per project.

## Prerequisites

- Claude Code installed
- Git installed

## Method 1: Plugin Marketplace (recommended)

In Claude Code:

```bash
/plugin marketplace add vibemastery/toolkit
/plugin install vibemastery-toolkit@vibemastery-marketplace
```

If your environment cannot access marketplace installation, use Method 2.

## Method 2: Manual clone + symlink

### 1) Clone the toolkit

```bash
git clone https://github.com/vibemastery/toolkit.git ~/.claude/vibemastery-toolkit
```

### 2) Copy skills into Claude Code global skills directory

```bash
mkdir -p ~/.claude/skills
cp -r ~/.claude/vibemastery-toolkit/skills/. ~/.claude/skills/
```

### 3) Add Laravel validation agents to your current project

Run this inside the project where you want to use brainstorming/design validation:

```bash
mkdir -p ./agents
cp -R ~/.claude/vibemastery-toolkit/agents/. ./agents/
```

## 4) Restart Claude Code

Restart the CLI so new skills are discovered.

## 5) Verify

In a new Claude Code session, ask:

```text
run brainstorming
```

If agents are available, the brainstorming workflow can run Laravel design validation.

## Update later

- Marketplace install: run `/plugin marketplace update vibemastery-marketplace` in Claude Code, then reinstall if needed.
- Manual install:

```bash
cd ~/.claude/vibemastery-toolkit
git pull
cp -r skills/. ~/.claude/skills/
```
