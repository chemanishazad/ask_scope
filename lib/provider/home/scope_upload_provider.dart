import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:loop/core/utils/service.dart';
import 'package:loop/model/home/edit_scope_model.dart';
import 'package:loop/model/home/scope_upload_model.dart';

final addNewScopeProvider =
    FutureProvider.family<Map<String, dynamic>, ScopeUploadModel>(
        (ref, params) async {
  try {
    // Dynamically generate file field names
    final List<String> fileFieldNames = [];
    final Map<String, String> fields = {
      'ref_id': params.refId,
      'currency': params.currency,
      'other_currency': params.otherCurrency,
      'service_name': params.serviceName,
      'subject_area': params.subjectArea,
      'other_subject_area': params.otherSubjectArea,
      'plan': params.plan,
      'comments': params.comments,
      'client_name': params.clientName,
      'plan_comments_Basic': params.planCommentsBasic,
      'plan_comments_Standard': params.planCommentsStandard,
      'plan_comments_Advanced': params.planCommentsAdvanced,
      'plan_word_counts_Basic': params.planWordCountBasic,
      'plan_word_counts_Standard': params.planWordCountStandard,
      'plan_word_counts_Advanced': params.planWordCountAdvanced,
      'isfeasability': params.feasibility,
      'feasability_user': params.feasabilityUser,
      'demo_done': params.demoDone,
      'demo_id': params.demoId,
      'tags': params.tags,
    };

    // Assign unique names to uploaded files
    final List<MapEntry<String, File>> fileEntries = [];
    for (int i = 0; i < params.picture.length; i++) {
      String fileFieldName = 'quote_upload_file[$i]';
      fileFieldNames.add(fileFieldName);
      fileEntries.add(MapEntry(fileFieldName, params.picture[i]));
    }

    // Send the request
    Response response = await ApiMaster().fire(
      path: '/submitRequestQuoteApiActionNew',
      method: HttpMethod.$formdata,
      multipartFields: fields,
      files: fileEntries.map((entry) => entry.value).toList(),
      fileFieldNames: fileEntries.map((entry) => entry.key).toList(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response Data: $data');
      return data;
    } else {
      return {'status': false, 'message': 'Failed to upload files'};
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final editScopeProvider =
    FutureProvider.family<Map<String, dynamic>, EditScopeApiModel>(
        (ref, params) async {
  try {
    // Dynamically generate file field names
    final Map<String, String> fields = {
      'ref_id': params.refId,
      'quote_id': params.quoteId,
      'currency': params.currency,
      'other_currency': params.otherCurrency,
      'service_name': params.serviceName,
      'subject_area': params.subjectArea,
      'other_subject_area': params.otherSubjectArea,
      'plan': params.plan,
      'comments': params.comments,
      'plan_comments_Basic': params.planCommentsBasic,
      'plan_comments_Standard': params.planCommentsStandard,
      'plan_comments_Advanced': params.planCommentsAdvanced,
      'plan_word_counts_Basic': params.planWordCountBasic,
      'plan_word_counts_Standard': params.planWordCountStandard,
      'plan_word_counts_Advanced': params.planWordCountAdvanced,
      'feas_user': params.feasabilityUser,
    };

    // Send the request
    Response response = await ApiMaster().fire(
      path: '/updateRequestQuoteApiAction',
      method: HttpMethod.$post,
      body: fields,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response Data: $data');
      return data;
    } else {
      return {'status': false, 'message': 'Failed to upload files'};
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});

final tagUpdateProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/updateTags',
      method: HttpMethod.$post,
      body: {
        'ref_id': params['refId'],
        'quote_id': params['quoteId'],
        'tags': params['tags'],
        'notification': params['notification'],
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('data${data}');
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final followerUpdateProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/updateFollowers',
      method: HttpMethod.$post,
      body: {
        'ref_id': params['refId'],
        'quote_id': params['quoteId'],
        'followers': params['followers'],
        'notification': params['notification'],
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('data${data}');
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
