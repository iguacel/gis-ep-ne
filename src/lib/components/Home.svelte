<script>
    import { isEn } from "$lib/stores/lang";
    import { base } from "$app/paths";
</script>

<main>
        <p>
            Hi
        </p>

        <p class="second">
            <a href={`${base}/about`}>About.</a>
        </p>
    
</main>

<style>
    main {
        font-weight: 400;
        font-size: 1.5em;
        max-width: 460px;
        margin-top: var(--margin);
    }

    a {
        text-decoration: underline;
        font-weight: 400;
    }

    .second {
        margin-top: 22px;
    }
</style>
