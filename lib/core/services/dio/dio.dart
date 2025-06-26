import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../shared/constants/url_constants.dart';
import 'dart:io';

class DioHelper {
  static Dio? dio;
  static bool _interceptorsAdded = false;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: UrlConstants.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    // TEMPORARY: Bypass SSL certificate verification for development
    // WARNING: Remove this in production!
    (dio!.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Add interceptors only once during initialization
    _addInterceptors();
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    Map<String, dynamic>? headers,
    String lang = 'en',
    String? token,
  }) async {
    try {
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
                  headers: headers ??
                      {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'Authorization': 'Bearer $token',
                      })
              : Options(
                  method: 'POST',
                  headers: {'Content-Type': 'application/json'}));
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Response> getData({
    required String url,
    String? token,
    required Map<String, dynamic> query,
    Map<String, dynamic>? header,
  }) async {
    try {
      var headers = header ??
          {
            'Authorization': 'Bearer $token',
            'Cookie': token,
          };

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
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Response> delete({
    required String url,
    required String token,
  }) async {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      return dio!.request(
        url,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Response> patch({
    required String url,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Cookie': token,
      };
      return dio!.request(
        url,
        options: Options(
          method: 'PATCH',
          headers: headers,
        ),
        data: data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Add interceptors only once during initialization
  static void _addInterceptors() {
    if (!_interceptorsAdded && dio != null && kDebugMode) {
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
      _interceptorsAdded = true;
    }
  }

  /// Handle Dio errors and provide meaningful error messages
  static String _handleDioError(DioException e) {
    String errorMessage = 'An unexpected error occurred';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode != null) {
          switch (e.response!.statusCode) {
            case 400:
              errorMessage = 'Bad request. Please check your input.';
              break;
            case 401:
              errorMessage = 'Unauthorized. Please login again.';
              break;
            case 403:
              errorMessage = 'Forbidden. You don\'t have permission.';
              break;
            case 404:
              errorMessage = 'Resource not found.';
              break;
            case 500:
              errorMessage = 'Server error. Please try again later.';
              break;
            default:
              errorMessage =
                  'Request failed with status: ${e.response!.statusCode}';
          }
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage =
            'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage =
            'Certificate verification failed. Please check your connection security.';
        break;
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true) {
          errorMessage = 'No internet connection. Please check your network.';
        } else if (e.message?.contains('HandshakeException') == true) {
          errorMessage = 'Security handshake failed. Please try again.';
        } else {
          errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
        }
        break;
    }

    // Log the error for debugging
    if (kDebugMode) {
      print('DioError: $errorMessage');
    }
    if (kDebugMode) {
      print('DioError Details: ${e.toString()}');
    }

    return errorMessage;
  }
}
