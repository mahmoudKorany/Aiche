import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../shared/constants/url_constants.dart';

class DioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: UrlConstants.baseUrl,
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    Map<String, dynamic>? headers,
    String lang = 'en',
    String? token,
  }) async {
    var response = await dio!.post(url,
        queryParameters: query,
        data: data,
        options: token != null
            ? Options(
                method: 'POST',
                followRedirects: false,
                validateStatus: (status) {
                  return status! < 500;
                },
                headers: headers ?? {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': 'Bearer $token',
                  })
            : Options(
                method: 'POST', headers: {'Content-Type': 'application/json'}));
   addInterceptors();
    return response;
  }

  static Future<Response> getData({
    required String url,
    String? token,
    required Map<String, dynamic> query,
    Map<String, dynamic>? header,
  }) async {
    var headers = header?? {
      'Authorization': 'Bearer $token',
      'Cookie': token,
    };
   addInterceptors();
    return await dio!.get(
      url,
      queryParameters: query,
      options: token != null
          ? Options(
              method: 'GET',
              headers: headers,
            )
          : null,
    );
  }

  static Future<Response> delete({
    required String url,
    required String token,
  }) async {
    var headers = {'Authorization': 'Bearer $token'};
    addInterceptors();
    return dio!.request(
      url,
      options: Options(
        method: 'DELETE',
        headers: headers,
      ),
    );
  }

  static Future<Response> patch({
    required String url,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Cookie': token,
    };
    addInterceptors();
    return dio!.request(
      url,
      options: Options(
        method: 'PATCH',
        headers: headers,
      ),
      data: data,
    );
  }

  /// put request
  static void addInterceptors( ) {
    dio!.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );
  }
}