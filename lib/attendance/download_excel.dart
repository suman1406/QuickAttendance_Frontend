import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;
import '../utils/api_constants.dart';
import '../utils/components/toast.dart';
import '../utils/dropdowns/drop_down_batch_year.dart';
import '../utils/dropdowns/drop_down_course.dart';
import '../utils/dropdowns/drop_down_dept.dart';
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';

class DownloadExcel extends StatefulWidget {
  const DownloadExcel({Key? key}) : super(key: key);

  @override
  DownloadExcelState createState() => DownloadExcelState();
}

class DownloadExcelState extends State<DownloadExcel> {
  final _batchYearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _semesterController = TextEditingController();
  final _courseNameController = TextEditingController();
  List<String> courses = [];
  String selectedCourse = 'Select a course';

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

      if (kDebugMode) {
        print('Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 200) {
        if (response.data is Map && response.data.containsKey('courses')) {
          List<dynamic> courseData = response.data['courses'];

          setState(() {
            courses = courseData.map((course) => course.toString()).toList();

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

  void _generateAndDownloadExcel() async {
    try {
      // Prepare data for sending to the server
      final Map<String, dynamic> requestData = {
        'batchYear': _batchYearController.text,
        'Semester': _semesterController.text,
        'Section': _sectionController.text,
        'Dept': _departmentController.text,
        'courseName': _courseNameController.text,
      };

      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final Dio dio = Dio();

      final Response<dynamic> response = await dio.post(
        ApiConstants().getAttendanceForCourse,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
        ),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        if (responseData is List<dynamic>) {
          if (kDebugMode) {
            print('Response data: $responseData');
          }
          List<Map<String, dynamic>> excelData =
              List<Map<String, dynamic>>.from(responseData);

          xcel.Workbook workbook = xcel.Workbook();
          xcel.Worksheet sheet = workbook.worksheets[0];

          // Design the Excel sheet (replace with your requirements)
          sheet.getRangeByName('A1').setText('Roll Numbers');
          sheet.getRangeByName('B1').setText('Names');

          // Create a Map to store data organized by periodNo
          Map<int, List<Map<String, dynamic>>> dataBySlot = {};

          // Organize data by periodNo
          for (int i = 0; i < excelData.length; i++) {
            Map<String, dynamic> studentData = excelData[i];
            int periodNo = studentData['periodNo'] ?? 0;

            if (!dataBySlot.containsKey(periodNo)) {
              dataBySlot[periodNo] = [];
            }

            dataBySlot[periodNo]?.add(studentData);
          }

          // Set up dynamic date columns
          int columnIndex = 3; // Start from the third column

          dataBySlot.forEach((periodNo, slotData) {
            // Set header for each slot
            sheet.getRangeByIndex(1, columnIndex).setText('2023-01-01_($periodNo)');

            // Set data for each student in the slot
            for (int i = 0; i < slotData.length; i++) {
              Map<String, dynamic> studentData = slotData[i];
              sheet.getRangeByIndex(i + 2, 1).setText(studentData['RollNo'] ?? ''); // Roll Numbers
              sheet.getRangeByIndex(i + 2, 2).setText(studentData['StdName'] ?? ''); // Names

              // Convert 'AttDateTime' to readable format
              DateTime attDateTime = DateTime.parse(studentData['AttDateTime']);
              // String formattedTime = DateFormat('H:mm:ss').format(attDateTime);

              // Convert to IST by adding 5 hours and 30 minutes
              DateTime istDateTime = attDateTime.add(const Duration(hours: 5, minutes: 30));

              // Format the IST time as a string
              String formattedTime = DateFormat('HH:mm:ss').format(istDateTime);

              sheet.getRangeByIndex(i + 2, columnIndex).setText(formattedTime); // Time
            }

            columnIndex++;
          });

          List<int> bytes = workbook.saveAsStream();
          Uint8List uint8List = Uint8List.fromList(bytes);

          final String fileName =
              'attendance_data_${DateTime.now().millisecondsSinceEpoch}.xlsx';

          const directoryDownload = '/storage/emulated/0/Download';

          // getApplicationDocumentsDirectory().path;



          final String filePath = '$directoryDownload/$fileName';

          File file = File(filePath);
          await file.writeAsBytes(uint8List);
          if (kDebugMode) {
            print('File saved at: $filePath');
          }
          showToast('Excel file generated successfully');
        } else {
          showToast('Failed to generate Excel file');
        }
      } else {
        showToast('Invalid response format. Expected a list.');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error generating and downloading Excel file: $error');
      }
      showToast('Error generating and downloading Excel file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        leading: IconButton(
          onPressed: () async {
            // final SharedPreferences sp = await SharedPreferences.getInstance();
            // final String userRole = sp.getString("userRole").toString();

            // if (userRole == "0") {
            //   Navigator.of(context).pushReplacement(
            //       CupertinoPageRoute(builder: (context) {
            //         return const ProfessorHomeScreen();
            //       }),);
            // } else if (userRole == "1") {
            //   Navigator.of(context).pushReplacement(
            //       CupertinoPageRoute(builder: (context) {
            //         return const AdminHomeScreen();
            //       }),);
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
        child: SingleChildScrollView(
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
              ElevatedButton(
                onPressed: () async {
                  _generateAndDownloadExcel();
                },
                child: const Text('Generate and Download Excel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
