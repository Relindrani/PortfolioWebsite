# Brandon Bixler — Portfolio

This repository contains the source code for my personal portfolio website, built with **Astro** and focused on presenting professional experience, system design thinking, and architectural decision-making.

The site is intentionally designed to be fast, minimal, and content-driven, with an emphasis on clarity over visual noise.

---

## Purpose

This portfolio serves three primary goals:

- Present professional experience in a clear, scannable format
- Showcase architectural thinking through the **Helios** project overview
- Demonstrate frontend craftsmanship without unnecessary framework complexity

Rather than acting as a generic showcase, the site is structured to reflect how I approach real-world systems: clear boundaries, deliberate tradeoffs, and maintainable design.

---

## Technology Stack

- **Astro** — static-first framework for performance and content clarity
- **Vanilla CSS** — custom styling without UI frameworks
- **Modern HTML semantics** — accessibility and maintainability
- **Minimal client-side JavaScript** — animations and progressive enhancement only

No heavy frontend frameworks are used by design.

---

## Site Structure

```
src/
├─ layouts/
│ └─ BaseLayout.astro # Global layout (header, footer, loader)
├─ components/
│ ├─ Header.astro
│ ├─ Footer.astro
│ └─ UI components
├─ pages/
│ ├─ index.astro # Overview
│ ├─ experience.astro # Professional experience timeline
│ ├─ helios.astro # System architecture & project overview
│ └─ contact.astro
├─ styles/
│ └─ globals.css
└─ public/
└─ diagrams/ # Architecture SVGs
```

Each page is authored as a standalone document while sharing a common layout and design system.

---

## Design Philosophy

- **Content first**: Visual design supports the narrative, not the other way around
- **Progressive enhancement**: Animations and motion enhance, never block
- **Explicit structure**: Clear sectioning, consistent spacing, predictable layout
- **Production mindset**: Decisions reflect real-world constraints, not demos

Animations are intentionally subtle and scroll-based to guide attention without distraction.

---

## Helios Project

The **Helios** section is a conceptual system design project focused on:

- Event-driven provisioning workflows
- Deterministic orchestration
- Clear service boundaries
- Operational visibility and correctness

Helios is not a commercial product — it exists as a technical exploration and architectural showcase.  
Detailed technical documentation and implementation notes live alongside the project as it evolves.

---

## Local Development

```bash
npm install
npm run dev
```

Astro will start a local development server with hot reloading.

---

## Deployment

The site is designed to be statically deployed and works well on platforms such as:

Netlify

Vercel

Cloudflare Pages

No server-side rendering is required.

---

## License

This project is licensed under the MIT License.

Feel free to reference patterns or structure, but please do not reuse content or branding as-is.
