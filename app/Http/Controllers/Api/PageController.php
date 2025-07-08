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
            ->ordered();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
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

    public function show($id)
    {
        $page = Page::where('id', $id)
            ->published()
            ->firstOrFail();

        return response()->json([
            'success' => true,
            'data' => $page
        ]);
    }

    public function homepage()
    {
        $page = Page::published()
            ->ordered()
            ->first();

        if (!$page) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune page définie'
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
            ->ordered()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pages
        ]);
    }

    public function latest()
    {
        $page = Page::published()
            ->orderBy('created_at', 'desc')
            ->first();

        if (!$page) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune page disponible'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $page->id,
                'title' => $page->title,
                'url' => $page->url,
                'embed_url' => $page->embed_url,
                'is_external' => $page->is_external,
                'content' => $page->content,
                'meta_title' => $page->meta_title,
                'meta_description' => $page->meta_description,
                'created_at' => $page->created_at,
                'updated_at' => $page->updated_at,
            ]
        ]);
    }
} 