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
