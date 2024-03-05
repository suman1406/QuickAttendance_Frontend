import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/components/text_field.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  CreateCoursePageState createState() => CreateCoursePageState();
}

class CreateCoursePageState extends State<CreateCoursePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _newCourseNameController = TextEditingController();
  late final String _errorMessage = '';

  @override
  void dispose() {
    _newCourseNameController.dispose();
    super.dispose();
  }

  String? _courseNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a course name';
    }
    return null;
  }

  void createCourse() async {
    final newCourseName = _newCourseNameController.text.trim();

    if (newCourseName.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Create Course Request:');
      print('newCourseName: $newCourseName');
    }

    // Create Dio instance
    final dio = Dio();

    // Send POST request to the backend server
    try {
      final response = await dio.post(
        ApiConstants().addCourse,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'courseName': newCourseName,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Create Course Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Course created successfully');
      } else if (response.statusCode == 403) {
        showToast('Course already exists');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error creating course: $error');
      }
    } finally {
      setState(() {
        _newCourseNameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
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
                controller: _newCourseNameController,
                prefixIcon: const Icon(Icons.book_rounded),
                keyboardType: TextInputType.text,
                validator: _courseNameValidator,
                labelText: 'Course Name',
                hintText: 'Please enter a course name',
                obscureText: false,
                enabled: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with createCourse
                    createCourse();
                  }
                },
                child: const Text('Create Course'),
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
