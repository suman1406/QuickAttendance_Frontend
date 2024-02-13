class ApiConstants {
  static const String baseUrl =
      'https://a522-2409-40f4-10ff-7ae1-d443-147d-58a5-8e8b.ngrok-free.app/api';

  String url =
      'https://a522-2409-40f4-10ff-7ae1-d443-147d-58a5-8e8b.ngrok-free.app/api';

  String login = '$baseUrl/login';
  String loginVerify = '$baseUrl/loginVerify';
  String addAdmin = '$baseUrl/add-admin';
  String deleteAdmin = '$baseUrl/delete-admin/';
  String addFaculty = '$baseUrl/add-faculty';
  String deleteFaculty = '$baseUrl/delete-faculty/';
  String editUser = '$baseUrl/edit-user';
  String getAllUsers = '$baseUrl/users/all';
  String forgotPassword = '$baseUrl/forgot-password';
  String resetVerify = '$baseUrl/reset-verify';
  String resetPassword = '$baseUrl/reset-password';
  String addStudent = '$baseUrl/add-student';
  String editStudent = '$baseUrl/edit-student';
  String fetchStudent = '$baseUrl/fetchStudent';
  String allUserRoles = '$baseUrl/allUserRoles';
  String deleteStudent = '$baseUrl/delete-student';
  String activateStudent = '$baseUrl/activate-student';
  String allStudents = '$baseUrl/all-students';
  String addStudents = '$baseUrl/add-students';
  String allBatchYears = '$baseUrl/all-batchYears';
  String allSections = '$baseUrl/all-sections';
  String addClass = '$baseUrl/add-class';
  String myClasses = '$baseUrl/my-classes';
  String allSemesters = '$baseUrl/all-semesters';
  String deleteClass = '$baseUrl/delete-class';
  String addSlot = '$baseUrl/add-slot';
  String deleteSlot = '$baseUrl/delete-slot';
  String addCourse = '$baseUrl/add-course';
  String deleteCourse = '$baseUrl/delete-course';
  String allCourses = '$baseUrl/all-courses';
  String myCourses = '$baseUrl/my-courses';
  String addDept = '$baseUrl/add-dept';
  String deleteDept = '$baseUrl/delete-dept';
  String allDepts = '$baseUrl/all-dept';
  String fetchUser = '$baseUrl/fetchUser';
  String allEmails = '$baseUrl/all-profs';
  String linkClassCourseProf = '$baseUrl/add-class-course-prof';
  String linkCourseProf = '$baseUrl/add-prof-course';
  String deleteClassCourseProf = '$baseUrl/delete-class-course-prof';
  String deleteProfCourse = '$baseUrl/delete-prof-course';
  String activateUser = '$baseUrl/activate-user';
  String addAttendance = '$baseUrl/add-attendance';
  String reqSlotID = '$baseUrl/req-slotID';
  String getAttendanceForSlot = '$baseUrl/attendance-slot';
  String getAttendanceForCourse = '$baseUrl/attd-coursewise';
}
