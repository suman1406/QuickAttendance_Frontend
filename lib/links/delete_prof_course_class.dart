import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_dept.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_batchYear.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_section.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_semester.dart';
import 'package:quick_attednce/utils/dropdowns/list_dropdown/multi_course_dropdown.dart';
import 'package:quick_attednce/utils/dropdowns/list_dropdown/multi_profEmail_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';

class DeleteProfCourseClassPage extends StatefulWidget {
  const DeleteProfCourseClassPage({Key? key}) : super(key: key);

  @override
  DeleteProfCourseClassPageState createState() =>
      DeleteProfCourseClassPageState();
}

class DeleteProfCourseClassPageState extends State<DeleteProfCourseClassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _batchYearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _semesterController = TextEditingController();
  final String _errorMessage = '';
  List<String> selectedCourses = [];
  List<String> selectedEmails = [];

  @override
  void dispose() {
    _batchYearController.dispose();
    _departmentController.dispose();
    _sectionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void deleteProfCourseClass() async {
    final batchYear = _batchYearController.text.trim();
    final department = _departmentController.text.trim();
    final section = _sectionController.text.trim();
    final semester = _semesterController.text.trim();

    if (batchYear.isEmpty ||
        department.isEmpty ||
        section.isEmpty ||
        semester.isEmpty) {
      if (kDebugMode) {
        print('Delete Prof/Course/Class Request:');
        print('batchYear: $batchYear');
        print('department: $department');
        print('section: $section');
        print('semester: $semester');
        print('courses: $selectedCourses');
        print('profEmails: $selectedEmails');
      }
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Delete Prof/Course/Class Request:');
      print('batchYear: $batchYear');
      print('department: $department');
      print('section: $section');
      print('semester: $semester');
      print('courses: $selectedCourses');
      print('profEmails: $selectedEmails');
    }

    // Create Dio instance
    final dio = Dio();

    // Send POST request to the backend server
    try {
      final response = await dio.delete(
        ApiConstants().deleteClassCourseProf,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'batchYear': batchYear,
          'Dept': department,
          'Section': section,
          'Semester': semester,
          'courses': selectedCourses,
          'profEmails': selectedEmails,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Delete Prof/Course/Class Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Professors and Courses deleted successfully');
      } else if (response.statusCode == 400) {
        showToast('Invalid data');
      } else if (response.statusCode == 404) {
        showToast('Class not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting Professors and Courses: $error');
      }
      showToast('Failed to delete Professors and Courses. Please try again.');
    } finally {
      setState(() {
        // Clear the controllers after submitting the form
        _batchYearController.clear();
        _departmentController.clear();
        _sectionController.clear();
        _semesterController.clear();
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
                Text(
                    'Are you sure you want to unlink professor and course from this class?'),
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
                deleteProfCourseClass(); // Perform course deletion
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
        title: const Text('Delete Prof/Course/Class'),
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
                BatchYearDropdown(
                  onChanged: (int newValue) {
                    setState(() {
                      _batchYearController.text = newValue.toString();
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                DepartmentDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      _departmentController.text = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                SemesterDropdown(
                  onChanged: (int newValue) {
                    setState(() {
                      _semesterController.text = newValue.toString();
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                SectionDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      _sectionController.text = newValue;
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
                MultiUserEmailDropdown(
                  onChanged: (List<String> newValues) {
                    setState(() {
                      selectedEmails = newValues;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with deleteProfCourseClass
                      await _showConfirmationDialog();
                      deleteProfCourseClass();
                      if (kDebugMode) {
                        print(
                            '=========================================================');
                      }
                    }
                  },
                  child: const Text('Delete Prof/Course/Class'),
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
