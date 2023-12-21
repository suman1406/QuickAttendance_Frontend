import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../professor/p_home_screen.dart';
import '../utils/api_constants.dart';
import '../utils/components/text_field.dart';
import '../utils/components/toast.dart';
import 'a_home_screen.dart';

class DeleteAdminPage extends StatefulWidget {
  const DeleteAdminPage({super.key});

  @override
  DeleteAdminPageState createState() => DeleteAdminPageState();
}

class DeleteAdminPageState extends State<DeleteAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _userEmailController = TextEditingController();
  final _adminProfNameController = TextEditingController();

  @override
  void dispose() {
    _userEmailController.dispose();
    _adminProfNameController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    // No space allowed. Can't be empty.
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Check for spaces
    if (value.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    // Check if it's a valid email address
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _adminProfNameValidator(String? value) {
    // No space allowed. Can't be empty.
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }

    return null;
  }

  void deleteAdmin() async {
    final userEmail = _userEmailController.text.trim();
    final adminProfName = _adminProfNameController.text.trim();

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Create Dio instance
    final dio = Dio();

    // Send DELETE request to backend server
    try {
      final response = await dio.delete(
        ApiConstants().deleteAdmin,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'Email': userEmail,
          'adminProfName': adminProfName,
        },
      );

      if (response.statusCode == 200) {
        showToast('Admin member deleted successfully');
      } else if (response.statusCode == 400) {
        showToast('Missing details');
      } else if (response.statusCode == 401) {
        showToast('Admin doesn\'t exist');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting admin: $error');
      }
    } finally {
      setState(() {
        _userEmailController.clear();
        _adminProfNameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Admin'),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextField(
                controller: _adminProfNameController,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                keyboardType: TextInputType.name,
                validator: _adminProfNameValidator,
                labelText: 'Admin Name',
                hintText: 'Please enter admin Name',
                obscureText: false,
                enabled: true,
              ),
              const SizedBox(height: 16.0),
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
                    // Form is valid, proceed with deleteAdmin
                    final SharedPreferences sp =
                        await SharedPreferences.getInstance();
                    final String? currentUserEmail = sp.getString("userEmail");

                    if (_userEmailController.text == currentUserEmail) {
                      showToast('Cannot delete yourself');
                      return;
                    } else {
                      deleteAdmin();
                    }
                  }
                },
                child: const Text('Delete Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
