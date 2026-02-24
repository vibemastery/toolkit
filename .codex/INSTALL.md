# Installing VibeMastery Toolkit for Codex

This guide installs all toolkit skills globally and makes Laravel validation agents available per project.

## Prerequisites

- Codex installed
- Git installed

## 1) Clone the toolkit

```bash
git clone https://github.com/vibemastery/toolkit.git ~/.codex/vibemastery-toolkit
```

## 2) Link skills into Codex global skills directory

```bash
mkdir -p ~/.codex/skills
rm -rf ~/.codex/skills/vibemastery-toolkit
ln -s ~/.codex/vibemastery-toolkit/skills ~/.codex/skills/vibemastery-toolkit
```

## 3) Add Laravel validation agents to your current project

Run this inside the project where you want to use brainstorming/design validation:

```bash
mkdir -p ./agents
cp -R ~/.codex/vibemastery-toolkit/agents/. ./agents/
```

## 4) Restart Codex

Restart Codex so the newly linked skills are discovered.

## 5) Verify

In a new Codex session, ask:

```text
run brainstorming
```

If agents are available, the brainstorming workflow can run Laravel design validation.

## Update later

```bash
cd ~/.codex/vibemastery-toolkit
git pull
```
