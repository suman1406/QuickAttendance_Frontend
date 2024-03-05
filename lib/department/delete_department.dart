import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dropdowns/drop_down_dept.dart';

class DeleteDepartmentPage extends StatefulWidget {
  const DeleteDepartmentPage({Key? key}) : super(key: key);

  @override
  DeleteDepartmentPageState createState() => DeleteDepartmentPageState();
}

class DeleteDepartmentPageState extends State<DeleteDepartmentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _deptNameController = TextEditingController();
  List<String> department = [];
  String selectedDepartment = 'Select a department'; // Set default value

  @override
  void dispose() {
    _deptNameController.dispose();
    _fetchDeptNames(); // Fetch dept names when the page is initialized
    super.dispose();
  }

  Future<void> _fetchDeptNames() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        ApiConstants().allDepts,
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
        // Ensure that the response data is a Map and contains the 'department' key
        if (response.data is Map && response.data.containsKey('depts')) {
          List<dynamic> courseData = response.data['depts'];

          setState(() {
            department = courseData.map((course) => course.toString()).toList();

            // Check if 'Select a course' is not already in the list
            if (!department.contains('Select a department')) {
              department.insert(0, 'Select a department');
            }

            selectedDepartment =
                department.isNotEmpty ? department[0] : 'Select a department';
          });
        } else {
          showToast('Invalid response format');
        }
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch department');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching department names: $error');
      }
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this department?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteDept(); // Perform course deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteDept() async {
    final deptName = _deptNameController.text.trim();

    if (deptName.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Delete Dept Request:');
      print('DeptName: $deptName');
    }
    // Create Dio instance
    final dio = Dio();

    // Send DELETE request to the backend server
    try {
      final response = await dio.delete(
        ApiConstants().deleteDept,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'deptName': deptName,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Delete Department Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 200) {
        showToast('Department deleted successfully');
      } else if (response.statusCode == 404) {
        showToast('Department not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting course: $error');
      }
    } finally {
      setState(() {
        _deptNameController.clear();
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Department'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DepartmentDropdown(
                onChanged: (String newValue) {
                  setState(() {
                    _deptNameController.text = newValue;
                    _fetchDeptNames();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with deleteDept
                    await _showConfirmationDialog();
                    deleteDept();
                    _fetchDeptNames(); // Update the dropdown after deletion
                  }
                },
                child: const Text('Delete Department'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
