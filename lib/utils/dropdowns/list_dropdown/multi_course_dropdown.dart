import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_constants.dart';
import '../../components/toast.dart';

class MultiCourseDropdown extends StatefulWidget {
  final Function(List<String>) onChanged;

  const MultiCourseDropdown({super.key, required this.onChanged});

  @override
  MultiCourseDropdownState createState() => MultiCourseDropdownState();
}

class MultiCourseDropdownState extends State<MultiCourseDropdown> {
  List<String> courses = [];
  List<String> selectedCourses = [];
  final TextEditingController _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourseNames();
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

      if (kDebugMode) {
        print('Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 200) {
        // Ensure that the response data is a Map and contains the 'courses' key
        if (response.data is Map && response.data.containsKey('courses')) {
          List<dynamic> courseData = response.data['courses'];

          // Check if "Select a Course" is in the list, and insert it at the first index if not present
          if (!courseData.contains('Select a Course')) {
            courseData.insert(0, 'Select a Course');
          }

          setState(() {
            courses = courseData.map((course) => course.toString()).toList();
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

  void _addCourse(String course) {
    setState(() {
      if (course != 'Select a Course' && !selectedCourses.contains(course)) {
        selectedCourses.add(course);
        widget.onChanged(selectedCourses);
      }
      _courseController.clear();
    });
  }

  void _removeCourse(String course) {
    setState(() {
      selectedCourses.remove(course);
      widget.onChanged(selectedCourses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selected Courses Box
        Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Selected Courses',
                      style: GoogleFonts.raleway(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: selectedCourses
                      .where((course) => course != 'Select a Course')
                      .map((course) {
                    return Chip(
                      label: Text(
                        course,
                        style: GoogleFonts.raleway(
                          color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onDeleted: () => _removeCourse(course),
                      deleteIconColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // Dropdown for Adding Courses
        Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCourses.isNotEmpty
                          ? 'Select a Course'
                          : 'Select a Course',
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      elevation: 16,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _addCourse(newValue);
                        }
                      },
                      items: courses.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: Text(
                              value,
                              style: GoogleFonts.raleway(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
