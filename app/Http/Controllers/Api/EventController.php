<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index(Request $request)
    {
        $query = Event::with('category')
            ->published()
            ->active()
            ->orderBy('start_date', 'asc');

        // Filtres
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('upcoming')) {
            $query->upcoming();
        }

        if ($request->has('featured')) {
            $query->featured();
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