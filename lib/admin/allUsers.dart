import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../professor/p_home_screen.dart';
import '../utils/dropdowns/drop_down_userRole.dart';
import 'a_home_screen.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  AllUsersPageState createState() => AllUsersPageState();
}

class AllUsersPageState extends State<AllUsersPage> {
  late int selectedUserRole;
  List<Map<String, dynamic>> users = [];

  Future<void> fetchUsers(int selectedUserRole) async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();
      final response = await dio.get(
        ApiConstants().getAllUsers,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $secretCode',
          },
        ),
        data: {
          'reqRole': selectedUserRole,
        },
      );

      if (kDebugMode) {
        print('Request URL: ${ApiConstants().getAllUsers}');
        print('Request Headers: ${response.requestOptions.headers}');
        print(
            'Request Query Parameters: ${response.requestOptions.queryParameters}');
        print('Response Status Code: ${response.statusCode}');
        print('Response Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response.data['users']);
        });
      } else if (response.statusCode == 400) {
        showToast('Invalid email');
      } else if (response.statusCode == 401) {
        showToast('Unauthorized Access');
      } else if (response.statusCode == 500) {
        print(selectedUserRole);
        print(response.data);
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch users');
        // Handle error
        if (kDebugMode) {
          print('Failed to fetch users');
        }
      }
    } catch (error) {
      // Handle error
      if (kDebugMode) {
        print('Error fetching users: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Set the selectedUserRole to the default role (0 for faculty)
    selectedUserRole = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        leading: IconButton(
          onPressed: () async {
            final SharedPreferences sp = await SharedPreferences.getInstance();
            final String userRole = sp.getString("userRole").toString();

            if (userRole == "0") {
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) {
                return const ProfessorHomeScreen();
              }),);
            } else if (userRole == "1") {
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) {
                return const AdminHomeScreen();
              }),);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                UserRoleDropdown(
                  onChanged: (String newValue) {
                    setState(() {
                      selectedUserRole = int.parse(newValue);
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Call API to get user data based on selected user role
                    if (kDebugMode) {
                      print(
                          '=================================$selectedUserRole');
                    }
                    fetchUsers(selectedUserRole);
                  },
                  child: const Text('Get User Data'),
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        title: Text('Name: ${user['profName']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user['email']}'),
                            // Add other user details as needed
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
