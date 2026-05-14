# Resume Website Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the terminal-inspired Astro static site shell described in `docs/superpowers/specs/2026-05-13-resume-website-design.md`, with all content as `<<PLACEHOLDER>>` markers, until `scripts/verify.sh` exits 0.

**Architecture:** Astro 5 static site generator. File-based routing with a content collection for projects validated by Zod. Self-hosted JetBrains Mono via `@fontsource-variable`. CSS custom properties for design tokens in a single global stylesheet. Zero JavaScript shipped to the client.

**Tech Stack:** Astro 5.x, Node 20 LTS, `@fontsource-variable/jetbrains-mono`, plain CSS, bash.

---

## File map

Files this plan creates (paths relative to `/home/jared/projects/resume-website/`):

```
.nvmrc
package.json                      (generated, then customized in Task 1)
package-lock.json                 (generated)
astro.config.mjs                  (generated)
tsconfig.json                     (generated)
scripts/verify.sh                 (new, Task 4)
src/styles/global.css             (new, Task 3)
src/content.config.ts             (new, Task 10)
src/content/projects/placeholder.md (new, Task 11)
src/components/Prompt.astro       (new, Task 5)
src/components/Nav.astro          (new, Task 6)
src/components/ProjectCard.astro  (new, Task 12)
src/components/SkillTag.astro     (new, Task 16)
src/layouts/Base.astro            (new, Task 7)
src/layouts/Project.astro         (new, Task 14)
src/pages/index.astro             (new, Task 8)
src/pages/about.astro             (new, Task 9)
src/pages/projects/index.astro    (new, Task 13)
src/pages/projects/[slug].astro   (new, Task 15)
src/pages/resume.astro            (new, Task 17)
src/pages/contact.astro           (new, Task 18)
src/pages/404.astro               (new, Task 19)
```

---

### Task 1: Initialize Astro project + pin Node version

**Files:**
- Create: `.nvmrc`, `package.json`, `astro.config.mjs`, `tsconfig.json`
- Generated: `package-lock.json`, `node_modules/` (from `npm install`)

Avoid `npm create astro` — its interactive prompts would hang a non-TTY Ralph iteration. Build the project files by hand instead; they are short.

- [ ] **Step 1: Pin Node version**

```bash
cd ~/projects/resume-website
echo "20" > .nvmrc
```

- [ ] **Step 2: Write `package.json`**

```json
{
  "name": "resume-website",
  "type": "module",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "dev": "astro dev",
    "start": "astro dev",
    "build": "astro build",
    "preview": "astro preview",
    "astro": "astro"
  },
  "engines": {
    "node": ">=20.0.0"
  },
  "dependencies": {
    "astro": "^5.0.0"
  }
}
```

- [ ] **Step 3: Write `astro.config.mjs`**

```js
// @ts-check
import { defineConfig } from 'astro/config';

export default defineConfig({});
```

- [ ] **Step 4: Write `tsconfig.json`**

```json
{
  "extends": "astro/tsconfigs/strict"
}
```

- [ ] **Step 5: Install dependencies**

```bash
npm install
```

Expected: `npm install` exits 0; `node_modules/` and `package-lock.json` are created. The Astro CLI is now available via `npm run`.

- [ ] **Step 6: Smoke-test the Astro toolchain**

```bash
npm run build
```

Expected: Astro reports `0 page(s) built` (no pages yet) and exits 0. If it exits non-zero, fix the error before continuing — Astro itself is mis-installed.

- [ ] **Step 7: Commit**

```bash
git add .nvmrc package.json package-lock.json astro.config.mjs tsconfig.json
git commit -m "Scaffold Astro project, pin Node 20"
```

---

### Task 2: Install JetBrains Mono variable font

**Files:**
- Modify: `package.json` (Astro adds the dependency)

- [ ] **Step 1: Install the variable font package**

```bash
cd ~/projects/resume-website
npm install @fontsource-variable/jetbrains-mono
```

- [ ] **Step 2: Confirm it landed in node_modules**

```bash
ls node_modules/@fontsource-variable/jetbrains-mono/index.css
```

Expected: prints the path (file exists). `@fontsource-variable/jetbrains-mono` ships the variable-weight `.woff2` plus an `index.css` that declares the `@font-face` rule.

- [ ] **Step 3: Commit**

```bash
git add package.json package-lock.json
git commit -m "Add JetBrains Mono variable font via @fontsource-variable"
```

