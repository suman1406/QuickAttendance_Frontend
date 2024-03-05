import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/admin/editUser/enter_email.dart';
import 'package:quick_attednce/utils/api_constants.dart';
import 'package:quick_attednce/utils/components/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/components/text_field.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({Key? key, required this.userEmail}) : super(key: key);

  final String userEmail;

  @override
  EditUserPageState createState() => EditUserPageState();
}

class EditUserPageState extends State<EditUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _profNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final String _errorMessage = '';

  Future<String?> fetchUserData() async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.get(
        '${ApiConstants().fetchUser}?userEmail=${widget.userEmail}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        _profNameController.text = userData['profName'];
        _emailController.text = userData['email'];
        // You may choose whether to populate the password field
        // _passwordController.text = userData['password'];
        showToast('Fetched user data!');
        return "0";
      } else if (response.statusCode == 404) {
        showToast('Something went wrong, please login again');
      } else if (response.statusCode == 401) {
        showToast('User not found');
      } else if (response.statusCode == 403) {
        showToast('Unauthorized access');
      } else if (response.statusCode == 405) {
        showToast('Failed to update user profile');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      } else {
        showToast('Failed to fetch user data');
        return Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) {
          return const EnterEmailScreen();
        }),);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching user data: $error');
      }
      showToast('Failed to fetch user data');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Add this line to fetch user data when the page initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) {
              return const EnterEmailScreen();
            }),);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyTextField(
                  controller: _profNameController,
                  validator: _profNameValidator,
                  prefixIcon: const Icon(
                      Icons.person), // Add your prefix icon if needed
                  labelText: 'Professor Name',
                  hintText: 'Enter professor name',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  enabled: true,
                ),
                const SizedBox(height: 16.0),
                MyTextField(
                  controller: _emailController,
                  validator: _emailValidator,
                  prefixIcon: const Icon(
                      Icons.badge_rounded), // Add your prefix icon if needed
                  labelText: 'Email',
                  hintText: 'Enter email',
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      editUser();
                    }
                  },
                  child: const Text('Edit User'),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _profNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the professor name';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the email';
    } else if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void editUser() async {
    try {
      final profName = _profNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final courseName = _courseNameController.text.trim();

      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? secretCode = sp.getString("SECRET_TOKEN");

      final dio = Dio();

      final response = await dio.put(
        ApiConstants().editUser,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $secretCode',
          },
          validateStatus: (status) => status! < 1000,
        ),
        data: {
          'profName': profName,
          'email': email,
          'password': password,
          'courseName': courseName,
        },
      );

      if (kDebugMode) {
        print('Edit User Response: ${response.statusCode} - ${response.data}');
      }

      if (response.statusCode == 200) {
        showToast('User updated successfully');
      } else if (response.statusCode == 400) {
        showToast('Invalid data');
      } else if (response.statusCode == 404) {
        showToast('User not found');
      } else if (response.statusCode == 500) {
        showToast('Internal Server Error');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error editing user: $error');
      }
      showToast('Failed to edit user. Please try again.');
    }
  }
}
