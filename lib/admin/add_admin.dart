import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/components/text_field.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  AddAdminPageState createState() => AddAdminPageState();
}

class AddAdminPageState extends State<AddAdminPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _newUserEmailController = TextEditingController();
  final String _errorMessage = '';

  @override
  void dispose() {
    _userNameController.dispose();
    _newUserEmailController.dispose();
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

  String? _userNameValidator(String? value) {
    // No space allowed. Can't be empty.
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  void addAdmin() async {
    final userName = _userNameController.text.trim();
    final newUserEmail = _newUserEmailController.text.trim();

    if (userName.isEmpty || newUserEmail.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Create Dio instance
    final dio = Dio();

    // Send POST request to backend server
    try {
      final response = await dio.post(
        ApiConstants().addAdmin,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'userName': userName,
          'newUserEmail': newUserEmail,
        },
      );
      if (response.statusCode == 200) {
        showToast('Admin added successfully');
      } else if (response.statusCode == 400) {
        showToast('Missing details');
      } else if (response.statusCode == 401) {
        showToast('User already exists');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding admin: $error');
      }
    } finally {
      setState(() {
        _userNameController.clear();
        _newUserEmailController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Admin'),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyTextField(
                controller: _userNameController,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                keyboardType: TextInputType.name,
                validator: _userNameValidator,
                labelText: 'User Name',
                hintText: 'Please enter a name',
                obscureText: false,
                enabled: true,
              ),
              const SizedBox(height: 16.0),
              MyTextField(
                controller: _newUserEmailController,
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with deleteAdmin
                    addAdmin();
                  }
                },
                child: const Text('Add Admin'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
