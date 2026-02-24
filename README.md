# VibeMastery Toolkit

A collection of AI skills for Laravel builders — from first setup to daily development.

Skills work with Claude Code, OpenCode, Codex, and any agent that supports the [skills.sh](https://skills.sh) standard.

---

## Start Here

**New to VibeMastery?** Begin with the setup wizard to create your first project, then use brainstorming whenever you want to build something new.

**Already have a project?** Jump straight to `brainstorming` for new features, or `debug-coach` when something breaks.

The skills follow a natural pipeline:

```
brainstorming → writing-plans → executing-plans
                             └→ subagent-driven-development
```

`brainstorming` shapes your idea and validates the design. `writing-plans` turns that into a step-by-step task list. Then you pick your execution style: `executing-plans` for batch progress in a separate session, or `subagent-driven-development` for task-by-task work in the same session.

`setup-wizard` and `debug-coach` are standalone — use them independently.

---

## Available Skills

| Skill | When to use it |
|---|---|
| [setup-wizard](skills/setup-wizard/) | Starting a brand new Laravel project |
| [debug-coach](skills/debug-coach/) | Something is broken — errors, failed commands, unexpected behavior |
| [brainstorming](skills/brainstorming/) | You have a feature idea and want to think it through before coding |
| [writing-plans](skills/writing-plans/) | You have an approved design and want a step-by-step implementation plan |
| [executing-plans](skills/executing-plans/) | You have a plan and want to execute it in batches with review checkpoints |
| [subagent-driven-development](skills/subagent-driven-development/) | You have a plan and want to execute it task-by-task with spec and quality reviews |

---

## Installation

### Recommended Quick Start

#### Claude Code (Plugin Marketplace)

```bash
/plugin marketplace add vibemastery/toolkit
/plugin install vibemastery-toolkit@vibemastery-marketplace
```

If your environment cannot access marketplace installation, use the detailed Claude Code guide below.

#### Codex

Tell Codex:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/vibemastery/toolkit/main/.codex/INSTALL.md
```

#### OpenCode

Tell OpenCode:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/vibemastery/toolkit/main/.opencode/INSTALL.md
```

OpenCode subagents are defined as markdown files in `.opencode/agents/`.
Codex multi-agent role configs are defined in `.codex/agents/*.toml`.

### skills.sh only (skills, no agents)

Install all skills from this repository:

```bash
npx skills add vibemastery/toolkit --skill '*'
```

Or install one skill at a time:

```bash
npx skills add vibemastery/toolkit/skills/setup-wizard
npx skills add vibemastery/toolkit/skills/debug-coach
npx skills add vibemastery/toolkit/skills/brainstorming
npx skills add vibemastery/toolkit/skills/writing-plans
npx skills add vibemastery/toolkit/skills/executing-plans
npx skills add vibemastery/toolkit/skills/subagent-driven-development
```

Important: `skills.sh` discovers and installs `SKILL.md` skills only. It does not install OpenCode markdown subagents from `.opencode/agents/` or Codex role configs from `.codex/agents/`.

### How to invoke each skill

Once installed, tell your AI tool what you want to do in plain English:

| You want to... | Say this |
|---|---|
| Set up a new project | `run setup wizard` |
| Debug an error | `run debug coach` — then paste your error |
| Plan a new feature | `run brainstorming` — then describe your idea |
| Write an implementation plan | `run writing plans` — then share your approved design |
| Execute a plan in batches | `run executing plans` — then share the plan file path |
| Execute a plan task-by-task | `run subagent-driven-development` — then share the plan file path |

---

## Repo Structure

```
toolkit/
├── .claude-plugin/          ← Claude plugin marketplace/plugin manifests
├── .opencode/
│   ├── INSTALL.md           ← OpenCode install guide
│   └── agents/              ← OpenCode markdown subagents
├── .codex/
│   ├── INSTALL.md           ← Codex install guide
│   ├── agents/              ← Codex multi-agent role config files
│   └── config.roles.example.toml
├── agents/                  ← Shared agent definitions for Claude-style setups
└── skills/
    └── <skill-name>/
        ├── SKILL.md          ← skill instructions (required)
        └── references/       ← templates and reference files
```

Each skill is self-contained under `skills/<skill-name>/`. Adding a new skill means adding a new folder — nothing else changes.

Note: per `skills.sh`, skill discovery is based on `SKILL.md` locations (for example `skills/` or `.agents/skills/`). The top-level `agents/` folder is for reusable specialist agents, not skill discovery.

---

## Acknowledgements

Built on the open `skills.sh` ecosystem and inspired by the Laravel and testing communities that share practical patterns for beginners.

Special thanks to [obra/superpowers](https://github.com/obra/superpowers) for pioneering skill patterns that influenced several workflows in this toolkit.
