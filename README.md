# VibeMastery Toolkit

A collection of AI skills for Laravel builders — from first setup to daily development.

Skills work with Claude Code, OpenCode, Codex, and any agent that supports the [skills.sh](https://skills.sh) standard.

---

## Available Skills

| Skill | What It Does | Install |
|---|---|---|
| [setup-wizard](skills/setup-wizard/) | Sets up a fresh Laravel project with Inertia + React, Pest, optional auth and admin panel | `npx skills add vibemastery/toolkit/skills/setup-wizard` |

---

## Usage

Install a skill into your project:

```bash
npx skills add vibemastery/toolkit/skills/setup-wizard
```

Then invoke it from your AI tool:

```
run the setup wizard
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
