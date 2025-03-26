import 'dart:io';

class EditScopeApiModel {
  final String refId;
  final String quoteId;
  final String currency;
  final String otherCurrency;
  final String serviceName;
  final String subjectArea;
  final String otherSubjectArea;
  final String plan;
  final String comments;
  final String planCommentsBasic;
  final String planCommentsStandard;
  final String planCommentsAdvanced;
  final String planWordCountBasic;
  final String planWordCountStandard;
  final String planWordCountAdvanced;
  final String feasabilityUser;

  // Constructor
  EditScopeApiModel({
    required this.refId,
    required this.quoteId,
    required this.otherCurrency,
    required this.currency,
    required this.serviceName,
    required this.subjectArea,
    required this.otherSubjectArea,
    required this.plan,
    required this.comments,
    required this.planCommentsBasic,
    required this.planCommentsStandard,
    required this.planCommentsAdvanced,
    required this.planWordCountBasic,
    required this.planWordCountStandard,
    required this.planWordCountAdvanced,
    required this.feasabilityUser,
  });
}
