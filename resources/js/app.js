import './bootstrap';

// Debug logging pour Dinor Login
console.log('🚀 Dinor App JavaScript loaded');

// Attendre que Filament Alpine soit prêt
document.addEventListener('DOMContentLoaded', function() {
    console.log('📄 DOM loaded');
    
    // Attendre un peu que Filament termine son setup
    setTimeout(() => {
        console.log('🔍 Alpine instance:', window.Alpine);
        
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
        
        // Debug des erreurs de login
        const alertElements = document.querySelectorAll('[role="alert"], .fi-notification');
        if (alertElements.length > 0) {
            console.log('⚠️ Alerts found:', alertElements);
        }
    }, 100);
});

// Debug AJAX requests
if (window.fetch) {
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
} 