class Flashcard {
  final String id;
  final String frontText; // İngilizce kelime/cümle
  final String backText;  // Türkçe karşılığı
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON'dan Flashcard nesnesi oluşturma
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      frontText: json['frontText'],
      backText: json['backText'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Flashcard nesnesini JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frontText': frontText,
      'backText': backText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Kopyalama metodu (güncelleme işlemleri için)
  Flashcard copyWith({
    String? id,
    String? frontText,
    String? backText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}