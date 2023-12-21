import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_batchYear.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_dept.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/components/text_field.dart';
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  AddStudentPageState createState() => AddStudentPageState();
}

class AddStudentPageState extends State<AddStudentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _rollNoController = TextEditingController();
  final _studentNameController = TextEditingController();
  late final _batchYearController = TextEditingController();
  late final _departmentController = TextEditingController();
  late final _sectionController = TextEditingController();
  late final _semesterController = TextEditingController();
  final String _errorMessage = '';
  late String selectedDepartment;
  late String selectedSemester;

  @override
  void dispose() {
    _rollNoController.dispose();
    _studentNameController.dispose();
    _batchYearController.dispose();
    _departmentController.dispose();
    _sectionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  String? _rollNoValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the roll number';
    }

    return null;
  }

  String? _studentNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the student name';
    }

    return null;
  }

  void addStudent() async {
    final rollNo = _rollNoController.text.trim();
    final studentName = _studentNameController.text.trim();
    final batchYear = _batchYearController.text.trim();
    final department = _departmentController.text.trim();
    final section = _sectionController.text.trim();
    final semester = _semesterController.text.trim();

    if (kDebugMode) {
      print('Add Student Request:');
      print('rollNo: $rollNo');
      print('studentName: $studentName');
      print('batchYear: $batchYear');
      print('department: $department');
      print('section: $section');
      print('semester: $semester');
    }

    if (rollNo.isEmpty ||
        studentName.isEmpty ||
        batchYear.isEmpty ||
        department.isEmpty ||
        section.isEmpty ||
        semester.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Add Student Request:');
      print('rollNo: $rollNo');
      print('studentName: $studentName');
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
        ApiConstants().addStudent,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'RollNo': rollNo,
          'StdName': studentName,
          'batchYear': batchYear,
          'Dept': department,
          'Section': section,
          'Semester': semester,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Add Student Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Student added successfully');
      } else if (response.statusCode == 400) {
        showToast('All fields are required');
      } else if (response.statusCode == 401) {
        showToast('Invalid roll number format');
      } else if (response.statusCode == 402) {
        showToast('Current user not found');
      } else if (response.statusCode == 403) {
        showToast('Student already present');
      } else if (response.statusCode == 404) {
        showToast('Department not found!');
      } else if (response.statusCode == 405) {
        showToast('Class not found!');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error\nFailed to add student');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding student: $error');
      }
      showToast('Failed to add student. Please try again.');
    } finally {
      setState(() {
        // Clear the controllers after submitting the form
        _rollNoController.clear();
        _studentNameController.clear();
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
        title: const Text('Add Student'),
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
                MyTextField(
                  controller: _rollNoController,
                  prefixIcon: const Icon(Icons.badge_rounded),
                  keyboardType: TextInputType.text,
                  validator: _rollNoValidator,
                  labelText: 'Roll Number',
                  hintText: 'Please enter the roll number',
                  obscureText: false,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),
                MyTextField(
                  controller: _studentNameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  keyboardType: TextInputType.name,
                  validator: _studentNameValidator,
                  labelText: 'Student Name',
                  hintText: 'Please enter the student name',
                  obscureText: false,
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
                const SizedBox(height: 16.0),
                SectionDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      _sectionController.text = newValue;
                    });
                  },
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
                SemesterDropdown(
                  onChanged: (int newValue) {
                    setState(() {
                      _semesterController.text = newValue.toString();
                      selectedSemester = newValue.toString();
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with addStudent
                      addStudent();
                      if (kDebugMode) {
                        print(
                            '=========================================================');
                      }
                    }
                  },
                  child: const Text('Add Student'),
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
