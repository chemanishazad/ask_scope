import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:loop/core/utils/service.dart';
import 'package:loop/model/home/scope_upload_model.dart';

final personalUpdateProvider =
    FutureProvider.family<Map<String, dynamic>, ScopeUploadModel>(
        (ref, params) async {
  try {
    final fields = {
      // 'name': params.name,
      // 'gender': params.gender,
      // 'dob': params.dob,
      // 'state': params.state,
      // 'city': params.city,
      // 'area_code': params.pinCode,
      // 'mobile': params.mobile,
      // 'address': params.pAddress,
      // 'current_address': params.cAddress,
      // 'linkedin_profile': params.linkedin,
    };

    Response response = await ApiMaster().fire(
      path: '/updatePersonalDetails',
      method: HttpMethod.$formdata,
      // multipartFields: fields,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('data${data}');
      return data;
    } else {
      return {'status': false, 'message': 'Failed to fetch skills'};
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
