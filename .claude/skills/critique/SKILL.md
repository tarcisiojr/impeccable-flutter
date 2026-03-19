---
name: critique
description: Evaluate design effectiveness from a UX perspective. Assesses visual hierarchy, information architecture, emotional resonance, and overall design quality with actionable feedback.
user-invokable: true
args:
  - name: area
    description: The feature or area to critique (optional)
    required: false
---

## MANDATORY PREPARATION

Use the frontend-design skill -- it contains design principles, anti-patterns, and the **Context Gathering Protocol**. Follow the protocol before proceeding -- if no design context exists yet, you MUST run teach-impeccable first. Additionally gather: what the interface is trying to accomplish.

---

## AUTOMATED ANTI-PATTERN SCAN (First Pass)

Before the manual critique, run the deterministic anti-pattern detector. This catches 25 issues across AI slop tells and general design quality problems with zero false negatives.

### Step 1: Determine the target

Based on the user's request, identify what to scan:
- **Specific file(s)**: Use the file path(s) directly
- **Component/area**: Identify the relevant directory or files
- **URL**: Use the URL directly (the script supports URL scanning via Puppeteer)
- **Whole project / vague target**: Default to the project root, but check scope first

### Step 2: Check scope (directories only)

For directory targets, estimate the number of scannable files first:

```bash
find [target-dir] -type f \( -name "*.html" -o -name "*.htm" -o -name "*.css" -o -name "*.scss" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" -o -name "*.astro" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/.next/*" | wc -l
```

- **< 200 files**: Run full scan (jsdom for HTML, regex for the rest)
- **200-500 files**: Run with `--fast` (regex-only, much faster)
- **> 500 files**: Narrow scope. Scan only the most relevant subdirectory, or ask the user which area to focus on.

### Step 3: Run the scan

```bash
node scripts/detect-antipatterns.mjs --json [--fast] [target]
```

The script exits with code 0 (clean) or 2 (findings). Use `--json` for structured output that's easier to parse.

### Step 4: Interpret results

- If findings are found, they MUST appear in the Anti-Patterns Verdict and Priority Issues
- Group findings by type (e.g., "5 side-tab borders across 3 files, 2 gradient text instances")
- Note which files have the most issues
- Deterministic findings are ground truth. Do not contradict them in the LLM analysis.

---

## BROWSER VISUALIZATION (When Available)

