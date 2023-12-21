import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../professor/p_home_screen.dart';
import '../../utils/components/text_field.dart';
import '../../admin/a_home_screen.dart';
import 'edit_student.dart';

class EnterRollNumberScreen extends StatefulWidget {
  const EnterRollNumberScreen({super.key});

  @override
  EnterRollNumberScreenState createState() => EnterRollNumberScreenState();
}

class EnterRollNumberScreenState extends State<EnterRollNumberScreen> {
  final TextEditingController _rollNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Roll Number'),
        leading: IconButton(
          onPressed: () async {
            final SharedPreferences sp = await SharedPreferences.getInstance();
            final String userRole = sp.getString("userRole").toString();

            if (userRole == "0") {
              Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(builder: (context) {
                return const ProfessorHomeScreen();
              }), (route) => false);
            } else if (userRole == "1") {
              Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(builder: (context) {
                return const AdminHomeScreen();
              }), (route) => false);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextField(
              controller: _rollNoController,
              keyboardType: TextInputType.text,
              enabled: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the roll number';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.badge_rounded),
              labelText: 'Roll Number',
              hintText: 'Please enter the roll number',
              obscureText: false,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String rollNumber = _rollNoController.text.trim();
                if (rollNumber.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditStudentPage(
                        studentRollNo: rollNumber,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
