# Resume Website — Design Spec

**Date:** 2026-05-13
**Status:** Approved (brainstorming complete; ready for implementation planning)
**Project:** `~/projects/resume-website`

---

## 1. Purpose and audience

A static portfolio + resume website. Job-hunting tool first, project showcase second. The same URL must work for two reader types:

- **Recruiters / HR** — scan the resume page in 10 seconds and pass to a hiring team.
- **Engineers / hiring managers** — drill into individual project deep-dives for technical depth.

Both audiences land well by default: `/resume` is the recruiter-scan page; `/projects/<slug>` is the engineer drill-down page; each must work standalone if shared as a single URL.

## 2. Scope

- Multi-page static site with dedicated project deep-dive pages.
- All content shipped as `<<DOUBLE_ANGLE_PLACEHOLDER>>` markers. The author fills real content in by hand later. No real bio, work history, or project text is generated during the build.
- One project placeholder; the author copies it to add more.

**Out of scope (for the initial build):**

- Real content of any kind (resume, projects, contact info).
- Custom domain, TLS, deployment pipeline.
- Blog, RSS, comments, analytics.
- Dark/light mode toggle — site is dark-only by design.
- Client-side JavaScript of any kind, including framework islands.
- Lighthouse-score gates, axe-core a11y audits, Playwright visual regression.

## 3. Site structure (page map)

```
/                    Home          — terminal-style hero, "ls" navigation, currently-doing footer
/about               About         — bio, longer-form intro, contact links
/resume              Resume        — work history, skills, education, downloadable PDF link
/projects            Projects index — grid of project cards (1 placeholder)
/projects/<slug>     Project page  — screenshots/diagrams, what it does, stack, lessons
/contact             Contact       — email + social links (mailto only, no form)
404                  Not found     — terminal-styled
```

All pages share a layout with the same header. Header style varies by context:

- **Home:** "ls ~"-style listing as the primary navigation (`work/  projects/  resume.pdf  contact.txt`).
- **Inner pages:** plain inline text nav (`~ · about · resume · projects · contact`) with the current page highlighted.

## 4. Stack

**Astro**, latest stable. Chosen for:

- File-based routing matches the multi-page structure naturally.
- Layout components avoid header/nav duplication.
- Content collections + Zod schema enforce project frontmatter shape.
- Dynamic routes (`projects/[slug].astro`) generate one page per markdown file with no per-project code changes.
- Zero JavaScript shipped by default — fits the terminal aesthetic and AWS-static deployment.

Bootstrap with `npm create astro@latest -- --template minimal`. The marketing/blog template is wrong for this site.

**Toolchain pinning:**

- `.nvmrc` pinned to Node 20 LTS.
- `package.json` `engines.node` matches.
- `package-lock.json` committed.

## 5. File / component architecture

```
src/
├── layouts/
│   ├── Base.astro          — HTML shell, font loading, nav, shared <head>
│   └── Project.astro       — Extends Base; wraps project deep-dive content
├── components/
│   ├── Nav.astro           — Top nav; prop variant="ls" (home) | "inline" (inner)
│   ├── Prompt.astro        — The "$ cmd / output" terminal primitive
│   ├── ProjectCard.astro   — Used on /projects index
│   └── SkillTag.astro      — Pill-style label for resume skills
├── pages/
│   ├── index.astro         — /
│   ├── about.astro         — /about
│   ├── resume.astro        — /resume
│   ├── contact.astro       — /contact
│   ├── projects/
│   │   ├── index.astro     — /projects (reads collection, renders cards)
│   │   └── [slug].astro    — /projects/<slug> (dynamic from collection)
│   └── 404.astro
├── content/
│   ├── projects/
│   │   └── placeholder.md  — Seed project; frontmatter + body
│   └── config.ts           — Zod schema for the collection
├── styles/
│   └── global.css          — CSS custom properties + base resets
└── assets/
    └── fonts/              — Self-hosted JetBrains Mono woff2
```

**The `Prompt` component is the design primitive.** Every page leads with one. On home: `$ whoami`, `$ cat ~/.bio`, `$ ls ~`. On `/about`: `$ cat ~/about.md`. On `/resume`: `$ cat ~/resume.txt`. This gives every page a consistent visual rhythm.

## 6. Content model

`src/content/config.ts` schema for the `projects` collection:

```ts
import { defineCollection, z } from 'astro:content';

const projects = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    summary: z.string(),
    stack: z.array(z.string()),
    status: z.enum(['shipped', 'wip', 'archived']),
    started: z.date(),
    finished: z.date().optional(),
    github_url: z.string().url().optional(),
    cover_alt: z.string().optional(),
  }),
});

export const collections = { projects };
```

`src/content/projects/placeholder.md`:

```markdown
---
title: "<<PROJECT_TITLE>>"
summary: "<<ONE_LINE_DESCRIPTION>>"
stack: ["<<TECH_1>>", "<<TECH_2>>"]
status: wip
started: 2026-01-01
github_url: "https://example.com/<<REPO>>"
---

## What it does

<<TWO_OR_THREE_PARAGRAPHS_DESCRIBING_THE_PROJECT>>

## Why I built it

<<MOTIVATION>>

## Lessons learned

<<LESSONS>>
```