---

### Task 3: Create the global stylesheet with design tokens

**Files:**
- Create: `src/styles/global.css`

- [ ] **Step 1: Create the stylesheet directory**

```bash
mkdir -p src/styles
```

- [ ] **Step 2: Write `src/styles/global.css`**

```css
/* JetBrains Mono — bundled by Astro via @fontsource-variable.
   Importing here drops the @font-face declaration into the bundled CSS. */
@import '@fontsource-variable/jetbrains-mono';

:root {
  --bg:        #0c0e10;
  --fg:        #d4d4d4;
  --fg-muted:  #8a8a8a;
  --accent:    #7ec699;
  --border:    #1f2226;
  --prompt:    #7ec699;

  --font-mono: 'JetBrains Mono Variable', ui-monospace, 'Cascadia Code', Menlo, monospace;

  --measure:        720px;
  --measure-wide:   880px;

  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 1rem;
  --space-4: 1.5rem;
  --space-5: 2rem;
  --space-6: 3rem;
  --space-7: 4rem;
}

* { box-sizing: border-box; }

html, body {
  margin: 0;
  padding: 0;
  background: var(--bg);
  color: var(--fg);
  font-family: var(--font-mono);
  font-size: 16px;
  line-height: 1.55;
  -webkit-font-smoothing: antialiased;
}

main {
  max-width: var(--measure);
  margin: 0 auto;
  padding: var(--space-6) var(--space-4);
}

main.wide {
  max-width: var(--measure-wide);
}

a {
  color: var(--accent);
  text-decoration: underline;
  text-underline-offset: 3px;
}

a:hover { color: var(--accent); }

a:focus-visible,
button:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 3px;
}

h1, h2, h3, h4 {
  font-weight: 400;
  margin: 0 0 var(--space-3);
  line-height: 1.2;
}

h1 { font-size: 2rem; }
h2 { font-size: 1.375rem; }
h3 { font-size: 1rem; }

.muted   { color: var(--fg-muted); }
.label   { font-size: 0.75rem; color: var(--fg-muted); letter-spacing: 1px; text-transform: uppercase; }
.divider { border-top: 1px solid var(--border); margin: var(--space-5) 0; }

/* The blinking caret — the one and only animation. */
.caret {
  display: inline-block;
  background: var(--accent);
  color: var(--bg);
  width: 0.6em;
  height: 1em;
  vertical-align: text-bottom;
  animation: caret-blink 1s steps(2) infinite;
}
@keyframes caret-blink { 50% { opacity: 0; } }
```

- [ ] **Step 3: Commit**

```bash
git add src/styles/global.css
git commit -m "Add design tokens and base styles in global.css"
```

---

### Task 4: Write `scripts/verify.sh` (the Ralph contract)

**Files:**
- Create: `scripts/verify.sh`

- [ ] **Step 1: Create the script directory**

```bash
mkdir -p scripts
```

- [ ] **Step 2: Write `scripts/verify.sh`**

