import 'dart:math';
import 'package:flutter/material.dart';

class GuessNumberScreen extends StatefulWidget {
  const GuessNumberScreen({Key? key}) : super(key: key);

  @override
  GuessNumberScreenState createState() => GuessNumberScreenState();
}

class GuessNumberScreenState extends State<GuessNumberScreen> {
  final TextEditingController controller = TextEditingController();
  final Random random = Random();
  late int targetNumber;
  int remainingAttempts = 3;
  String message = '';

  @override
  void initState() {
    super.initState();
    targetNumber = random.nextInt(16);
  }

  void checkGuess() {
    if (remainingAttempts > 0) {
      int guess = int.tryParse(controller.text) ?? -1;
      if (guess == targetNumber) {
        _showDialog('Congratulations', 'You guessed right!');
      } else {
        setState(() {
          remainingAttempts--;
          message = 'Try again! You have $remainingAttempts attempts left.';
        });
        if (remainingAttempts == 0) {
          _showDialog('Game Over', 'You lost. The number was $targetNumber.');
        }
      }
      controller.clear();
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Game Over') {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Guess a number between 0 and 15',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your guess here',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => checkGuess(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkGuess,
              child: const Text('Guess'),
            ),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
