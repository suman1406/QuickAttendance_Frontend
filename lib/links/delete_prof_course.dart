import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/dropdowns/list_dropdown/multi_course_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/dropdowns/prof_email_drop_down.dart';

class DeleteProfCoursePage extends StatefulWidget {
  const DeleteProfCoursePage({Key? key}) : super(key: key);

  @override
  DeleteProfCoursePageState createState() => DeleteProfCoursePageState();
}

class DeleteProfCoursePageState extends State<DeleteProfCoursePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _profEmailController = TextEditingController();
  final String _errorMessage = '';
  List<String> selectedCourses = [];
  String selectedProfEmail = '';

  @override
  void dispose() {
    _profEmailController.dispose();
    super.dispose();
  }

  void deleteProfCourse() async {

    if (selectedProfEmail.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Delete Prof Course Request:');
      print('profEmail: $selectedProfEmail');
      print('courses: $selectedCourses');
    }

    // Create Dio instance
    final dio = Dio();

    // Send POST request to the backend server
    try {
      final response = await dio.delete(
        ApiConstants().deleteProfCourse,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'profEmail': selectedProfEmail,
          'courses': selectedCourses,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Delete Prof Course Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Courses deleted successfully');
      } else if (response.statusCode == 404) {
        showToast('User, course, or professor not found or inactive');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting prof course: $error');
      }
      showToast('Failed to delete courses. Please try again.');
    } finally {
      setState(() {
        // Clear the controllers after submitting the form
        _profEmailController.clear();
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to unlink courses?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteProfCourse(); // Perform course deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Prof Course'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfEmailDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      selectedProfEmail = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                MultiCourseDropdown(
                  onChanged: (List<String> newValues) {
                    setState(() {
                      selectedCourses = newValues;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with deleteProfCourse
                      deleteProfCourse();
                      if (kDebugMode) {
                        print(
                            '=========================================================');
                      }
                    }
                  },
                  child: const Text('Delete Prof Course'),
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
      ),
    );
  }
}
