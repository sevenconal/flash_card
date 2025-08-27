import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../models/flashcard_service.dart';
import 'dart:math';

enum StudyMode {
  allCards, // Tüm kartlar
  newCards, // Sadece yeni kartlar
  reviewCards, // Tekrar edilecek kartlar
  randomCards, // Rastgele kartlar
}

class StudyModeScreen extends StatefulWidget {
  const StudyModeScreen({super.key});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  late List<Flashcard> _studyCards;
  late List<Flashcard> _originalCards;
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  int _incorrectCount = 0;
  int _skippedCount = 0;
  int _totalStudied = 0;
  StudyMode _currentMode = StudyMode.allCards;
  DateTime _startTime = DateTime.now();
  bool _isCompleted = false;
  Map<String, int> _cardAttempts = {};
  List<Flashcard> _incorrectCards = [];

  @override
  void initState() {
    super.initState();
    _initializeStudySession();
  }

  void _initializeStudySession() {
    final service = Provider.of<FlashcardService>(context, listen: false);
    _originalCards = List.from(service.flashcards);
    _studyCards = List.from(_originalCards);
    _studyCards.shuffle(Random());
    _startTime = DateTime.now();
    _resetCounters();
  }

  void _resetCounters() {
    _currentIndex = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _skippedCount = 0;
    _totalStudied = 0;
    _showAnswer = false;
    _isCorrect = false;
    _cardAttempts.clear();
    _incorrectCards.clear();
    _isCompleted = false;
  }

  void _changeStudyMode(StudyMode mode) {
    setState(() {
      _currentMode = mode;
      _resetCounters();

      switch (mode) {
        case StudyMode.allCards:
          _studyCards = List.from(_originalCards);
          break;
        case StudyMode.newCards:
          // Yeni kartlar (son 3 günde eklenen)
          final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
          _studyCards = _originalCards
              .where((card) => card.createdAt.isAfter(threeDaysAgo))
              .toList();
          break;
        case StudyMode.reviewCards:
          // Tekrar edilecek kartlar (yanlış olanlar)
          _studyCards = List.from(
              _incorrectCards.isEmpty ? _originalCards : _incorrectCards);
          break;
        case StudyMode.randomCards:
          _studyCards = List.from(_originalCards);
          _studyCards.shuffle(Random());
          break;
      }

      if (_studyCards.isNotEmpty) {
        _studyCards.shuffle(Random());
      }
    });
  }