```bash
#!/usr/bin/env bash
# verify.sh — the "done" check for the resume-website shell.
# Asserts every requirement from
# docs/superpowers/specs/2026-05-13-resume-website-design.md §9.

set -uo pipefail

cd "$(dirname "$0")/.."

red()   { printf '\033[0;31m%s\033[0m' "$*"; }
green() { printf '\033[0;32m%s\033[0m' "$*"; }
ok()   { printf '  %s %s\n' "$(green ✓)" "$*"; }
fail() { printf '  %s %s\n' "$(red ✗)" "$*"; FAILED=1; }

FAILED=0

# 1. npm install resolves cleanly.
if npm install --silent >/dev/null 2>&1; then
    ok "npm install resolves"
else
    fail "npm install failed"
fi

# 2. npm run build exits 0.
if npm run build --silent >/dev/null 2>&1; then
    ok "npm run build exits 0"
else
    fail "npm run build failed (run 'npm run build' to see the error)"
fi

# 3. Each expected page exists in dist/.
for page in \
    "dist/index.html" \
    "dist/about/index.html" \
    "dist/resume/index.html" \
    "dist/projects/index.html" \
    "dist/projects/placeholder/index.html" \
    "dist/contact/index.html" \
    "dist/404.html"; do
    if [[ -f "$page" ]]; then
        ok "page exists: $page"
    else
        fail "page missing: $page"
    fi
done

# 4. JetBrains Mono is referenced in the bundled CSS.
if grep -lqsR 'JetBrains Mono' dist/_astro/*.css 2>/dev/null; then
    ok "bundled CSS references JetBrains Mono"
else
    fail "bundled CSS does not reference JetBrains Mono"
fi

# 5. Every design token is defined in the bundled CSS.
for token in --bg --fg --fg-muted --accent --border --prompt; do
    if grep -qsR -- "$token *:" dist/_astro/*.css 2>/dev/null; then
        ok "token defined: $token"
    else
        fail "token missing: $token"
    fi
done

# 6. Every built page renders the Prompt component (grep class="prompt").
shopt -s globstar nullglob
for page in dist/**/*.html; do
    if ! grep -q 'class="prompt"' "$page"; then
        fail "page missing class=\"prompt\": $page"
    fi
done
shopt -u globstar nullglob
[[ $FAILED -eq 0 ]] && ok "every page contains class=\"prompt\""

# 7. Placeholder marker convention is in use.
for page in \
    "dist/about/index.html" \
    "dist/resume/index.html" \
    "dist/projects/placeholder/index.html" \
    "dist/contact/index.html"; do
    if [[ -f "$page" ]] && grep -q '<<' "$page"; then
        ok "placeholder marker present: $page"
    else
        fail "placeholder marker missing: $page"
    fi
done

# 8. No <script> tags in any built page (zero-JS rule).
shopt -s globstar nullglob
SCRIPT_HITS=0
for page in dist/**/*.html; do
    if grep -q '<script' "$page"; then
        fail "page contains <script> tag: $page"
        SCRIPT_HITS=$((SCRIPT_HITS+1))
    fi
done
shopt -u globstar nullglob
[[ "$SCRIPT_HITS" -eq 0 ]] && ok "no <script> tags in built pages"

# 9. Bundled CSS parses (balanced braces).
for css in dist/_astro/*.css; do
    [[ -f "$css" ]] || continue
    opens=$(tr -cd '{' < "$css" | wc -c)
    closes=$(tr -cd '}' < "$css" | wc -c)
    if [[ "$opens" -eq "$closes" ]]; then
        ok "CSS braces balanced: $(basename "$css")"
    else
        fail "CSS braces unbalanced ($opens vs $closes): $css"
    fi
done

echo
if [[ "$FAILED" -eq 0 ]]; then
    green "verify.sh: ALL CHECKS PASSED"
    echo
    exit 0
else
    red "verify.sh: ONE OR MORE CHECKS FAILED"
    echo
    exit 1
fi
```

- [ ] **Step 3: Make the script executable**

```bash
chmod +x scripts/verify.sh
```

- [ ] **Step 4: Run it — confirm it fails (no pages yet)**

```bash
./scripts/verify.sh
```

Expected: many `✗` lines, final line `verify.sh: ONE OR MORE CHECKS FAILED`, exit 1. This is correct at this point. The remaining tasks will turn the checks green one by one.

- [ ] **Step 5: Commit**

```bash
git add scripts/verify.sh
git commit -m "Add verify.sh — the success-criterion gate"
```

---

### Task 5: Build the `Prompt` component

**Files:**
- Create: `src/components/Prompt.astro`

- [ ] **Step 1: Create the components directory**

```bash
mkdir -p src/components
```

- [ ] **Step 2: Write `src/components/Prompt.astro`**

```astro
---
// Prompt — the terminal-line design primitive used across every page.
// The outermost element MUST carry class="prompt" so scripts/verify.sh
// can grep for it on every built page (see spec §5 and §9 check 6).
interface Props {
  cmd: string;
}
const { cmd } = Astro.props;
---
<div class="prompt">
  <span class="sigil">$</span> <span class="cmd">{cmd}</span>
  <div class="output"><slot /></div>
</div>

<style>
  .prompt {
    margin: 0 0 var(--space-4);
    font-family: var(--font-mono);
  }
  .sigil { color: var(--prompt); }
  .cmd   { color: var(--fg); }
  .output {
    margin: var(--space-2) 0 0;
    color: var(--fg);
    max-width: 56ch;
  }
  .output :global(.muted) { color: var(--fg-muted); }
</style>
```

- [ ] **Step 3: Commit**

```bash
git add src/components/Prompt.astro
git commit -m "Add Prompt component — the terminal-line primitive"
```

---

### Task 6: Build the `Nav` component

**Files:**
- Create: `src/components/Nav.astro`

