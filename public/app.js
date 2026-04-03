import {
	initGlassTerminal,
	renderTerminalLayout,
} from "./js/components/glass-terminal.js";
import { initLensEffect } from "./js/components/lens.js";
import { initFrameworkViz } from "./js/components/framework-viz.js";
import { initScrollReveal } from "./js/utils/reveal.js";
import { initAnchorScroll, initHashTracking } from "./js/utils/scroll.js";
import { initSectionNav } from "./js/components/section-nav.js";
import { initFoundationGrid } from "./js/components/foundation-grid.js";

// ============================================
// STATE
// ============================================

let allCommands = [];

// ============================================
// CONTENT LOADING
// ============================================

function escapeHtml(value) {
	if (typeof value !== "string") return "";
	return value
		.replaceAll("&", "&amp;")
		.replaceAll("<", "&lt;")
		.replaceAll(">", "&gt;")
		.replaceAll('"', "&quot;")
		.replaceAll("'", "&#39;");
}

async function loadContent() {
	try {
		const [commandsRes, patternsRes] = await Promise.all([
			fetch("/api/commands"),
			fetch("/api/patterns"),
		]);

		// Check for HTTP errors
		if (!commandsRes.ok) {
			throw new Error(`Commands API failed: ${commandsRes.status}`);
		}
		if (!patternsRes.ok) {
			throw new Error(`Patterns API failed: ${patternsRes.status}`);
		}

		allCommands = await commandsRes.json();
		const patternsData = await patternsRes.json();

		// Render commands (Glass Terminal)
		renderTerminalLayout(allCommands);

		// Initialize gallery card stack
		initGalleryStack();

		// Render patterns with tabbed navigation
		renderPatternsWithTabs(patternsData.patterns, patternsData.antipatterns);
	} catch (error) {
		console.error("Failed to load content:", error);
		showLoadError(error);
	}
}

function showLoadError(error) {
	// Show error in commands section
	const commandsGallery = document.querySelector('.commands-gallery');
	if (commandsGallery) {
		commandsGallery.innerHTML = `
			<div class="load-error" role="alert">
				<div class="load-error-icon" aria-hidden="true">⚠</div>
				<h3 class="load-error-title">Failed to load commands</h3>
				<p class="load-error-text">There was a problem loading the content. Please check your connection and try again.</p>
				<button class="btn btn-secondary load-error-retry" onclick="location.reload()">
					Retry
				</button>
			</div>
		`;
	}

	// Show error in patterns section
	const patternsContainer = document.getElementById("patterns-categories");
	if (patternsContainer) {
		patternsContainer.innerHTML = `
			<div class="load-error" role="alert">
				<div class="load-error-icon" aria-hidden="true">⚠</div>
				<h3 class="load-error-title">Failed to load patterns</h3>
				<p class="load-error-text">There was a problem loading the content. Please check your connection and try again.</p>
				<button class="btn btn-secondary load-error-retry" onclick="location.reload()">
					Retry
				</button>
			</div>
		`;
	}
}

function initGalleryStack() {
	const container = document.querySelector('.gallery-stack-container');
	const stack = document.getElementById('gallery-stack');
	if (!stack || !container) return;

	const cards = stack.querySelectorAll('.gallery-stack-card');
	const counter = container.querySelector('.gallery-stack-counter');
	const total = cards.length;
	let current = 0;
	let lastScroll = 0;

	function update() {
		cards.forEach((card, i) => {
			const offset = (i - current + total) % total;
			card.dataset.offset = offset;
		});
	}

	function next() { current = (current + 1) % total; update(); }
	function prev() { current = (current - 1 + total) % total; update(); }

	container.querySelector('.gallery-stack-prev').addEventListener('click', prev);
	container.querySelector('.gallery-stack-next').addEventListener('click', next);

	stack.addEventListener('wheel', (e) => {
		e.preventDefault();
		const now = Date.now();
		if (now - lastScroll < 350) return;
		lastScroll = now;
		if (e.deltaY > 0) next(); else prev();
	}, { passive: false });

	update();
}

