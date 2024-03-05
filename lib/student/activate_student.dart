import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/components/text_field.dart';
import '../utils/components/toast.dart';

class ActivateStudentPage extends StatefulWidget {
  const ActivateStudentPage({Key? key}) : super(key: key);

  @override
  ActivateStudentPageState createState() => ActivateStudentPageState();
}

class ActivateStudentPageState extends State<ActivateStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _rollNoController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _batchYearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _semesterController = TextEditingController();

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

  Future<void> fetchStudentData() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        '${ApiConstants().fetchStudent}?studentRollNo=${_rollNoController.text}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
      );

      if (response.statusCode == 200) {
        final studentData = response.data['student'];
        _studentNameController.text = studentData['StdName'];
        _batchYearController.text = studentData['batchYear'].toString();
        _departmentController.text = studentData['DeptName'];
        _sectionController.text = studentData['Section'];
        _semesterController.text = studentData['Semester'].toString();
      } else {
        showToast('Failed to fetch student data');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching student data: $error');
      }
      showToast('Failed to fetch student data');
    }
  }

  void activateStudent(BuildContext context) async {
    // Perform activation logic here
    final rollNo = _rollNoController.text.trim();

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Create Dio instance
    final dio = Dio();

    // Send POST request to backend server for activation
    try {
      final response = await dio.post(
        ApiConstants().activateStudent,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'RollNo': rollNo,
          // Add other necessary data for activation if required
        },
      );

      if (response.statusCode == 200) {
        showToast('Student activated successfully');
      } else if (response.statusCode == 400) {
        showToast('Student activation failed');
      } else if (response.statusCode == 401) {
        showToast('Access Restricted');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error activating student: $error');
      }
    } finally {
      // Clear text controllers
      setState(() {
        _rollNoController.clear();
        _studentNameController.clear();
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
          title: const Text('Confirm Activation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Roll Number: ${_rollNoController.text}'),
              Text('Student Name: ${_studentNameController.text}'),
              Text('Batch Year: ${_batchYearController.text}'),
              Text('Department: ${_departmentController.text}'),
              Text('Section: ${_sectionController.text}'),
              Text('Semester: ${_semesterController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                activateStudent(context); // Perform student activation
              },
              child: const Text('Activate'),
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
        title: const Text('Activate Student'),
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
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _showConfirmationDialog();
                    await fetchStudentData(); // Fetch student data before activation
                  }
                },
                child: const Text('Activate Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
