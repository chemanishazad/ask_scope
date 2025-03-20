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
  final String feasibility;
  final String feasabilityUser;

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
    required this.feasibility,
    required this.feasabilityUser,
  });
}
