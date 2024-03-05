import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/components/text_field.dart';
import '../utils/components/toast.dart';

class DeleteFacultyPage extends StatefulWidget {
  const DeleteFacultyPage({super.key});

  @override
  DeleteFacultyPageState createState() => DeleteFacultyPageState();
}

class DeleteFacultyPageState extends State<DeleteFacultyPage> {
  final _formKey = GlobalKey<FormState>();
  final _userEmailController = TextEditingController();
  final _profNameController = TextEditingController();

  @override
  void dispose() {
    _userEmailController.dispose();
    _profNameController.dispose();
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

  String? __profNameValidator(String? value) {
    // No space allowed. Can't be empty.
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }

    return null;
  }

  void deleteFaculty() async {
    final userEmail = _userEmailController.text.trim();
    final facultyProfName = _profNameController.text.trim();

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Create Dio instance
    final dio = Dio();

    // Send DELETE request to backend server
    try {
      final response = await dio.delete(
        ApiConstants().deleteFaculty,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'Email': userEmail,
          'facultyProfName': facultyProfName,
        },
      );

      if (response.statusCode == 200) {
        showToast('Faculty member deleted successfully');
      } else if (response.statusCode == 400) {
        showToast('Missing details');
      } else if (response.statusCode == 401) {
        showToast('Faculty doesn\'t exist');
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
        _profNameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Faculty'),
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
            children: [
              MyTextField(
                controller: _profNameController,
                prefixIcon: const Icon(Icons.person_outline_rounded),
                keyboardType: TextInputType.name,
                validator: __profNameValidator,
                labelText: 'Faculty Name',
                hintText: 'Please enter faculty name',
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
                      deleteFaculty();
                    }
                  }
                },
                child: const Text('Delete Faculty'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
