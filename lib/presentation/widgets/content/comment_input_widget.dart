import 'package:flutter/material.dart';

class CommentInputWidget extends StatefulWidget {
  final Function(String content) onSubmit;
  final String? placeholder;
  final bool enabled;

  const CommentInputWidget({
    super.key,
    required this.onSubmit,
    this.placeholder,
    this.enabled = true,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isExpanded = _focusNode.hasFocus;
    });
  }

  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(content);
      _controller.clear();
      _focusNode.unfocus();
      
      // Afficher un feedback de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Commentaire publié avec succès'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la publication: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
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

  void _cancel() {
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar et champ de saisie
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar de l'utilisateur connecté
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              
              // Champ de saisie
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled && !_isSubmitting,
                      decoration: InputDecoration(
                        hintText: widget.placeholder ?? 'Écrivez un commentaire...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: _isSubmitting
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _controller.text.trim().isNotEmpty
                                ? IconButton(
                                    onPressed: _submitComment,
                                    icon: Icon(
                                      Icons.send,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    tooltip: 'Publier le commentaire',
                                  )
                                : null,
                      ),
                      maxLines: _isExpanded ? 4 : 1,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        setState(() {}); // Pour mettre à jour l'icône d'envoi
                      },
                      onSubmitted: (_) => _submitComment(),
                    ),
                    
                    // Actions étendues
                    if (_isExpanded) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Informations sur les commentaires
                          Expanded(
                            child: Text(
                              'Soyez respectueux et constructif dans vos commentaires',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          
                          // Actions
                          TextButton(
                            onPressed: _cancel,
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _controller.text.trim().isNotEmpty && !_isSubmitting
                                ? _submitComment
                                : null,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Publier'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Conseils pour les commentaires (affiché seulement lors du premier focus)
          if (_isExpanded && _controller.text.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conseils pour un bon commentaire',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Partagez votre expérience ou vos questions\n'
                    '• Restez constructif et respectueux\n'
                    '• Évitez le spam et les contenus inappropriés',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 