# Sai docs repository instructions

## Repository purpose

This repository is a public Markdown mirror for Sai documentation. It exists
so people can read the source, refer to specific files in GitHub issues, and
report corrections.

## Canonical source

The canonical source is in the Sai Web repository at
`docs-app/src/content/`.

- `content/docs/` mirrors published documentation pages.
- `content/blog/` mirrors published blog posts.

The mirrored files are not the place to make content edits. Update the source
in Sai Web and refresh this snapshot when the public copy changes.

## Working with the mirror

Keep the Markdown content intact when refreshing it. Do not rewrite links,
frontmatter, or formatting just to make it fit another documentation system.
Files marked `draft: true` do not belong in the public snapshot.

Use GitHub issues for questions, corrections, and requests about the public
content.

## Legacy files

The older documentation tree outside `content/` is retained during the mirror
transition. Treat it as legacy material unless a task explicitly asks you to
update it.
