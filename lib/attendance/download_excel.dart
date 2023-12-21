// import 'dart:io';
// import 'package:excel/excel.dart' as excel;
// import 'package:excel/excel.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dio/dio.dart';
//
// import '../utils/api_constants.dart';
// import '../utils/components/text_field.dart';
// import '../utils/components/toast.dart';
// import '../utils/dropdowns/drop_down_batchYear.dart';
// import '../utils/dropdowns/drop_down_course.dart';
// import '../utils/dropdowns/drop_down_dept.dart';
// import '../utils/dropdowns/drop_down_section.dart';
// import '../utils/dropdowns/drop_down_semester.dart';
//
// class AttendanceSlotView extends StatefulWidget {
//   const AttendanceSlotView({Key? key}) : super(key: key);
//
//   @override
//   AttendanceSlotViewState createState() => AttendanceSlotViewState();
// }
//
// class AttendanceSlotViewState extends State<AttendanceSlotView> {
//   List<Map<String, dynamic>> attendanceDetails = [];
//   final _batchYearController = TextEditingController();
//   final _departmentController = TextEditingController();
//   final _sectionController = TextEditingController();
//   final _semesterController = TextEditingController();
//   final _periodController = TextEditingController();
//   final _courseNameController = TextEditingController();
//   List<String> courses = [];
//   String selectedCourse = 'Select a course';
//   DateTime? selectedDate;
//
//   @override
//   void dispose() {
//     _periodController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchCourseNames() async {
//     try {
//       final SharedPreferences sp = await SharedPreferences.getInstance();
//       final String? secretCode = sp.getString("SECRET_TOKEN");
//
//       final dio = Dio();
//
//       final response = await dio.get(
//         ApiConstants().allCourses,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'authorization': 'Bearer $secretCode',
//           },
//           validateStatus: (status) => status! < 1000,
//         ),
//       );
//
//       print('Response: ${response.statusCode} - ${response.data}');
//
//       if (response.statusCode == 200) {
//         if (response.data is Map && response.data.containsKey('courses')) {
//           List<dynamic> courseData = response.data['courses'];
//
//           setState(() {
//             courses = courseData.map((course) => course.toString()).toList();
//
//             if (!courses.contains('Select a course')) {
//               courses.insert(0, 'Select a course');
//             }
//
//             selectedCourse =
//             courses.isNotEmpty ? courses[0] : 'Select a course';
//           });
//         } else {
//           showToast('Invalid response format');
//         }
//       } else if (response.statusCode == 500) {
//         showToast('Internal Server Error');
//       } else {
//         showToast('Failed to fetch courses');
//       }
//     } catch (error) {
//       if (kDebugMode) {
//         print('Error fetching course names: $error');
//       }
//     }
//   }
//
//   Future<void> _fetchAttendanceDetails(
//       String classID, String periodNo, DateTime date) async {
//     try {
//       final SharedPreferences sp = await SharedPreferences.getInstance();
//       final String? secretCode = sp.getString("SECRET_TOKEN");
//
//       final dio = Dio();
//
//       final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//
//       final response = await dio.get(
//         ApiConstants().getAttendanceForSlot,
//         queryParameters: {
//           'classID': classID,
//           'PeriodNo': periodNo,
//           'date': formattedDate,
//         },
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'authorization': 'Bearer $secretCode',
//           },
//           validateStatus: (status) => status! < 1000,
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         setState(() {
//           attendanceDetails = List<Map<String, dynamic>>.from(response.data);
//         });
//       } else {
//         showToast('Failed to fetch attendance details');
//       }
//     } catch (error) {
//       if (kDebugMode) {
//         print('Error fetching attendance details: $error');
//       }
//     }
//   }
//
//   void _generateAndDownloadExcel() async {
//     Excel excel = Excel.createExcel();
//     Sheet sheetObject = excel['Sheet1'];
//
//     // Add headers
//     sheetObject.appendRow([
//       Cell('Class Details', cellStyle: CellStyle(backgroundColorHex: '#FFFF00')),
//       Cell('Course Name', cellStyle: CellStyle(backgroundColorHex: '#FFFF00')),
//       Cell('Roll Number', cellStyle: CellStyle(backgroundColorHex: '#FFFF00')),
//       Cell('Student Name', cellStyle: CellStyle(backgroundColorHex: '#FFFF00')),
//       Cell('Date-wise Attendance', cellStyle: CellStyle(backgroundColorHex: '#FFFF00')),
//     ]);
//
//     // Add data
//     sheetObject.appendRow([
//       Cell('Batch Year: ${_batchYearController.text}'),
//       Cell('Department: ${_departmentController.text}'),
//       Cell('Section: ${_sectionController.text}'),
//       Cell('Semester: ${_semesterController.text}'),
//       Cell('Course: ${_courseNameController.text}'),
//     ]);
//
//     for (var studentDetails in attendanceDetails) {
//       sheetObject.appendRow([
//         Cell(''),
//         Cell(''),
//         Cell(studentDetails['RollNO']),
//         Cell(''),
//         Cell(studentDetails['attstatus']),
//       ]);
//     }
//
//     // Save to file
//     var fileSavePath = '/path/to/your/storage/folder/attendance_sheet.xlsx';
//     await excel.encode()!.then((onValue) {
//       if (onValue != null) {
//         File(fileSavePath).writeAsBytesSync(onValue);
//       }
//     });
//
//     showToast('Excel sheet generated and saved at: $fileSavePath');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               BatchYearDropdown(
//                 onChanged: (int newValue) {
//                   setState(() {
//                     _batchYearController.text = newValue.toString();
//                   });
//                 },
//               ),
//               const SizedBox(height: 16.0),
//               DepartmentDropdown(
//                 onChanged: (String newValue) {
//                   setState(() {
//                     _departmentController.text = newValue;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16.0),
//               SectionDropdown(
//                 onChanged: (String newValue) {
//                   setState(() {
//                     _sectionController.text = newValue;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16.0),
//               SemesterDropdown(
//                 onChanged: (int newValue) {
//                   setState(() {
//                     _semesterController.text = newValue.toString();
//                   });
//                 },
//               ),
//               const SizedBox(height: 16.0),
//               CourseDropdown(
//                 onChanged: (String newValue) {
//                   setState(() {
//                     _courseNameController.text = newValue;
//                     _fetchCourseNames();
//                   });
//                 },
//               ),
//               const SizedBox(height: 16.0),
//               MyTextField(
//                 controller: _periodController,
//                 prefixIcon: const Icon(Icons.access_alarms_rounded),
//                 validator: null,
//                 labelText: 'Period Number',
//                 hintText: 'Please enter a period number',
//                 obscureText: false,
//                 keyboardType: TextInputType.number,
//                 enabled: true,
//               ),
//               const SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_periodController.text.isNotEmpty &&
//                       selectedDate != null) {
//                     final String batchYear = _batchYearController.text;
//                     final String department = _departmentController.text;
//                     final String section = _sectionController.text;
//                     final String semester = _semesterController.text;
//                     final String course = _courseNameController.text;
//
//                     final String periodNo = _periodController.text;
//                     final DateTime selectedDate = this.selectedDate!;
//
//                     _fetchAttendanceDetails(
//                       'get classID based on selected dropdown values',
//                       periodNo,
//                       selectedDate,
//                     );
//                   } else {
//                     showToast('Please select all inputs');
//                   }
//                 },
//                 child: const Text('Fetch Attendance'),
//               ),
//               const SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: () async {
//                   DateTime? pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2101),
//                   );
//                   if (pickedDate != null && pickedDate != selectedDate) {
//                     setState(() {
//                       selectedDate = pickedDate;
//                     });
//                   }
//                 },
//                 child: const Text('Select Date'),
//               ),
//               const SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: () async {
//                   // Additional code to generate and download Excel
//                   _generateAndDownloadExcel();
//                 },
//                 child: const Text('Generate and Download Excel'),
//               ),
//               const SizedBox(height: 16.0),
//               if (attendanceDetails.isNotEmpty)
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: attendanceDetails.length,
//                     itemBuilder: (context, index) {
//                       final studentDetails = attendanceDetails[index];
//                       final rollNo = studentDetails['RollNO'];
//                       final attStatus = studentDetails['attstatus'];
//
//                       return ListTile(
//                         title: Text('Roll No: $rollNo'),
//                         subtitle: Text('Attendance Status: $attStatus'),
//                       );
//                     },
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
