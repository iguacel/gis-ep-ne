import { writable, derived } from 'svelte/store';
import { browser } from '$app/environment';
import { THEMES } from '$lib/config';

// THEME

function initializeTheme() {
    if (browser) {  
        const savedTheme = localStorage.getItem('theme');
        if (savedTheme) {
            return savedTheme;
        } else {
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            return prefersDark ? 'dark' : 'light';
        }
    }
    return 'light';  
}

export const theme = writable('light');  

if (browser) {  
    theme.set(initializeTheme());  

    
    theme.subscribe($theme => {
        localStorage.setItem('theme', $theme);
        document.body.setAttribute('data-theme', $theme);
    });
}

export const isDark = derived(theme, $theme => $theme === THEMES.DARK);
