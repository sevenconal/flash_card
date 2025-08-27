import 'package:flutter/material.dart';
import 'add_word_screen.dart';
import 'add_sentence_screen.dart';
import 'study_mode_screen.dart';

class AddFlashcardOptions extends StatelessWidget {
  const AddFlashcardOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Ne yapmak istiyorsunuz?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          // Hızlı çalışma seçeneği
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudyModeScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Hızlı Çalışma'),
            ),
          ),
          
          const Divider(),
          
          const Text(
            'Yeni Flashcard Türü Seçin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}