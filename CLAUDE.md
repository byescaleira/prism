# Prism — Session Rules

## MANDATORY: Read `.prism/` Before Any Work
Every session MUST read `.prism/profile.md` and the relevant rules before starting work.
- Code changes → read `.prism/rules/swift.md`, `.prism/rules/architecture.md`
- Git operations → read `.prism/rules/git.md`
- New features → read `.prism/trackers/roadmap.md` to understand current phase
- PRs → read `.prism/rules/review.md`
- New module/component/middleware → read matching `.prism/skills/` file
- Track progress in `.prism/trackers/roadmap.md` and `.prism/trackers/tech-debt.md`

## Quick Reference
- **Rules**: `.prism/rules/` — swift, git, testing, naming, architecture, review
- **Skills**: `.prism/skills/` — new-module, new-component, new-middleware
- **Patterns**: `.prism/patterns/` — error-handling, concurrency, di
- **Templates**: `.prism/templates/` — store.swift, endpoint.swift, middleware.swift
- **Trackers**: `.prism/trackers/` — roadmap, tech-debt, changelog-next

---

# Web Engineering & Design Skill (Elite Standards)

## 1. Documentation-First (Inspirado em MDN/Stripe)
- **Self-Documenting Code**: Todo componente deve ter comentários JSDoc explicando props e comportamentos complexos.
- **Explain the "Why"**: Ao criar uma solução, explique brevemente por que escolheu essa abordagem técnica (ex: "Usei debounce aqui para evitar excesso de re-renders").
- **Clear Examples**: Sempre forneça um exemplo de uso prático para novos componentes criados.

## 2. Visual Excellence (Inspirado em Stripe/Tailwind)
- **Fluid UI**: Implemente tipografia e espaçamento fluidos (utilize `clamp()` ou funções do Tailwind v4).
- **Stripe Layout**: Para dashboards, utilize o padrão de 3 colunas e hierarquia visual clara através de sombras (box-shadow) e bordas sutis.
- **Refined Transitions**: Use animações de 150ms-300ms com `cubic-bezier` para interações (hover, active, focus).

## 3. Technical Mastery (Inspirado em React/Next.js)
- **Performance**: Priorize Server Components (RSC) por padrão. Minimize o uso de `use client`.
- **Accessibility (A11y)**: O código deve ser navegável por teclado. Use `aria-label`, `roles` corretos e foco visível (`focus-visible`).
- **Semantic HTML**: Nunca use `div` onde um `main`, `section`, `article` ou `button` seria mais apropriado.

## 4. Development Workflow
- **Searchability**: O código deve ser organizado para ser fácil de encontrar (nomenclatura semântica de arquivos).
- **Error Handling**: Implemente estados de Erro e Loading (Skeletons) para toda requisição assíncrona.
