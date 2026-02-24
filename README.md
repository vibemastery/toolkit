# VibeMastery Toolkit

A collection of AI skills for Laravel builders — from first setup to daily development.

Skills work with Claude Code, OpenCode, Codex, and any agent that supports the [skills.sh](https://skills.sh) standard.

---

## Available Skills

| Skill | What It Does | Install |
|---|---|---|
| [setup-wizard](skills/setup-wizard/) | Sets up a fresh Laravel project with Inertia + React, Pest, optional auth and admin panel | `npx skills add vibemastery/toolkit/skills/setup-wizard` |
| [prompt-router](skills/prompt-router/) | Routes learners to the best prompt/skill based on what they are building right now | `npx skills add vibemastery/toolkit/skills/prompt-router` |
| [debug-coach](skills/debug-coach/) | Turns Laravel errors into plain English and guides root-cause-first fixes | `npx skills add vibemastery/toolkit/skills/debug-coach` |

---

## Usage

Install a skill into your project:

```bash
npx skills add vibemastery/toolkit/skills/setup-wizard
```

Or install another skill directly:

```bash
npx skills add vibemastery/toolkit/skills/prompt-router
npx skills add vibemastery/toolkit/skills/debug-coach
```

Then invoke it from your AI tool:

```
run the setup wizard

run prompt router

run debug coach
```

---

## Repo Structure

```
toolkit/
└── skills/
    └── <skill-name>/
        ├── SKILL.md          ← skill instructions (required)
        ├── references/       ← templates and reference files
        └── scripts/          ← helper scripts
```

Each skill is self-contained under `skills/<skill-name>/`. Adding a new skill means adding a new folder — nothing else changes.
