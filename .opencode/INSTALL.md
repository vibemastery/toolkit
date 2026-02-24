# Installing VibeMastery Toolkit for OpenCode

This guide installs all toolkit skills globally and makes Laravel validation agents available per project.

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

## 3) Add Laravel validation agents to your current project

Run this inside the project where you want to use brainstorming/design validation:

```bash
mkdir -p ./agents
cp -R ~/.config/opencode/vibemastery-toolkit/agents/. ./agents/
```

## 4) Restart OpenCode

Restart OpenCode so the newly linked skills are discovered.

## 5) Verify

In a new OpenCode session, ask:

```text
run brainstorming
```

If agents are available, the brainstorming workflow can run Laravel design validation.

## Update later

```bash
cd ~/.config/opencode/vibemastery-toolkit
git pull
```
