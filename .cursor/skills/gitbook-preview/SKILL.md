---
name: gitbook-preview
description: Preview the Sai docs GitBook-style Markdown locally with Docsify. Use when editing Markdown docs in sai-docs, checking rendered content, or running the local docs preview.
---

# GitBook Preview

Use this repo-local workflow when editing Markdown docs and you need a quick local preview without adding package scripts or dependency files.

## Command

From the repo root:

```bash
just gitbook-preview
```

Open `http://localhost:4000/`.

## Details

- `just gitbook-preview` runs `bunx --bun docsify-cli@4.4.4 serve . -p 4000 -i README.md`.
- `docsify-cli@4.4.4` is the version confirmed to serve this repo's `README.md` preview.
- `-i README.md` is required because this repo does not have a checked-in `index.html`.
- This is a lightweight preview for Markdown editing. GitBook-specific blocks and production rendering are still handled by GitBook.

## Setup

If Bun is missing, run:

```bash
just i-bun
```

The recipe installs the pinned Bun version used by this repo's preview workflow.
