/**
 * COMMENTS_SECTION.DART - SECTION COMPLÈTE DE GESTION DES COMMENTAIRES
 * 
 * FONCTIONNALITÉS :
 * - Affichage de la liste des commentaires avec pagination
 * - Formulaire d'ajout de commentaire avec validation
 * - Gestion des états de chargement et d'erreur
 * - Authentification requise pour poster
 * - Interface responsive et accessible
 * - Actions contextuelles (supprimer, charger plus)
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/comments_service.dart';
import '../../composables/use_auth_handler.dart';
import 'comment_item.dart';

class CommentsSection extends ConsumerStatefulWidget {
  final String contentType;
  final String contentId;
  final String contentTitle;
  final VoidCallback? onAuthRequired;

  const CommentsSection({
    Key? key,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
    this.onAuthRequired,
  }) : super(key: key);

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isSubmitting = false;
  bool _showFullSection = false;

  @override
  void initState() {
    super.initState();
    // Charger les commentaires au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentsServiceProvider.notifier)
          .loadComments(widget.contentType, widget.contentId);
      
      // Vérifier l'authentification
      _checkAuthentication();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les commentaires quand les dépendances changent
    ref.read(commentsServiceProvider.notifier)
        .loadComments(widget.contentType, widget.contentId, refresh: true);
  }

  Future<void> _checkAuthentication() async {
    final authHandler = ref.read(useAuthHandlerProvider.notifier);
    final isValid = await authHandler.checkAuth();
    print('🔐 [CommentsSection] Vérification auth: $isValid');
  }

  Future<void> _forceReconnect() async {
    print('🔄 [CommentsSection] Forcer la reconnexion...');
    final authHandler = ref.read(useAuthHandlerProvider.notifier);
    
    // Essayer de se connecter en tant qu'invité
    final success = await authHandler.loginAsGuest();
    print('🔄 [CommentsSection] Connexion invité: $success');
    
    if (success) {
      // Recharger les commentaires après connexion
      await ref.read(commentsServiceProvider.notifier)
          .loadComments(widget.contentType, widget.contentId, refresh: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion invité réussie'),
            backgroundColor: Color(0xFF38A169),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de reconnexion'),
            backgroundColor: Color(0xFFE53E3E),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsKey = '${widget.contentType}_${widget.contentId}';
    final commentsState = ref.watch(commentsProvider(commentsKey));
    final authHandler = ref.watch(useAuthHandlerProvider);
    
    // Debug: Afficher l'état d'authentification
    print('🔐 [CommentsSection] État authentification:');
    print('   - isAuthenticated: ${authHandler.isAuthenticated}');
    print('   - userName: ${authHandler.userName}');
    print('   - token: ${authHandler.token != null ? "Présent" : "Absent"}');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la section
          _buildSectionHeader(commentsState),
          const SizedBox(height: 16),

          // Aperçu ou section complète
          if (_showFullSection) ...[
            // Debug: Afficher l'état d'authentification
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Auth:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  Text(
                    'isAuthenticated: ${authHandler.isAuthenticated}',
                    style: TextStyle(fontSize: 10, color: Colors.orange[700]),
                  ),
                  Text(
                    'userName: ${authHandler.userName ?? "null"}',
                    style: TextStyle(fontSize: 10, color: Colors.orange[700]),
                  ),
                  Text(
                    'token: ${authHandler.token != null ? "Présent" : "Absent"}',
                    style: TextStyle(fontSize: 10, color: Colors.orange[700]),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _checkAuthentication,
                          child: Text('Vérifier Auth', style: TextStyle(fontSize: 10)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _forceReconnect,
                          child: Text('Reconnecter', style: TextStyle(fontSize: 10)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Formulaire d'ajout de commentaire
            if (authHandler.isAuthenticated) ...[
              _buildCommentForm(),
              const SizedBox(height: 16),
            ] else ...[
              _buildAuthPrompt(),
              const SizedBox(height: 16),
            ],

            // Liste des commentaires
            _buildCommentsList(commentsState),
          ] else ...[
            // Aperçu des commentaires
            _buildCommentsPreview(commentsState),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(CommentsState commentsState) {
    final commentsCount = commentsState.comments.length;
    
    return Row(
      children: [
        const Icon(
          Icons.comment_outlined,
          size: 20,
          color: Color(0xFF4A5568),
        ),
        const SizedBox(width: 8),
        Text(
          'Commentaires',
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            commentsCount.toString(),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
        const Spacer(),
        
        // Bouton voir tout / réduire
        if (commentsCount > 0)
          TextButton(
            onPressed: () {
              setState(() {
                _showFullSection = !_showFullSection;
              });
            },
            child: Text(
              _showFullSection ? 'Réduire' : 'Voir tout',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFFE53E3E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _commentFocusNode.hasFocus 
                  ? const Color(0xFFE53E3E) 
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextField(
            controller: _commentController,
            focusNode: _commentFocusNode,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Partagez votre avis...',
              hintStyle: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              counterStyle: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: Color(0xFF718096),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF2D3748),
            ),
            onChanged: (value) {
              setState(() {}); // Reconstruire pour activer/désactiver le bouton
            },
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _commentController.text.trim().isEmpty ? null : () {
                _commentController.clear();
                _commentFocusNode.unfocus();
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _commentController.text.trim().isEmpty || _isSubmitting 
                  ? null 
                  : _submitComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Publier',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.login,
            size: 20,
            color: Color(0xFF4A5568),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Connectez-vous pour laisser un commentaire',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: widget.onAuthRequired,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Se connecter',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(CommentsState commentsState) {
    if (commentsState.isLoading && commentsState.comments.isEmpty) {
      return _buildLoadingState();
    }

    if (commentsState.error != null && commentsState.comments.isEmpty) {
      return _buildErrorState(commentsState.error!);
    }

    if (commentsState.comments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Liste des commentaires
        ...commentsState.comments.map((comment) => CommentItem(
          comment: comment,
          onDelete: () => _deleteComment(comment.id),
        )),

        // Bouton "Charger plus" si nécessaire
        if (commentsState.hasMore) ...[
          const SizedBox(height: 16),
          Center(
            child: commentsState.isLoadingMore
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () => _loadMoreComments(),
                    child: const Text(
                      'Charger plus de commentaires',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Color(0xFFE53E3E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentsPreview(CommentsState commentsState) {
    if (commentsState.isLoading) {
      return _buildLoadingState();
    }

    if (commentsState.comments.isEmpty) {
      return const Text(
        'Aucun commentaire pour le moment',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF718096),
        ),
      );
    }

    // Afficher les 2 premiers commentaires en mode compact
    final previewComments = commentsState.comments.take(2).toList();
    
    return Column(
      children: [
        ...previewComments.map((comment) => CommentItemCompact(
          comment: comment,
          onTap: () {
            setState(() {
              _showFullSection = true;
            });
          },
        )),
        
        if (commentsState.comments.length > 2) ...[
          const SizedBox(height: 8),
          Text(
            'et ${commentsState.comments.length - 2} autres commentaires...',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF718096),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFFE53E3E),
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF4A5568),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.read(commentsServiceProvider.notifier)
                  .loadComments(widget.contentType, widget.contentId, refresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.comment_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucun commentaire pour le moment',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Soyez le premier à partager votre avis !',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await ref.read(commentsServiceProvider.notifier)
          .addComment(
            widget.contentType,
            widget.contentId,
            _commentController.text.trim(),
          );

      if (success) {
        _commentController.clear();
        _commentFocusNode.unfocus();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commentaire ajouté avec succès'),
              backgroundColor: Color(0xFF38A169),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'ajout du commentaire'),
              backgroundColor: Color(0xFFE53E3E),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [CommentsSection] Erreur soumission: $e');
      
      if (e.toString().contains('Authentification requise')) {
        widget.onAuthRequired?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout du commentaire'),
            backgroundColor: Color(0xFFE53E3E),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final success = await ref.read(commentsServiceProvider.notifier)
          .deleteComment(widget.contentType, widget.contentId, commentId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commentaire supprimé'),
            backgroundColor: Color(0xFF38A169),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ [CommentsSection] Erreur suppression: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Color(0xFFE53E3E),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadMoreComments() async {
    await ref.read(commentsServiceProvider.notifier)
        .loadMoreComments(widget.contentType, widget.contentId);
  }
}