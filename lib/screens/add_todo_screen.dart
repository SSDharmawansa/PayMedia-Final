import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paymedia/screens/ui/widgets/custom_dialog.dart';

class AddTodoScreen extends StatefulWidget {
  final bool isEditing;
  final String? docId;
  final Map<String, dynamic>? initialData;

  const AddTodoScreen({
    Key? key,
    this.isEditing = false,
    this.docId,
    this.initialData,
  }) : super(key: key);

  @override
  State<AddTodoScreen> createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _todoDescriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _todoDescriptionController = TextEditingController(text: widget.initialData?['description'] ?? '');
    _selectedDate = widget.initialData?['date'].toDate() ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSubmissionSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomDialog();
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> todoData = {
        'name': _nameController.text,
        'description': _todoDescriptionController.text,
        'date': Timestamp.fromDate(_selectedDate),
      };

      if (widget.isEditing && widget.docId != null) {
        // Update existing todo
        await FirebaseFirestore.instance
            .collection('todos')
            .doc(widget.docId)
            .update(todoData);
      } else {
        // Add new todo
        await FirebaseFirestore.instance
            .collection('todos')
            .add(todoData);
      }

      _showSubmissionSuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Todo Task' : 'Add Todo Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _todoDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Todo Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text("Selected date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
