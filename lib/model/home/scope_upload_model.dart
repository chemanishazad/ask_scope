import 'dart:io';

class ScopeUploadModel {
  final String refId;
  final String currency;
  final String otherCurrency;
  final String serviceName;
  final String subjectArea;
  final String otherSubjectArea;
  final String plan;
  final String comments;
  final String clientName;
  final String planCommentsBasic;
  final String planCommentsStandard;
  final String planCommentsAdvanced;
  final String planWordCountBasic;
  final String planWordCountStandard;
  final String planWordCountAdvanced;
  final String feasibility;
  final String feasabilityUser;
  final String demoDone;
  final String demoId;
  final String tags;
  final List<File> picture;

  // Constructor
  ScopeUploadModel({
    required this.refId,
    required this.otherCurrency,
    required this.currency,
    required this.serviceName,
    required this.subjectArea,
    required this.otherSubjectArea,
    required this.plan,
    required this.comments,
    required this.clientName,
    required this.planCommentsBasic,
    required this.planCommentsStandard,
    required this.planCommentsAdvanced,
    required this.planWordCountBasic,
    required this.planWordCountStandard,
    required this.planWordCountAdvanced,
    required this.feasibility,
    required this.feasabilityUser,
    required this.demoDone,
    required this.demoId,
    required this.tags,
    required this.picture,
  });
}
