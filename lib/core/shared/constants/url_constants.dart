class UrlConstants {
  static const String baseUrl =
      'https://backend.aichesusc.org/api/';

  //user

  static const String login = 'login';
  static const String register = 'register';
  static const String getUserDetails = 'profile';
  static const String signWithGoogle = 'auth/google/callback';
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
  static const String getCommittees = 'committees';

  ///Tasks
  static const String getTasks = 'tasks';

  ///sessions
  static const String getSessions = 'sessions';

  // banner
  static const String getHomeBanner = 'baners';


  // get Material
  static const String getMaterial = 'materials';


  //SHOP
  static const String getAllProducts = 'products';
  static const String getAllCollections = 'collections';
  static const String placeProductOrder = 'products-orders';
  static const String placeCollectionOrder = 'collections-orders';


  // reqest-join
  static const String requestJoin = 'reqest-join';

}
