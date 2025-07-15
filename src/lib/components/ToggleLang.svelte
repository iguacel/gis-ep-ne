<script>
    import { lang } from "$lib/stores/lang";

    function toggleLanguage() {
        $lang === "en" ? lang.setLang("es") : lang.setLang("en");
    }
</script>

<button aria-label="toggle theme" on:click={toggleLanguage}>
    <svg
        width="57px"
        height="32px"
        viewBox="0 0 56 30"
        xmlns="http://www.w3.org/2000/svg"
    >
        <g class={$lang}>
            <path
                d="M15.2 29.3C7.3 29.3.9 22.9.9 15S7.3.7 15.2.7h25.6C48.7.7 55.1 7.1 55.1 15s-6.4 14.3-14.3 14.3H15.2Z"
                stroke="var(--c-fg)"
                stroke-width="1.5"
                fill="var(--c-fg)"
            />

            <circle
                class={$lang}
                cx="15.2"
                cy="15"
                r="14.3"
                stroke="var(--c-fg)"
                stroke-width="1.5"
                fill="var(--c-bg)"
            />

            <path
                class="en"
                d="M12.7,18h1.3c-.1.7-.5,1.3-1.1,1.7-.6.4-1.4.7-2.3.7s-2.1-.3-2.7-1c-.7-.7-1-1.6-1-2.8v-1.3c0-1.1.3-2,1-2.7.7-.7,1.5-1,2.6-1s2,.3,2.6,1c.6.7.9,1.7.9,2.9v.8h-5.8v.3c0,.8.2,1.4.6,1.9s1,.7,1.7.7,1-.1,1.4-.3c.4-.2.6-.5.7-.9ZM10.5,12.6c-.7,0-1.3.2-1.7.7s-.6,1.1-.6,1.9h4.5c0-.8-.2-1.5-.6-1.9s-.9-.7-1.6-.7ZM15.9,20.2v-8.6h1.3v1.5h.1c.2-.5.6-.9,1.1-1.2s1-.4,1.7-.4c.9,0,1.6.3,2.1.8s.7,1.3.7,2.4v5.6h-1.3v-5.2c0-.8-.2-1.3-.5-1.7-.3-.4-.8-.6-1.5-.6s-1.3.2-1.7.7c-.4.5-.7,1-.7,1.8v5.1h-1.3Z"
                fill="var(--c-bg)"
            />
            <path
                class="es"
                d="M39.5,18h1.3c-.1.7-.5,1.3-1.1,1.7-.6.4-1.4.7-2.3.7s-2.1-.3-2.7-1c-.7-.7-1-1.6-1-2.8v-1.3c0-1.1.3-2,1-2.7.7-.7,1.5-1,2.6-1s2,.3,2.6,1c.6.7.9,1.7.9,2.9v.8h-5.8v.3c0,.8.2,1.4.6,1.9s1,.7,1.7.7,1-.1,1.4-.3c.4-.2.6-.5.7-.9ZM37.3,12.6c-.7,0-1.3.2-1.7.7s-.6,1.1-.6,1.9h4.5c0-.8-.2-1.5-.6-1.9s-.9-.7-1.6-.7ZM43.1,13.9c0-.7.3-1.3.9-1.8.6-.5,1.3-.7,2.3-.7s1.6.2,2.2.6c.6.4.9,1,1,1.7h-1.3c0-.4-.3-.7-.6-.9s-.8-.3-1.3-.3-1,.1-1.3.4c-.3.2-.5.5-.5.9s.1.6.4.8c.2.2.6.4,1.2.5l1.2.3c.8.2,1.4.5,1.8.9.4.4.6.9.6,1.5s-.3,1.4-.9,1.9c-.6.5-1.4.7-2.4.7s-1.8-.2-2.4-.6-.9-1-1-1.7h1.4c0,.4.3.7.7.9.4.2.8.3,1.4.3s1.1-.1,1.4-.4c.3-.2.5-.6.5-1s-.1-.6-.3-.8c-.2-.2-.6-.4-1.2-.5l-1.3-.3c-1.5-.4-2.3-1.1-2.3-2.4Z"
                fill="var(--c-bg)"
            />
        </g></svg
    >
</button>

<style>
    button {
        position: absolute;
        top: var(--padding);
        right: calc(var(--padding) * 2.5);
        width: 57px;
        height: 2rem;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    svg {
        position: absolute;
        cursor: pointer;
    }

    circle {
        transition: transform 0.25s ease-out;
    }

    circle.es {
        transform: translatex(25.7px);
    }
</style>
