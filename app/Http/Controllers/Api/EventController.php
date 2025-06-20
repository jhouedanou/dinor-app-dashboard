<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index(Request $request)
    {
        // Version de diagnostic sans filtres restrictifs
        $query = Event::with('category')
            ->orderBy('start_date', 'asc');

        // Filtres optionnels seulement
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('upcoming')) {
            $query->where('start_date', '>=', now()->toDateString());
        }

        if ($request->has('featured')) {
            $query->where('is_featured', true);
        }

        if ($request->has('published_only')) {
            $query->where('is_published', true);
        }

        if ($request->has('active_only')) {
            $query->where('status', 'active');
        }

        if ($request->has('location')) {
            $query->where('location', 'like', "%{$request->location}%");
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('location', 'like', "%{$search}%");
            });
        }

        $events = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $events->items(),
            'pagination' => [
                'current_page' => $events->currentPage(),
                'last_page' => $events->lastPage(),
                'per_page' => $events->perPage(),
                'total' => $events->total(),
            ],
            'debug_info' => [
                'total_events_in_db' => Event::count(),
                'published_events' => Event::where('is_published', true)->count(),
                'active_events' => Event::where('status', 'active')->count(),
            ]
        ]);
    }

    public function show($id)
    {
        $event = Event::with('category')
            ->published()
            ->active()
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $event
        ]);
    }

    public function upcoming()
    {
        $events = Event::with('category')
            ->published()
            ->active()
            ->upcoming()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $events
        ]);
    }

    public function featured()
    {
        $events = Event::with('category')
            ->published()
            ->active()
            ->featured()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $events
        ]);
    }

    public function register(Request $request, $id)
    {
        $event = Event::findOrFail($id);
        
        if ($event->is_full) {
            return response()->json([
                'success' => false,
                'message' => 'Cet événement est complet'
            ], 400);
        }

        // Logique d'inscription ici
        $event->increment('current_participants');

        return response()->json([
            'success' => true,
            'message' => 'Inscription réussie',
            'data' => $event->fresh()
        ]);
    }
} 