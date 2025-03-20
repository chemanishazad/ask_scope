import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loop/core/utils/config.dart';
import 'package:loop/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HttpMethod {
  $get,
  $post,
  $delete,
  $patch,
  $put,
  $formdata, // New HttpMethod for form-data
}

enum MultipartFileType { image, audio, video, text }

enum ContentType { json, formData, urlEncoded }

class ApiMaster {
  static String? _token; // Store token in memory

  ApiMaster._();

  static final ApiMaster _instance = ApiMaster._();

  factory ApiMaster() {
    return _instance;
  }

  // Set the token after login
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loopUserToken', token);
  }

  // Clear the token on logout
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loopUserToken');
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('loopUserToken');
    print('Loaded token: $_token');
  }

  // Main method to make API calls
  Future<dynamic> fire({
    required String path,
    Map<String, dynamic>? queryParameters,
    bool headerOverride = false,
    Map<String, String>? headers,
    bool? auth = true,
    HttpMethod method = HttpMethod.$get,
    Object? body,
    ContentType contentType = ContentType.json,
    MultipartFileType? multipartFileType,
    Map<String, String>? multipartFields,
    List<File>? files,
    List<String>? fileFieldNames,
  }) async {
    try {
      if (kDebugMode) {
        print("Request : $method > $path ~ $body");
      }

      final Map<String, String> headersInit = {
        'Content-Type': _getContentType(contentType),
      };

      Map<String, String>? finalHeaders = !headerOverride
          ? headers
          : {
              ...headersInit,
              ...headers!,
            };

      if (auth!) {
        if (_token != null) {
          finalHeaders = {...?finalHeaders, "Authorization": "Bearer $_token"};
          print('Using headers: $finalHeaders'); // Debug print
        } else {
          throw Exception("Access token is null");
        }
      }

      final config = Config();
      final Uri apiEndpoint =
          config.apiUri(path, queryParameters: queryParameters);

      if (kDebugMode) {
        print("Request : $method > $path ~ $apiEndpoint");
      }

      dynamic response;

      switch (method) {
        case HttpMethod.$get:
          response = await http.get(apiEndpoint, headers: finalHeaders);
          break;

        case HttpMethod.$post:
          response = await _handlePostRequest(
            apiEndpoint,
            finalHeaders,
            body,
            contentType,
          );
          break;

        case HttpMethod.$formdata:
          response = await _handleFormDataRequest(apiEndpoint, finalHeaders,
              multipartFields, files, fileFieldNames);
          break;

        case HttpMethod.$delete:
          response =
              await _handleDeleteRequest(apiEndpoint, finalHeaders, body);
          break;

        case HttpMethod.$patch:
          response = await _handlePatchRequest(apiEndpoint, finalHeaders, body);
          break;

        case HttpMethod.$put:
          response = await _handlePutRequest(apiEndpoint, finalHeaders, body);
          break;
      }

      if (response != null) {
        if (kDebugMode) {
          print('Response Status Code: ${response.statusCode}');
        }

        if (response.statusCode == 401 || response.statusCode == 404) {
          _handleUnauthorized();
          throw Exception("Unauthorized access. Please log in again.");
        }
      }
      return response;
    } on SocketException catch (e) {
      throw Exception("error > $e");
    } catch (e) {
      throw Exception("error > $e");
    }
  }

  // Handle Form-Data (Multipart Request)
  // Handle Form-Data (Multipart Request)
  Future<http.Response> _handleFormDataRequest(
    Uri apiEndpoint,
    Map<String, String>? finalHeaders,
    Map<String, String>? multipartFields,
    List<File>? files,
    List<String>? fileFieldNames, // List of file field names
  ) async {
    try {
      var request = http.MultipartRequest('POST', apiEndpoint);

      // Add headers to the request
      if (finalHeaders != null) {
        request.headers.addAll(finalHeaders);
      }

      // Add fields to the form-data
      if (multipartFields != null) {
        multipartFields.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      // Add files to the form-data
      if (files != null && files.isNotEmpty && fileFieldNames != null) {
        if (files.length == fileFieldNames.length) {
          for (int i = 0; i < files.length; i++) {
            File file = files[i];
            String fieldName = fileFieldNames[i];

            if (file.existsSync()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  fieldName, // Dynamic field name
                  file.path,
                ),
              );
            } else {
              throw Exception('File does not exist: ${file.path}');
            }
          }
        } else {
          throw Exception(
              'Mismatch between the number of files and field names.');
        }
      }

      // Send the request and get the response
      var streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Error during form-data upload: $e');
    }
  }

  // Handle POST requests
  Future<http.Response> _handlePostRequest(
    Uri apiEndpoint,
    Map<String, String>? finalHeaders,
    Object? body,
    ContentType contentType,
  ) async {
    return await http.post(
      apiEndpoint,
      headers: finalHeaders,
      body: contentType == ContentType.json ? jsonEncode(body) : body,
    );
  }

  // Handle DELETE requests
  Future<http.Response> _handleDeleteRequest(
      Uri apiEndpoint, Map<String, String>? finalHeaders, Object? body) async {
    var request = http.Request("DELETE", apiEndpoint);
    request.headers.addAll(finalHeaders!);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    var streamedResponse = await http.Client().send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  // Handle PATCH requests
  Future<http.Response> _handlePatchRequest(
      Uri apiEndpoint, Map<String, String>? finalHeaders, Object? body) async {
    return await http.patch(apiEndpoint, headers: finalHeaders, body: body);
  }

  // Handle PUT requests
  Future<http.Response> _handlePutRequest(
      Uri apiEndpoint, Map<String, String>? finalHeaders, Object? body) async {
    return await http.put(apiEndpoint, headers: finalHeaders, body: body);
  }

  // Helper method to get content type
  String _getContentType(ContentType contentType) {
    switch (contentType) {
      case ContentType.json:
        return 'application/json';
      case ContentType.formData:
        return 'multipart/form-data';
      case ContentType.urlEncoded:
        return 'application/x-www-form-urlencoded';
      default:
        return 'application/json';
    }
  }

  // Handle unauthorized requests
  void _handleUnauthorized() {
    // Notify the app to refresh or navigate to login screen
    ApiMaster.clearToken();

    if (navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!)
          .pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
