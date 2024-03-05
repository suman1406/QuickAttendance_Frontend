import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/attendance/qr_cam_screen.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/text_field.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/dropdowns/drop_down_batchYear.dart';
import '../utils/dropdowns/drop_down_course.dart';
import '../utils/dropdowns/drop_down_dept.dart';
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';

class AttendanceDetailsPage extends StatefulWidget {
  const AttendanceDetailsPage({Key? key}) : super(key: key);

  @override
  AttendanceDetailsPageState createState() => AttendanceDetailsPageState();
}

class AttendanceDetailsPageState extends State<AttendanceDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _batchYearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _semesterController = TextEditingController();
  final _periodController = TextEditingController();
  final _courseNameController = TextEditingController();
  final String _errorMessage = '';
  List<String> courses = [];
  String selectedCourse = 'Select a course';

  @override
  void dispose() {
    _batchYearController.dispose();
    _departmentController.dispose();
    _sectionController.dispose();
    _semesterController.dispose();
    _periodController.dispose();
    _courseNameController.dispose();
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

  Future<String?> _addAttendance() async {
    final batchYear = _batchYearController.text.trim();
    final department = _departmentController.text.trim();
    final section = _sectionController.text.trim();
    final semester = _semesterController.text.trim();
    final period = _periodController.text.trim();
    final course = _courseNameController.text.trim();

    if (batchYear.isEmpty ||
        department.isEmpty ||
        section.isEmpty ||
        semester.isEmpty ||
        period.isEmpty ||
        course.isEmpty) {
      return null;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Add Attendance Request:');
      print('batchYear: $batchYear');
      print('department: $department');
      print('section: $section');
      print('semester: $semester');
      print('period: $period');
      print('course: $course');
    }

    // Create Dio instance
    final dio = Dio();

    // Send POST request to the backend server
    try {
      final response = await dio.post(
        ApiConstants().reqSlotID,
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
          'periodNo': period.toString(),
          'course': course,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Add Attendance Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 200) {
        final slotIds = response.data["SlotIDs"].toString();
        sp.setString("SlotIDs", slotIds);
        return slotIds;
      } else if (response.statusCode == 400) {
        showToast('Invalid data');
      } else if (response.statusCode == 404) {
        showToast('Current user not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding attendance: $error');
      }
      showToast('Failed to add attendance. Please try again.');
    } finally {
      setState(() {
        // Clear the controllers after submitting the form
        _batchYearController.clear();
        _departmentController.clear();
        _sectionController.clear();
        _semesterController.clear();
        _periodController.clear();
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Attendance'),
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
                CourseDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      _courseNameController.text = newValue;
                      _fetchCourseNames();
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                MyTextField(
                  controller: _periodController,
                  prefixIcon: const Icon(Icons.access_alarms_rounded),
                  validator: null,
                  labelText: 'Period Number',
                  hintText: 'Please enter a period number',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  enabled: true,
                ),
                const SizedBox(height: 7.0),
                Text(
                  'Please note that if there are multiple periods, input them in the form of 1, 2, 3.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final SharedPreferences sp =
                        await SharedPreferences.getInstance();
                    final String? slotIds = sp.getString("SlotIDs");

                    if (_formKey.currentState!.validate()) {
                      _addAttendance().then((res) => {
                            if (res == slotIds)
                              {
                                Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) {
                                    return QRScanningPage(slotIds: slotIds, course: _courseNameController.text.trim());
                                  },
                                ))
                              }
                          });
                    }
                  },
                  child: const Text('Next'),
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
