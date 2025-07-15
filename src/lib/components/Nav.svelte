<script lang="ts">
    import { base } from "$app/paths";
    import { isEn } from "$lib/stores/lang";
    import { isDev } from "$lib/stores/dev";
    import IsDev from "./IsDev.svelte";
</script>

<nav>
    <ul class="links">
        <li>
            <a href={`${base}/`}>{$isEn ? "Home" : "Inicio"}</a>
        </li>
        <li>
            <a href={`${base}/about`}>{$isEn ? "About" : "Info"}</a>
        </li>
    </ul>

    {#if $isDev}
        <IsDev/>
    {/if}
</nav>

<style>
    ul {
        list-style-type: none;
        margin: 0;
        padding: 0;
        text-align: left;
        font-size: 24px;
    }

    a, li {
        font-weight: 600;
    }
</style>
