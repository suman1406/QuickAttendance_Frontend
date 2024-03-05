import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../components/toast.dart';

class DepartmentDropdown extends StatefulWidget {
  final Function(String) onChanged;

  const DepartmentDropdown({super.key, required this.onChanged});

  @override
  DepartmentDropdownState createState() => DepartmentDropdownState();
}

class DepartmentDropdownState extends State<DepartmentDropdown> {
  List<String> dept = [];
  String selectedDept = 'Select a department'; // Set default value

  @override
  void initState() {
    super.initState();
    _fetchDeptNames();
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
        // Ensure that the response data is a Map and contains the 'depts' key
        if (response.data is Map && response.data.containsKey('depts')) {
          List<dynamic> deptData = response.data['depts'];

          setState(() {
            dept = deptData.map<String>((dept) => dept.toString()).toList();

            // Check if 'Select a dept' is not already in the list
            if (!dept.contains(AppConstants.selectDepartment)) {
              dept.insert(0, AppConstants.selectDepartment);
            }

            selectedDept =
                dept.isNotEmpty ? dept[0] : AppConstants.selectDepartment;
          });
        } else {
          showToast(AppConstants.invalidResponseFormat);
        }
      } else if (response.statusCode == 500) {
        showToast(AppConstants.internalServerError);
      } else {
        showToast(AppConstants.failedToFetchDept);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching dept names: $error');
      }
      showToast('$error');
    }
  }

  void _onDropdownOpened() {
    _fetchDeptNames();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(
          color: colorScheme.onPrimaryContainer,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.category_rounded,
              color: colorScheme.secondary,
              size: 25,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDept,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.primary,
                  ),
                  iconSize: 30,
                  elevation: 16,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  onChanged: (String? newValue) {
                    if (kDebugMode) {
                      print('Selected value: $newValue');
                    }
                    if (newValue != null) {
                      setState(() {
                        selectedDept = newValue;
                        widget.onChanged(newValue);
                      });
                    }
                  },
                  onTap: () => _onDropdownOpened(),
                  items: dept.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          color: colorScheme.background,
                        ),
                        child: Text(
                          value,
                          style: GoogleFonts.raleway(
                            color: colorScheme.onPrimaryContainer,
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
    );
  }
}

class AppConstants {
  static const String selectDepartment = 'Select a department';
  static const String invalidResponseFormat = 'Invalid response format';
  static const String internalServerError = 'Internal Server Error';
  static const String failedToFetchDept = 'Failed to fetch department';
}
