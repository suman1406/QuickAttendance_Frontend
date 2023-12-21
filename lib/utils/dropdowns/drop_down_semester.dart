import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../components/toast.dart';

class SemesterDropdown extends StatefulWidget {
  final Function(int) onChanged;

  const SemesterDropdown({Key? key, required this.onChanged});

  @override
  _SemesterDropdownState createState() => _SemesterDropdownState();
}

class _SemesterDropdownState extends State<SemesterDropdown> {
  List<int> semesters = [];
  late int selectedSemester = 1; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    _fetchSemesters();
  }

  Future<void> _fetchSemesters() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        ApiConstants().allSemesters,
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
        // Ensure that the response data is a Map and contains the 'semesters' key
        if (response.data is Map && response.data.containsKey('semesters')) {
          List<dynamic> semesterData = response.data['semesters'];

          setState(() {
            semesters = semesterData.map((semester) => semester as int).toList();

            // Check if 'Select a semester' is not already in the list
            if (!semesters.contains(1)) {
              semesters.insert(0, 1);
            }

            selectedSemester = semesters.isNotEmpty ? semesters[0] : 1;
          });

        } else {
          showToast('Invalid response format');
        }
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch semesters');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching semesters: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
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
              Icons.numbers_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
            const SizedBox(width: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedSemester,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary,),
                iconSize: 30,
                elevation: 16,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                onChanged: (int? newValue) {
                  if (kDebugMode) {
                    print('Selected value: $newValue');
                  }
                  if (newValue != null) {
                    setState(() {
                      selectedSemester = newValue;
                      widget.onChanged(newValue);
                    });
                  }
                },
                items: semesters.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Text(
                        'Semester $value',
                        style: GoogleFonts.raleway(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
