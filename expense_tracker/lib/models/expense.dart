class Expense {
  final String id; // Added unique ID for easier identification/deletion
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? note; // Added notes field

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    String? id, // Optional ID parameter
  }) : id =
           id ??
           DateTime.now().millisecondsSinceEpoch
               .toString(); // Auto-generate ID if not provided

  // Convert an Expense object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'note': note,
    };
  }

  // Convert a Map to an Expense object
  static Expense fromMap(Map<String, dynamic> map) {
    // Use try-catch for safer date parsing
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(map['date']);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Expense(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? '',
      amount:
          (map['amount'] is int)
              ? (map['amount'] as int).toDouble()
              : (map['amount'] ?? 0.0),
      date: parsedDate,
      category: map['category'] ?? 'Uncategorized',
      note: map['note'],
    );
  }

  // Create a copy of the expense with some fields updated
  Expense copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? note,
  }) {
    return Expense(
      id: id, // Keep the same ID
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}
