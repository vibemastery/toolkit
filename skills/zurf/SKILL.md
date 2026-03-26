---
name: zurf
description: "Search the web and fetch website content using the zurf CLI (browserbase-powered). Use when Claude needs to search for information online, fetch a webpage, read documentation from a URL, or gather data from websites. Triggers on: web search, fetch URL, read website, look up online, 'what does [url] say', scrape page, or any task requiring live web content."
---

# Zurf

Search the web and fetch website content via `zurf`, a CLI powered by Browserbase.

## Prerequisites

Before first use, check if zurf is installed by running `which zurf`. If not found, prompt the user to install it: `npm install -g @vibemastery/zurf`

If zurf commands fail with auth errors, prompt the user to run `zurf init`. Use `zurf config which` to debug configuration issues.

## Commands

### Search

```bash
zurf search "query" --json
```

Returns search results as JSON (URLs, titles, snippets). Use to find relevant URLs before fetching.

Options: `--num-results <n>` (1-25, default 10)

### Fetch

```bash
zurf fetch <url> --json
```

Fast, lightweight retrieval of static web pages without launching a browser. Returns extracted page content as JSON. Limited to 1 MB per page. Output can be large — always run fetches inside a sub-agent.

Options: `--html` (return HTML instead of markdown), `--proxies`, `--allow-redirects`, `--allow-insecure-ssl`

### Browse

```bash
zurf browse <url> --json
```

Opens the URL in a cloud Chromium browser via Browserbase, waits for full JavaScript rendering, then returns the content. Use this instead of `fetch` for single-page applications, dynamic/JS-heavy content, or pages that require a real browser. Output can be large — always run browses inside a sub-agent.

Options: `--html` (return HTML instead of markdown)

### Init

```bash
zurf init
```

Saves Browserbase API key and optional Project ID. Supports `--global` and `--local` flags.

### Config

```bash
zurf config which
```

Shows where API credentials are loaded from (without revealing secrets). Useful for debugging auth issues.

## Hard Rules

1. **Always use sub-agents for `zurf fetch` and `zurf browse`**. Their output contains full page content that will bloat the main context. Dispatch each to a sub-agent with clear instructions on what to extract and return.
2. **Search before fetch** when the user asks a general question. Use `zurf search` to find relevant URLs first, then fetch the most promising results.
3. **Use `fetch` by default, `browse` for JS-heavy pages**. Most pages work fine with `fetch`. Use `browse` only when the page is a single-page application, requires JavaScript rendering, or `fetch` returns incomplete content.
4. **Be specific with sub-agent prompts**. Tell the sub-agent exactly what to extract — do not ask it to "summarize everything."
5. **Run multiple fetches/browses in parallel** when possible. Dispatch one sub-agent per URL.

## Workflow

### User provides a URL

1. Dispatch a sub-agent to run `zurf fetch <url> --json` (or `zurf browse <url> --json` for JS-heavy pages) and extract the requested information.
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

For JS-heavy pages, replace `zurf fetch` with `zurf browse` in the sub-agent prompt.
