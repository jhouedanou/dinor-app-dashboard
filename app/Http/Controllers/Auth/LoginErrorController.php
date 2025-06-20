<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class LoginErrorController extends Controller
{
    public function show()
    {
        return view('filament.pages.auth.login-error', [
            'title' => __('dinor.login_error_title'),
            'heading' => __('dinor.login_error_heading'),
            'subheading' => __('dinor.login_error_subheading'),
        ]);
    }
} 