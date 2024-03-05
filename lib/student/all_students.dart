import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../professor/p_home_screen.dart';
import '../utils/dropdowns/drop_down_batchYear.dart';
import '../utils/dropdowns/drop_down_dept.dart';
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';
import '../admin/a_home_screen.dart';

class AllStudentsPage extends StatefulWidget {
  const AllStudentsPage({Key? key}) : super(key: key);

  @override
  AllStudentsPageState createState() => AllStudentsPageState();
}

class AllStudentsPageState extends State<AllStudentsPage> {
  List<Map<String, dynamic>> students = [];
  late final _batchYearController = TextEditingController();
  late final _departmentController = TextEditingController();
  late final _sectionController = TextEditingController();
  late final _semesterController = TextEditingController();

  late String selectedBatchYear;
  late String selectedSection;
  late String selectedSemester;
  late String selectedDepartment;

  Future<void> fetchStudents() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();
      final response = await dio.get(
        ApiConstants().allStudents,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'batchYear': selectedBatchYear,
          'dept': selectedDepartment,
          'section': selectedSection,
          'semester': selectedSemester,
        },
      );

      print('Dio Request: ${response}');
      print(selectedBatchYear);
      print(selectedDepartment);
      print(selectedSection);
      print(selectedSemester);

      if (response.statusCode == 200) {
        setState(() {
          students = List<Map<String, dynamic>>.from(response.data['students']);
        });

        print(students);
      } else {
        // Handle error
        print('Failed to fetch students');
      }
    } catch (error) {
      // Handle error
      print('Error fetching students: $error');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Data'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                    selectedBatchYear = newValue.toString();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DepartmentDropdown(
                onChanged: (String newValue) {
                  setState(() {
                    _departmentController.text = newValue.toString();
                    selectedDepartment = newValue.toString();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              SectionDropdown(
                onChanged: (String newValue) {
                  setState(() {
                    _sectionController.text = newValue.toString();
                    selectedSection = newValue.toString();
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
                  // Call API to get student data based on selected parameters
                  fetchStudents();
                },
                child: const Text('Get Student Data'),
              ),
              const SizedBox(height: 16.0),
              Container(
                // Replace Expanded with Container
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true, // Set shrinkWrap to true
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      child: ListTile(
                        title: Text('Roll No: ${student['RollNo']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${student['StdName']}'),
                            // Text('Batch Year: ${student['batchYear']}'),
                            // Text('Department: ${student['dept']}'),
                            // Text('Section: ${student['section']}'),
                            // Text('Semester: ${student['semester']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
