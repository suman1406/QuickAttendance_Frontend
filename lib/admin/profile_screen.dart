import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../professor/p_home_screen.dart';
import 'a_home_screen.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
  });

  @override
  State<UserProfilePage> createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String joke = '';

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey('userName')) {
        _nameController.text = sp.getString('userName')!;
      }
      if (sp.containsKey('userEmail')) {
        _emailController.text = sp.getString('userEmail')!;
      }
    });

    _fetchJoke();
  }

  Future<void> _fetchJoke() async {
    final Dio dio = Dio();

    try {
      final Response response =
          await dio.get('https://api.chucknorris.io/jokes/random');

      if (kDebugMode) {
        print(response.data);
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        setState(() {
          joke = data['value'];
        });
      } else {
        if (kDebugMode) {
          print('Failed to load joke');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100.0,
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/200/300?image=${Random().nextInt(100)}',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                _nameController.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _emailController.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(
                height: 20.0,
              ),
              Text(
                'Random Joke',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                joke.isNotEmpty ? joke : 'Loading joke...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
