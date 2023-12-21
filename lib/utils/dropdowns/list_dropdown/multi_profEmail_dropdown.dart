import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_constants.dart';
import '../../components/toast.dart';

class MultiUserEmailDropdown extends StatefulWidget {
  final Function(List<String>) onChanged;

  const MultiUserEmailDropdown({super.key, required this.onChanged});

  @override
  _MultiUserEmailDropdownState createState() => _MultiUserEmailDropdownState();
}

class _MultiUserEmailDropdownState extends State<MultiUserEmailDropdown> {
  List<String> email = [];
  List<String> selectedEmails = [];
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
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

      print('Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response data is a List
        if (response.data is Map && response.data.containsKey('profs')) {
          List<dynamic> emailData = response.data['profs'];

          print('Email Data: $emailData');

          if (emailData.isEmpty) {
            showToast('No users found');
          } else {
            // Check if "Select a Email" is in the list, and insert it at the first index if not present
            if (!emailData.any((user) => user['email'] == 'Select a Email')) {
              emailData.insert(0, {'email': 'Select a Email'});
            }

            setState(() {
              email = emailData.map((user) => user['email'].toString()).toList();
            });
          }
        } else {
          showToast('Invalid response format');
        }
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch email');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching email names: $error');
      }
    }
  }

  void _addEmail(String email) {
    setState(() {
      if (email != 'Select a Email' && !selectedEmails.contains(email)) {
        selectedEmails.add(email);
        widget.onChanged(selectedEmails);
      }
      _emailController.clear();
    });
  }

  void _removeEmail(String email) {
    setState(() {
      selectedEmails.remove(email);
      widget.onChanged(selectedEmails);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selected Emails Box
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
                      'Selected Emails',
                      style: GoogleFonts.raleway(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: selectedEmails
                      .where((email) => email != 'Select a Email')
                      .map((email) {
                    return Chip(
                      label: Text(
                        email,
                        style: GoogleFonts.raleway(
                          color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onDeleted: () => _removeEmail(email),
                      deleteIconColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // Dropdown for Adding Emails
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
                      value: selectedEmails.isNotEmpty
                          ? 'Select a Email'
                          : 'Select a Email',
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      elevation: 16,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _addEmail(newValue);
                        }
                      },
                      items: email.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: Text(
                              value,
                              style: GoogleFonts.raleway(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
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