If you have access to browser automation tools that control a real visual browser in front of the user (e.g., `mcp__claude-in-chrome__javascript_tool` and `mcp__claude-in-chrome__navigate`, or Cursor's browser integration), AND the target includes a viewable page (HTML file or URL), enhance the critique with live visual overlays.

### How it works

1. **Navigate to the page**: For URLs, navigate directly. For local HTML files, check if a dev server is running (look at package.json scripts for `dev`, `start`, or `serve`) and use its URL. As a fallback, try `file:///` + absolute path.

2. **Read the browser detection script**:
```bash
cat scripts/detect-antipatterns-browser.js
```

3. **Inject the script** via `javascript_tool` (or equivalent): Pass the entire script content as JavaScript to evaluate in the page context. The script is an IIFE that auto-executes and shows visual overlays.

4. **Interpret**: After injection, the user's browser shows pink/magenta outlines around every problematic element with labels describing the issue. A banner at the top shows page-level findings. The user can hover overlays to see detailed tooltips.

5. **Reference the visuals** in your critique report: "As highlighted in the browser, the card component uses a side-tab border pattern..."

If the target has multiple important views (e.g., a full site), inject the script on 3-5 representative pages.

**If injection fails** (tool not available, CSP error, page won't load), continue with CLI scan results only. Do not let browser issues block the critique.

---

Conduct a holistic design critique, evaluating whether the interface actually works -- not just technically, but as a designed experience. Think like a design director giving feedback.

## Design Critique

Evaluate the interface across these dimensions:

### 1. AI Slop Detection (CRITICAL)

**This is the most important check.** Does this look like every other AI-generated interface from 2024-2025?

Review the design against ALL the **DON'T** guidelines in the frontend-design skill -- they are the fingerprints of AI-generated work. Check for the AI color palette, gradient text, dark mode with glowing accents, glassmorphism, hero metric layouts, identical card grids, generic fonts, and all other tells.

**The test**: If you showed this to someone and said "AI made this," would they believe you immediately? If yes, that's the problem.

### 2. Visual Hierarchy
- Does the eye flow to the most important element first?
- Is there a clear primary action? Can you spot it in 2 seconds?
- Do size, color, and position communicate importance correctly?
- Is there visual competition between elements that should have different weights?

### 3. Information Architecture
- Is the structure intuitive? Would a new user understand the organization?
- Is related content grouped logically?
- Are there too many choices at once? (cognitive overload)
- Is the navigation clear and predictable?

### 4. Emotional Resonance
- What emotion does this interface evoke? Is that intentional?
- Does it match the brand personality?
- Does it feel trustworthy, approachable, premium, playful -- whatever it should feel?
- Would the target user feel "this is for me"?

### 5. Discoverability & Affordance
- Are interactive elements obviously interactive?
- Would a user know what to do without instructions?
- Are hover/focus states providing useful feedback?
- Are there hidden features that should be more visible?

### 6. Composition & Balance
- Does the layout feel balanced or uncomfortably weighted?
- Is whitespace used intentionally or just leftover?
- Is there visual rhythm in spacing and repetition?
- Does asymmetry feel designed or accidental?

### 7. Typography as Communication
- Does the type hierarchy clearly signal what to read first, second, third?
- Is body text comfortable to read? (line length, spacing, size)
- Do font choices reinforce the brand/tone?
- Is there enough contrast between heading levels?

### 8. Color with Purpose
- Is color used to communicate, not just decorate?
- Does the palette feel cohesive?
- Are accent colors drawing attention to the right things?
- Does it work for colorblind users? (not just technically -- does meaning still come through?)

### 9. States & Edge Cases
- Empty states: Do they guide users toward action, or just say "nothing here"?
- Loading states: Do they reduce perceived wait time?
- Error states: Are they helpful and non-blaming?
- Success states: Do they confirm and guide next steps?

### 10. Microcopy & Voice
- Is the writing clear and concise?
- Does it sound like a human (the right human for this brand)?
- Are labels and buttons unambiguous?
- Does error copy help users fix the problem?

## Generate Critique Report

Structure your feedback as a design director would:

### Anti-Patterns Verdict

**Start here.** Does this look AI-generated?

**Deterministic scan**: Summarize what the automated detector found, with counts and file locations. These are confirmed issues. Do not dispute them.

**Visual overlays** (if browser was used): Reference what the user can see highlighted in their browser.

**LLM assessment**: Your own evaluation of AI slop tells beyond what the detector checks. The detector covers 25 specific patterns; your assessment should cover everything else: overall aesthetic feel, layout sameness, generic composition, missed opportunities for personality.

### Overall Impression
A brief gut reaction -- what works, what doesn't, and the single biggest opportunity.

### What's Working
Highlight 2-3 things done well. Be specific about why they work.

### Priority Issues
The 3-5 most impactful design problems, ordered by importance:

For each issue:
- **What**: Name the problem clearly
- **Why it matters**: How this hurts users or undermines goals
- **Fix**: What to do about it (be concrete)
- **Command**: Which command to use (prefer: /animate, /quieter, /optimize, /adapt, /clarify, /distill, /delight, /onboard, /normalize, /audit, /harden, /polish, /extract, /bolder, /arrange, /typeset, /critique, /colorize, /overdrive -- or other installed skills you're sure exist)

### Minor Observations
Quick notes on smaller issues worth addressing.

### Questions to Consider
Provocative questions that might unlock better solutions:
- "What if the primary action were more prominent?"
- "Does this need to feel this complex?"
- "What would a confident version of this look like?"

**Remember**:
- Be direct -- vague feedback wastes everyone's time
- Be specific -- "the submit button" not "some elements"
- Say what's wrong AND why it matters to users
- Give concrete suggestions, not just "consider exploring..."
- Prioritize ruthlessly -- if everything is important, nothing is
- Don't soften criticism -- developers need honest feedback to ship great design