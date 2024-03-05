import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/components/text_field.dart';
import '../utils/dropdowns/drop_down_dept.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({Key? key}) : super(key: key);

  @override
  AddClassPageState createState() => AddClassPageState();
}

class AddClassPageState extends State<AddClassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _batchYearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _semesterController = TextEditingController();
  final String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
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
                Text(
                  'Note: Ensure that you explicitly select the designated options, even if they are visibly presented.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16.0),

                MyTextField(
                  controller: _batchYearController,
                  prefixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Batch Year is required';
                    }
                    return null;
                  },
                  labelText: 'Batch Year',
                  hintText: 'Enter Batch Year',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),

                DepartmentDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      _departmentController.text = newValue;
                    });
                  },
                ),

                // MyTextField(
                //   controller: _departmentController,
                //   prefixIcon: const Icon(Icons.work),
                //   validator: (value) {
                //     if (value.isEmpty) {
                //       return 'Department is required';
                //     }
                //     return null;
                //   },
                //   labelText: 'Department',
                //   hintText: 'Enter Department',
                //   obscureText: false,
                //   keyboardType: TextInputType.text,
                //   enabled: true,
                // ),
                const SizedBox(height: 16.0),

                MyTextField(
                  controller: _sectionController,
                  prefixIcon: const Icon(Icons.group),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Section is required';
                    }
                    return null;
                  },
                  labelText: 'Section',
                  hintText: 'Enter Section',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),

                MyTextField(
                  controller: _semesterController,
                  prefixIcon: const Icon(Icons.school),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Semester is required';
                    }
                    return null;
                  },
                  labelText: 'Semester',
                  hintText: 'Enter Semester',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with addClass
                      addClass();
                      if (kDebugMode) {
                        print(
                            '=========================================================');
                      }
                    }
                  },
                  child: const Text('Add Class'),
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

  void addClass() async {
    final batchYear = _batchYearController.text.trim();
    final department = _departmentController.text.trim();
    final section = _sectionController.text.trim();
    final semester = _semesterController.text.trim();

    if (batchYear.isEmpty ||
        department.isEmpty ||
        section.isEmpty ||
        semester.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Add Class Request:');
      print('batchYear: $batchYear');
      print('department: $department');
      print('section: $section');
      print('semester: $semester');
    }

    // Create Dio instance
    final dio = Dio();

    // Send POST request to the backend server
    try {
      final response = await dio.post(
        ApiConstants().addClass,
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
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print('Add Class Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Class added successfully');
      } else if (response.statusCode == 400) {
        showToast('Invalid data');
      } else if (response.statusCode == 404) {
        showToast('Current user not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding class: $error');
      }
      showToast('Failed to add class. Please try again.');
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
}
