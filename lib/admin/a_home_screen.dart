import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_attednce/admin/activate_user.dart';
import 'package:quick_attednce/admin/editUser/enter_email.dart';
import 'package:quick_attednce/admin/profile_screen.dart';
import 'package:quick_attednce/admin/specific_users.dart';
import 'package:quick_attednce/attendance/attendance_details.dart';
import 'package:quick_attednce/attendance/attendance_for_slot.dart';
import 'package:quick_attednce/attendance/download_excel.dart';
import 'package:quick_attednce/auth/login_screen.dart';
import 'package:quick_attednce/class/create_class.dart';
import 'package:quick_attednce/class/delete_class.dart';
import 'package:quick_attednce/class/my_class.dart';
import 'package:quick_attednce/course/create_course.dart';
import 'package:quick_attednce/course/delete_course.dart';
import 'package:quick_attednce/course/my_courses.dart';
import 'package:quick_attednce/department/create_department.dart';
import 'package:quick_attednce/department/delete_department.dart';
import 'package:quick_attednce/links/delete_prof_course.dart';
import 'package:quick_attednce/links/delete_prof_course_class.dart';
import 'package:quick_attednce/settings_screen.dart';
import 'package:quick_attednce/slot/create_slot.dart';
import 'package:quick_attednce/slot/delete_slot.dart';
import 'package:quick_attednce/student/activate_student.dart';
import 'package:quick_attednce/admin/add_admin.dart';
import 'package:quick_attednce/admin/add_faculty.dart';
import 'package:quick_attednce/student/add_student.dart';
import 'package:quick_attednce/admin/allUsers.dart';
import 'package:quick_attednce/student/add_students_excel.dart';
import 'package:quick_attednce/student/delete_student.dart';
import 'package:quick_attednce/student/editStudent/enter_roll.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../links/link_prof_course_class.dart';
import '../utils/components/loading_screen.dart';
import 'package:quick_attednce/student/all_students.dart';
import 'delete_admin.dart';
import 'delete_faculty.dart';
import '../links/link_prof_course.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  AdminHomeScreenState createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  late bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userRoleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey("userName")) {
        _nameController.text = sp.getString("userName")!;
      }
      if (sp.containsKey('userEmail')) {
        _emailController.text = sp.getString("userEmail")!;
      }
      if (sp.containsKey("userRole")) {
        _userRoleController.text = sp.getString("userRole")!;
      }

      setState(() {
        isLoading = false; // Set loading state to false after data retrieval
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen(
            message: 'Loading ...',
          )
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              title: Text(
                "Welcome, ${_nameController.text}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isLogin', false);
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings_rounded,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) {
                        return const SettingsPage();
                      },
                    ));
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildQuickAccessButtonsRow(context),
                    const Divider(
                      height: 20.0,
                    ),
                    const SizedBox(height: 10.0),
                    buildUserDetailsCard(context),
                    const Divider(
                      height: 20.0,
                    ),
                    const SizedBox(height: 10.0),

                    // Attendance

                    CategoryCard(
                      title: 'Attendance',
                      actions: [
                        buildActionCard(context, 'Add Attendance', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AttendanceDetailsPage();
                            },
                          ));
                        }),
                        // buildActionCard(context, 'View Attendance', () {
                        //   Navigator.of(context).push(CupertinoPageRoute(
                        //     builder: (context) {
                        //       return const AttendanceSlotView();
                        //     },
                        //   ));
                        // }),
                        buildActionCard(context, 'Download Excel', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DownloadExcel();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Admin

                    CategoryCard(
                      title: 'Admin',
                      actions: [
                        buildActionCard(context, 'Add Admin', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AddAdminPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Admin', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteAdminPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Faculty

                    CategoryCard(
                      title: 'Faculty',
                      actions: [
                        buildActionCard(context, 'Add Faculty', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AddFacultyPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Faculty', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteFacultyPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Student

                    CategoryCard(
                      title: 'Student',
                      actions: [
                        buildActionCard(context, 'Add Student', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AddStudentPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Edit Student', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return EnterRollNumberScreen();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Student', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteStudentPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Activate Student', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const ActivateStudentPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'All Students', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AllStudentsPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Add Students', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AddStudentsExcelUploadPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // General

                    CategoryCard(
                      title: 'General',
                      actions: [
                        buildActionCard(context, 'Edit User', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const EnterEmailScreen();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Get All Users', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AllUsersPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Activate User', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const ActivateUserPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Class

                    CategoryCard(
                      title: 'Class',
                      actions: [
                        buildActionCard(context, 'Add Class', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const AddClassPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Class', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteClassPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'My Classes', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const MyClassPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Linking
                    CategoryCard(
                      title: 'Linking',
                      actions: [
                        buildActionCard(context, 'Link Prof/Course to a class',
                            () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const LinkProfCourseClassPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Link Professor to a Course',
                            () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const LinkProfCoursePage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Prof/Course class',
                            () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteProfCourseClassPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Professor Course', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteProfCoursePage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Slot
                    CategoryCard(
                      title: 'Slot',
                      actions: [
                        buildActionCard(context, 'Add Slot', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const CreateSlotPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Slot', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteSlotPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Course

                    CategoryCard(
                      title: 'Course',
                      actions: [
                        buildActionCard(context, 'Add Course', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const CreateCoursePage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Course', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteCoursePage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'My Courses', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const MyCoursesPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // Department

                    CategoryCard(
                      title: 'Department',
                      actions: [
                        buildActionCard(context, 'Add Department', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const CreateDepartmentPage();
                            },
                          ));
                        }),
                        buildActionCard(context, 'Delete Department', () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) {
                              return const DeleteDepartmentPage();
                            },
                          ));
                        }),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildQuickAccessButtonsRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return const MyCoursesPage();
                },
              ));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'My Courses',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return const MyClassPage();
                },
              ));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'My Classes',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return const SpecUsers(selectedUserRole: 1);
                },
              ));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'All Admins',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) {
                  return const SpecUsers(selectedUserRole: 0);
                },
              ));
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'All Faculty',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  Widget buildUserDetailsCard(BuildContext context) {
    String userRole;

    if (_userRoleController.text == "1") {
      userRole = "Admin";
    } else if (_userRoleController.text == "0") {
      userRole = "Professor";
    } else {
      userRole = "Unknown Role";
    }

    return Card(
      color: Colors.blueGrey[900],
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16.0),

            // Name

            Row(
              children: [
                const Text(
                  'Name:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _nameController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            // Email

            Row(
              children: [
                const Text(
                  'Email:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _emailController
                        .text, // Replace with the actual user's email
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            // Role

            Row(
              children: [
                const Text(
                  'Role:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    userRole,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16.0),

            // View Profile Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the user profile page
                Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(builder: (context) {
                  return const UserProfilePage();
                }),);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionCard(
    BuildContext context,
    String title,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}

class CategoryCard extends StatefulWidget {
  final String title;
  final List<Widget> actions;

  const CategoryCard({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  CategoryCardState createState() => CategoryCardState();
}

class CategoryCardState extends State<CategoryCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            const SizedBox(height: 3.0),
            Visibility(
              visible: _isExpanded,
              child: Column(
                children: widget.actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
