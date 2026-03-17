/**
 * Anti-Pattern Browser Detector for Impeccable
 *
 * Drop this script into any page to visually highlight UI anti-patterns.
 * Uses getComputedStyle() and document.styleSheets for accurate detection.
 *
 * Usage: <script src="detect-antipatterns-browser.js"></script>
 * Re-scan: window.impeccableScan()
 */
(function () {
  if (typeof window === 'undefined') return;

  const LABEL_BG = 'oklch(55% 0.25 350)';
  const OUTLINE_COLOR = 'oklch(60% 0.25 350)';

  const SAFE_TAGS = new Set([
    'blockquote', 'nav', 'a', 'input', 'textarea', 'select',
    'pre', 'code', 'span', 'th', 'td', 'tr', 'li', 'label',
    'button', 'hr', 'html', 'head', 'body', 'script', 'style',
    'link', 'meta', 'title', 'br', 'img', 'svg', 'path', 'circle',
    'rect', 'line', 'polyline', 'polygon', 'g', 'defs', 'use',
  ]);

  const OVERUSED_FONTS = new Set([
    'inter', 'roboto', 'open sans', 'lato', 'montserrat', 'arial', 'helvetica',
  ]);

  const GENERIC_FONTS = new Set([
    'serif', 'sans-serif', 'monospace', 'cursive', 'fantasy',
    'system-ui', 'ui-serif', 'ui-sans-serif', 'ui-monospace', 'ui-rounded',
    '-apple-system', 'blinkmacsystemfont', 'segoe ui',
    'inherit', 'initial', 'unset', 'revert',
  ]);

  // -----------------------------------------------------------------------
  // Detection (computed styles)
  // -----------------------------------------------------------------------

  function isNeutralColor(color) {
    if (!color || color === 'transparent') return true;
    const m = color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    if (!m) return true;
    return (Math.max(+m[1], +m[2], +m[3]) - Math.min(+m[1], +m[2], +m[3])) < 30;
  }

  function checkElementBorders(el) {
    const tag = el.tagName.toLowerCase();
    if (SAFE_TAGS.has(tag)) return [];
    const rect = el.getBoundingClientRect();
    if (rect.width < 20 || rect.height < 20) return [];

    const findings = [];
    const style = getComputedStyle(el);
    const sides = ['Top', 'Right', 'Bottom', 'Left'];
    const widths = {}, colors = {};
    for (const s of sides) {
      widths[s] = parseFloat(style[`border${s}Width`]) || 0;
      colors[s] = style[`border${s}Color`] || '';
    }
    const radius = parseFloat(style.borderRadius) || 0;

    for (const side of sides) {
      const w = widths[side];
      if (w < 1 || isNeutralColor(colors[side])) continue;

      const others = sides.filter(s => s !== side);
      const maxOther = Math.max(...others.map(s => widths[s]));
      if (!(w >= 2 && (maxOther <= 1 || w >= maxOther * 2))) continue;

      const sn = side.toLowerCase();
      const isSide = side === 'Left' || side === 'Right';

      if (isSide) {
        if (radius > 0) findings.push({ type: 'side-tab', detail: `border-${sn}: ${w}px + border-radius: ${radius}px` });
        else if (w >= 3) findings.push({ type: 'side-tab', detail: `border-${sn}: ${w}px` });
      } else {
        if (radius > 0 && w >= 2) findings.push({ type: 'border-accent-on-rounded', detail: `border-${sn}: ${w}px + border-radius: ${radius}px` });
      }
    }
    return findings;
  }

  function parseRgb(color) {
    if (!color || color === 'transparent') return null;
    const m = color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/);
    if (!m) return null;
    return { r: +m[1], g: +m[2], b: +m[3], a: m[4] !== undefined ? +m[4] : 1 };
  }

  function relativeLuminance({ r, g, b }) {
    const [rs, gs, bs] = [r / 255, g / 255, b / 255].map(c =>
      c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4
    );
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }

  function contrastRatio(c1, c2) {
    const l1 = relativeLuminance(c1), l2 = relativeLuminance(c2);
    return (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
  }

  function colorToHex(c) {
    return '#' + [c.r, c.g, c.b].map(v => v.toString(16).padStart(2, '0')).join('');
  }

  function hasChroma(c, threshold = 30) {
    return c && (Math.max(c.r, c.g, c.b) - Math.min(c.r, c.g, c.b)) >= threshold;
  }

  function getHue(c) {
    const r = c.r / 255, g = c.g / 255, b = c.b / 255;
    const max = Math.max(r, g, b), min = Math.min(r, g, b);
    if (max === min) return 0;
    const d = max - min;
    let h;
    if (max === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
    else if (max === g) h = ((b - r) / d + 2) / 6;
    else h = ((r - g) / d + 4) / 6;
    return Math.round(h * 360);
  }

  function resolveBackground(el) {
    let current = el;
    while (current && current.nodeType === 1) {
      const bg = parseRgb(getComputedStyle(current).backgroundColor);
      if (bg && bg.a > 0.1) return bg;
      current = current.parentElement;
    }
    return { r: 255, g: 255, b: 255 };
  }

  function checkElementColors(el) {
    const tag = el.tagName.toLowerCase();
    if (SAFE_TAGS.has(tag)) return [];
    const rect = el.getBoundingClientRect();
    if (rect.width < 10 || rect.height < 10) return [];

    const findings = [];
    const style = getComputedStyle(el);
    const textColor = parseRgb(style.color);
    const bgColor = parseRgb(style.backgroundColor);
    const fontSize = parseFloat(style.fontSize) || 16;
    const fontWeight = parseInt(style.fontWeight) || 400;
    const hasDirectText = [...el.childNodes].some(n => n.nodeType === 3 && n.textContent.trim());
    const classList = el.getAttribute('class') || '';

    // --- Pure black background only (#000 bg — #fff and text colors are fine) ---
    if (bgColor && bgColor.a > 0.1 && bgColor.r === 0 && bgColor.g === 0 && bgColor.b === 0) {
      findings.push({ type: 'pure-black-white', detail: '#000 background' });
    }

    if (hasDirectText && textColor) {
      const effectiveBg = resolveBackground(el);

      // --- Gray on colored background ---
      const textLum = relativeLuminance(textColor);
      const isGray = !hasChroma(textColor, 20) && textLum > 0.05 && textLum < 0.85;
      if (isGray && hasChroma(effectiveBg, 40)) {
        findings.push({ type: 'gray-on-color', detail: `text ${colorToHex(textColor)} on bg ${colorToHex(effectiveBg)}` });
      }

      // --- Low contrast ---
      const ratio = contrastRatio(textColor, effectiveBg);
      const isLargeText = fontSize >= 18 || (fontSize >= 14 && fontWeight >= 700) || ['h1','h2','h3'].includes(tag);
      const threshold = isLargeText ? 3.0 : 4.5;
      if (ratio < threshold) {
        findings.push({ type: 'low-contrast', detail: `${ratio.toFixed(1)}:1 (need ${threshold}:1) — ${colorToHex(textColor)} on ${colorToHex(effectiveBg)}` });
      }

      // --- AI palette: purple/violet on headings ---
      if (hasChroma(textColor, 50)) {
        const hue = getHue(textColor);
        if (hue >= 260 && hue <= 310 && (['h1','h2','h3'].includes(tag) || fontSize >= 20)) {
          findings.push({ type: 'ai-color-palette', detail: `Purple text (${colorToHex(textColor)}) on heading` });
        }
      }
    }

    // --- Gradient text ---
    const bgClip = style.webkitBackgroundClip || style.backgroundClip || '';
    if (bgClip === 'text' && (style.backgroundImage || '').includes('gradient')) {
      findings.push({ type: 'gradient-text', detail: 'background-clip: text + gradient' });
    }

    // --- Tailwind class checks ---
    if (classList) {
      const TW_GRAY_TEXT = /\btext-(?:gray|slate|zinc|neutral|stone)-\d+\b/;
      const TW_COLORED_BG = /\bbg-(?:red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d+\b/;

      if (/\bbg-black\b/.test(classList)) findings.push({ type: 'pure-black-white', detail: 'bg-black' });

      const grayMatch = classList.match(TW_GRAY_TEXT);
      const colorBgMatch = classList.match(TW_COLORED_BG);
      if (grayMatch && colorBgMatch) {
        findings.push({ type: 'gray-on-color', detail: `${grayMatch[0]} on ${colorBgMatch[0]}` });
      }

      if (/\bbg-clip-text\b/.test(classList) && /\bbg-gradient-to-/.test(classList)) {
        findings.push({ type: 'gradient-text', detail: 'bg-clip-text + bg-gradient (Tailwind)' });
      }

      const purpleText = classList.match(/\btext-(?:purple|violet|indigo)-\d+\b/);
      if (purpleText && (['h1','h2','h3'].includes(tag) || /\btext-(?:[2-9]xl)\b/.test(classList))) {
        findings.push({ type: 'ai-color-palette', detail: `${purpleText[0]} on heading` });
      }

      if (/\bfrom-(?:purple|violet|indigo)-\d+\b/.test(classList) && /\bto-(?:purple|violet|indigo|blue|cyan|pink|fuchsia)-\d+\b/.test(classList)) {
        findings.push({ type: 'ai-color-palette', detail: 'Purple gradient (Tailwind)' });
      }
    }

    return findings;
  }

  function checkTypography() {
    const findings = [];

    // Collect fonts from stylesheets
    const fonts = new Set();
    const overusedFound = new Set();
    for (const sheet of document.styleSheets) {
      let rules;
      try { rules = sheet.cssRules || sheet.rules; } catch { continue; }
      if (!rules) continue;
      for (const rule of rules) {
        if (rule.type !== 1) continue;
        const ff = rule.style?.fontFamily;
        if (!ff) continue;
        const stack = ff.split(',').map(f => f.trim().replace(/^['"]|['"]$/g, '').toLowerCase());
        const primary = stack.find(f => f && !GENERIC_FONTS.has(f));
        if (primary) {
          fonts.add(primary);
          if (OVERUSED_FONTS.has(primary)) overusedFound.add(primary);
        }
      }
    }

    // Google Fonts links
    const html = document.documentElement.outerHTML;
    const gfRe = /fonts\.googleapis\.com\/css2?\?family=([^&"'\s]+)/gi;
    let m;
    while ((m = gfRe.exec(html)) !== null) {
      for (const f of m[1].split('|').map(f => f.split(':')[0].replace(/\+/g, ' ').toLowerCase())) {
        fonts.add(f);
        if (OVERUSED_FONTS.has(f)) overusedFound.add(f);
      }
    }

    for (const font of overusedFound) {
      findings.push({ type: 'overused-font', detail: `Primary font: ${font}` });
    }

    if (fonts.size === 1 && document.querySelectorAll('*').length > 20) {
      findings.push({ type: 'single-font', detail: `Only font: ${[...fonts][0]}` });
    }

    // Flat type hierarchy
    const sizes = new Set();
    for (const el of document.querySelectorAll('h1,h2,h3,h4,h5,h6,p,span,a,li,td,th,label,button,div')) {
      const fs = parseFloat(getComputedStyle(el).fontSize);
      if (fs > 0 && fs < 200) sizes.add(Math.round(fs * 10) / 10);
    }
    if (sizes.size >= 3) {
      const sorted = [...sizes].sort((a, b) => a - b);
      const ratio = sorted[sorted.length - 1] / sorted[0];
      if (ratio < 2.0) {
        findings.push({ type: 'flat-type-hierarchy', detail: `Sizes: ${sorted.map(s => s + 'px').join(', ')} (ratio ${ratio.toFixed(1)}:1)` });
      }
    }

    return findings;
  }

  // -----------------------------------------------------------------------
  // Layout checks (page-level)
  // -----------------------------------------------------------------------

  function isCardLike(el) {
    const tag = el.tagName.toLowerCase();
    if (SAFE_TAGS.has(tag) || ['input','select','textarea','img','video','canvas','picture'].includes(tag)) return false;
    const style = getComputedStyle(el);
    const cls = el.getAttribute('class') || '';
    const hasShadow = (style.boxShadow && style.boxShadow !== 'none') || /\bshadow(?:-sm|-md|-lg|-xl|-2xl)?\b/.test(cls);
    const hasRadius = parseFloat(style.borderRadius) > 0 || /\brounded(?:-sm|-md|-lg|-xl|-2xl|-full)?\b/.test(cls);
    const hasBg = (style.backgroundColor && style.backgroundColor !== 'rgba(0, 0, 0, 0)') || /\bbg-(?:white|gray-\d+|slate-\d+)\b/.test(cls);
    const hasBorder = /\bborder\b/.test(cls);
    return [hasShadow, hasRadius, hasBg || hasBorder].filter(Boolean).length >= 2;
  }

  function checkLayout() {
    const findings = [];

    // --- Nested cards ---
    const flaggedPairs = new Set();
    for (const el of document.querySelectorAll('*')) {
      if (!isCardLike(el)) continue;
      const tag = el.tagName.toLowerCase();
      const cls = el.getAttribute('class') || '';
      const style = getComputedStyle(el);
      // Exclude dropdowns, modals, tooltips
      if (style.position === 'absolute' || style.position === 'fixed') continue;
      if (/\b(?:dropdown|popover|tooltip|menu|modal|dialog)\b/i.test(cls)) continue;
      // Exclude tiny elements (badges, chips)
      if ((el.textContent?.trim().length || 0) < 20) continue;
      const rect = el.getBoundingClientRect();
      if (rect.width < 50 || rect.height < 30) continue;

      let parent = el.parentElement;
      while (parent) {
        if (isCardLike(parent)) {
          const key = el.tagName + ':' + parent.tagName;
          if (!flaggedPairs.has(key)) {
            flaggedPairs.add(key);
            findings.push({ type: 'nested-cards', detail: `Card inside card`, el });
          }
          break;
        }
        parent = parent.parentElement;
      }
    }

    return findings;
  }

  // -----------------------------------------------------------------------
  // Highlighting
  // -----------------------------------------------------------------------

  const overlays = [];
  const TYPE_LABELS = {
    'side-tab': 'side-tab',
    'border-accent-on-rounded': 'accent+rounded',
    'overused-font': 'overused font',
    'single-font': 'single font',
    'flat-type-hierarchy': 'flat hierarchy',
    'pure-black-white': 'pure #000/#fff',
    'gray-on-color': 'gray on color',
    'low-contrast': 'low contrast',
    'gradient-text': 'gradient text',
    'ai-color-palette': 'AI palette',
    'nested-cards': 'nested cards',
  };

  function highlight(el, findings) {
    const rect = el.getBoundingClientRect();
    const outline = document.createElement('div');
    outline.className = 'impeccable-overlay';
    Object.assign(outline.style, {
      position: 'absolute',
      top: `${rect.top + scrollY - 2}px`,
      left: `${rect.left + scrollX - 2}px`,
      width: `${rect.width + 4}px`,
      height: `${rect.height + 4}px`,
      border: `2px solid ${OUTLINE_COLOR}`,
      borderRadius: '4px',
      pointerEvents: 'none',
      zIndex: '99999',
      boxSizing: 'border-box',
    });

    const label = document.createElement('div');
    label.className = 'impeccable-label';
    label.textContent = findings.map(f => TYPE_LABELS[f.type] || f.type).join(', ');
    Object.assign(label.style, {
      position: 'absolute', top: '-20px', left: '0',
      background: LABEL_BG, color: 'white',
      fontSize: '11px', fontFamily: 'system-ui, sans-serif', fontWeight: '600',
      padding: '2px 8px', borderRadius: '3px', whiteSpace: 'nowrap',
      lineHeight: '16px', letterSpacing: '0.02em',
    });
    outline.appendChild(label);

    const tooltip = document.createElement('div');
    tooltip.className = 'impeccable-tooltip';
    tooltip.innerHTML = findings.map(f => f.detail).join('<br>');
    Object.assign(tooltip.style, {
      position: 'absolute', bottom: '-28px', left: '0',
      background: 'rgba(0,0,0,0.85)', color: '#e5e5e5',
      fontSize: '11px', fontFamily: 'ui-monospace, monospace',
      padding: '4px 8px', borderRadius: '3px', whiteSpace: 'nowrap',
      lineHeight: '16px', display: 'none', zIndex: '100000',
    });
    outline.appendChild(tooltip);

    outline.addEventListener('mouseenter', () => {
      outline.style.pointerEvents = 'auto';
      tooltip.style.display = 'block';
      outline.style.background = 'oklch(60% 0.25 350 / 0.08)';
    });
    outline.addEventListener('mouseleave', () => {
      outline.style.pointerEvents = 'none';
      tooltip.style.display = 'none';
      outline.style.background = 'none';
    });

    document.body.appendChild(outline);
    overlays.push(outline);
  }

  function showPageBanner(findings) {
    if (!findings.length) return;
    const banner = document.createElement('div');
    banner.className = 'impeccable-overlay';
    Object.assign(banner.style, {
      position: 'fixed', top: '0', left: '0', right: '0', zIndex: '100000',
      background: LABEL_BG, color: 'white',
      fontFamily: 'system-ui, sans-serif', fontSize: '13px',
      padding: '8px 16px', display: 'flex', flexWrap: 'wrap',
      gap: '12px', alignItems: 'center', pointerEvents: 'auto',
    });
    for (const f of findings) {
      const tag = document.createElement('span');
      tag.textContent = `${TYPE_LABELS[f.type] || f.type}: ${f.detail}`;
      Object.assign(tag.style, {
        background: 'rgba(255,255,255,0.15)', padding: '2px 8px',
        borderRadius: '3px', fontSize: '12px', fontFamily: 'ui-monospace, monospace',
      });
      banner.appendChild(tag);
    }
    const close = document.createElement('button');
    close.textContent = '\u00d7';
    Object.assign(close.style, {
      marginLeft: 'auto', background: 'none', border: 'none',
      color: 'white', fontSize: '18px', cursor: 'pointer', padding: '0 4px',
    });
    close.addEventListener('click', () => banner.remove());
    banner.appendChild(close);
    document.body.appendChild(banner);
    overlays.push(banner);
  }

  // -----------------------------------------------------------------------
  // Console summary
  // -----------------------------------------------------------------------

  function printSummary(allFindings) {
    if (allFindings.length === 0) {
      console.log('%c[impeccable] No anti-patterns found.', 'color: #22c55e; font-weight: bold');
      return;
    }
    console.group(
      `%c[impeccable] ${allFindings.length} anti-pattern${allFindings.length === 1 ? '' : 's'} found`,
      'color: oklch(60% 0.25 350); font-weight: bold'
    );
    for (const { el, findings } of allFindings) {
      for (const f of findings) {
        console.log(`%c${f.type}%c ${f.detail}`, 'color: oklch(55% 0.25 350); font-weight: bold', 'color: inherit', el);
      }
    }
    console.groupEnd();
  }

  // -----------------------------------------------------------------------
  // Main scan
  // -----------------------------------------------------------------------

  function scan() {
    for (const o of overlays) o.remove();
    overlays.length = 0;

    const allFindings = [];

    // Element-level border checks
    for (const el of document.querySelectorAll('*')) {
      if (el.classList.contains('impeccable-overlay') ||
          el.classList.contains('impeccable-label') ||
          el.classList.contains('impeccable-tooltip')) continue;
      const findings = [...checkElementBorders(el), ...checkElementColors(el)];
      if (findings.length > 0) {
        highlight(el, findings);
        allFindings.push({ el, findings });
      }
    }

    // Page-level typography checks
    const typoFindings = checkTypography();
    if (typoFindings.length > 0) {
      showPageBanner(typoFindings);
      allFindings.push({ el: document.body, findings: typoFindings });
    }

    // Page-level layout checks
    const layoutFindings = checkLayout();
    for (const f of layoutFindings) {
      const el = f.el || document.body;
      delete f.el;
      highlight(el, [f]);
      allFindings.push({ el, findings: [f] });
    }

    printSummary(allFindings);
    return allFindings;
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => setTimeout(scan, 100));
  } else {
    setTimeout(scan, 100);
  }

  window.impeccableScan = scan;
})();
