import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final List<dynamic> chat;
  final String quoteId;
  final String userId;
  const ChatScreen(
      {super.key,
      required this.chat,
      required this.quoteId,
      required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final _debouncer = Debouncer(milliseconds: 300);

  OverlayEntry? _mentionOverlayEntry;
  List<Map<String, dynamic>> _availableUsers = [];
  dynamic _replyingToMessage;
  File? _selectedFile;
  bool _isMentionOverlayVisible = false;
  bool _isSending = false;
  final _messageInputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchAvailableUsers();
    _messageFocusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottomOfChat());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.removeListener(_handleFocusChange);
    _messageFocusNode.dispose();
    _removeMentionOverlay();
    _debouncer.cancel();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_messageFocusNode.hasFocus) {
      _removeMentionOverlay();
    }
  }

  Future<void> _fetchAvailableUsers() async {
    try {
      final chatUsers = await ref
          .read(chatDropdownProvider({'quoteId': widget.quoteId}).future);

      if (mounted) {
        setState(() {
          _availableUsers = (chatUsers['data'] as List)
              .map((user) => {
                    'id': user['id'],
                    'name':
                        '${user['fld_first_name']} ${user['fld_last_name']}',
                    'email': user['fld_email'] ?? '',
                  })
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load team members: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectFileToAttach() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
        _scrollToBottomOfChat();
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to attach file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatMessageTimestamp(String timestamp) {
    try {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return DateFormat('hh:mm a').format(dateTime);
      } else if (messageDate.year == now.year) {
        return DateFormat('MMM dd, hh:mm a').format(dateTime);
      } else {
        return DateFormat('MMM dd yyyy, hh:mm a').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  void _setMessageToReply(dynamic message) {
    if (mounted) {
      setState(() => _replyingToMessage = message);
      _scrollToBottomOfChat();
      _messageFocusNode.requestFocus();
    }
  }

  void _clearReply() {
    if (mounted) {
      setState(() => _replyingToMessage = null);
    }
  }

  void _scrollToBottomOfChat() {
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

  Future<void> _sendChatMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedFile == null) return;

    setState(() => _isSending = true);

    try {
      final visibleText = _messageController.text;
      final messageText = _prepareMessageForSending(visibleText);
      final mentions = _extractMentions(messageText);

      final formData = {
        'ref_id': widget.userId,
        'quote_id': widget.quoteId,
        'message': messageText,
        'user_type': 'user',
        'category': 'PhD',
        'markstatus': '0',
        'mention_ids': mentions.map((m) => m['id']).join(','),
        'mention_users': mentions.map((m) => '@${m['name']}').join(','),
      };

      print('Sending: $formData');

      // Make the actual API call here
      // final response = await post(
      //   Uri.parse('https://apacvault.com/Mobapi/submitUserChatNew'),
      //   body: formData,
      //   headers: {'Authorization': 'YOUR_TOKEN'},
      // );

      // Clear after sending
      _messageController.clear();
      setState(() {
        _selectedFile = null;
        _isSending = false;
        _mentionedUserIds.clear();
        _lastInsertedMentions.clear();
        if (_replyingToMessage != null) _clearReply();
      });

      _scrollToBottomOfChat();
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, String>> _extractMentions(String text) {
    final mentionRegex = RegExp(r'\{\{\[(.*?),(.*?)\]\}\}');
    final matches = mentionRegex.allMatches(text);

    return matches.map((match) {
      return {
        'name': match.group(1)!.trim(),
        'id': match.group(2)!.trim(),
      };
    }).toList();
  }

  void _showMentionSuggestionsIfNeeded(String text) {
    _debouncer.run(() {
      final cursorPosition = _messageController.selection.baseOffset;

      if (cursorPosition <= 0 || text.length < cursorPosition) {
        _removeMentionOverlay();
        return;
      }

      final lastAtPos = text.lastIndexOf('@', cursorPosition - 1);
      if (lastAtPos == -1 ||
          lastAtPos < text.lastIndexOf(' ', cursorPosition)) {
        _removeMentionOverlay();
        return;
      }

      final searchTerm =
          text.substring(lastAtPos + 1, cursorPosition).toLowerCase();

      final availableUsersForMention = _availableUsers.where((user) {
        return !_mentionedUserIds.contains(user['id'].toString()) &&
            (user['name'].toLowerCase().contains(searchTerm) ||
                user['email'].toLowerCase().contains(searchTerm));
      }).toList();

      if (availableUsersForMention.isNotEmpty) {
        _displayMentionSuggestions(availableUsersForMention, cursorPosition);
      } else {
        _removeMentionOverlay();
      }
    });
  }


  void _displayMentionSuggestions(
      List<Map<String, dynamic>> users, int cursorPos) {
    if (_isMentionOverlayVisible) {
      _refreshMentionOverlay(users);
      return;
    }

    _mentionOverlayEntry?.remove();

    final renderBox =
        _messageInputKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    _mentionOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: (offset.dy - 250) - keyboardHeight,
          width: renderBox.size.width * 1,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mention Team Member',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontSize: 11,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              size: 20, color: Theme.of(context).primaryColor),
                          onPressed: _removeMentionOverlay,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildMentionUserItem(user);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_mentionOverlayEntry!);
    if (mounted) {
      setState(() => _isMentionOverlayVisible = true);
    }
  }

  Widget _buildMentionUserItem(Map<String, dynamic> user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.blue.shade100,
        child: Text(
          user['name'][0].toUpperCase(),
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user['name'],
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        user['email'],
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _insertMentionedUser(user),
    );
  }

  void _refreshMentionOverlay(List<Map<String, dynamic>> users) {
    if (_mentionOverlayEntry == null) return;

    _mentionOverlayEntry!.markNeedsBuild();
    if (users.isEmpty) {
      _removeMentionOverlay();
    }
  }

  void _removeMentionOverlay() {
    if (_mentionOverlayEntry != null) {
      _mentionOverlayEntry!.remove();
      _mentionOverlayEntry = null;
      if (mounted) {
        setState(() => _isMentionOverlayVisible = false);
      }
    }
  }

  final Set<String> _mentionedUserIds = {};

  String _prepareMessageForSending(String visibleText) {
    // Sort mentions by position (last to first) to avoid position shifts
    _lastInsertedMentions
        .sort((a, b) => b['position'].compareTo(a['position']));

    String preparedText = visibleText;
    for (final mention in _lastInsertedMentions) {
      preparedText = preparedText.replaceRange(
        mention['position'],
        mention['position'] + mention['length'],
        mention['full'],
      );
    }
    return preparedText;
  }

  final List<Map<String, dynamic>> _lastInsertedMentions = [];
  void _insertMentionedUser(Map<String, dynamic> user) {
    final cursorPosition = _messageController.selection.baseOffset;
    final text = _messageController.text;
    final atPos = text.lastIndexOf('@', cursorPosition - 1);
    if (atPos == -1) return;

    // Track the mention
    _mentionedUserIds.add(user['id'].toString());

    final fullMention = '{{[${user['name']},${user['id']}]}}';
    final visibleMention = '@${user['name']}';

    final before = text.substring(0, atPos);
    final after = text.substring(cursorPosition);

    _messageController.text = '$before$visibleMention $after';

    // Store the mention details
    _lastInsertedMentions.add({
      'visible': visibleMention,
      'full': fullMention,
      'position': atPos,
      'length': visibleMention.length
    });

    _messageController.selection = TextSelection.collapsed(
      offset: (atPos + visibleMention.length + 1).toInt(),
    );

    _removeMentionOverlay();
    _messageFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedChat = _sortChatMessagesByDate();
    print(widget.userId);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildChatList(sortedChat),
          ),
          _buildMessageComposer(theme),
        ],
      ),
    );
  }

  Widget _buildChatList(List<dynamic> messages) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildChatMessageWithReplies(message);
      },
    );
  }

  Widget _buildChatMessageWithReplies(dynamic message) {
    final hasReplies =
        message['replies'] != null && message['replies'].isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChatMessageItem(message,
            isMainMessage: true, showReplyButton: !hasReplies),
        if (hasReplies)
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Column(
              children: (message['replies'] as List)
                  .asMap()
                  .entries
                  .map<Widget>((entry) {
                final isLastReply = entry.key == message['replies'].length - 1;
                return _buildChatMessageItem(entry.value,
                    isMainMessage: false, showReplyButton: isLastReply);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildChatMessageItem(dynamic message,
      {bool isMainMessage = false, bool showReplyButton = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildUserAvatar(message),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageHeader(message),
                const SizedBox(height: 4),
                _buildMessageBubble(message, showReplyButton),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(dynamic message) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.blue.shade100,
      child: message['fld_avatar'] == null || message['fld_avatar'].isEmpty
          ? Text(
              message['fld_first_name'][0].toUpperCase(),
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageHeader(dynamic message) {
    return Row(
      children: [
        Text(
          '${message['fld_first_name']} ${message['fld_last_name']}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatMessageTimestamp(message['date']),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(dynamic message, bool showReplyButton) {
    final isPending = message['pending_responses'] != null &&
        message['pending_responses'].isNotEmpty;
    final theme = Theme.of(context);
    final isFile = message['isfile'] == '1';
    final filePath = message['file_path'] ?? '';
    final hasText =
        message['message']?.isNotEmpty == true && message['message'] != 'null';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasText)
                        Padding(
                          padding: EdgeInsets.only(bottom: isFile ? 8.0 : 0),
                          child: Text.rich(
                            _parseMessageWithMentions(message['message']),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      if (isFile) _buildFileMessage(filePath),
                    ],
                  ),
                ),
              ),
              if (showReplyButton)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: IconButton(
                    icon: Icon(Icons.reply,
                        size: 18, color: Colors.grey.shade600),
                    onPressed: () => _setMessageToReply(message),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ),
        if (isPending) _buildPendingResponseIndicator(message),
      ],
    );
  }

  Widget _buildFileMessage(String fileUrl) {
    final fileName = fileUrl.split('/').last;

    return GestureDetector(
      onTap: () => _launchFileUrl(fileUrl),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(fileUrl),
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Tap to view',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchFileUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPendingResponseIndicator(dynamic message) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${message['pending_responses'].join(', ')} ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 11,
                  ),
                ),
                TextSpan(
                  text: 'response pending',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _sortChatMessagesByDate() {
    return List.from(widget.chat)
      ..sort((a, b) => int.parse(a['date']).compareTo(int.parse(b['date'])));
  }

  Widget _buildMessageComposer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_replyingToMessage != null) _buildReplyPreview(),
          if (_selectedFile != null) _buildFileAttachmentPreview(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attachment),
                onPressed: _selectFileToAttach,
              ),
              Expanded(
                child: Container(
                  key: _messageInputKey,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(fontSize: 14),
                    onTap: () {
                      if (_messageController.text.contains('@')) {
                        _showMentionSuggestionsIfNeeded(
                            _messageController.text);
                      }
                    },
                    onChanged: _showMentionSuggestionsIfNeeded,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor,
                ),
                child: IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                  onPressed: _isSending ? null : _sendChatMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyingToMessage['fld_first_name']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _parseMessageContent(_replyingToMessage['message']),
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
            onPressed: _clearReply,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildFileAttachmentPreview() {
    final fileSize = _selectedFile != null
        ? '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB'
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                _getFileIcon(_selectedFile!.path),
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!.path.split('/').last,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
            onPressed: () {
              if (mounted) {
                setState(() => _selectedFile = null);
              }
            },
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _parseMessageContent(String message) {
    return message.replaceAllMapped(RegExp(r'\{\{(.*?)\}\}'), (match) {
      return match.group(1)!.split(',').first.trim();
    });
  }

  TextSpan _parseMessageWithMentions(String message) {
    final mentionRegex = RegExp(r'\{\{\[(.*?),(.*?)\]\}\}');
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      }
    }

    return TextSpan(children: children);
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}
