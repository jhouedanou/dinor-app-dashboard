<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginErrorController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return redirect('/admin');
});

Route::get('/dashboard', function () {
    return redirect('/admin');
})->name('dashboard');

// Route pour la page d'erreur de connexion admin
Route::get('/admin/login-error', [LoginErrorController::class, 'show'])->name('admin.login.error');

// Route de test pour l'authentification
Route::get('/admin/test-auth', function() {
    $admin = App\Models\AdminUser::where('email', 'admin@dinor.app')->first();
    Auth::guard('admin')->login($admin);
    
    return [
        'auth_check' => Auth::guard('admin')->check(),
        'user' => Auth::guard('admin')->user(),
        'redirect_to' => '/admin'
    ];
});