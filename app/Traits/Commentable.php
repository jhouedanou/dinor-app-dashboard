<?php

namespace App\Traits;

use App\Models\Comment;
use Illuminate\Database\Eloquent\Relations\MorphMany;

trait Commentable
{
    /**
     * Get all comments for this model
     */
    public function comments(): MorphMany
    {
        return $this->morphMany(Comment::class, 'commentable');
    }

    /**
     * Get approved comments only
     */
    public function approvedComments(): MorphMany
    {
        return $this->morphMany(Comment::class, 'commentable')
                   ->approved()
                   ->topLevel()
                   ->orderBy('created_at', 'desc');
    }

    /**
     * Get comments count attribute
     */
    public function getCommentsCountAttribute()
    {
        return $this->comments()->approved()->count();
    }

    /**
     * Get pending comments count (for admin)
     */
    public function getPendingCommentsCountAttribute()
    {
        return $this->comments()->pending()->count();
    }

    /**
     * Add a comment to this content
     */
    public function addComment(array $data)
    {
        $comment = $this->comments()->create([
            'user_id' => $data['user_id'] ?? null,
            'author_name' => $data['author_name'] ?? null,
            'author_email' => $data['author_email'] ?? null,
            'content' => $data['content'],
            'is_approved' => $data['is_approved'] ?? false,
            'ip_address' => $data['ip_address'] ?? null,
            'user_agent' => $data['user_agent'] ?? null,
            'parent_id' => $data['parent_id'] ?? null,
        ]);

        // Update comments count if the comment is approved
        if ($comment && ($data['is_approved'] ?? false)) {
            $this->updateCommentsCount();
        }

        return $comment;
    }

    /**
     * Update the comments count
     */
    public function updateCommentsCount()
    {
        $count = $this->comments()->approved()->count();
        $this->update(['comments_count' => $count]);
        return $count;
    }

    /**
     * Scope to order by comments count
     */
    public function scopeOrderByComments($query, $direction = 'desc')
    {
        return $query->withCount(['comments' => function ($query) {
                        $query->approved();
                    }])
                    ->orderBy('comments_count', $direction);
    }

    /**
     * Scope to get most commented content
     */
    public function scopeMostCommented($query, $limit = 10)
    {
        return $query->withCount(['comments' => function ($query) {
                        $query->approved();
                    }])
                    ->orderBy('comments_count', 'desc')
                    ->limit($limit);
    }

    /**
     * Get recent comments for this content
     */
    public function getRecentComments($limit = 5)
    {
        return $this->approvedComments()
                   ->with(['user', 'replies'])
                   ->limit($limit)
                   ->get();
    }
} 