- [ ] **Step 1: Write `src/components/Nav.astro`**

```astro
---
// Nav — used in the Base layout. Two variants:
//   variant="ls"      — home page: "ls ~" style listing
//   variant="inline"  — inner pages: compact " ~ · about · resume · ... "
interface Props {
  variant?: 'ls' | 'inline';
  current?: string;
}
const { variant = 'inline', current = '' } = Astro.props;

const links = [
  { href: '/',         label: '~',          slug: 'home' },
  { href: '/about',    label: 'about',      slug: 'about' },
  { href: '/resume',   label: 'resume',     slug: 'resume' },
  { href: '/projects', label: 'projects',   slug: 'projects' },
  { href: '/contact',  label: 'contact',    slug: 'contact' },
];
---
{variant === 'ls' ? (
  <nav class="nav-ls">
    <a href="/about"    class="entry">about/</a>
    <a href="/projects" class="entry">projects/</a>
    <a href="/resume"   class="entry">resume.md</a>
    <a href="/contact"  class="entry">contact.txt</a>
  </nav>
) : (
  <nav class="nav-inline">
    {links.map((link, idx) => (
      <>
        <a href={link.href} class={current === link.slug ? 'active' : ''}>{link.label}</a>
        {idx < links.length - 1 && <span class="sep"> · </span>}
      </>
    ))}
  </nav>
)}

<style>
  .nav-ls {
    display: flex;
    gap: var(--space-4);
    flex-wrap: wrap;
    margin: 0 0 var(--space-4);
  }
  .nav-ls .entry { color: var(--accent); }
  .nav-inline {
    margin: 0 0 var(--space-6);
    color: var(--fg-muted);
    font-size: 0.875rem;
    letter-spacing: 0.5px;
  }
  .nav-inline a {
    color: var(--fg-muted);
    text-decoration: none;
  }
  .nav-inline a.active {
    color: var(--fg);
  }
  .nav-inline a:hover { color: var(--fg); }
  .nav-inline .sep { color: var(--border); }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/Nav.astro
git commit -m "Add Nav component (ls + inline variants)"
```

---

### Task 7: Build the `Base` layout

**Files:**
- Create: `src/layouts/Base.astro`

- [ ] **Step 1: Create the layouts directory**

```bash
mkdir -p src/layouts
```

- [ ] **Step 2: Write `src/layouts/Base.astro`**

```astro
---
import '../styles/global.css';
import Nav from '../components/Nav.astro';

interface Props {
  title: string;
  description?: string;
  current?: string;
  navVariant?: 'ls' | 'inline';
  wide?: boolean;
}
const {
  title,
  description = '<<SITE_TAGLINE>>',
  current = '',
  navVariant = 'inline',
  wide = false,
} = Astro.props;
---
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content={description} />
    <title>{title}</title>
  </head>
  <body>
    <main class={wide ? 'wide' : ''}>
      <Nav variant={navVariant} current={current} />
      <slot />
    </main>
  </body>
</html>
```

- [ ] **Step 3: Commit**

```bash
git add src/layouts/Base.astro
git commit -m "Add Base layout"
```

---

### Task 8: Build the home page

**Files:**
- Create: `src/pages/index.astro`

- [ ] **Step 1: Create the pages directory if missing**

```bash
mkdir -p src/pages
```

- [ ] **Step 2: Write `src/pages/index.astro`**

```astro
---
import Base from '../layouts/Base.astro';
import Prompt from '../components/Prompt.astro';
---
<Base title="<<YOUR_NAME>>" current="home" navVariant="ls">

  <Prompt cmd="whoami">
    <<YOUR_NAME>>
  </Prompt>

  <Prompt cmd="cat ~/.bio">
    <<ONE_LINE_TAGLINE>><br />
    <<TWO_LINE_INTRO_PARAGRAPH>>
    <span class="muted">Currently: <<CURRENT_FOCUS>>.</span>
  </Prompt>

  <Prompt cmd="ls ~">
    <a href="/about">about/</a>
    {'   '}
    <a href="/projects">projects/</a>
    {'   '}
    <a href="/resume">resume.md</a>
    {'   '}
    <a href="/contact">contact.txt</a>
  </Prompt>

  <div class="caret-line">
    <span style="color: var(--prompt)">$</span> <span class="caret"></span>
  </div>

</Base>

<style>
  .caret-line {
    margin-top: var(--space-5);
  }
</style>
```

