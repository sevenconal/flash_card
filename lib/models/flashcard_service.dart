import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class FlashcardService with ChangeNotifier {
  List<Flashcard> _flashcards = [];

  List<Flashcard> get flashcards => _flashcards;

  FlashcardService() {
    _loadFromStorage();
  }

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
    _saveToStorage();
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
      _saveToStorage();
      notifyListeners();
    }
  }

  // Flashcard silme
  void deleteFlashcard(String id) {
    _flashcards.removeWhere((flashcard) => flashcard.id == id);
    _saveToStorage();
    notifyListeners();
  }

  // Rastgele ID oluşturma
  String _generateId() {
    final random = Random();
    return '${random.nextInt(1000000)}';
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('flashcards');
    if (jsonString == null || jsonString.isEmpty) {
      return;
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      _flashcards = decoded
          .map((item) => Flashcard.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      // Ignore malformed storage
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_flashcards.map((f) => f.toJson()).toList());
    await prefs.setString('flashcards', encoded);
  }
}