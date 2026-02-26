<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProfessionalContent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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