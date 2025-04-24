class UrlConstants {
  static const String baseUrl =
      'https://backend1.koyeb.app/api/';

  ///user

  static const String login = 'login';
  static const String register = 'register';
  static const String getUserDetails = 'profile';
  //logout
  static const String logout = 'logout';
  //update
  static const String updateUser = 'profile';

  ///Events
  static const String getEvents = 'events';
  static String getEventDetailsbyId({required String id}) => 'events/$id';

  ///blogs
  static const String getBlogs = 'blogs';
  static String getBlogDetailsbyId({required String id}) => 'blogs/$id';

  ///awards
  static const String getAwards = 'awards';
  static String getAwardDetailsbyId({required String id}) => 'awards/$id';

  ///committees
  static const String getCommitties = 'committees';
  static String getCommitteeDetailsbyId({required String id}) =>
      'committees/$id';

  ///Tasks
  static String getTasks(String committeeId) => 'committees/$committeeId/tasks';
  static String getTasksbyId(
          {required String committeeId, required String id}) =>
      'committees/$committeeId/tasks/$id';

  ///sessions
  static String getSessions(String committeeId) =>
      'committees/$committeeId/sessions';
  static String getSessionDetailsbyId(
          {required committeeId, required String id}) =>
      'committees/$committeeId/sessions/$id';

  // banner
  static const String getHomeBanner = 'baners';


  // get Material
  static const String getMaterial = 'materials';
}
