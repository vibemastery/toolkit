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

### 2) Link skills into Claude Code global skills directory

```bash
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/vibemastery-toolkit
ln -s ~/.claude/vibemastery-toolkit/skills ~/.claude/skills/vibemastery-toolkit
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

- Marketplace install: run plugin update commands in Claude Code.
- Manual install:

```bash
cd ~/.claude/vibemastery-toolkit
git pull
```