- [ ] **Step 3: Build and verify the home page renders**

```bash
npm run build
test -f dist/index.html && echo "home page built"
```

Expected: prints `home page built`.

- [ ] **Step 4: Commit**

```bash
git add src/pages/index.astro
git commit -m "Add home page with terminal-style hero"
```

---

### Task 9: Build the `/about` page

**Files:**
- Create: `src/pages/about.astro`

- [ ] **Step 1: Write `src/pages/about.astro`**

```astro
---
import Base from '../layouts/Base.astro';
import Prompt from '../components/Prompt.astro';
---
<Base title="about — <<YOUR_NAME>>" current="about">

  <Prompt cmd="cat ~/about.md">
    <h1>About</h1>
    <p><<PARAGRAPH_ABOUT_YOURSELF_AND_BACKGROUND>></p>
    <p><<PARAGRAPH_ABOUT_WHAT_DRIVES_YOU_PROFESSIONALLY>></p>
    <p class="muted"><<OPTIONAL_PERSONAL_TIDBIT_HOBBY_LOCATION>></p>
  </Prompt>

  <div class="divider"></div>

  <Prompt cmd="cat ~/.links">
    <a href="<<GITHUB_URL>>">github</a>{'   '}
    <a href="<<LINKEDIN_URL>>">linkedin</a>{'   '}
    <a href="mailto:<<EMAIL>>">email</a>
  </Prompt>

</Base>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/about.astro
git commit -m "Add /about page"
```

---

### Task 10: Define the projects content collection

**Files:**
- Create: `src/content.config.ts`

- [ ] **Step 1: Write `src/content.config.ts`**

Note for the reader: Astro v5 expects the content config at `src/content.config.ts` (not the v4 location of `src/content/config.ts`). The collection uses a `glob` loader; the v4 `type: 'content'` shorthand is gone.

```ts
import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { glob } from 'astro/loaders';

const projects = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/projects' }),
  schema: z.object({
    title:      z.string(),
    summary:    z.string(),
    stack:      z.array(z.string()),
    status:     z.enum(['shipped', 'wip', 'archived']),
    started:    z.coerce.date(),
    finished:   z.coerce.date().optional(),
    github_url: z.string().url().optional(),
    cover_alt:  z.string().optional(),
  }),
});

export const collections = { projects };
```

- [ ] **Step 2: Commit**

```bash
git add src/content.config.ts
git commit -m "Add projects content collection schema (Zod)"
```

---

### Task 11: Create the placeholder project entry

**Files:**
- Create: `src/content/projects/placeholder.md`

- [ ] **Step 1: Create the content directory**

```bash
mkdir -p src/content/projects
```

- [ ] **Step 2: Write `src/content/projects/placeholder.md`**

```markdown
---
title: "<<PROJECT_TITLE>>"
summary: "<<ONE_LINE_DESCRIPTION>>"
stack: ["<<TECH_1>>", "<<TECH_2>>", "<<TECH_3>>"]
status: wip
started: 2026-01-01
github_url: "https://example.com/<<REPO>>"
cover_alt: "<<ALT_TEXT_DESCRIBING_PROJECT_COVER_IF_ADDED_LATER>>"
---

## What it does

<<TWO_OR_THREE_PARAGRAPHS_DESCRIBING_THE_PROJECT>>

## Why I built it

<<MOTIVATION_AND_PROBLEM_IT_SOLVES>>

## Architecture

<<HIGH_LEVEL_ARCHITECTURE_DIAGRAM_OR_DESCRIPTION>>

## Lessons learned

- <<LESSON_1>>
- <<LESSON_2>>
- <<LESSON_3>>
```

- [ ] **Step 3: Commit**

```bash
git add src/content/projects/placeholder.md
git commit -m "Add placeholder project entry"
```

---

### Task 12: Build the `ProjectCard` component

**Files:**
- Create: `src/components/ProjectCard.astro`

- [ ] **Step 1: Write `src/components/ProjectCard.astro`**

