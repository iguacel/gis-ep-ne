import { writable, derived } from 'svelte/store';

function createLangStore() {
    const { subscribe, set } = writable('en'); // default language

    return {
        subscribe,
        setLang: (lang) => {
            localStorage.setItem('userLang', lang);
            set(lang);
        },
        initialize: () => {
            const lang = localStorage.getItem('userLang') || 'en';
            set(lang);
        }
    };
}

export const lang = createLangStore();

export const isEn = derived(lang, $lang => $lang === 'en');