**Placeholder convention:** every authorable text is wrapped in `<<DOUBLE_ANGLES>>`. The expectation is that `grep -r '<<' src/ content/` after the build finds every blank slot so the author can sweep through them. The `/resume` page is hard-coded as a single `.astro` page (work history, skills, education sections inline) with the same marker convention. Resumes don't need a CMS.

## 7. Visual design system

Terminal-inspired, refined. Mono everywhere, soft contrast, one accent color, one animation.

**Color tokens** (defined as CSS custom properties on `:root` in `global.css`):

| Token         | Value     | Purpose                                          |
| ------------- | --------- | ------------------------------------------------ |
| `--bg`        | `#0c0e10` | Page background. Dark cool gray, not pure black. |
| `--fg`        | `#d4d4d4` | Body text. Warm off-white.                       |
| `--fg-muted`  | `#8a8a8a` | Secondary text, metadata, captions.              |
| `--accent`    | `#7ec699` | Prompt `$`, links, currently-active nav item.    |
| `--border`    | `#1f2226` | Dividers, subtle outlines.                       |
| `--prompt`    | `#7ec699` | Alias of `--accent` for semantic clarity.        |

All foreground/background combinations must meet WCAG AA contrast.

**Typography:**

- Family: **JetBrains Mono Variable**, self-hosted as `.woff2` in `src/assets/fonts/`. No CDN fonts (offline-clean, no third-party requests, no FOUT).
- Stack: `'JetBrains Mono', ui-monospace, 'Cascadia Code', Menlo, monospace`.
- Line-height: `1.55` for body, `1.2` for headings.
- Type scale (rem): `0.75 / 0.875 / 1 / 1.375 / 2`.
- Heading hierarchy is conveyed by size and color, not by typeface or weight changes.

**Layout:**

- Max content width: `720px` for most pages; `880px` for `/resume`.
- Single column on all viewports (mono reads poorly in multi-column).
- Generous vertical spacing — `1rem / 1.5rem / 2rem / 3rem / 4rem` scale.

**Motion:**

- One animation: the blinking caret `_` after the prompt on the home page.
- No hover transitions, no scroll-triggered reveals, no skeleton loaders, no page transitions.

**Interactive states:**

- Links: underlined `--accent`; same color on hover (no transition).
- Focus: `2px` solid `--accent` outline, `3px` offset.

## 8. Build and deploy

**Scripts** (provided by Astro template, unmodified):

- `npm run dev` — local hot-reload at `localhost:4321`.
- `npm run build` — emits `dist/` static site.
- `npm run preview` — serves `dist/` locally for verification.

**Build output structure (`dist/`):**

```
dist/
├── index.html
├── about/index.html
├── resume/index.html
├── projects/index.html
├── projects/placeholder/index.html
├── contact/index.html
├── 404.html
├── _astro/<hash>.css       (hashed CSS bundles)
└── fonts/JetBrainsMono-*.woff2
```

**Deployment target:** AWS, decided later. The build output is plain static so both AWS S3 + CloudFront and AWS Amplify work without code changes. No deployment pipeline is part of this build.

## 9. Testing and Ralph success criterion

`scripts/verify.sh` is the single source of truth for "done." Ralph runs this on every iteration; only when it exits 0 does Ralph emit the completion promise.

**`scripts/verify.sh` asserts:**

1. `npm install --silent` exits 0 (lockfile resolves).
2. `npm run build` exits 0 (Astro builds cleanly, no template errors).
3. Each expected output file exists in `dist/`:
   - `index.html`
   - `about/index.html`
   - `resume/index.html`
   - `projects/index.html`
   - `projects/placeholder/index.html`
   - `contact/index.html`
   - `404.html`
4. Every output page references `JetBrains Mono` (via `@font-face` in the bundled CSS or a `<link>` tag).
5. `global.css` (or its built form in `dist/_astro/*.css`) defines every design token: `--bg`, `--fg`, `--fg-muted`, `--accent`, `--border`, `--prompt`.
6. Every page renders the `Prompt` component (grep `dist/**/*.html` for the prompt's CSS class — e.g., `class="prompt"` or `class="prompt-line"`).
7. The placeholder marker convention is in use: each of `about/index.html`, `resume/index.html`, `projects/placeholder/index.html`, `contact/index.html` contains at least one `<<` token.
8. No `<script>` tags appear in any built page (zero-JS rule).
9. `dist/_astro/*.css` parses (cheap brace-balance check).

Each failed check prints what's wrong; the script returns non-zero.

**Ralph loop contract** (the prompt and flags for `/ralph-loop`):

- **Goal:** Build the Astro shell per this spec at `docs/superpowers/specs/2026-05-13-resume-website-design.md`.
- **Constraint:** Use `<<DOUBLE_ANGLE>>` placeholders for every piece of content. Never invent real bio, work history, or project text.
- **Verification:** After every significant change, run `bash scripts/verify.sh`.
- **Stop condition:** When `verify.sh` exits 0, emit the literal string `<promise>SHELL COMPLETE</promise>`.
- **Loop flags:** `--completion-promise "SHELL COMPLETE" --max-iterations 25`.

The `--max-iterations 25` is the safety net; if verify.sh somehow never passes, the loop bounds before it spirals.
