import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/student/editStudent/enter_roll.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_dept.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/components/text_field.dart';
import '../../utils/dropdowns/drop_down_section.dart';

class EditStudentPage extends StatefulWidget {
  final String studentRollNo;

  const EditStudentPage({Key? key, required this.studentRollNo})
      : super(key: key);

  @override
  EditStudentPageState createState() => EditStudentPageState();
}

class EditStudentPageState extends State<EditStudentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _rollNoController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _batchYearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _semesterController = TextEditingController();
  final String _errorMessage = '';
  late final String selectedDepartment;
  late final String selectedSemester;

  @override
  void initState() {
    super.initState();
    // Fetch existing student data and populate the form
    fetchStudentData();
  }

  void fetchStudentData() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        '${ApiConstants().fetchStudent}?studentRollNo=${widget.studentRollNo}',
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
        _rollNoController.text = studentData['RollNo'];
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

  void editStudent() async {
    try {
      final rollNo = _rollNoController.text.trim();
      final studentName = _studentNameController.text.trim();
      final batchYear = _batchYearController.text.trim();
      final department = _departmentController.text.trim();
      final section = _sectionController.text.trim();
      final semester = _semesterController.text.trim();

      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.put(
        ApiConstants().editStudent,
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

      if (kDebugMode) {
        print(
            'Edit Student Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 200) {
        showToast('Student updated successfully');
      } else if (response.statusCode == 400) {
        showToast('Invalid data');
      } else if (response.statusCode == 404) {
        showToast('Student not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error editing student: $error');
      }
      showToast('Failed to edit student. Please try again.');
    } finally {
      // Additional cleanup or UI updates if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) {
                return EnterRollNumberScreen();
              }),
              (route) => false,
            );
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
                MyTextField(
                  controller: _rollNoController,
                  validator: _rollNoValidator,
                  prefixIcon: const Icon(Icons.badge_rounded),
                  keyboardType: TextInputType.text,
                  labelText: 'Roll Number',
                  hintText: 'Please enter the roll number',
                  obscureText: false,
                  enabled: false,
                ),
                const SizedBox(height: 16.0),
                MyTextField(
                  controller: _departmentController,
                  validator: null, // Add your validation logic here
                  prefixIcon: const Icon(Icons.category_rounded),
                  labelText: 'Department',
                  hintText: 'Please enter the department',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),
                MyTextField(
                  controller: _studentNameController,
                  validator: _studentNameValidator,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  labelText: 'Student Name',
                  hintText: 'Please enter the student name',
                  obscureText: false,
                  keyboardType: TextInputType.name,
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
                // MyTextField(
                //   controller: _sectionController,
                //   validator: null, // Add your validation logic here
                //   prefixIcon: const Icon(Icons.grade_rounded),
                //   labelText: 'Section',
                //   hintText: 'Please enter the section',
                //   obscureText: false,
                //   keyboardType: TextInputType.text,
                //   enabled: true,
                // ),
                const SizedBox(height: 16.0),
                // BatchYearDropdown(
                //   onChanged: (int newValue) {
                //     setState(() {
                //       _batchYearController.text = newValue.toString();
                //     });
                //   },
                // ),
                MyTextField(
                  controller: _batchYearController,
                  validator: null, // Add your validation logic here
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                  labelText: 'Batch Year',
                  hintText: 'Please enter the batch year',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),
                // SemesterDropdown(
                //   onChanged: (int newValue) {
                //     setState(() {
                //       _semesterController.text = newValue.toString();
                //       selectedSemester = newValue.toString();
                //     });
                //   },
                // ),
                MyTextField(
                  controller: _semesterController,
                  validator: null,
                  prefixIcon: const Icon(Icons.numbers_rounded),
                  labelText: 'Semester',
                  hintText: 'Please enter the semester',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      editStudent();
                    }
                  },
                  child: const Text('Edit Student'),
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
