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
| [brainstorming](skills/brainstorming/) | Converts feature ideas into a beginner-friendly, agent-validated high-level plan, then hands off to writing-plans | `npx skills add vibemastery/toolkit/skills/brainstorming` |
| [writing-plans](skills/writing-plans/) | Converts approved designs into beginner-friendly, step-by-step implementation plans before coding | `npx skills add vibemastery/toolkit/skills/writing-plans` |
| [executing-plans](skills/executing-plans/) | Executes implementation plans in batches with verification checkpoints and user feedback loops | `npx skills add vibemastery/toolkit/skills/executing-plans` |
| [subagent-driven-development](skills/subagent-driven-development/) | Executes implementation plans in-session with per-task subagent implementation plus spec and quality reviews | `npx skills add vibemastery/toolkit/skills/subagent-driven-development` |

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
npx skills add vibemastery/toolkit/skills/brainstorming
npx skills add vibemastery/toolkit/skills/writing-plans
npx skills add vibemastery/toolkit/skills/executing-plans
npx skills add vibemastery/toolkit/skills/subagent-driven-development
```

Then invoke it from your AI tool:

```
run the setup wizard

run prompt router

run debug coach

run brainstorming

run writing plans

run executing plans

run subagent-driven-development
```

---

## Repo Structure

```
toolkit/
├── agents/                 ← Laravel design validation agents
└── skills/
    └── <skill-name>/
        ├── SKILL.md          ← skill instructions (required)
        ├── references/       ← templates and reference files
        └── scripts/          ← helper scripts
```

Each skill is self-contained under `skills/<skill-name>/`. Adding a new skill means adding a new folder — nothing else changes.

Note: per `skills.sh`, skill discovery is based on `SKILL.md` locations (for example `skills/` or `.agents/skills/`). The top-level `agents/` folder is for reusable specialist agents, not skill discovery.
