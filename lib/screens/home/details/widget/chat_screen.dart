import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loop/provider/home/home_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final List<dynamic> chat;
  final String quoteId;
  const ChatScreen({super.key, required this.chat, required this.quoteId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final LayerLink _mentionLayerLink = LayerLink();

  OverlayEntry? _mentionOverlayEntry;
  List<Map<String, dynamic>> _availableUsers = [];
  dynamic _replyingToMessage;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
    _messageFocusNode.addListener(() {
      if (!_messageFocusNode.hasFocus) {
        _hideMentionOverlay();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _hideMentionOverlay();
    super.dispose();
  }

  Future<void> _loadAvailableUsers() async {
    final chatUsers = await ref
        .read(chatDropdownProvider({'quoteId': widget.quoteId}).future);

    setState(() {
      _availableUsers = (chatUsers['data'] as List)
          .map((user) => {
                'id': user['id'],
                'name': '${user['fld_first_name']} ${user['fld_last_name']}'
              })
          .toList();
    });

    print("Loaded users: $_availableUsers");

    if (_messageController.text.contains('@')) {
      _handleMentionTrigger(_messageController.text);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  String _formatMessageDate(String timestamp) {
    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
    return DateFormat('MMM dd, hh:mm a').format(dateTime);
  }

  void _handleReply(dynamic message) {
    setState(() => _replyingToMessage = message);
    _scrollToBottom();
  }

  void _cancelReply() => setState(() => _replyingToMessage = null);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _messageController.clear();
    if (_replyingToMessage != null) _cancelReply();
  }

  void _handleMentionTrigger(String text) {
    final cursorPosition = _messageController.selection.baseOffset;
    print("Cursor Position: $cursorPosition, Text: $text");

    if (cursorPosition <= 0 || text.length < cursorPosition) {
      _hideMentionOverlay();
      return;
    }

    if (text[cursorPosition - 1] == '@') {
      print("Mention detected!");

      final mentionedIds = _getMentionedUserIds();
      final filteredUsers = _availableUsers
          .where((user) => !mentionedIds.contains(user['id']))
          .toList();

      print("Filtered Users: $filteredUsers");

      if (filteredUsers.isNotEmpty) {
        _showMentionOverlay(filteredUsers, cursorPosition);
      } else {
        _hideMentionOverlay();
      }
    }
  }

  Set<String> _getMentionedUserIds() {
    final text = _messageController.text;
    final mentions = RegExp(r'\{\{(.*?),(.*?)\}\}');
    final mentionedIds = <String>{};

    for (final match in mentions.allMatches(text)) {
      mentionedIds.add(match.group(2)!.trim());
    }
    return mentionedIds;
  }

  void _showMentionOverlay(List<Map<String, dynamic>> users, int cursorPos) {
    print("Showing overlay for users: $users");

    _mentionOverlayEntry?.remove();

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final textFieldHeight = renderBox.size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    _mentionOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: (offset.dy + textFieldHeight - 200) - keyboardHeight,
          width: renderBox.size.width,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  print("Adding user to overlay: ${user['name']}");
                  return ListTile(
                    title: Text(user['name']),
                    onTap: () => _selectMentionedUser(user),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_mentionOverlayEntry!);
  }

  void _updateMentionOverlay(List<Map<String, dynamic>> users) {
    if (_mentionOverlayEntry == null) return;

    _mentionOverlayEntry!.markNeedsBuild();
    if (users.isEmpty) {
      _hideMentionOverlay();
    }
  }

  void _hideMentionOverlay() {
    _mentionOverlayEntry?.remove();
    _mentionOverlayEntry = null;
  }

  void _selectMentionedUser(Map<String, dynamic> user) {
    final cursorPosition = _messageController.selection.baseOffset;
    final text = _messageController.text;

    // Find the last @ position before cursor
    final atPos = text.lastIndexOf('@', cursorPosition - 1);
    if (atPos == -1) return;

    // Create a proper mention format
    final mention = '{{${user['name']},${user['id']}}}';

    // Replace @ with formatted mention
    final before = text.substring(0, atPos);
    final after = text.substring(cursorPosition);
    _messageController.text = '$before$mention$after';

    // Move cursor to the end of the inserted mention
    _messageController.selection = TextSelection.collapsed(
      offset: atPos + mention.length,
    );

    _hideMentionOverlay();
    _messageFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final sortedChat = _getSortedChatMessages();
    print(_availableUsers);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: sortedChat.length,
              itemBuilder: (context, index) =>
                  _buildMessageItem(sortedChat[index]),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  List<dynamic> _getSortedChatMessages() {
    return List.from(widget.chat)
      ..sort((a, b) => int.parse(a['date']).compareTo(int.parse(b['date'])));
  }

  Widget _buildMessageItem(dynamic message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MessageBubble(
          message: message,
          formatDate: _formatMessageDate,
          isMainMessage: true,
        ),
        if (message['replies'] != null && message['replies'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              children: message['replies']
                  .map<Widget>((reply) => MessageBubble(
                        message: reply,
                        formatDate: _formatMessageDate,
                        isMainMessage: false,
                      ))
                  .toList(),
            ),
          ),
        _buildReplyButton(message),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildReplyButton(dynamic message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => _handleReply(message),
          child: Text(
            'Reply',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return CompositedTransformTarget(
      link: _mentionLayerLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            if (_replyingToMessage != null) _buildReplyPreview(),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(children: [
                  Icon(Icons.attachment, color: Colors.blue.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ]),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(fontSize: 13),
                    onChanged: _handleMentionTrigger,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, size: 18, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Replying to ${_replyingToMessage['fld_first_name']}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _cancelReply,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _cleanMessage(_replyingToMessage['message']),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _cleanMessage(String message) {
    return message.replaceAllMapped(RegExp(r'\{\{(.*?)\}\}'), (match) {
      return match.group(1)!.split(',').first.trim();
    });
  }
}

class MessageBubble extends StatelessWidget {
  final dynamic message;
  final String Function(String) formatDate;
  final bool isMainMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.formatDate,
    this.isMainMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = isMainMessage &&
        message['pending_responses'] != null &&
        message['pending_responses'].isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              message['fld_first_name'][0].toUpperCase(),
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${message['fld_first_name']} ${message['fld_last_name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatDate(message['date']),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMainMessage
                        ? Colors.blue.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isMainMessage
                          ? Colors.blue.shade100
                          : Colors.grey.shade300,
                      width: 0.5,
                    ),
                  ),
                  child: Text.rich(
                    _buildMessageWithMentions(message['message']),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
                if (isPending) _buildPendingIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildMessageWithMentions(String message) {
    final mentionRegex = RegExp(r'\{\{\{(.*?),(.*?)\}\}\}');
    final parts = message.split(mentionRegex);
    final matches = mentionRegex.allMatches(message).toList();

    final children = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        children.add(TextSpan(
          text: parts[i],
          style: const TextStyle(color: Colors.black),
        ));
      }

      if (i < matches.length) {
        final mention = matches[i].group(1)!;
        children.add(
          TextSpan(
            text: mention,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        );
      }
    }

    return TextSpan(children: children);
  }

  Widget _buildPendingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${message['pending_responses'].join(', ')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 10,
                  ),
                ),
                TextSpan(
                  text: ' response pending',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
