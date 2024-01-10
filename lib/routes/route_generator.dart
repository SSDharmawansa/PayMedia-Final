import 'dart:io';
import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/home_screen.dart';
import '../utils/constants/routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MyCustomForm());
      case Routes.homeScreen:
        if (args is SecondScreenArguments) {
          return MaterialPageRoute(
            builder: (_) => SecondScreen(
              username: args.username,
              nicNumber: args.nicNumber,
              contactNumber: args.contactNumber,
              emailAddress: args.emailAddress,
              gender: args.gender,
              birthday: args.birthday,
              initialImage: args.initialImage,
              intName: args.intName,
            ),
          );
        }
        return errorRoute();
      default:
        return errorRoute();
    }
  }

  static Route<dynamic> errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error: Route not found'),
        ),
      );
    });
  }
}

class SecondScreenArguments {
  final String username;
  final String nicNumber;
  final String contactNumber;
  final String emailAddress;
  final String gender;
  final DateTime? birthday;
  final File? initialImage;
  final String intName;

  SecondScreenArguments({
    required this.username,
    required this.nicNumber,
    required this.contactNumber,
    required this.emailAddress,
    required this.gender,
    this.birthday,
    this.initialImage,
    required this.intName,
  });
}
