<script>
	import { onMount } from "svelte";
	import ToggleLang from "$lib/components/ToggleLang.svelte";
	import ToggleTheme from "$lib/components/ToggleTheme.svelte";
	import { lang } from "$lib/stores/lang";
	import { isDev } from "$lib/stores/dev";

	function toggleDevMode() {
		isDev.update((value) => !value);
	}

	function handleKeydown(event) {
		if (event.key.toLowerCase() === "d") {
			toggleDevMode();
		}
	}

	onMount(() => {
		lang.initialize();

		window.addEventListener("keydown", handleKeydown);
		return () => {
			window.removeEventListener("keydown", handleKeydown);
		};
	});
</script>

<ToggleTheme />
<ToggleLang />

<div class="scanlines"></div>

<div class="app">
	<main>
		<slot />
	</main>
</div>

<style>
	.app {
		width: 100%;
		max-width: var(--max-width);
		overflow: hidden;
		padding: var(--padding);
		margin: 0 auto;
	}
</style>