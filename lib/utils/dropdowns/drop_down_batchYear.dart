import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';
import '../components/toast.dart';

class BatchYearDropdown extends StatefulWidget {
  final Function(int) onChanged;
  final int? initialValue;

  const BatchYearDropdown({Key? key, required this.onChanged, this.initialValue})
      : super(key: key);

  @override
  _BatchYearDropdownState createState() => _BatchYearDropdownState();
}

class _BatchYearDropdownState extends State<BatchYearDropdown> {
  List<int> batchYears = [];
  late int selectedBatchYear;

  @override
  void initState() {
    super.initState();
    selectedBatchYear = widget.initialValue ?? 0; // Use initialValue if provided, otherwise default to 0
    _fetchBatchYears();
  }

  Future<void> _fetchBatchYears() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        ApiConstants().allBatchYears,
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
        // Ensure that the response data is a Map and contains the 'batchYears' key
        if (response.data is Map && response.data.containsKey('batchYears')) {
          List<dynamic> batchYearData = response.data['batchYears'];

          setState(() {
            batchYears = batchYearData.map((batchYear) => batchYear as int).toList();

            // Check if 'Select a batch year' is not already in the list
            if (!batchYears.contains(0)) {
              batchYears.insert(0, 0);
            }
          });

        } else {
          showToast('Invalid response format');
        }
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch batch years');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching batch years: $error');
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
              Icons.date_range,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
            const SizedBox(width: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedBatchYear,
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
                      selectedBatchYear = newValue;
                      widget.onChanged(newValue);
                    });
                  }
                },
                items: batchYears.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Text(
                        value == 0 ? 'Select a batch year' : value.toString(),
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
