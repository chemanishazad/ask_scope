import 'dart:io';

class SubmitChatApiModel {
  final List<File> file;
  final String refId;
  final String quoteId;
  final String message;
  final String userType;
  final String category;
  final String markStatus;
  final String mentionIds;
  final String mentionUsers;

  SubmitChatApiModel({
    required this.file,
    required this.refId,
    required this.quoteId,
    required this.message,
    required this.userType,
    required this.category,
    required this.markStatus,
    required this.mentionIds,
    required this.mentionUsers,
  });
}
