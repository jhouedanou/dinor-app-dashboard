<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProfessionalContent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfessionalContentController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();
        
        if (!$user || !$user->isProfessional()) {
            return response()->json(['message' => 'Accès non autorisé'], 403);
        }

        $contents = ProfessionalContent::where('user_id', $user->id)
            ->with(['user', 'reviewer'])
            ->orderBy('submitted_at', 'desc')
            ->paginate(10);

        return response()->json($contents);
    }

    public function store(Request $request)
    {
        try {
            $user = Auth::user();
            
            if (!$user || !$user->isProfessional()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Accès non autorisé'
                ], 403);
            }

            // Log des données reçues pour debug
            \Log::info('Données reçues pour création de contenu professionnel:', [
                'user_id' => $user->id,
                'content_type' => $request->input('content_type'),
                'title' => $request->input('title'),
                'has_ingredients' => $request->has('ingredients'),
                'has_steps' => $request->has('steps'),
                'ingredients_count' => $request->input('ingredients') ? count($request->input('ingredients')) : 0,
                'steps_count' => $request->input('steps') ? count($request->input('steps')) : 0,
            ]);

            $validated = $request->validate([
                'content_type' => ['required', Rule::in(['recipe', 'tip', 'event', 'video'])],
                'title' => 'required|string|max:255',
                'description' => 'required|string',
                'content' => 'required|string',
                'images' => 'nullable|array',
                'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
                'video_url' => 'nullable|url|max:255',
                'difficulty' => ['nullable', Rule::in(['beginner', 'easy', 'medium', 'hard', 'expert'])],
                'category' => 'nullable|string|max:255',
                'preparation_time' => 'nullable|integer|min:0',
                'cooking_time' => 'nullable|integer|min:0',
                'servings' => 'nullable|integer|min:1',
                'ingredients' => 'nullable|array',
                'ingredients.*.name' => 'required_with:ingredients|string',
                'ingredients.*.quantity' => 'nullable|string',
                'ingredients.*.unit' => 'nullable|string',
                'steps' => 'nullable|array',
                'steps.*.instruction' => 'required_with:steps|string',
                'tags' => 'nullable|array',
                'tags.*' => 'string',
            ]);

            // Handle image uploads
            $imagePaths = [];
            if ($request->hasFile('images')) {
                foreach ($request->file('images') as $image) {
                    $path = $image->store('professional-content', 'public');
                    $imagePaths[] = $path;
                }
            }

            // Préparer les données pour la création
            $contentData = [
                'user_id' => $user->id,
                'content_type' => $validated['content_type'],
                'title' => $validated['title'],
                'description' => $validated['description'],
                'content' => $validated['content'],
                'images' => $imagePaths,
                'video_url' => $validated['video_url'] ?? null,
                'difficulty' => $validated['difficulty'] ?? null,
                'category' => $validated['category'] ?? null,
                'preparation_time' => $validated['preparation_time'] ?? null,
                'cooking_time' => $validated['cooking_time'] ?? null,
                'servings' => $validated['servings'] ?? null,
                'ingredients' => $validated['ingredients'] ?? null,
                'steps' => $validated['steps'] ?? null,
                'tags' => $validated['tags'] ?? null,
                'status' => 'pending',
                'submitted_at' => now(),
            ];

            // Log des données avant création
            \Log::info('Données préparées pour création:', $contentData);

            $content = ProfessionalContent::create($contentData);

            return response()->json([
                'success' => true,
                'message' => 'Contenu soumis avec succès',
                'data' => $content->load(['user'])
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            \Log::error('Erreur de validation création contenu:', $e->errors());
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            \Log::error('Erreur création contenu professionnel: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur interne du serveur',
                'error' => config('app.debug') ? $e->getMessage() : 'INTERNAL_SERVER_ERROR'
            ], 500);
        }
    }

    public function show(ProfessionalContent $professionalContent)
    {
        $user = Auth::user();
        
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        // Users can only see their own content unless they're admin/moderator
        if ($professionalContent->user_id !== $user->id && !$user->isModerator()) {
            return response()->json(['message' => 'Accès non autorisé'], 403);
        }

        return response()->json($professionalContent->load(['user', 'reviewer']));
    }

    public function update(Request $request, ProfessionalContent $professionalContent)
    {
        $user = Auth::user();
        
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        // Only content owner can update their content and only if it's pending or rejected
        if ($professionalContent->user_id !== $user->id) {
            return response()->json(['message' => 'Accès non autorisé'], 403);
        }

        if (!in_array($professionalContent->status, ['pending', 'rejected'])) {
            return response()->json(['message' => 'Ce contenu ne peut plus être modifié'], 422);
        }

        $validated = $request->validate([
            'content_type' => ['required', Rule::in(['recipe', 'tip', 'event', 'video'])],
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'content' => 'required|string',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
            'video_url' => 'nullable|url|max:255',
            'difficulty' => ['nullable', Rule::in(['beginner', 'easy', 'medium', 'hard', 'expert'])],
            'category' => 'nullable|string|max:255',
            'preparation_time' => 'nullable|integer|min:0',
            'cooking_time' => 'nullable|integer|min:0',
            'servings' => 'nullable|integer|min:1',
            'ingredients' => 'nullable|array',
            'ingredients.*.name' => 'required_with:ingredients|string',
            'ingredients.*.quantity' => 'nullable|string',
            'ingredients.*.unit' => 'nullable|string',
            'steps' => 'nullable|array',
            'steps.*.instruction' => 'required_with:steps|string',
            'tags' => 'nullable|array',
            'tags.*' => 'string',
        ]);

        // Handle image uploads
        $imagePaths = $professionalContent->images ?? [];
        if ($request->hasFile('images')) {
            // Delete old images
            if ($professionalContent->images) {
                foreach ($professionalContent->images as $oldPath) {
                    Storage::disk('public')->delete($oldPath);
                }
            }
            
            // Upload new images
            $imagePaths = [];
            foreach ($request->file('images') as $image) {
                $path = $image->store('professional-content', 'public');
                $imagePaths[] = $path;
            }
        }

        $professionalContent->update([
            'content_type' => $validated['content_type'],
            'title' => $validated['title'],
            'description' => $validated['description'],
            'content' => $validated['content'],
            'images' => $imagePaths,
            'video_url' => $validated['video_url'] ?? null,
            'difficulty' => $validated['difficulty'] ?? null,
            'category' => $validated['category'] ?? null,
            'preparation_time' => $validated['preparation_time'] ?? null,
            'cooking_time' => $validated['cooking_time'] ?? null,
            'servings' => $validated['servings'] ?? null,
            'ingredients' => $validated['ingredients'] ?? null,
            'steps' => $validated['steps'] ?? null,
            'tags' => $validated['tags'] ?? null,
            'status' => 'pending', // Reset to pending when updated
            'submitted_at' => now(),
            'reviewed_at' => null,
            'reviewed_by' => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Contenu mis à jour avec succès',
            'data' => $professionalContent->load(['user'])
        ]);
    }

    public function destroy(ProfessionalContent $professionalContent)
    {
        $user = Auth::user();
        
        if (!$user) {
            return response()->json(['message' => 'Non authentifié'], 401);
        }

        // Only content owner can delete their content and only if it's not published
        if ($professionalContent->user_id !== $user->id) {
            return response()->json(['message' => 'Accès non autorisé'], 403);
        }

        if ($professionalContent->status === 'published') {
            return response()->json(['message' => 'Le contenu publié ne peut pas être supprimé'], 422);
        }

        // Delete associated images
        if ($professionalContent->images) {
            foreach ($professionalContent->images as $imagePath) {
                Storage::disk('public')->delete($imagePath);
            }
        }

        $professionalContent->delete();

        return response()->json([
            'success' => true,
            'message' => 'Contenu supprimé avec succès'
        ]);
    }

    public function getContentTypes()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'content_types' => ProfessionalContent::CONTENT_TYPES,
                'difficulties' => ProfessionalContent::DIFFICULTIES,
            ]
        ]);
    }
}