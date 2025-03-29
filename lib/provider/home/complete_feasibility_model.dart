import 'dart:io';

class CompleteFeasibilityModel {
  final List<File> file;
  final String refId;
  final String quoteId;
  final String feasibilityComments;
  final String userId;

  CompleteFeasibilityModel({
    required this.file,
    required this.refId,
    required this.quoteId,
    required this.feasibilityComments,
    required this.userId,
  });
}
