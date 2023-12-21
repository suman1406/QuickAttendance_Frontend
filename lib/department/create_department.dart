import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/components/text_field.dart';

class CreateDepartmentPage extends StatefulWidget {
  const CreateDepartmentPage({super.key});

  @override
  CreateDepartmentPageState createState() => CreateDepartmentPageState();
}

class CreateDepartmentPageState extends State<CreateDepartmentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _newDeptNameController = TextEditingController();
  late final String _errorMessage = '';

  @override
  void dispose() {
    _newDeptNameController.dispose();
    super.dispose();
  }

  String? _departmentNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a course name';
    }
    return null;
  }

  void createDept() async {
    final newDeptName = _newDeptNameController.text.trim();

    if (newDeptName.isEmpty) {
      return;
    }

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Create Course Request:');
      print('newDeptName: $newDeptName');
    }

    // Create Dio instance
    final dio = Dio();

    // Send POST request to the backend server
    try {
      final response = await dio.post(
        ApiConstants().addDept,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'deptName': newDeptName,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Create Dept Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Dept created successfully');
      } else if (response.statusCode == 403) {
        showToast('Dept already exists');
      } else if (response.statusCode == 500) {
        showToast('Dept Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error creating dept: $error');
      }
    } finally {
      setState(() {
        _newDeptNameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Department'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyTextField(
                  controller: _newDeptNameController,
                  prefixIcon: const Icon(Icons.book_rounded),
                  keyboardType: TextInputType.text,
                  validator: _departmentNameValidator,
                  labelText: 'Department Name',
                  hintText: 'Please enter a department name',
                  obscureText: false,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with createDept
                      createDept();
                    }
                  },
                  child: const Text('Create Department'),
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
