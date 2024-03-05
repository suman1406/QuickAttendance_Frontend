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
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class AddStudentsExcelUploadPage extends StatefulWidget {
  const AddStudentsExcelUploadPage({Key? key}) : super(key: key);

  @override
  AddStudentsExcelUploadPageState createState() =>
      AddStudentsExcelUploadPageState();
}

class AddStudentsExcelUploadPageState
    extends State<AddStudentsExcelUploadPage> {
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
  List<List<String>> excelData = [];

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

  Future<void> addStudentsFromExcel(List<List<String>> excelData) async {
    final List<String> rollNumbers = excelData.map((row) => row[0]).toList();

    final List<String> studentNames = excelData.map((row) => row[1]).toList();
    if (rollNumbers.length != studentNames.length) {
      showToast('Error: Roll numbers and student names count mismatch.');
      return;
    }

    print('===========================================');
    print(rollNumbers);
    print(studentNames);
    print('===========================================');

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    try {
      final response = await Dio().post(
        ApiConstants().addStudents,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'batchYear': _batchYearController.text.trim(),
          'dept': _departmentController.text.trim(),
          'section': _sectionController.text.trim(),
          'semester': _semesterController.text.trim(),
          'stuName': studentNames,
          'RollNo': rollNumbers,
        },
      );

      if (kDebugMode) {
        print(
            'Add Student Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Students added successfully');
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
        showToast('Internal Server Error\nFailed to add students');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding students: $error');
      }
      showToast('Failed to add students. Please try again.');
    } finally {
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

  Future<void> readExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      // Assuming the same setup as in your code
      String filePath = result.files.single.path!;
      File file = File(filePath);

      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      List<List<String>> allData = [];

// Iterate through sheets
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];

        // Skip processing if the sheet doesn't have rows or has less than 2 columns
        if (sheet == null || sheet.maxColumns < 2) {
          continue;
        }

        // Process remaining rows
        for (var row in sheet.rows.skip(1)) {
          if (row[0]?.value == null || row[1]?.value == null) {
            break; // Stop processing when encountering an empty cell
          }

          // Assuming Roll Number is in the first column and Student Name is in the second column
          String rollNumber = row[0]?.value.toString().trim() ?? '';
          String studentName = row[1]?.value.toString() ?? '';

          // Print or use the Roll Number and Student Name as needed
          if (kDebugMode) {
            print('Roll Number: $rollNumber, Student Name: $studentName');
          }

          // Optionally, you can store the data in a list
          allData.add([rollNumber, studentName]);
        }
      }

      setState(() {
        excelData = allData; // Update the state variable
      });

      if (kDebugMode) {
        print(excelData);
      }

      List<String> rollNumbers = excelData.map((row) => row[0]).toList();
      List<String> studentNames = excelData.map((row) => row[1]).toList();

      Set<String> uniqueRoll = Set<String>.from(rollNumbers);
      Set<String> names = Set<String>.from(studentNames);

      List<String> uniqueRollNumbers = uniqueRoll.toList();
      List<String> uniqueStudentNames = names.toList();

      if (kDebugMode) {
        print(uniqueRollNumbers);
        print(uniqueStudentNames);
      }

      Map<String, dynamic> jsonData = {
        'Roll Number': uniqueRollNumbers,
        'Student Name': uniqueStudentNames,
      };
      String jsonString = jsonEncode(jsonData);

      if (kDebugMode) {
        print(jsonString);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Students'),
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
                    readExcelFile();
                  },
                  child: const Text('Upload Excel File'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (excelData.isNotEmpty &&
                        _formKey.currentState!.validate()) {
                      addStudentsFromExcel(excelData);
                    } else {
                      showToast('Error: Excel data is empty.');
                    }
                  },
                  child: const Text('Add Students'),
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
