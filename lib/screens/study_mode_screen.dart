import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../models/flashcard_service.dart';
import 'dart:math';

class StudyModeScreen extends StatefulWidget {
  const StudyModeScreen({super.key});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  late List<Flashcard> _studyCards;
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    final service = Provider.of<FlashcardService>(context, listen: false);
    _studyCards = List.from(service.flashcards);
    _studyCards.shuffle(Random());
    _totalCount = _studyCards.length;
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _studyCards.length;
      _showAnswer = false;
      _isCorrect = false;
    });
  }

  void _previousCard() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _studyCards.length) % _studyCards.length;
      _showAnswer = false;
      _isCorrect = false;
    });
  }

  void _markCorrect() {
    setState(() {
      _isCorrect = true;
      _correctCount++;
    });
    // Çalışma sayısını artır
    final service = Provider.of<FlashcardService>(context, listen: false);
    service.incrementStudyCount();
  }

  void _markIncorrect() {
    setState(() {
      _isCorrect = false;
    });
    // Çalışma sayısını artır
    final service = Provider.of<FlashcardService>(context, listen: false);
    service.incrementStudyCount();
  }

  @override
  Widget build(BuildContext context) {
    if (_studyCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Çalışma Modu')),
        body: const Center(
          child: Text('Çalışmak için önce flashcard ekleyin!'),
        ),
      );
    }

    final currentCard = _studyCards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Çalışma Modu (${_currentIndex + 1}/${_studyCards.length})',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _studyCards.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Score display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Doğru: $_correctCount'),
                    Text('Toplam: $_totalCount'),
                    Text(
                      'Başarı: ${_totalCount > 0 ? ((_correctCount / _totalCount) * 100).round() : 0}%',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Flashcard display
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: Card(
                  elevation: 8,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAnswer ? 'Türkçe Karşılığı:' : 'İngilizce:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showAnswer
                              ? currentCard.backText
                              : currentCard.frontText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (_showAnswer)
                          Text(
                            'Dokununca gizle',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          )
                        else
                          Text(
                            'Dokununca cevabı gör',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Answer feedback buttons (only show when answer is visible)
            if (_showAnswer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _markIncorrect,
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Yanlış'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _markCorrect,
                    icon: const Icon(Icons.check, color: Colors.green),
                    label: const Text('Doğru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _previousCard,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Önceki Kart',
                ),
                IconButton(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Sonraki Kart',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
