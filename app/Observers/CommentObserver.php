<?php

namespace App\Observers;

use App\Models\Comment;

class CommentObserver
{
    /**
     * Handle the Comment "created" event.
     */
    public function created(Comment $comment): void
    {
        if ($comment->is_approved) {
            $this->updateCommentableCount($comment);
        }
    }

    /**
     * Handle the Comment "updated" event.
     */
    public function updated(Comment $comment): void
    {
        // If approval status changed, update count
        if ($comment->isDirty('is_approved')) {
            $this->updateCommentableCount($comment);
        }
    }

    /**
     * Handle the Comment "deleted" event.
     */
    public function deleted(Comment $comment): void
    {
        if ($comment->is_approved) {
            $this->updateCommentableCount($comment);
        }
    }

    /**
     * Handle the Comment "restored" event.
     */
    public function restored(Comment $comment): void
    {
        if ($comment->is_approved) {
            $this->updateCommentableCount($comment);
        }
    }

    /**
     * Handle the Comment "force deleted" event.
     */
    public function forceDeleted(Comment $comment): void
    {
        if ($comment->is_approved) {
            $this->updateCommentableCount($comment);
        }
    }

    /**
     * Update the comments count for the commentable model
     */
    private function updateCommentableCount(Comment $comment): void
    {
        $commentable = $comment->commentable;
        
        if ($commentable && method_exists($commentable, 'updateCommentsCount')) {
            $commentable->updateCommentsCount();
        }
    }
}
