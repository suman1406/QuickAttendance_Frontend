import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_batchYear.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_dept.dart';
import 'package:quick_attednce/utils/dropdowns/drop_down_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/a_home_screen.dart';
import '../professor/p_home_screen.dart';
import '../utils/dropdowns/drop_down_section.dart';
import '../utils/dropdowns/drop_down_semester.dart';

class CreateSlotPage extends StatefulWidget {
  const CreateSlotPage({Key? key}) : super(key: key);

  @override
  CreateSlotPageState createState() => CreateSlotPageState();
}

class CreateSlotPageState extends State<CreateSlotPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedBatchYear = 'Select a batch year';
  String selectedDepartment = 'Select a department';
  String selectedSection = 'Select a section';
  String selectedSemester = 'Select a semester';
  String selectedCourse = 'Select a course';
  String selectedPeriodNo = '1';
  late final _semesterController = TextEditingController();
  late final _batchYearController = TextEditingController();

  void createSlot() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? secretCode = sp.getString("SECRET_TOKEN");

    // Implement your logic to create a slot
    // Use the selected values: selectedBatchYear, selectedDepartment, selectedSection,
    // selectedSemester, selectedCourse, and selectedPeriodNo

    try {
      final dio = Dio();

      final response = await dio.post(
        ApiConstants().addSlot,
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

      print('Create Slot Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 201) {
        showToast('Slot created successfully');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to create slot');
      }
    } catch (error) {
      print('Error creating slot: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Slot'),
        leading: IconButton(
          onPressed: () async {
            final SharedPreferences sp = await SharedPreferences.getInstance();
            final String userRole = sp.getString("userRole").toString();

            if (userRole == "0") {
              Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(builder: (context) {
                    return const ProfessorHomeScreen();
                  }), (route) => false);
            } else if (userRole == "1") {
              Navigator.of(context).pushAndRemoveUntil(
                  CupertinoPageRoute(builder: (context) {
                    return const AdminHomeScreen();
                  }), (route) => false);
            }
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
                    _semesterController.text = newValue.toString();
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with createSlot
                    createSlot();
                  }
                },
                child: const Text('Create Slot'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
