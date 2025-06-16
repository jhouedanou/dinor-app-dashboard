import './bootstrap';

import Alpine from 'alpinejs';

window.Alpine = Alpine;

// Debug logging pour Dinor Login
console.log('🚀 Dinor App JavaScript loaded');

// Écouter les soumissions de formulaire
document.addEventListener('DOMContentLoaded', function() {
    console.log('📄 DOM loaded');
    
    // Debug form submissions
    document.addEventListener('submit', function(e) {
        console.log('📝 Form submitted:', e.target);
        const formData = new FormData(e.target);
        console.log('📊 Form data:', Object.fromEntries(formData));
    });
    
    // Debug login attempts
    const loginForms = document.querySelectorAll('form[action*="login"]');
    loginForms.forEach(form => {
        console.log('🔐 Login form found:', form);
    });
});

// Debug AJAX requests
const originalFetch = window.fetch;
window.fetch = function(...args) {
    console.log('🌐 Fetch request:', args);
    return originalFetch.apply(this, args)
        .then(response => {
            console.log('✅ Fetch response:', response);
            return response;
        })
        .catch(error => {
            console.error('❌ Fetch error:', error);
            throw error;
        });
};

Alpine.start(); 