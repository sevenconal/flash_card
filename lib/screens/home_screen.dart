import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_service.dart';
import '../widgets/flashcard_item.dart';
import 'add_flashcard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Uygulaması'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<FlashcardService>(
        builder: (context, flashcardService, child) {
          final flashcards = flashcardService.flashcards;
          
          if (flashcards.isEmpty) {
            return const Center(
              child: Text(
                'Henüz hiç flashcard oluşturulmamış.\nYeni bir flashcard oluşturmak için + butonuna tıklayın.',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = flashcards[index];
              return FlashcardItem(flashcard: flashcard);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // AddFlashcardScreen'e yönlendirme
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