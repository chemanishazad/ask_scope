import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import 'package:loop/core/utils/service.dart';

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
