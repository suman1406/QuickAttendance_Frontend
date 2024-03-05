import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';

class MyClassPage extends StatefulWidget {
  const MyClassPage({super.key});

  @override
  MyClassPageState createState() => MyClassPageState();
}

class MyClassPageState extends State<MyClassPage> {
  List<Map<String, dynamic>> userClasses = [];

  @override
  void initState() {
    super.initState();
    fetchUserClasses();
  }

  Future<void> fetchUserClasses() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");
      final String? userEmail = sp.getString("userEmail");

      final response = await Dio().get(
        ApiConstants().myClasses,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {'userEmail': userEmail},
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Response Data: ${response.data}');
        }
        final List<dynamic> classes = response.data;
        setState(() {
          userClasses = List<Map<String, dynamic>>.from(classes);
        });
      } else {
        // Handle error cases, show a message, or retry logic
        if (kDebugMode) {
          print('Failed to fetch user classes: ${response.statusCode}');
        }
      }
    } catch (error) {
      // Handle network errors or other exceptions
      if (kDebugMode) {
        print('Error fetching user classes: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
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
      body: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        child: userClasses.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userClasses.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      title: Text(
                        'Dept ${userClasses[index]["DeptName"]}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Section: ${userClasses[index]["Section"]}'),
                          Text('Semester: ${userClasses[index]["Semester"]}'),
                          Text(
                              'Batch Year: ${userClasses[index]["batchYear"]}'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to class details or perform an action
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
