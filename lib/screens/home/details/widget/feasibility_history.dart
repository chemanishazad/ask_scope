import 'package:flutter/material.dart';
import 'package:loop/core/const/styles.dart';

class FeasibilityHistory extends StatelessWidget {
  const FeasibilityHistory({
    super.key,
    required this.history,
  });

  final Map<String, dynamic>? history;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> historyData = history?['historyData'] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: historyData.length,
      itemBuilder: (context, index) {
        final historyItem = historyData[index];
        final String firstName = historyItem['from_first_name'] ?? '';
        final String lastName = historyItem['from_last_name'] ?? '';
        final String fullName = (firstName + " " + lastName).trim();
        final String isDeleted = historyItem['deleted_from_user_name'] ?? '';
        final String message = historyItem['message'] ?? '';
        final String date = historyItem['created_at'] ?? '';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: cardDecoration(context: context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDeleted.isEmpty ? fullName : isDeleted,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: fullName.isEmpty ? Colors.red : Colors.black,
                          decoration: fullName.isEmpty
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
