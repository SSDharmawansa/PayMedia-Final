import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  factory Todo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}
