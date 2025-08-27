import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../screens/edit_flashcard_screen.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_service.dart';

class FlashcardItem extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardItem({super.key, required this.flashcard});

  @override
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _animationController.reverse().then((_) {
        setState(() {
          _isFlipped = false;
        });
      });
    } else {
      _animationController.forward().then((_) {
        setState(() {
          _isFlipped = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final flipValue = _animation.value;
          final isHalfway = flipValue >= 0.5;

          // Kartın ön ve arka yüzlerini ayrı ayrı oluştur
          final frontFace = _buildCardFace(
            text: widget.flashcard.frontText,
            language: 'İngilizce',
            icon: Icons.language,
            isBack: false,
          );

          final backFace = _buildCardFace(
            text: widget.flashcard.backText,
            language: 'Türkçe',
            icon: Icons.translate,
            isBack: true,
          );

          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: _isFlipped ? 12 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: isHalfway ? backFace : frontFace,
              key: ValueKey(isHalfway),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace({
    required String text,
    required String language,
    required IconData icon,
    required bool isBack,
  }) {
    return Container(
      key: ValueKey('${isBack ? 'back' : 'front'}_$text'),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card type indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isBack ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  language,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isBack ? Colors.blue[800] : Colors.grey[700],
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                icon,
                color: isBack ? Colors.blue[600] : Colors.grey[600],
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main text content
          Text(
            text,
            style: TextStyle(
              fontSize: isBack ? 20 : 22,
              fontWeight: FontWeight.w600,
              color: isBack ? Colors.blue[800] : Colors.grey[800],
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Date information
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                'Oluşturulma: ${widget.flashcard.createdAt.toString().split(' ').first}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Flip hint
              if (!isBack)
                Text(
                  'Çevirmek için dokun',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const Spacer(),

              // Edit button
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    _editFlashcard(context);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  tooltip: 'Düzenle',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Delete button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    _deleteFlashcard(context);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red[700],
                    size: 20,
                  ),
                  tooltip: 'Sil',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editFlashcard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlashcardScreen(flashcard: widget.flashcard),
      ),
    );
  }

  void _deleteFlashcard(BuildContext context) {
    final flashcardService = Provider.of<FlashcardService>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Flashcard Sil'),
          content: const Text(
            'Bu flashcard\'ı silmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                flashcardService.deleteFlashcard(widget.flashcard.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
