<script>
    import Project from "./Project.svelte";
    import Title from "./Title.svelte";

    export let projectsList;
    export let title;
    export let leadin;
    export let name;
</script>

<Title>
    {title}
    <p class="light">{leadin}</p>
</Title>

<div class="grid-container">
    {#each projectsList as p}
        <Project data={p} name={name} />
    {/each}
</div>

<style>
    .grid-container {
        display: grid;
        grid-template-columns: 1fr;
        grid-gap: 32px;
        margin-top: var(--margin);
    }

    @media only screen and (min-width: 666px) {
        .grid-container {
            grid-template-columns: repeat(2, 1fr);
        }
    }

    @media only screen and (min-width: 769px) {
        .grid-container {
            grid-template-columns: repeat(3, 1fr);
        }
    }

    .light {
        font-weight: 400;
    }
</style>
