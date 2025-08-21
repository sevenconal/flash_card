import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_service.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _turkishController = TextEditingController();

  @override
  void dispose() {
    _englishController.dispose();
    _turkishController.dispose();
    super.dispose();
  }

  void _saveWord() {
    if (_formKey.currentState!.validate()) {
      final flashcardService = Provider.of<FlashcardService>(context, listen: false);
      flashcardService.addFlashcard(_englishController.text, _turkishController.text);
      
      Navigator.pop(context); // Önceki ekrana dön
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kelime Ekle'),
        actions: [
          IconButton(
            onPressed: _saveWord,
            icon: const Icon(Icons.save),
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _englishController,
                decoration: const InputDecoration(
                  labelText: 'İngilizce Kelime',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen İngilizce kelimeyi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _turkishController,
                decoration: const InputDecoration(
                  labelText: 'Türkçe Karşılığı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen Türkçe karşılığı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWord,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}