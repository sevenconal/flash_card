import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_service.dart';

class AddSentenceScreen extends StatefulWidget {
  const AddSentenceScreen({super.key});

  @override
  State<AddSentenceScreen> createState() => _AddSentenceScreenState();
}

class _AddSentenceScreenState extends State<AddSentenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _turkishController = TextEditingController();

  @override
  void dispose() {
    _englishController.dispose();
    _turkishController.dispose();
    super.dispose();
  }

  void _saveSentence() {
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
        title: const Text('Yeni Cümle Ekle'),
        actions: [
          IconButton(
            onPressed: _saveSentence,
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
                  labelText: 'İngilizce Cümle',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen İngilizce cümleyi girin';
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
                maxLines: 3,
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
                  onPressed: _saveSentence,
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