```astro
---
import type { CollectionEntry } from 'astro:content';

interface Props {
  project: CollectionEntry<'projects'>;
}
const { project } = Astro.props;
const { title, summary, stack, status } = project.data;
---
<a href={`/projects/${project.id}`} class="card">
  <div class="card-head">
    <h3>{title}</h3>
    <span class={`status ${status}`}>{status}</span>
  </div>
  <p class="summary">{summary}</p>
  <ul class="stack">
    {stack.map((tech) => <li>{tech}</li>)}
  </ul>
</a>

<style>
  .card {
    display: block;
    border: 1px solid var(--border);
    padding: var(--space-4);
    margin: 0 0 var(--space-4);
    text-decoration: none;
    color: var(--fg);
  }
  .card:hover { border-color: var(--accent); }
  .card-head {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    gap: var(--space-3);
    margin-bottom: var(--space-2);
  }
  .card h3 { margin: 0; color: var(--fg); }
  .status {
    font-size: 0.75rem;
    color: var(--fg-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
  }
  .status.shipped { color: var(--accent); }
  .summary {
    margin: 0 0 var(--space-3);
    color: var(--fg-muted);
  }
  .stack {
    margin: 0;
    padding: 0;
    list-style: none;
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-2);
  }
  .stack li {
    font-size: 0.75rem;
    color: var(--fg-muted);
    border: 1px solid var(--border);
    padding: 2px var(--space-2);
  }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/ProjectCard.astro
git commit -m "Add ProjectCard component"
```

---

### Task 13: Build the `/projects` index page

**Files:**
- Create: `src/pages/projects/index.astro`

- [ ] **Step 1: Create the projects pages directory**

```bash
mkdir -p src/pages/projects
```

- [ ] **Step 2: Write `src/pages/projects/index.astro`**

```astro
---
import { getCollection } from 'astro:content';
import Base from '../../layouts/Base.astro';
import Prompt from '../../components/Prompt.astro';
import ProjectCard from '../../components/ProjectCard.astro';

const projects = await getCollection('projects');
---
<Base title="projects — <<YOUR_NAME>>" current="projects">

  <Prompt cmd="ls -la ~/projects">
    <p class="muted">{projects.length} project{projects.length === 1 ? '' : 's'}. <span><<INTRO_TO_PROJECTS_LIST>></span></p>
  </Prompt>

  <section>
    {projects.map((p) => <ProjectCard project={p} />)}
  </section>

</Base>
```

- [ ] **Step 3: Commit**

```bash
git add src/pages/projects/index.astro
git commit -m "Add /projects index page"
```

---

### Task 14: Build the `Project` layout

**Files:**
- Create: `src/layouts/Project.astro`

- [ ] **Step 1: Write `src/layouts/Project.astro`**

```astro
---
import Base from './Base.astro';
import Prompt from '../components/Prompt.astro';
import type { CollectionEntry } from 'astro:content';

interface Props {
  project: CollectionEntry<'projects'>;
}
const { project } = Astro.props;
const { title, summary, stack, status, started, finished, github_url } = project.data;

const dateFmt = (d?: Date) =>
  d ? d.toISOString().slice(0, 10) : 'present';
---
<Base title={`${title} — <<YOUR_NAME>>`} current="projects">

  <Prompt cmd={`cat ~/projects/${project.id}/README.md`}>
    <h1>{title}</h1>
    <p class="muted">{summary}</p>
    <p class="meta">
      <span class="label">status</span> {status}{'  '}
      <span class="label">started</span> {dateFmt(started)}{'  '}
      <span class="label">finished</span> {dateFmt(finished)}{'  '}
      {github_url && (
        <>
          <span class="label">repo</span> <a href={github_url}>{github_url}</a>
        </>
      )}
    </p>
    <ul class="stack">
      {stack.map((tech) => <li>{tech}</li>)}
    </ul>
  </Prompt>

  <article>
    <slot />
  </article>

</Base>

<style>
  .meta {
    margin: var(--space-2) 0 var(--space-4);
    font-size: 0.875rem;
    color: var(--fg-muted);
  }
  .stack {
    margin: 0 0 var(--space-5);
    padding: 0;
    list-style: none;
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-2);
  }
  .stack li {
    font-size: 0.75rem;
    color: var(--fg-muted);
    border: 1px solid var(--border);
    padding: 2px var(--space-2);
  }
  article :global(h2) {
    margin-top: var(--space-5);
    color: var(--fg);
  }
  article :global(p) { color: var(--fg); }
  article :global(li) { color: var(--fg); }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/layouts/Project.astro
git commit -m "Add Project layout"
```

---

### Task 15: Build the dynamic project page

**Files:**
- Create: `src/pages/projects/[slug].astro`

- [ ] **Step 1: Write `src/pages/projects/[slug].astro`**

