import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/utils/service.dart';
import 'package:loop/model/auth/userModel.dart';

import 'package:shared_preferences/shared_preferences.dart';

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return await _loadUserFromPrefs();
  }

  Future<UserModel?> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      return UserModel(
        id: prefs.getString('id')!,
        username: prefs.getString('username')!,
        email: prefs.getString('email')!,
        token: prefs.getString('token')!,
      );
    }
    return null;
  }

  Future<void> logout(BuildContext context) async {
    final response = await ApiMaster().fire(
      path: '/logout',
      auth: false,
      method: HttpMethod.$get,
    );

    final data = json.decode(response.body);
    print(data);

    if (response.statusCode == 200 || response.statusCode == 403) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('id');
      await prefs.remove('email');
      await prefs.remove('username');
      await prefs.remove('token');
      state = const AsyncData(null);
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

      Fluttertoast.showToast(msg: 'Logout Success');
    }
  }
}

final loginProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, data) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final response = await ApiMaster().fire(
      path: '/loginapi',
      method: HttpMethod.$post,
      auth: false,
      body: {
        'email': data['email'],
        'password': data['password'],
      },
      contentType: ContentType.json,
    );
    final responseBody = response.body;
    if (response.statusCode == 200) {
      final data = json.decode(responseBody);

      print('Parsed Response: $responseBody');

      if (data['status'] == true) {
        final loopUser = data['loopuser'];
        final instaUser = data['instauser'];

        // Loop User Details
        final loopUserId = loopUser['id'];
        final loopUserName = loopUser['fld_first_name'];
        final loopUserEmail = loopUser['fld_email'];
        final loopUserType = loopUser['fld_admin_type'];
        final loopUserToken = loopUser['mobtoken'];

        // Insta User Details
        final instaUserId = instaUser['id'];
        final instaUserName = instaUser['name'];
        final instaUserEmail = instaUser['email_id'];
        final instaUserType = instaUser['user_type'];
        final instaTeamId = instaUser['team_id'];

        // Store in SharedPreferences
        await prefs.setBool('isLoggedIn', true);

        // Loop User Data
        await prefs.setString('loopUserId', loopUserId);
        await prefs.setString('loopUserName', loopUserName);
        await prefs.setString('loopUserEmail', loopUserEmail);
        await prefs.setString('loopUserType', loopUserType);
        await prefs.setString('loopUserToken', loopUserToken);

        // Insta User Data
        await prefs.setString('instaUserId', instaUserId);
        await prefs.setString('instaUserName', instaUserName);
        await prefs.setString('instaUserEmail', instaUserEmail);
        await prefs.setString('instaUserType', instaUserType);
        await prefs.setString('instaTeamId', instaTeamId);

        ApiMaster.setToken(loopUserToken);

        print(
            'Login Successful: LoopUser ID - $loopUserId, InstaUser ID - $instaUserId');
        return data;
      } else {
        print('Login failed: ${data['message']}');
        return data;
      }
    } else {
      print('HTTP error: ${response.statusCode}');
      throw Exception('HTTP error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during login: $e');
    throw Exception('Error during login: $e');
  }
});
