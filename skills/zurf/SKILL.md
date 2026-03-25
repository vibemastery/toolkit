---
name: zurf
description: "Search the web and fetch website content using the zurf CLI (browserbase-powered). Use when Claude needs to search for information online, fetch a webpage, read documentation from a URL, or gather data from websites. Triggers on: web search, fetch URL, read website, look up online, 'what does [url] say', scrape page, or any task requiring live web content."
---

# Zurf

Search the web and fetch website content via `zurf`, a CLI powered by Browserbase.

## Prerequisites

Before first use, check if zurf is installed by running `which zurf`. If not found, prompt the user to install it: `npm install -g @vibemastery/zurf`

API keys are configured via `zurf init` (supports `--global` and `--local` flags). If zurf commands fail with auth errors, prompt the user to run `zurf init`.

## Commands

### Search

```bash
zurf search "query" --json
```

Returns search results as JSON. Use to find relevant URLs before fetching.

### Fetch

```bash
zurf fetch <url> --json
```

Returns extracted page content as JSON. Output can be large — always run fetches inside a sub-agent.

## Hard Rules

1. **Always use sub-agents for `zurf fetch`**. Fetch output contains full page content that will bloat the main context. Dispatch each fetch to a sub-agent with clear instructions on what to extract and return.
2. **Search before fetch** when the user asks a general question. Use `zurf search` to find relevant URLs first, then fetch the most promising results.
3. **Be specific with sub-agent prompts**. Tell the sub-agent exactly what to extract — do not ask it to "summarize everything."
4. **Run multiple fetches in parallel** when possible. Dispatch one sub-agent per URL.

## Workflow

### User provides a URL

1. Dispatch a sub-agent to run `zurf fetch <url> --json` and extract the requested information.
2. Present the sub-agent's findings.

### User asks a question requiring web research

1. Run `zurf search "query" --json` directly (search results are small enough for the main context).
2. Select the most relevant URLs from results.
3. Dispatch sub-agents in parallel to fetch each URL with specific extraction instructions.
4. Synthesize findings from all sub-agents into a consolidated answer.

## Sub-Agent Prompt Pattern

When dispatching a fetch sub-agent:

```
Fetch the URL {url} by running: zurf fetch {url} --json

Then extract and return ONLY:
{specific information needed}

Do not return raw HTML. Return a concise summary of the requested information.
```
