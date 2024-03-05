import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_batch_year.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_dept.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';

class DeleteSlotPage extends StatefulWidget {
  const DeleteSlotPage({Key? key}) : super(key: key);

  @override
  DeleteSlotPageState createState() => DeleteSlotPageState();
}

class DeleteSlotPageState extends State<DeleteSlotPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedBatchYear = 'Select a batch year';
  String selectedDepartment = 'Select a department';
  String selectedSection = 'Select a section';
  String selectedSemester = 'Select a semester';
  String selectedPeriodNo = '1';
  late final _batchYearController = TextEditingController();

  void deleteSlot() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    try {
      final dio = Dio();

      final response = await dio.delete(
        ApiConstants().deleteSlot,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          "batchYear": selectedBatchYear,
          "Dept": selectedDepartment,
          "Section": selectedSection,
          "Semester": selectedSemester,
          "periodNo": selectedPeriodNo,
        },
      );

      if (kDebugMode) {
        print(
            'Delete Slot Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 201) {
        showToast('Slot deleted successfully');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to delete slot');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting slot: $error');
      }
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this slot?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteSlot(); // Perform course deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Slot'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BatchYearDropdown(
                onChanged: (int newValue) {
                  setState(() {
                    _batchYearController.text = newValue.toString();
                    selectedBatchYear = newValue.toString();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DepartmentDropdown(
                onChanged: (String newValue) {
                  setState(() {
                    selectedDepartment = newValue;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              SectionDropdown(
                onChanged: (String newValue) {
                  setState(() {
                    selectedSection = newValue;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              SemesterDropdown(
                onChanged: (int newValue) {
                  setState(() {
                    selectedSemester = newValue.toString();
                  });
                },
              ),
              const SizedBox(height: 16.0),
              SlotDropdown(
                onChanged: (String newValue) {
                  setState(() {
                    selectedPeriodNo = newValue;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with deleteSlot
                    await _showConfirmationDialog();
                    deleteSlot();
                  }
                },
                child: const Text('Delete Slot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
