import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_service.dart';
import '../widgets/flashcard_item.dart';
import 'add_flashcard_screen.dart';
import 'study_mode_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Uygulaması'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudyModeScreen(),
                ),
              );
            },
            icon: const Icon(Icons.school),
            tooltip: 'Çalışma Modu',
          ),
        ],
      ),
      body: Consumer<FlashcardService>(
        builder: (context, flashcardService, child) {
          final flashcards = flashcardService.flashcards;

          if (flashcards.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz hiç flashcard oluşturulmamış.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Yeni bir flashcard oluşturmak için + butonuna tıklayın.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistics card
              Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${flashcards.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text('Toplam Kart'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${flashcards.where((f) => f.frontText.split(' ').length > 1).length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('Cümle'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${flashcards.where((f) => f.frontText.split(' ').length == 1).length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const Text('Kelime'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Study mode button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudyModeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school),
                    label: const Text('Çalışmaya Başla'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Flashcards list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final flashcard = flashcards[index];
                    return FlashcardItem(flashcard: flashcard);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return const AddFlashcardOptions();
            },
          );
        },
        tooltip: 'Yeni Flashcard',
        child: const Icon(Icons.add),
      ),
    );
  }
}
