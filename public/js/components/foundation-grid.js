import { skillFocusAreas, dimensionGuidelineCounts } from '../data.js';

export function initFoundationGrid() {
	const container = document.querySelector('.foundation-grid');
	if (!container) return;

	const dimensions = skillFocusAreas['impeccable'];
	if (!dimensions) return;

	container.innerHTML = dimensions.map(dim => `
		<div class="foundation-card">
			<div class="foundation-card-header">
				<span class="foundation-card-label">${dim.area}</span>
				<span class="foundation-card-count">${dimensionGuidelineCounts[dim.area] || ''}</span>
			</div>
			<p class="foundation-card-detail">${dim.detail}</p>
		</div>
	`).join('');
}
