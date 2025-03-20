import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  // Function to map API icons to Flutter icons
  IconData getNotificationIcon(String iconName) {
    switch (iconName) {
      case 'quote':
        return Icons.request_quote;
      case 'feasability':
        return Icons.assignment;
      case 'chat':
        return Icons.chat;
      case 'tag':
        return Icons.label;
      case 'completed':
        return Icons.check_circle;
      case 'transferred':
        return Icons.sync_alt;
      case 'discount':
        return Icons.local_offer;
      default:
        return Icons.notifications; 
    }
  }

  void markAllAsRead() {
    // TODO: Implement API call to mark all notifications as read
    print("Marking all notifications as read...");
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(notificationGetProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
        title: const Text("Notifications",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: const Text(
              "Read All",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
        data: (notificationData) {
          final List<dynamic> notifications =
              notificationData['notifications'] ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final String iconType = notification['icon'] ?? '';

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: cardDecoration(context: context),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(getNotificationIcon(iconType),
                        color: Colors.blue.shade700),
                  ),
                  title: Text(notification['fld_first_name'] ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${notification['message']} on quotation for Ref Id ${notification['ref_id']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: notification['isread'] == "0"
                      ? const Icon(Icons.circle, color: Colors.red, size: 12)
                      : null,
                  onTap: () {
                    print("Notification ID: ${notification['id']}");
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
