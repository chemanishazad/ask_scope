import 'dart:io';

class AskDiscountModel {
  final List<File> file;
  final String refId;
  final String quoteId;
  final String comments;
  final String ptp;
  final String amount;
  final String oldPlans;
  final String selectedPlan;

  AskDiscountModel({
    required this.file,
    required this.refId,
    required this.quoteId,
    required this.comments,
    required this.amount,
    required this.oldPlans,
    required this.selectedPlan,
    required this.ptp,
  });
}
