import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'add_todo_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api_screen.dart';
import 'game_screen.dart';

class SecondScreen extends StatefulWidget {
  final String username;
  final String nicNumber;
  final String contactNumber;
  final String emailAddress;
  final String gender;
  final DateTime? birthday;
  final File? initialImage;
  final String intName;

  const SecondScreen({
    Key? key,
    required this.username,
    required this.nicNumber,
    required this.contactNumber,
    required this.emailAddress,
    required this.gender,
    this.birthday,
    this.initialImage,
    required this.intName,
  }) : super(key: key);

  @override
  State<SecondScreen> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  int currentIndex = 0;
  int todoCount = 0;
  File? image;

  @override
  void initState() {
    super.initState();
    image = widget.initialImage;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        image = File(selectedImage.path);
      });
    }
  }
  void toggleTodoCompleted(String docId, bool isCompleted) async {
    await FirebaseFirestore.instance
        .collection('todos')
        .doc(docId)
        .update({'isCompleted': !isCompleted});
  }

  void navigateToAddTodoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoScreen(isEditing: false)),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ApiScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GuessNumberScreen()),
        );
        break;
    }
  }
  void deleteTodo(String docId) async {
    await FirebaseFirestore.instance.collection('todos').doc(docId).delete();
  }
  void navigateToEditTodoScreen(String docId, Map<String, dynamic> todoData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(
          isEditing: true,
          docId: docId,
          initialData: todoData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Todo List'),
            Text('Count: $todoCount'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('todos').snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No Todos Found'));
          }

          List<DocumentSnapshot> docs = snapshot.data!.docs;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (todoCount != docs.length) {
              setState(() {
                todoCount = docs.length;
              });
            }
          });
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var todo = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;
              bool isCompleted = todo['isCompleted'] ?? false;

              return Dismissible(
                key: Key(docId),
                background: Container(color: Colors.red),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Are you sure you wish to delete this item?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("DELETE"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("CANCEL"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  deleteTodo(docId);
                },
                child: Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(color: isCompleted ? Colors.lightGreen[50] : const Color(0xFFEEEEEE),),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      leading: Container(
                        padding: const EdgeInsets.only(right: 12.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(width: 1.0, color: Colors.black26),
                          ),
                        ),
                        child: const Icon(Icons.assignment, color: Colors.blue), // Custom icon
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            todo['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5), // Adds a small gap
                          Text(
                            todo['description'],
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 5), // Adds a small gap
                          Text(
                            DateFormat('yyyy-MM-dd').format((todo['date'] as Timestamp).toDate()),
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ),
                      onTap: () {
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: Colors.green,
                            ),
                            onPressed: () => toggleTodoCompleted(docId, isCompleted),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => navigateToEditTodoScreen(docId, todo),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: GestureDetector(
                onTap: pickImage,
                child: Column(
                  children: [
                    const Text('Input Details'),
                    if (image != null)
                      SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipOval(
                              child: Image.file(image!, fit: BoxFit.cover, width: 100.0, height: 100.0),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black38,
                              ),
                              child: const Icon(Icons.linked_camera_outlined, color: Colors.white, size: 24.0),
                            ),
                          ],
                        ),
                      ),
                    if (image == null)
                      Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ListTile(title: Text('Name with Initials: ${widget.intName}')),
            ListTile(title: Text('NIC Number: ${widget.nicNumber}')),
            ListTile(title: Text('Birthday: ${widget.birthday != null ? DateFormat('yyyy-MM-dd').format(widget.birthday!) : 'Not available'}')),
            ListTile(title: Text('Contact Number: ${widget.contactNumber}')),
            ListTile(title: Text('Email Address: ${widget.emailAddress}')),
            ListTile(title: Text('Gender: ${widget.gender}')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddTodoScreen,
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'API Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Game',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        onTap: onItemTapped,
      ),
    );
  }
}