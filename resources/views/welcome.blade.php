<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>{{ config('app.name', 'Laravel') }}</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,600&display=swap" rel="stylesheet" />

        <!-- Styles -->
        <style>
            :root {
                --dinor-red: #E1251B;
                --dinor-gray: #818080;
                --dinor-champagne: #E6D9D0;
                --dinor-goldenrod: #9E7C22;
                --dinor-blood-red: #690E08;
                --dinor-red-light: #FF5A50;
                --dinor-champagne-light: #F4ECE6;
                --dinor-champagne-dark: #D4C4B8;
            }

            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }

            html, body {
                height: 100%;
                font-family: 'Open Sans', 'Roboto', sans-serif;
                background: linear-gradient(135deg, var(--dinor-red) 0%, var(--dinor-blood-red) 100%);
                color: #FFFFFF;
                line-height: 1.6;
                -webkit-font-smoothing: antialiased;
                -moz-osx-font-smoothing: grayscale;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 2rem;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            .header {
                text-align: center;
                margin-bottom: 3rem;
            }

            .header h1 {
                font-size: 3rem;
                font-weight: 700;
                color: #FFFFFF;
                margin-bottom: 1rem;
                text-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
                font-family: 'Open Sans', sans-serif;
            }

            .header p {
                font-size: 1.25rem;
                color: var(--dinor-champagne-light);
                font-family: 'Roboto', sans-serif;
            }

            .nav {
                display: flex;
                justify-content: center;
                gap: 2rem;
                margin-bottom: 3rem;
                flex-wrap: wrap;
            }

            .nav a {
                display: inline-flex;
                align-items: center;
                padding: 1rem 2rem;
                background: rgba(255, 255, 255, 0.1);
                color: #FFFFFF;
                text-decoration: none;
                border-radius: 12px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                font-weight: 600;
                font-family: 'Roboto', sans-serif;
                transition: all 0.3s ease;
                backdrop-filter: blur(10px);
                -webkit-backdrop-filter: blur(10px);
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
            }

            .nav a:hover {
                background: var(--dinor-goldenrod);
                color: #FFFFFF;
                transform: translateY(-2px);
                box-shadow: 0 8px 24px rgba(158, 124, 34, 0.4);
                border-color: var(--dinor-goldenrod);
            }

            .footer {
                text-align: center;
                margin-top: 3rem;
                color: var(--dinor-champagne);
                font-size: 0.875rem;
                font-family: 'Roboto', sans-serif;
            }

            @media (max-width: 768px) {
                .container {
                    padding: 1rem;
                }

                .header h1 {
                    font-size: 2rem;
                }

                .header p {
                    font-size: 1rem;
                }

                .nav {
                    flex-direction: column;
                    align-items: center;
                    gap: 1rem;
                }

                .nav a {
                    width: 100%;
                    max-width: 300px;
                    justify-content: center;
                }
            }

            /* Bubbles animation for visual appeal */
            .bubbles {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                overflow: hidden;
                z-index: -1;
                pointer-events: none;
            }

            .bubble {
                position: absolute;
                bottom: -100px;
                width: 40px;
                height: 40px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 50%;
                opacity: 0.6;
                animation: bubble-rise 15s infinite linear;
            }

            .bubble:nth-child(1) {
                left: 10%;
                animation-delay: 0s;
                animation-duration: 13s;
            }

            .bubble:nth-child(2) {
                left: 20%;
                animation-delay: 2s;
                animation-duration: 16s;
                width: 60px;
                height: 60px;
            }

            .bubble:nth-child(3) {
                left: 60%;
                animation-delay: 4s;
                animation-duration: 18s;
            }

            .bubble:nth-child(4) {
                left: 70%;
                animation-delay: 6s;
                animation-duration: 14s;
                width: 80px;
                height: 80px;
            }

            .bubble:nth-child(5) {
                left: 90%;
                animation-delay: 8s;
                animation-duration: 12s;
            }

            @keyframes bubble-rise {
                0% {
                    bottom: -100px;
                    transform: translateX(0);
                }
                50% {
                    transform: translateX(100px);
                }
                100% {
                    bottom: 100vh;
                    transform: translateX(-200px);
                }
            }
        </style>
    </head>
    <body>
        <!-- Animated bubbles background -->
        <div class="bubbles">
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
            <div class="bubble"></div>
        </div>

        <div class="container">
            <div class="header">
                <h1>Bienvenue sur {{ config('app.name', 'Dinor App') }}</h1>
                <p>Votre application est prête à être utilisée.</p>
            </div>

            <div class="nav">
                <a href="/admin">🏠 Dashboard Admin</a>
                <a href="/pwa">📱 Application PWA</a>
            </div>

            <div class="footer">
                <p>Laravel v{{ Illuminate\Foundation\Application::VERSION }} (PHP v{{ PHP_VERSION }})</p>
                <p style="margin-top: 0.5rem; font-size: 0.75rem; opacity: 0.8;">
                    © {{ date('Y') }} Dinor App - Votre assistant culinaire personnel
                </p>
            </div>
        </div>
    </body>
</html>