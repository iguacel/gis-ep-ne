<script>
    import { isDark } from "$lib/stores/theme";
    import { isEn } from "$lib/stores/lang";
</script>

<div class="dev mono op">
    <p class="pm">dev mode (D)</p>
    <p class="pm">{$isDark ? "dark" : "light"}</p>
    <p class="pm">{$isEn ? "en" : "es"}</p>
</div>

<style>
    .dev {
        margin-top: var(--padding);
    }
</style>
