import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../screens/add_word_screen.dart';
// ignore: unused_import
import '../screens/add_sentence_screen.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_service.dart';

class FlashcardItem extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardItem({super.key, required this.flashcard});

  @override
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isFlipped
                    ? widget.flashcard.backText
                    : widget.flashcard.frontText,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              // Tarih bilgisi
              Text(
                'Oluşturulma: ${widget.flashcard.createdAt.toString().split(' ').first}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              // İşlem butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      // Düzenleme işlemi
                      _editFlashcard(context);
                    },
                    icon: const Icon(Icons.edit),
                    tooltip: 'Düzenle',
                  ),
                  IconButton(
                    onPressed: () {
                      // Silme işlemi
                      _deleteFlashcard(context);
                    },
                    icon: const Icon(Icons.delete),
                    tooltip: 'Sil',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editFlashcard(BuildContext context) {
    // Düzenleme işlemi için geçici olarak AddWordScreen kullanıyoruz
    // Gerçek uygulamada düzenleme için özel bir ekran oluşturulabilir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddWordScreen()),
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
                Navigator.pop(context); // Dialog'u kapat
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                flashcardService.deleteFlashcard(widget.flashcard.id);
                Navigator.pop(context); // Dialog'u kapat
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
