/// COMMENT_ITEM.DART - COMPOSANT D'AFFICHAGE D'UN COMMENTAIRE
/// 
/// FONCTIONNALITÉS :
/// - Affichage des informations du commentaire (auteur, contenu, date)
/// - Avatar utilisateur avec fallback
/// - Actions contextuelles (supprimer si propriétaire)
/// - Format de date intelligent (relatif)
/// - Design responsive et accessible
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/comments_service.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onDelete;
  final bool showActions;

  const CommentItem({
    super.key,
    required this.comment,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du commentaire
          _buildCommentHeader(context),
          const SizedBox(height: 12),
          
          // Contenu du commentaire
          _buildCommentContent(),
          
          // Actions (si activées)
          if (showActions && comment.isOwner) ...[
            const SizedBox(height: 12),
            _buildCommentActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar utilisateur
        _buildUserAvatar(),
        const SizedBox(width: 12),
        
        // Informations utilisateur
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom utilisateur
              Text(
                comment.authorName,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Date du commentaire
              Text(
                _formatDate(comment.createdAt),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
        
        // Badge propriétaire (optionnel)
        if (comment.isOwner)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Vous',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE53E3E),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF7FAFC),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: comment.authorAvatar != null && comment.authorAvatar!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: comment.authorAvatar!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildAvatarFallback(),
              errorWidget: (context, url, error) => _buildAvatarFallback(),
            )
          : _buildAvatarFallback(),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    // Générer une couleur basée sur le nom d'utilisateur
    final colors = [
      const Color(0xFFE53E3E),
      const Color(0xFF38A169),
      const Color(0xFF3182CE),
      const Color(0xFF805AD5),
      const Color(0xFFE67E22),
      const Color(0xFF00ACC1),
    ];
    
    final colorIndex = comment.authorName.hashCode.abs() % colors.length;
    final backgroundColor = colors[colorIndex];
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(comment.authorName),
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentContent() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        comment.content,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF4A5568),
          height: 1.5,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCommentActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Bouton supprimer
        TextButton.icon(
          onPressed: () => _showDeleteConfirmation(context),
          icon: const Icon(
            Icons.delete_outline,
            size: 16,
            color: Color(0xFFE53E3E),
          ),
          label: const Text(
            'Supprimer',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFFE53E3E),
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Supprimer le commentaire',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce commentaire ? Cette action est irréversible.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF4A5568),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    // Configurer la locale française pour timeago
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    
    // Si c'est aujourd'hui, utiliser timeago
    if (difference.inDays == 0) {
      return timeago.format(date, locale: 'fr');
    }
    
    // Si c'est cette semaine
    if (difference.inDays < 7) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} ';
    }
    
    // Si c'est cette année
    if (date.year == now.year) {
      return '${date.day}/${date.month.toString().padLeft(2, '0')}';
    }
    
    // Sinon, afficher la date complète
    return '${date.day}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Widget de commentaire en mode compact pour les listes
class CommentItemCompact extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onTap;

  const CommentItemCompact({
    super.key,
    required this.comment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar compact
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE53E3E),
              ),
              child: Center(
                child: Text(
                  _getInitials(comment.authorName),
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Contenu compact
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Color(0xFF4A5568),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }
}