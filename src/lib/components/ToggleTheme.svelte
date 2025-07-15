<script lang="ts">
    import { theme } from "$lib/stores/theme";
    import { THEMES } from "$lib/config";

    function toggleTheme(): void {
        theme.update((current) =>
            current === THEMES.LIGHT ? THEMES.DARK : THEMES.LIGHT,
        );
    }
</script>

<button aria-label="toggle theme" on:click={toggleTheme}>
    <svg
        viewBox="-0.75 -0.75 31.5 31.5"
        width="30"
        height="30"
        fill="var(--c-bg)"
        style="display:block;overflow:visible;cursor:pointer;padding:0"
        ><circle
            style="transition:fill 200ms;will-change:fill"
            cx="15"
            cy="15"
            r="15"
            fill="var(--c-fg)"
        ></circle><path
            style="transition:fill 200ms;will-change:fill"
            d="M 15 30 A 1 1 0 0 0 15 0"
            fill="var(--c-bg)"
            stroke="none"
        ></path><circle
            cx="15"
            cy="15"
            r="15"
            stroke="var(--c-fg)"
            stroke-width="1.5"
            fill="transparent"
        ></circle></svg
    >
</button>

<style>
    button {
        position: absolute;
        top: var(--padding);
        right: var(--padding);
        width: 2rem;
        height: 2rem;
        display: flex;
        justify-content: center;
        align-items: center;
    }
</style>
