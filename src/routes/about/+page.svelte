<script>
    import Header from "$lib/components/Header.svelte";
    import { isEn } from "$lib/stores/lang";
    import About from "$lib/components/About.svelte";

    const texts = {
        en: {
            greeting: "Hello",
        },
        es: {
            greeting: "Hola",
        },
    };
    
</script>

<Header>{$isEn ? texts.en.greeting : texts.es.greeting}</Header>
<About/>