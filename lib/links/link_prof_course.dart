import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/dropdowns/list_dropdown/multi_course_dropdown.dart';
import 'package:quick_attednce/utils/dropdowns/prof_email_drop_down.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkProfCoursePage extends StatefulWidget {
  const LinkProfCoursePage({Key? key}) : super(key: key);

  @override
  LinkProfCoursePageState createState() => LinkProfCoursePageState();
}

class LinkProfCoursePageState extends State<LinkProfCoursePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _errorMessage = '';
  List<String> selectedCourses = [];
  String selectedProfEmail = '';

  void linkCourses() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Print or log the request payload for debugging
    if (kDebugMode) {
      print('Link Prof/Course Request:');
      print('courses: $selectedCourses');
      print('profEmail: $selectedProfEmail');
    }

    // Create Dio instance
    final dio = Dio();

    // Send POST request to the backend server
    try {
      final response = await dio.post(
        ApiConstants().linkCourseProf,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'courses': selectedCourses,
          'profEmail': selectedProfEmail,
        },
      );

      // Print the response for debugging
      if (kDebugMode) {
        print(
            'Link Prof/Course Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Linked successfully');
      } else if (response.statusCode == 400) {
        showToast('Invalid data');
      } else if (response.statusCode == 404) {
        showToast('Current user not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error linking courses: $error');
      }
      showToast('Failed to link. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link a Professor to Courses'),
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
                ProfEmailDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      selectedProfEmail = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                MultiCourseDropdown(
                  onChanged: (List<String> newValues) {
                    setState(() {
                      selectedCourses = newValues;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with linkCourses
                      linkCourses();
                      if (kDebugMode) {
                        print(
                            '=========================================================');
                      }
                    }
                  },
                  child: const Text('Link'),
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