Astro v5 uses `getCollection` + `render` for content-collection pages. The slug parameter is `post.id` (the v4 `post.slug` is gone).

```astro
---
import { getCollection, render } from 'astro:content';
import Project from '../../layouts/Project.astro';

export async function getStaticPaths() {
  const projects = await getCollection('projects');
  return projects.map((project) => ({
    params: { slug: project.id },
    props:  { project },
  }));
}

const { project } = Astro.props;
const { Content } = await render(project);
---
<Project project={project}>
  <Content />
</Project>
```

- [ ] **Step 2: Build and confirm the placeholder project page is generated**

```bash
npm run build
test -f dist/projects/placeholder/index.html && echo "project deep-dive built"
```

Expected: prints `project deep-dive built`.

- [ ] **Step 3: Commit**

```bash
git add src/pages/projects/[slug].astro
git commit -m "Add dynamic /projects/[slug] page"
```

---

### Task 16: Build the `SkillTag` component

**Files:**
- Create: `src/components/SkillTag.astro`

- [ ] **Step 1: Write `src/components/SkillTag.astro`**

```astro
---
interface Props {
  name: string;
}
const { name } = Astro.props;
---
<span class="skill">{name}</span>

<style>
  .skill {
    display: inline-block;
    font-size: 0.875rem;
    color: var(--fg);
    border: 1px solid var(--border);
    padding: 2px var(--space-2);
    margin: 0 var(--space-1) var(--space-1) 0;
  }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/SkillTag.astro
git commit -m "Add SkillTag component"
```

---

### Task 17: Build the `/resume` page

**Files:**
- Create: `src/pages/resume.astro`

- [ ] **Step 1: Write `src/pages/resume.astro`**

```astro
---
import Base from '../layouts/Base.astro';
import Prompt from '../components/Prompt.astro';
import SkillTag from '../components/SkillTag.astro';
---
<Base title="resume — <<YOUR_NAME>>" current="resume" wide={true}>

  <Prompt cmd="cat ~/resume.txt">
    <h1><<YOUR_NAME>></h1>
    <p class="muted"><<HEADLINE_ROLE>> · <<CITY_STATE>> · <a href="mailto:<<EMAIL>>"><<EMAIL>></a> · <a href="<<PORTFOLIO_URL>>"><<PORTFOLIO_URL>></a></p>
    <p><a href="/<<RESUME_PDF_FILENAME>>.pdf">Download PDF</a></p>
  </Prompt>

  <section>
    <h2 class="section-h">Experience</h2>

    <div class="entry">
      <div class="entry-head">
        <strong><<JOB_TITLE_1>></strong> · <<COMPANY_1>>
        <span class="muted"><<DATE_RANGE_1>></span>
      </div>
      <ul>
        <li><<BULLET_1_ACHIEVEMENT_OR_RESPONSIBILITY>></li>
        <li><<BULLET_2>></li>
        <li><<BULLET_3>></li>
      </ul>
    </div>

    <div class="entry">
      <div class="entry-head">
        <strong><<JOB_TITLE_2>></strong> · <<COMPANY_2>>
        <span class="muted"><<DATE_RANGE_2>></span>
      </div>
      <ul>
        <li><<BULLET_1>></li>
        <li><<BULLET_2>></li>
      </ul>
    </div>
  </section>

  <div class="divider"></div>

  <section>
    <h2 class="section-h">Skills</h2>
    <p>
      <SkillTag name="<<SKILL_1>>" />
      <SkillTag name="<<SKILL_2>>" />
      <SkillTag name="<<SKILL_3>>" />
      <SkillTag name="<<SKILL_4>>" />
      <SkillTag name="<<SKILL_5>>" />
      <SkillTag name="<<SKILL_6>>" />
    </p>
  </section>

  <div class="divider"></div>

  <section>
    <h2 class="section-h">Education</h2>
    <div class="entry">
      <div class="entry-head">
        <strong><<DEGREE>></strong> · <<INSTITUTION>>
        <span class="muted"><<EDUCATION_DATE_RANGE>></span>
      </div>
      <p><<OPTIONAL_NOTE_ON_HONORS_OR_RELEVANT_COURSEWORK>></p>
    </div>
  </section>

</Base>

<style>
  .section-h {
    color: var(--accent);
    margin-bottom: var(--space-3);
  }
  .entry {
    margin: 0 0 var(--space-4);
  }
  .entry-head {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    gap: var(--space-3);
    flex-wrap: wrap;
    margin-bottom: var(--space-2);
  }
  ul { margin: 0; padding-left: 1.25rem; }
  li { margin-bottom: var(--space-1); }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/resume.astro
git commit -m "Add /resume page"
```

