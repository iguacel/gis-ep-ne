<script>
	import { isEn } from '$lib/stores/lang';
	import { links } from '$lib/data/links';
</script>

<main>
	<div class="grid">
		<div class="info">
			<p>Lorem ipsum.</p>
		</div>

		<div class="links">
			<ul>
				{#each links as l}
					<li>
						<a href={l.href} target="_blank" rel="noopener noreferrer">{l.name}</a>
					</li>
				{/each}
			</ul>
		</div>
	</div>
</main>

<style>
	.info {
		font-weight: 400;
		font-size: 1.5em;
		max-width: 460px;
	}

	a {
		text-decoration: underline;
		font-weight: 400;
	}

	.grid {
		margin-top: var(--margin);
		display: grid;
		grid-template-columns: 1fr;
		grid-gap: 64px;
	}

	@media only screen and (min-width: 666px) {
		.grid {
			grid-template-columns: repeat(2, 1fr);
		}
	}

	@media only screen and (min-width: 769px) {
		.grid {
			grid-template-columns: 2fr 1fr;
		}
	}

	.links {
		font-size: 1.5em;
		display: flex;
		align-items: flex-end;
	}
</style>
