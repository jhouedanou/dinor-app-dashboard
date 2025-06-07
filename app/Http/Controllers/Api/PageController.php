<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Page;
use Illuminate\Http\Request;

class PageController extends Controller
{
    public function index(Request $request)
    {
        $query = Page::published()
            ->rootPages()
            ->ordered();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('content', 'like', "%{$search}%");
            });
        }

        $pages = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $pages->items(),
            'pagination' => [
                'current_page' => $pages->currentPage(),
                'last_page' => $pages->lastPage(),
                'per_page' => $pages->perPage(),
                'total' => $pages->total(),
            ]
        ]);
    }

    public function show($slug)
    {
        $page = Page::where('slug', $slug)
            ->published()
            ->with('children')
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $page
        ]);
    }

    public function homepage()
    {
        $page = Page::where('is_homepage', true)
            ->published()
            ->first();

        if (!$page) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune page d\'accueil définie'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $page
        ]);
    }

    public function menu()
    {
        $pages = Page::published()
            ->rootPages()
            ->ordered()
            ->with('children')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pages
        ]);
    }
} 