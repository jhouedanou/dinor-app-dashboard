<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ __('dinor.login_error_title') }}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { 
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif; 
        }
    </style>
</head>
<body class="bg-gray-50">
    <div class="flex flex-col items-center justify-center min-h-screen p-4">
        <div class="w-full max-w-md">
            <!-- Logo -->
            <div class="flex justify-center mb-8">
                <div class="flex items-center text-3xl font-bold text-orange-600">
                    🍽️ {{ config('app.name') }}
                </div>
            </div>

            <!-- Carte d'erreur -->
            <div class="bg-white dark:bg-gray-900 shadow-lg rounded-lg p-6 border border-gray-200 dark:border-gray-700">
                <!-- Icône d'erreur -->
                <div class="flex justify-center mb-4">
                    <div class="p-3 bg-red-100 dark:bg-red-900/20 rounded-full">
                        <svg class="w-8 h-8 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                        </svg>
                    </div>
                </div>

                <!-- Titre -->
                <h1 class="text-2xl font-bold text-center text-gray-900 mb-2">
                    {{ __('dinor.login_error_heading') }}
                </h1>

                <!-- Sous-titre -->
                <p class="text-center text-gray-600 mb-6">
                    {{ __('dinor.login_error_subheading') }}
                </p>

                <!-- Message d'erreur détaillé -->
                <div class="bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-800 rounded-lg p-4 mb-6">
                    <div class="flex items-start">
                        <svg class="w-5 h-5 text-red-400 mt-0.5 mr-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                        </svg>
                        <div>
                            <h3 class="text-sm font-medium text-red-800 dark:text-red-200">
                                {{ __('dinor.login_error_details_title') }}
                            </h3>
                            <div class="mt-2 text-sm text-red-700 dark:text-red-300">
                                <ul class="list-disc list-inside space-y-1">
                                    <li>{{ __('dinor.login_error_reason_1') }}</li>
                                    <li>{{ __('dinor.login_error_reason_2') }}</li>
                                    <li>{{ __('dinor.login_error_reason_3') }}</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Conseils -->
                <div class="bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mb-6">
                    <div class="flex items-start">
                        <svg class="w-5 h-5 text-blue-400 mt-0.5 mr-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
                        </svg>
                        <div>
                            <h3 class="text-sm font-medium text-blue-800 dark:text-blue-200">
                                {{ __('dinor.login_error_tips_title') }}
                            </h3>
                            <div class="mt-2 text-sm text-blue-700 dark:text-blue-300">
                                <ul class="list-disc list-inside space-y-1">
                                    <li>{{ __('dinor.login_error_tip_1') }}</li>
                                    <li>{{ __('dinor.login_error_tip_2') }}</li>
                                    <li>{{ __('dinor.login_error_tip_3') }}</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Actions -->
                <div class="flex flex-col space-y-3">
                    <a href="{{ route('filament.admin.auth.login') }}" 
                       class="inline-flex items-center justify-center px-4 py-2 bg-orange-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-orange-700 focus:bg-orange-700 active:bg-orange-900 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2 transition ease-in-out duration-150">
                        {{ __('dinor.return_to_login') }}
                    </a>
                    
                    <a href="mailto:support@dinorapp.com" 
                       class="inline-flex items-center justify-center px-4 py-2 bg-white border border-gray-300 rounded-md font-semibold text-xs text-gray-700 uppercase tracking-widest shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2 disabled:opacity-25 transition ease-in-out duration-150">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                        </svg>
                        {{ __('dinor.contact_support') }}
                    </a>
                </div>
            </div>

            <!-- Footer -->
            <div class="text-center mt-6 text-sm text-gray-500">
                © {{ date('Y') }} {{ config('app.name') }}. {{ __('dinor.all_rights_reserved') }}
            </div>
        </div>
    </div>
</body>
</html> 