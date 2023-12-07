import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:paymedia/utils/constants/routes.dart';
import 'package:provider/provider.dart';
import 'controllers/nic_calculation.dart';
import 'models/todo_counter.dart';
import 'routes/route_generator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    ChangeNotifierProvider(
    create: (context) => TodoCounter(),
    child: const MyApp(),
  ),
  //   ChangeNotifierProvider(
  //     create: (context) => TodoCounter(),
  //     child: DevicePreview(
  //     builder: (context) => const MyApp(),
  //     enabled: true,
  //     ),
  //   ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = ' ';
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      title: appTitle,
      home: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final nicNumberController = TextEditingController();
  final contactNumberController = TextEditingController();
  final emailAddressController = TextEditingController();
  bool isMale = false;
  bool isFemale = false;
  DateTime? birthday;
  String intName = '';
  String gender = '';
  // Old NIC format: 9 digits followed by V
  RegExp oldNICValid = RegExp(r'^[0-9]{9}[vV]$');
  // New NIC format: 12 digits
  RegExp newNICValid = RegExp(r'^[0-9]{12}$');


  //NIC birthday cal
  DateTime? calculateBirthdayFromNIC(String nic) {
    int year, dayOfYear;

    if (nic.length == 10) {
      year = 1900 + int.parse(nic.substring(0, 2));
      dayOfYear = int.parse(nic.substring(2, 5));
      if (dayOfYear > 500) {
        dayOfYear -= 500; // Female
      }
    } else if (nic.length == 12) {
      year = int.parse(nic.substring(0, 4));
      dayOfYear = int.parse(nic.substring(4, 7));
      if (dayOfYear > 500) {
        dayOfYear -= 500; // Female
      }
    } else {
      return null;
    }

    if (!isLeapYear(year) && dayOfYear > 59) {

      dayOfYear -= 1;
    }

    return DateTime(year, 1, 1).add(Duration(days: dayOfYear - 1));
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
  }

  //Name with initials
  String getNameWithInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';
    // Iterate over all parts except the last one
    for (int i = 0; i < names.length - 1; i++) {
      String namePart = names[i];
      if (namePart.isNotEmpty) {
        initials += '${namePart[0]}.';
      }
    }
    // Append the last word (last name) as it is
    return initials + (names.isNotEmpty ? names.last : '');
  }

  //NIC gender
  String determineGenderFromNIC(String nic) {
    if (nic.length == 10) {
      // Old NIC format
      int dayOfYear = int.parse(nic.substring(2, 5));
      return (dayOfYear > 500) ? 'Female' : 'Male';
    } else if (nic.length == 12) {
      // New NIC format
      int dayOfYear = int.parse(nic.substring(4, 7));
      return (dayOfYear > 500) ? 'Female' : 'Male';
    }
    return 'Unknown';
  }

  @override
  void dispose() {
    usernameController.dispose();
    nicNumberController.dispose();
    contactNumberController.dispose();
    emailAddressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: const Center(child: Text('Sign Up'),),
      ),
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          SingleChildScrollView(
        child:Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image.asset('assets/image/bank.jpg'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  hintText: 'Username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: nicNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  hintText: 'NIC Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a NIC Number';
                  }
                  if (!oldNICValid.hasMatch(value) && !newNICValid.hasMatch(value)) {
                    return 'Please enter a valid NIC number';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: contactNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  hintText: 'Contact Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact number';
                  } else if (!RegExp(r'(?:\+94|0)?[0-9]{9,10}$').hasMatch(value)) {
                    return 'Please enter a valid Sri Lankan contact number';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: emailAddressController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  hintText: 'Email Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return '''Please enter a valid email address''';
                  }
                  return null;
                },
              ),
            ),
            // CheckboxListTile(
            //   title: const Text('Male'),
            //   value: isMale,
            //   onChanged: (bool? newValue) {
            //     setState(() {
            //       isMale = newValue!;
            //       isFemale = false; // Uncheck Female when Male is checked
            //     });
            //   },
            // ),
            //
            // CheckboxListTile(
            //   title: const Text('Female'),
            //   value: isFemale,
            //   onChanged: (bool? newValue) {
            //     setState(() {
            //       isFemale = newValue!;
            //       isMale = false; // Uncheck Male when Female is checked
            //     });
            //   },
            // ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(right: 30),

                child: ElevatedButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed:() {
                  if (_formKey.currentState!.validate()) {
                    birthday = NicCalculation.calculateBirthdayFromNIC(
                        nicNumberController.text);
                    gender = determineGenderFromNIC(
                        nicNumberController.text);
                    intName = getNameWithInitials(
                        usernameController.text);

                    Navigator.of(context).pushNamed(
                        Routes.homeScreen,
                    arguments: SecondScreenArguments(
                        username: usernameController.text,
                        nicNumber: nicNumberController.text,
                        contactNumber: contactNumberController.text,
                        emailAddress: emailAddressController.text,
                        birthday: birthday,
                        gender: gender,
                        intName: intName),
                    );

                    // Navigator.push(context,
                    //   MaterialPageRoute(builder: (context) =>
                    //       SecondScreen(
                    //         username: usernameController.text,
                    //         nicNumber: nicNumberController.text,
                    //         contactNumber: contactNumberController.text,
                    //         emailAddress: emailAddressController.text,
                    //         gender: gender,
                    //         // gender: isMale ? 'Male' : isFemale
                    //         //     ? 'Female'
                    //         //     : 'Not selected',
                    //         birthday: birthday,
                    //         intName: intName,
                    //       )),
                    // );
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all required fields'))
                    );
                  }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text('Submit'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          ),]
      ),
    );
  }
}
