import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../components/toast.dart';

class ProfEmailDropdown extends StatefulWidget {
  final Function(String) onChanged;

  const ProfEmailDropdown({super.key, required this.onChanged});

  @override
  _ProfEmailDropdownState createState() => _ProfEmailDropdownState();
}

class _ProfEmailDropdownState extends State<ProfEmailDropdown> {
  List<String> profEmails = [];
  String selectedProfEmail = 'Select a professor email'; // Set default value

  @override
  void initState() {
    super.initState();
    _fetchProfEmails();
  }

  Future<void> _fetchProfEmails() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        ApiConstants().allEmails,
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
        // Ensure that the response data is a Map and contains the 'profs' key
        if (response.data is Map && response.data.containsKey('profs')) {
          List<dynamic> profData = response.data['profs'];

          setState(() {
            profEmails = profData.map<String>((prof) {
              if (prof is Map<String, dynamic> && prof.containsKey('email')) {
                // Access the 'email' key and convert it to String
                return prof['email'].toString();
              }
              // Handle the case when the structure is different
              return prof.toString();
            }).toList();

            // Check if 'Select a professor email' is not already in the list
            if (!profEmails.contains(AppConstants.selectProfEmail)) {
              profEmails.insert(0, AppConstants.selectProfEmail);
            }

            selectedProfEmail = profEmails.isNotEmpty
                ? profEmails[0]
                : AppConstants.selectProfEmail;
          });
        } else {
          showToast(AppConstants.invalidResponseFormat);
        }
      } else if (response.statusCode == 400) {
        showToast('Something went wrong, please login again');
      } else if (response.statusCode == 401) {
        showToast('Access restricted');
      } else if (response.statusCode == 500) {
        showToast(AppConstants.internalServerError);
      } else {
        showToast(AppConstants.failedToFetchProfEmails);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching professor emails: $error');
      }
      showToast('$error');
    }
  }

  void _onDropdownOpened() {
    _fetchProfEmails();
  }

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
              Icons.badge_rounded,
              color: colorScheme.secondary,
              size: 25,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProfEmail,
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
                        selectedProfEmail = newValue;
                        widget.onChanged(newValue);
                      });
                    }
                  },
                  onTap: () => _onDropdownOpened(),
                  items:
                      profEmails.map<DropdownMenuItem<String>>((String value) {
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
  static const String selectProfEmail = 'Select a professor email';
  static const String invalidResponseFormat = 'Invalid response format';
  static const String internalServerError = 'Internal Server Error';
  static const String failedToFetchProfEmails =
      'Failed to fetch professor emails';
}