function renderPatternsWithTabs(patterns, antipatterns) {
	const container = document.getElementById("patterns-categories");
	if (!container || !patterns || !antipatterns) return;

	const antipatternMap = {};
	antipatterns.forEach(cat => { antipatternMap[cat.name] = cat.items; });

	const tabsHTML = patterns.map((cat, i) =>
		`<button class="patterns-tab${i === 0 ? ' is-active' : ''}" data-index="${i}">${escapeHtml(cat.name)}</button>`
	).join('');

	const panelsHTML = patterns.map((cat, i) => {
		const antiItems = antipatternMap[cat.name] || [];
		return `
		<div class="patterns-content${i === 0 ? ' is-active' : ''}" data-index="${i}">
			<div class="patterns-col patterns-col--dont">
				<ul>${antiItems.map(item => `<li>${escapeHtml(item)}</li>`).join('')}</ul>
			</div>
			<div class="patterns-col patterns-col--do">
				<ul>${cat.items.map(item => `<li>${escapeHtml(item)}</li>`).join('')}</ul>
			</div>
		</div>`;
	}).join('');

	container.innerHTML = `<div class="patterns-tabs">${tabsHTML}</div>${panelsHTML}`;

	container.addEventListener('click', (e) => {
		const tab = e.target.closest('.patterns-tab');
		if (!tab) return;
		const index = tab.dataset.index;
		container.querySelectorAll('.patterns-tab').forEach(t => t.classList.remove('is-active'));
		container.querySelectorAll('.patterns-content').forEach(p => p.classList.remove('is-active'));
		tab.classList.add('is-active');
		container.querySelector(`.patterns-content[data-index="${index}"]`).classList.add('is-active');
	});
}

// ============================================
// EVENT HANDLERS
// ============================================

// Sync prefix radio buttons to hidden checkbox + update download button label
document.querySelectorAll('input[name="prefix-choice"]').forEach((radio) => {
	radio.addEventListener('change', () => {
		const prefixToggle = document.getElementById('prefix-toggle');
		if (prefixToggle) prefixToggle.checked = radio.value === 'prefixed';
		const btnLabel = document.querySelector('#download-zip-btn span');
		if (btnLabel) {
			btnLabel.textContent = radio.value === 'prefixed'
				? 'Download prefixed zip'
				: 'Download universal zip';
		}
	});
});

// Handle bundle download clicks via event delegation
document.addEventListener("click", (e) => {
	const bundleBtn = e.target.closest("[data-bundle]");
	if (bundleBtn) {
		const provider = bundleBtn.dataset.bundle;
		const prefixToggle = document.getElementById('prefix-toggle');
		const usePrefixed = prefixToggle && prefixToggle.checked;
		const bundleName = usePrefixed ? `${provider}-prefixed` : provider;
		window.location.href = `/api/download/bundle/${bundleName}`;
	}

	// Handle copy button clicks
	const copyBtn = e.target.closest("[data-copy]");
	if (copyBtn) {
		const textToCopy = copyBtn.dataset.copy;
		const onCopied = () => {
			copyBtn.classList.add('copied');
			setTimeout(() => copyBtn.classList.remove('copied'), 1500);
		};
		if (navigator.clipboard?.writeText) {
			navigator.clipboard.writeText(textToCopy).then(onCopied).catch(() => {});
		} else {
			// Fallback for non-HTTPS or older browsers
			const ta = Object.assign(document.createElement('textarea'), { value: textToCopy, style: 'position:fixed;left:-9999px' });
			document.body.appendChild(ta);
			ta.select();
			try { document.execCommand('copy'); onCopied(); } catch {}
			ta.remove();
		}
	}
});


// ============================================
// STARTUP
// ============================================

function init() {
	initAnchorScroll();
	initHashTracking();
	initLensEffect();
	initScrollReveal();
	initGlassTerminal();
	initFrameworkViz();
	initFoundationGrid();
	initSectionNav();
	loadContent();

	document.body.classList.add("loaded");
}

if (document.readyState === "loading") {
	document.addEventListener("DOMContentLoaded", init);
} else {
	init();
}
