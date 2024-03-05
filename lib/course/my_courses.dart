import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({Key? key}) : super(key: key);

  @override
  MyCoursesPageState createState() => MyCoursesPageState();
}

class MyCoursesPageState extends State<MyCoursesPage> {
  List<String> userCourses = [];

  Future<void> fetchUserCourses() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");
      final String? userEmail = sp.getString("userEmail");

      final response = await Dio().get(
        ApiConstants().myCourses,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        queryParameters: {'userEmail': userEmail},
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Response Data: ${response.data}');
        }
        final List<dynamic> courses = response.data['courses'];

        setState(() {
          userCourses = courses
              .whereType<String>()
              .map((course) => 'Course: $course')
              .toList();
        });
      } else {
        // Handle error cases, show a message, or retry logic
        print('Failed to fetch user courses: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error fetching user courses: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: userCourses.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userCourses.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(
                        userCourses[index],
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Navigate to course details or perform an action
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
