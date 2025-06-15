import 'package:flutter/material.dart';
import '../../../data/models/publication_model.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final String publicationId;
  final Function(String parentId, String content)? onReply;
  final Function(String commentId)? onLike;
  final Function(String commentId)? onDelete;
  final int maxDepth;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.publicationId,
    this.onReply,
    this.onLike,
    this.onDelete,
    this.maxDepth = 3,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _showReplyInput = false;
  bool _showReplies = true;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: widget.comment.depth * 16.0,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentContent(),
          if (_showReplyInput) _buildReplyInput(),
          if (widget.comment.hasReplies && _showReplies) _buildReplies(),
        ],
      ),
    );
  }

  Widget _buildCommentContent() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du commentaire
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    widget.comment.author.firstName.isNotEmpty
                        ? widget.comment.author.firstName[0].toUpperCase()
                        : '?',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Nom et date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.comment.author.firstName} ${widget.comment.author.lastName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.comment.formattedDate,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (widget.comment.isEdited) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(modifié)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menu d'actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'flag',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 16),
                          SizedBox(width: 8),
                          Text('Signaler'),
                        ],
                      ),
                    ),
                    // Option de suppression seulement pour l'auteur
                    if (_isAuthor())
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Contenu du commentaire
            Text(
              widget.comment.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Actions du commentaire
            Row(
              children: [
                // Like
                InkWell(
                  onTap: () => widget.onLike?.call(widget.comment.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.comment.userHasLiked 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          size: 16,
                          color: widget.comment.userHasLiked
                              ? Colors.red
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        if (widget.comment.likesCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            widget.comment.likesCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.comment.userHasLiked
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Répondre
                if (widget.comment.canHaveReplies && 
                    widget.comment.depth < widget.maxDepth)
                  InkWell(
                    onTap: _toggleReplyInput,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Répondre',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const Spacer(),
                
                // Afficher/masquer les réponses
                if (widget.comment.hasReplies)
                  InkWell(
                    onTap: _toggleReplies,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showReplies ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.comment.repliesCount} réponse${widget.comment.repliesCount > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répondre à ${widget.comment.author.firstName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _replyController,
            decoration: InputDecoration(
              hintText: 'Écrivez votre réponse...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelReply,
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _submitReply,
                child: const Text('Répondre'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplies() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: widget.comment.replies.map((reply) {
          return CommentWidget(
            comment: reply,
            publicationId: widget.publicationId,
            onReply: widget.onReply,
            onLike: widget.onLike,
            onDelete: widget.onDelete,
            maxDepth: widget.maxDepth,
          );
        }).toList(),
      ),
    );
  }

  void _toggleReplyInput() {
    setState(() {
      _showReplyInput = !_showReplyInput;
      if (!_showReplyInput) {
        _replyController.clear();
      }
    });
  }

  void _toggleReplies() {
    setState(() {
      _showReplies = !_showReplies;
    });
  }

  void _cancelReply() {
    setState(() {
      _showReplyInput = false;
      _replyController.clear();
    });
  }

  void _submitReply() {
    final content = _replyController.text.trim();
    if (content.isNotEmpty) {
      widget.onReply?.call(widget.comment.id, content);
      _cancelReply();
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'flag':
        _flagComment();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _flagComment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commentaire signalé')),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le commentaire'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce commentaire ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call(widget.comment.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  bool _isAuthor() {
    // TODO: Vérifier si l'utilisateur actuel est l'auteur du commentaire
    // Cela nécessiterait d'avoir accès aux informations de l'utilisateur connecté
    return false;
  }
} 