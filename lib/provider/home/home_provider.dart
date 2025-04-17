import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import 'package:loop/core/utils/service.dart';
import 'package:loop/provider/home/submitChatApiModel.dart';

final contactMadeQueryProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/loadContactMadeQueriesNew',
      method: HttpMethod.$post,
      body: {
        'user_id': params['userId'],
        'user_type': params['userType'],
        'team_id': params['teamId'],
        'search_keywords': params['searchKeywords'],
        'ref_id': params['refId'],
        'website': params['website'],
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
final markAsDoneDemoProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  final field = {
    'ref_id': params['refId'],
    'quote_id': params['quoteId'],
    'demoId': params['demoId'],
  };
  try {
    Response response = await ApiMaster().fire(
      path: '/markasdemodone',
      method: HttpMethod.$post,
      body: field,
    );
    print(field);
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
final requestAccessProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  final field = {
    'assign_id': params['assignId'],
  };
  try {
    Response response = await ApiMaster().fire(
      path: '/requestAccessfortransferredquery',
      method: HttpMethod.$post,
      body: field,
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

final websiteProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getAllWebsites',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final summaryProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getQuoteSummary',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final userSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  final field = {
    'user_id': params['userId'],
  };
  try {
    Response response = await ApiMaster().fire(
      path: '/getQuoteSummaryWithId',
      method: HttpMethod.$post,
      body: field,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final userFollowingProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  final field = {
    'user_id': params['userId'],
  };
  try {
    Response response = await ApiMaster().fire(
      path: '/getFollowingTasksWithId',
      method: HttpMethod.$post,
      body: field,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final userFeasibilityProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  final field = {
    'user_id': params['userId'],
  };
  try {
    Response response = await ApiMaster().fire(
      path: '/getAllFeasabilityAssignedToUserWithId',
      method: HttpMethod.$post,
      body: field,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final followingProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getFollowingTasks',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final notificationGetProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getNotifications',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to fetch notifications');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final readAllNotificationProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/readAllNotifications',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print(jsonData);
      return jsonData;
    } else {
      throw Exception('Failed to fetch notifications');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final queryDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, data) async {
    final param = {
      'ref_id': data['refId'],
      'quote_id': data['quoteId'],
    };
    try {
      final response = await ApiMaster().fire(
        path: '/adminScopeDetails',
        method: HttpMethod.$get,
        queryParameters: param,
      );
      print('response$response');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  },
);
final quoteHistoryProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, data) async {
    final param = {
      'ref_id': data['refId'],
      'quote_id': data['quoteId'],
    };
    try {
      final response = await ApiMaster().fire(
        path: '/getquotehistory',
        method: HttpMethod.$get,
        queryParameters: param,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  },
);
final queryChatProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, data) async {
    final param = {
      'quote_id': data['quoteId'],
    };
    try {
      final response = await ApiMaster().fire(
        path: '/getQuoteChatApiNew',
        method: HttpMethod.$get,
        queryParameters: param,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  },
);
final feasibilityHistoryProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, data) async {
    final param = {
      'ref_id': data['refId'],
      'quote_id': data['quoteId'],
    };
    try {
      final response = await ApiMaster().fire(
        path: '/getFeasabilityHistory',
        method: HttpMethod.$get,
        queryParameters: param,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  },
);
final chatDropdownProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, data) async {
    final param = {'quote_id': data['quoteId']};
    try {
      final response = await ApiMaster().fire(
        path: '/fetchUsersToMention',
        method: HttpMethod.$get,
        queryParameters: param,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  },
);

final currencyDropdownProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getCurrencies',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final serviceDropdownProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getServices',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final tlUserDropdownProvider = FutureProvider.autoDispose
    .family<Map<String, Map<String, String>>, String>((ref, assignUsers) async {
  final field = {
    'assign_users': assignUsers,
  };

  try {
    Response response = await ApiMaster().fire(
      path: '/tlUsers',
      method: HttpMethod.$post,
      auth: false,
      body: field,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true && data['users'] is List) {
        // Convert the List<Map> to Map<String, Map> format
        final usersMap = <String, Map<String, String>>{};
        for (final user in data['users']) {
          usersMap[user['id']] = {
            'fld_first_name': user['fld_first_name'],
            'fld_last_name': user['fld_last_name'],
          };
        }
        return usersMap;
      } else {
        throw Exception('Invalid data format from API');
      }
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error loading users: ${e.toString()}');
  }
});
final tlTransferRequestProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, users) async {
  final field = {
    'users': users,
  };

  try {
    Response response = await ApiMaster().fire(
      path: '/getalltransferrequestsfortl',
      method: HttpMethod.$post,
      auth: false,
      body: field,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return data;
      } else {
        throw data;
      }
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error loading users: ${e.toString()}');
  }
});
final tlAssignedUserDropdownProvider =
    FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getAllassignedUsersfortl',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final tagsDropdownProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getAllTags',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final filterUserDropdownProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getExceptUsers',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final allUserDropdownProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getAllUsers',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final feasibilityDataProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/getAllFeasabilityAssignedToUser',
      method: HttpMethod.$get,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData;
    } else {
      throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final transferUserProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/transferUser',
      method: HttpMethod.$post,
      body: {
        'ref_id': params['refId'],
        'quote_id': params['quoteId'],
        'user_id': params['userId'],
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
final approveTransferUserProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/approvetransferrequest',
      method: HttpMethod.$post,
      body: {
        'ref_id': params['refId'],
        'status': params['status'],
        'admin_id': params['userId'],
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final readSingleNotificationProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/readmessage',
      method: HttpMethod.$post,
      body: {'id': params['id']},
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

final submitChatProvider =
    FutureProvider.family<Map<String, dynamic>, SubmitChatApiModel>(
        (ref, params) async {
  try {
    final fields = {
      'ref_id': params.refId,
      'quote_id': params.quoteId,
      'message': params.message,
      'user_type': params.userType,
      'category': params.category,
      'markstatus': params.markStatus,
      'mention_ids': params.mentionIds,
      'mention_users': params.mentionUsers,
    };
    print(fields);

    final List<String> fileFieldNames = ['file'];
    Response response = await ApiMaster().fire(
      path: '/submitUserChatNew',
      method: HttpMethod.$formdata,
      fileFieldNames: fileFieldNames,
      multipartFields: fields,
      files: params.file,
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
final replyToChatProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    final fields = {
      'chat_id': params['chatId'] ?? '',
      'message': params['message'] ?? '',
      'user_type': params['userType'] ?? '',
    };

    Response response = await ApiMaster().fire(
      path: '/submitReply',
      method: HttpMethod.$formdata,
      multipartFields: fields,
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

final markCallRecordProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/markascallrecordingpending',
      method: HttpMethod.$post,
      body: {
        'ref_id': params['refId'],
        'quote_id': params['quoteId'],
        'callrecordingpending': params['callRecordingPending'],
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
final tlScopeProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/listAskForScopeForTl',
      method: HttpMethod.$post,
      body: {
        'assign_users': params['assign_users'],
        'current_tl': params['current_tl'],
        'start_date': params['start_date'],
        'end_date': params['end_date'],
        'feasability_status': params['feasability_status'],
        'ptp': params['ptp'],
        'ref_id': params['refId'],
        'user_id': params['user_id'],
        'service_name': params['service_name'],
        'status': params['status'],
        'tags': params['tags'],
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
final tlScopeRequestProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, params) async {
  try {
    Response response = await ApiMaster().fire(
      path: '/listAskForScopeForTl',
      method: HttpMethod.$post,
      body: {
        'ref_id': params['ref_id'],
        'scope_id': params['scope_id'],
        'search_keywords': params['search_keywords'],
        'service_name': params['service_name'],
        'subject_area': params['subject_area'],
        'feasability_status': params['feasability_status'],
        'userid': params['userid'],
        'ptp': params['ptp'],
        'callrecordingpending': params['callrecordingpending'],
        'start_date': params['start_date'],
        'end_date': params['end_date'],
        'status': params['status'],
        'tags': params['tags'],
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      return data;
    }
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
});
