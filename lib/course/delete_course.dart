import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/dropdowns/drop_down_course.dart';

class DeleteCoursePage extends StatefulWidget {
  const DeleteCoursePage({Key? key}) : super(key: key);

  @override
  DeleteCoursePageState createState() => DeleteCoursePageState();
}

class DeleteCoursePageState extends State<DeleteCoursePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  List<String> courses = [];
  String selectedCourse = 'Select a course'; // Set default value

  @override
  void dispose() {
    _courseNameController.dispose();
    _fetchCourseNames(); // Fetch course names when the page is initialized
    super.dispose();
  }

  Future<void> _fetchCourseNames() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        ApiConstants().allCourses,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
      );

      print('Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        // Ensure that the response data is a Map and contains the 'courses' key
        if (response.data is Map && response.data.containsKey('courses')) {
          List<dynamic> courseData = response.data['courses'];

          setState(() {
            courses = courseData.map((course) => course.toString()).toList();

            // Check if 'Select a course' is not already in the list
            if (!courses.contains('Select a course')) {
              courses.insert(0, 'Select a course');
            }

            selectedCourse =
                courses.isNotEmpty ? courses[0] : 'Select a course';
          });
        } else {
          showToast('Invalid response format');
        }
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch courses');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching course names: $error');
      }
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
                Text('Are you sure you want to delete this course?'),
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
                deleteCourse(); // Perform course deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteCourse() async {
    final courseName = _courseNameController.text.trim();

    if (courseName.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    print('Delete Course Request:');
    print('courseName: $courseName');

    // Create Dio instance
    final dio = Dio();

    // Send DELETE request to the backend server
    try {
      final response = await dio.delete(
        ApiConstants().deleteCourse,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'courseName': courseName,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Delete Course Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 200) {
        showToast('Course deleted successfully');
      } else if (response.statusCode == 404) {
        showToast('Course not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      print('Error deleting course: $error');
    } finally {
      setState(() {
        _courseNameController.clear();
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Course'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CourseDropdown(
                onChanged: (String newValue) {
                  setState(() {
                    _courseNameController.text = newValue;
                    _fetchCourseNames();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with deleteCourse
                    await _showConfirmationDialog();
                    deleteCourse();
                    _fetchCourseNames(); // Update the dropdown after deletion
                  }
                },
                child: const Text('Delete Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