  void _nextCard() {
    if (_currentIndex < _studyCards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _isCorrect = false;
      });
    } else {
      _completeStudySession();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
        _isCorrect = false;
      });
    }
  }

  void _skipCard() {
    setState(() {
      _skippedCount++;
      _totalStudied++;
      _showAnswer = false;
      _isCorrect = false;
    });

    // Kartı sona taşı
    if (_studyCards.length > 1) {
      final skippedCard = _studyCards.removeAt(_currentIndex);
      _studyCards.add(skippedCard);
      if (_currentIndex >= _studyCards.length) {
        _currentIndex = _studyCards.length - 1;
      }
    }

    if (_totalStudied >= _studyCards.length) {
      _completeStudySession();
    }
  }

  void _markCorrect() {
    setState(() {
      _isCorrect = true;
      _correctCount++;
      _totalStudied++;
    });

    final currentCard = _studyCards[_currentIndex];
    _cardAttempts[currentCard.id] = (_cardAttempts[currentCard.id] ?? 0) + 1;

    // Çalışma sayısını artır
    final service = Provider.of<FlashcardService>(context, listen: false);
    service.incrementStudyCount();

    // Bir sonraki karta geç
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nextCard();
      }
    });
  }

  void _markIncorrect() {
    setState(() {
      _isCorrect = false;
      _incorrectCount++;
      _totalStudied++;
    });

    final currentCard = _studyCards[_currentIndex];
    _cardAttempts[currentCard.id] = (_cardAttempts[currentCard.id] ?? 0) + 1;

    // Yanlış kartı listeye ekle
    if (!_incorrectCards.contains(currentCard)) {
      _incorrectCards.add(currentCard);
    }

    // Çalışma sayısını artır
    final service = Provider.of<FlashcardService>(context, listen: false);
    service.incrementStudyCount();

    // Bir sonraki karta geç
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nextCard();
      }
    });
  }

  void _completeStudySession() {
    setState(() {
      _isCompleted = true;
    });
  }

  void _restartStudy() {
    _initializeStudySession();
  }

  Duration get _elapsedTime => DateTime.now().difference(_startTime);
  double get _accuracyRate =>
      _totalStudied > 0 ? (_correctCount / _totalStudied) * 100 : 0;
  int get _remainingCards => _studyCards.length - _currentIndex;

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    if (_studyCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Çalışma Modu'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Çalışmak için önce flashcard ekleyin!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _studyCards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Çalışma Modu (${_currentIndex + 1}/${_studyCards.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<StudyMode>(
            icon: const Icon(Icons.more_vert),
            onSelected: _changeStudyMode,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: StudyMode.allCards,
                child: Text('Tüm Kartlar'),
              ),
              const PopupMenuItem(
                value: StudyMode.newCards,
                child: Text('Yeni Kartlar'),
              ),
              const PopupMenuItem(
                value: StudyMode.reviewCards,
                child: Text('Tekrar Kartları'),
              ),
              const PopupMenuItem(
                value: StudyMode.randomCards,
                child: Text('Rastgele Kartlar'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Study mode indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getModeColor(_currentMode).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getModeColor(_currentMode)),
              ),
              child: Text(
                _getModeText(_currentMode),
                style: TextStyle(
                  color: _getModeColor(_currentMode),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Progress and statistics
            _buildProgressSection(),

            const SizedBox(height: 24),

            // Flashcard display
            Expanded(
              child: _buildFlashcardDisplay(currentCard),
            ),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: _totalStudied / _studyCards.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        // Statistics cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Doğru',
                '$_correctCount',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Yanlış',
                '$_incorrectCount',
                Colors.red,
                Icons.cancel,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Atla',
                '$_skippedCount',
                Colors.orange,
                Icons.skip_next,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Time and accuracy
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Süre',
                _formatDuration(_elapsedTime),
                Colors.blue,
                Icons.timer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Başarı',
                '${_accuracyRate.round()}%',
                _accuracyRate >= 80
                    ? Colors.green
                    : _accuracyRate >= 60
                        ? Colors.orange
                        : Colors.red,
                Icons.emoji_events,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardDisplay(Flashcard card) {
    return GestureDetector(
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
              // Card type indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: card.frontText.split(' ').length == 1
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: card.frontText.split(' ').length == 1
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                child: Text(
                  card.frontText.split(' ').length == 1 ? 'Kelime' : 'Cümle',
                  style: TextStyle(
                    color: card.frontText.split(' ').length == 1
                        ? Colors.orange
                        : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                _showAnswer ? card.backText : card.frontText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Tap instruction
              Text(
                _showAnswer ? 'Dokununca gizle' : 'Dokununca cevabı gör',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),

              // Attempt count
              if (_cardAttempts[card.id] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_cardAttempts[card.id]} kez çalışıldı',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_showAnswer) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _previousCard,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Önceki Kart',
          ),
          ElevatedButton.icon(
            onPressed: _skipCard,
            icon: const Icon(Icons.skip_next),
            label: const Text('Atla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _nextCard,
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Sonraki Kart',
          ),
        ],
      );
    }

    return Column(
      children: [
        // Feedback buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _markIncorrect,
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text('Yanlış'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _markCorrect,
                icon: const Icon(Icons.check, color: Colors.green),
                label: const Text('Doğru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Navigation
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
    );
  }

  Widget _buildCompletionScreen() {
    final totalTime = _elapsedTime;
    final totalCards = _studyCards.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Tamamlandı!'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 80,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 24),

            // Congratulations text
            const Text(
              'Tebrikler!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${totalCards} kartı başarıyla tamamladınız!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Final statistics
            _buildFinalStats(totalTime),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _restartStudy,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Çalış'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Sayfa'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
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

  Widget _buildFinalStats(Duration totalTime) {
    return Column(
      children: [
        _buildFinalStatRow(
            'Toplam Süre', _formatDuration(totalTime), Icons.timer),
        _buildFinalStatRow('Doğru Cevap', '$_correctCount', Icons.check_circle),
        _buildFinalStatRow('Yanlış Cevap', '$_incorrectCount', Icons.cancel),
        _buildFinalStatRow('Atlanan Kart', '$_skippedCount', Icons.skip_next),
        _buildFinalStatRow(
            'Başarı Oranı', '${_accuracyRate.round()}%', Icons.emoji_events),
      ],
    );
  }

  Widget _buildFinalStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(StudyMode mode) {
    switch (mode) {
      case StudyMode.allCards:
        return Colors.blue;
      case StudyMode.newCards:
        return Colors.green;
      case StudyMode.reviewCards:
        return Colors.orange;
      case StudyMode.randomCards:
        return Colors.purple;
    }
  }

  String _getModeText(StudyMode mode) {
    switch (mode) {
      case StudyMode.allCards:
        return 'Tüm Kartlar';
      case StudyMode.newCards:
        return 'Yeni Kartlar';
      case StudyMode.reviewCards:
        return 'Tekrar Kartları';
      case StudyMode.randomCards:
        return 'Rastgele Kartlar';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