---

### Task 18: Build the `/contact` page

**Files:**
- Create: `src/pages/contact.astro`

- [ ] **Step 1: Write `src/pages/contact.astro`**

```astro
---
import Base from '../layouts/Base.astro';
import Prompt from '../components/Prompt.astro';
---
<Base title="contact — <<YOUR_NAME>>" current="contact">

  <Prompt cmd="cat ~/contact.txt">
    <h1>Contact</h1>
    <p><<ONE_LINE_INVITE_TO_REACH_OUT>></p>

    <p>
      <span class="label">email</span>{' '}
      <a href="mailto:<<EMAIL>>"><<EMAIL>></a>
    </p>
    <p>
      <span class="label">github</span>{' '}
      <a href="<<GITHUB_URL>>"><<GITHUB_HANDLE>></a>
    </p>
    <p>
      <span class="label">linkedin</span>{' '}
      <a href="<<LINKEDIN_URL>>"><<LINKEDIN_HANDLE>></a>
    </p>
  </Prompt>

</Base>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/contact.astro
git commit -m "Add /contact page"
```

---

### Task 19: Build the `404` page

**Files:**
- Create: `src/pages/404.astro`

- [ ] **Step 1: Write `src/pages/404.astro`**

```astro
---
import Base from '../layouts/Base.astro';
import Prompt from '../components/Prompt.astro';
---
<Base title="404 — <<YOUR_NAME>>" current="">

  <Prompt cmd="ls /nowhere">
    <p>ls: cannot access '/nowhere': No such file or directory</p>
    <p class="muted">The page you were looking for does not exist.</p>
    <p><a href="/">cd ~</a></p>
  </Prompt>

</Base>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/404.astro
git commit -m "Add 404 page"
```

---

### Task 20: Run verify.sh — confirm all checks pass

**Files:** none (validation only)

- [ ] **Step 1: Run verify.sh**

```bash
cd ~/projects/resume-website
./scripts/verify.sh
```

Expected output:
- Every check prefixed with `✓`
- Final line: `verify.sh: ALL CHECKS PASSED`
- Exit code 0

- [ ] **Step 2: If any check fails, fix the specific reported file/issue and re-run.**

The script prints exactly what is missing. Common failures and their fixes:
- `page missing class="prompt"` → the named page is rendered without the `<Prompt>` component; add one.
- `token missing: --foo` → `src/styles/global.css` is missing that custom property; re-add per Task 3.
- `placeholder marker missing` → the page does not contain any `<<` token; ensure at least one `<<PLACEHOLDER>>` survived rendering.
- `bundled CSS does not reference JetBrains Mono` → the `@import '@fontsource-variable/jetbrains-mono'` line in `global.css` was removed; restore it.
- `page contains <script> tag` → an Astro view-transitions `<ClientRouter />` import or framework island slipped in; remove it. (No JS in this shell, by design.)

- [ ] **Step 3: Final commit (only if any fix landed in Step 2)**

```bash
git add -u
git commit -m "Final verify.sh pass — all checks green"
```

- [ ] **Step 4: Emit the completion promise**

When `verify.sh` is green and every task above is checked, output the literal string:

`<promise>SHELL COMPLETE</promise>`

This is the signal the Ralph loop watches for. Without it (and below `--max-iterations 25`), the loop continues.

---

## Ralph loop invocation

Once this plan is committed, the Ralph loop that will execute it:

```
/ralph-loop "Read docs/superpowers/plans/2026-05-13-resume-website-implementation.md. Find the first unchecked task (- [ ]) in order. Complete it exactly as written: create or modify the listed files with the exact code shown, run the listed verification commands, then mark the task's checkboxes as done (- [x]) in the plan file itself. Use <<DOUBLE_ANGLE>> placeholders for any authorable content — never invent real bio, work history, or project text. After every task, run bash scripts/verify.sh and read its output. When verify.sh exits 0 AND every checkbox in the plan is checked, emit <promise>SHELL COMPLETE</promise>." --completion-promise "SHELL COMPLETE" --max-iterations 30
```

`--max-iterations 30` gives headroom over the 20 tasks for retries.
