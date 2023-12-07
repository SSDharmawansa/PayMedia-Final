import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addTodoTask(
      {required String name, required String description, required DateTime date}) async {
    CollectionReference todos = firestore.collection('todos');

    return todos.add({
      'name': name,
      'description': description,
      'date': date,
    }).then((value) => print("Todo Added"))
        .catchError((error) => print("Failed to add todo: $error"));
  }
  Stream<QuerySnapshot> getTodosStream() {
    return firestore.collection('todos').snapshots();
  }
}
