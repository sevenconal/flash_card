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
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudyModeScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Çalışmaya Başla',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${flashcards.length} kart ile çalış',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getMotivationalMessage(
                                          flashcards.length),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStudyStat(
                                context,
                                'Bugün',
                                '${flashcardService.dailyStudyCount}',
                                Icons.today,
                                Colors.orange,
                              ),
                              _buildStudyStat(
                                context,
                                'Bu Hafta',
                                '${flashcardService.weeklyStudyCount}',
                                Icons.calendar_view_week,
                                Colors.green,
                              ),
                              _buildStudyStat(
                                context,
                                'Toplam',
                                '${flashcardService.totalStudyCount}',
                                Icons.emoji_events,
                                Colors.yellow,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildStudyStat(BuildContext context, String label, String count,
      IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _getMotivationalMessage(int cardCount) {
    if (cardCount == 0) {
      return 'İlk kartınızı oluşturun!';
    } else if (cardCount < 5) {
      return 'Harika başlangıç!';
    } else if (cardCount < 10) {
      return 'Çok güzel ilerliyorsunuz!';
    } else if (cardCount < 20) {
      return 'Muhteşem! Devam edin!';
    } else {
      return 'Siz bir kelime ustasısınız!';
    }
  }
}
