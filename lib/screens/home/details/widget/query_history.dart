import 'package:flutter/material.dart';

class QueryHistory extends StatelessWidget {
  const QueryHistory({
    super.key,
    required this.history,
  });

  final Map<String, dynamic>? history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quote History',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history!['historyData'].length,
          itemBuilder: (context, index) {
            final historyItem = history!['historyData'][index];
            final String firstName = historyItem['fld_first_name'] ?? '';
            final String lastName = historyItem['fld_last_name'] ?? '';
            final String fullName = (firstName + " " + lastName).trim();
            final String isDeleted = historyItem['deleted_user_name'] ?? '';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name or "Project Manager" with strikethrough if missing
                  Expanded(
                    flex: 3,
                    child: Text(
                      isDeleted.isEmpty ? fullName : isDeleted,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fullName.isEmpty ? Colors.red : Colors.black,
                        decoration: fullName.isEmpty
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Message
                  Expanded(
                    flex: 6,
                    child: Text(historyItem['message']),
                  ),
                  // Date
                  Expanded(
                    flex: 4,
                    child: Text(
                      historyItem['created_at'],
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
