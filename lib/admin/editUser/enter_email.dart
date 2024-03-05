import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/admin/editUser/edit_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/dropdowns/prof_email_drop_down.dart';

class EnterEmailScreen extends StatefulWidget {
  const EnterEmailScreen({super.key});

  @override
  EnterEmailScreenState createState() => EnterEmailScreenState();
}

class EnterEmailScreenState extends State<EnterEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  String selectedProfEmail = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Email'),
        leading: IconButton(
          onPressed: () async {
            // final SharedPreferences sp = await SharedPreferences.getInstance();
            // final String userRole = sp.getString("userRole").toString();

            // if (userRole == "0") {
            //   Navigator.of(context).pushReplacement(
            //       CupertinoPageRoute(builder: (context) {
            //     return const ProfessorHomeScreen();
            //   }),);
            // } else if (userRole == "1") {
            //   Navigator.of(context).pushReplacement(
            //       CupertinoPageRoute(builder: (context) {
            //     return const AdminHomeScreen();
            //   }),);
            // }

            Navigator.of(context).pop();
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
            ProfEmailDropdown(
              onChanged: (String newValue) {
                setState(() {
                  selectedProfEmail = newValue;
                });
              },
            ),
            // MyTextField(
            //   controller: _emailController,
            //   keyboardType: TextInputType.emailAddress,
            //   enabled: true,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter the email';
            //     }
            //     return null;
            //   },
            //   prefixIcon: const Icon(Icons.badge_rounded),
            //   labelText: 'Email',
            //   hintText: 'Please enter the email',
            //   obscureText: false,
            // ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // String userEmail = _emailController.text.trim();
                String userEmail = selectedProfEmail;
                if (userEmail.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserPage(
                        userEmail: userEmail,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        '_emailController', _emailController));
  }
}
