import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/dropdowns/drop_down_batchYear.dart';
import '../utils/dropdowns/drop_down_dept.dart';
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';

class DeleteClassPage extends StatefulWidget {
  const DeleteClassPage({Key? key}) : super(key: key);

  @override
  DeleteClassPageState createState() => DeleteClassPageState();
}

class DeleteClassPageState extends State<DeleteClassPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _batchYearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _semesterController = TextEditingController();
  final String _errorMessage = '';

  @override
  void dispose() {
    _batchYearController.dispose();
    _departmentController.dispose();
    _sectionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void deleteClass() async {
    final batchYear = _batchYearController.text.trim();
    final department = _departmentController.text.trim();
    final section = _sectionController.text.trim();
    final semester = _semesterController.text.trim();

    if (batchYear.isEmpty || department.isEmpty || section.isEmpty || semester.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Create Dio instance
    final dio = Dio();

    // Send DELETE request to the backend server
    try {
      final response = await dio.delete(
        ApiConstants().deleteClass,
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

      if (response.statusCode == 201) {
        showToast('Class deleted successfully');
      } else if (response.statusCode == 400) {
        showToast('Invalid data');
      } else if (response.statusCode == 403) {
        showToast('Permission denied');
      } else if (response.statusCode == 404) {
        showToast('Class not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting class: $error');
      }
      showToast('Failed to delete class. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Class'),
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
                SectionDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      _sectionController.text = newValue;
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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with deleteClass
                      deleteClass();
                      if (kDebugMode) {
                        print(
                            '=========================================================');
                      }
                    }
                  },
                  child: const Text('Delete Class'),
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
