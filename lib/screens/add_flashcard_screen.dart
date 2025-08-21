import 'package:flutter/material.dart';
import 'add_word_screen.dart';
import 'add_sentence_screen.dart';

class AddFlashcardOptions extends StatelessWidget {
  const AddFlashcardOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Yeni Flashcard Türü Seçin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Bottom sheet'i kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddWordScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Kelime'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Bottom sheet'i kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSentenceScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Cümle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}