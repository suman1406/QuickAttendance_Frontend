import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../components/toast.dart';

class SectionDropdown extends StatefulWidget {
  final Function(String) onChanged;
  final String? initialValue;

  const SectionDropdown({Key? key, required this.onChanged, this.initialValue})
      : super(key: key);

  @override
  SectionDropdownState createState() => SectionDropdownState();
}

class SectionDropdownState extends State<SectionDropdown> {
  List<String> sections = [];
  late String selectedSection;

  @override
  void initState() {
    super.initState();
    selectedSection = widget.initialValue ?? 'A'; // Use initialValue if provided, otherwise default to 'A'
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        ApiConstants().allSections,
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
        // Ensure that the response data is a Map and contains the 'sections' key
        if (response.data is Map && response.data.containsKey('sections')) {
          List<dynamic> sectionData = response.data['sections'];

          setState(() {
            sections = sectionData.map((section) => section.toString()).toList();

            // Check if 'Select a section' is not already in the list
            if (!sections.contains('A')) {
              sections.insert(0, 'A');
            }
          });

        } else {
          showToast('Invalid response format');
        }
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch sections');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching sections: $error');
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
              Icons.grade_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
            const SizedBox(width: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSection,
                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary,),
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
                      selectedSection = newValue;
                      widget.onChanged(newValue);
                    });
                  }
                },
                items: sections.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Text(
                        'Section $value',
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
