import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../professor/p_home_screen.dart';
import '../utils/api_constants.dart';
import '../utils/components/text_field.dart';
import '../utils/components/toast.dart';
import 'a_home_screen.dart';

class ActivateUserPage extends StatefulWidget {
  const ActivateUserPage({super.key});

  @override
  ActivateUserPageState createState() => ActivateUserPageState();
}

class ActivateUserPageState extends State<ActivateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _userEmailController = TextEditingController();

  @override
  void dispose() {
    _userEmailController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  void activateUser() async {
    final userEmail = _userEmailController.text.trim();

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    final dio = Dio();

    try {
      final response = await dio.post(
        ApiConstants().activateUser,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'email': userEmail,
        },
      );

      if (response.statusCode == 201) {
        showToast('User activated successfully');
      } else if (response.statusCode == 403) {
        showToast('User not found');
      } else if (response.statusCode == 500) {
        showToast('Failed to activate user');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error activating user: $error');
      }
    } finally {
      setState(() {
        _userEmailController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activate User'),
        leading: IconButton(
          onPressed: () async {
            final SharedPreferences sp = await SharedPreferences.getInstance();
            final String userRole = sp.getString("userRole").toString();

            if (userRole == "0") {
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) {
                return const ProfessorHomeScreen();
              }),);
            } else if (userRole == "1") {
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) {
                return const AdminHomeScreen();
              }),);
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextField(
                controller: _userEmailController,
                prefixIcon: const Icon(Icons.badge_rounded),
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
                labelText: 'Email',
                hintText: 'Please enter an email',
                obscureText: false,
                enabled: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    activateUser();
                  }
                },
                child: const Text('Activate User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
