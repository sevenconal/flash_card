import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardService with ChangeNotifier {
  List<Flashcard> _flashcards = [];

  List<Flashcard> get flashcards => _flashcards;

  // Yeni bir flashcard ekleme
  void addFlashcard(String frontText, String backText) {
    final newFlashcard = Flashcard(
      id: _generateId(),
      frontText: frontText,
      backText: backText,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _flashcards.add(newFlashcard);
    notifyListeners();
  }

  // Flashcard güncelleme
  void updateFlashcard(String id, String frontText, String backText) {
    final index = _flashcards.indexWhere((flashcard) => flashcard.id == id);
    if (index != -1) {
      _flashcards[index] = _flashcards[index].copyWith(
        frontText: frontText,
        backText: backText,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Flashcard silme
  void deleteFlashcard(String id) {
    _flashcards.removeWhere((flashcard) => flashcard.id == id);
    notifyListeners();
  }

  // Rastgele ID oluşturma
  String _generateId() {
    final random = Random();
    return '${random.nextInt(1000000)}';
  }
}