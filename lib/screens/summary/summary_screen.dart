import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:lottie/lottie.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(summaryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final summaryData = ref.watch(summaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quote Summary",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Palette.themeColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by Client Name, Ref ID, or Status...",
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: summaryData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text("Error: $error")),
              data: (summaryList) {
                final filteredList = summaryList.where((item) {
                  final clientName = item['client_name']?.toLowerCase() ?? '';
                  final refId = item['ref_id']?.toLowerCase() ?? '';
                  final status = item['status']?.toLowerCase() ?? '';

                  return clientName.contains(searchQuery) ||
                      refId.contains(searchQuery) ||
                      status.contains(searchQuery);
                }).toList();
                if (filteredList.isEmpty) {
                  return const Center(child: Text("No data available"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return _buildClientCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> data) {
    Color statusColor = Colors.black;
    if (data["display_status"] == 'Feasibility Completed' ||
        data["display_status"] == 'Submitted') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: cardDecoration(context: context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Scope ID: ${data['id']}",
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(data['display_status'],
                        style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    InkWell(
                        onTap: () {
                          print(data);
                          Navigator.pushNamed(context, '/detailsQuery',
                              arguments: {
                                'refId': data['ref_id'],
                                'quoteId': data['id'],
                              });
                          // Navigator.pushNamed(context, '/detailsQuery',
                          //     arguments: data['ref_id']);
                        },
                        child:
                            Lottie.asset('assets/json/right.json', height: 25)),
                  ],
                ),
              ],
            ),
            const Divider(height: 15, thickness: 1, color: Colors.grey),
            _buildRow(
                Icons.person, "Client Name", data["client_name"] ?? "N/A"),
            _buildRow(Icons.assignment, "Ref ID", data["ref_id"] ?? "N/A"),
            _buildRow(Icons.work, "Service", data["service_name"] ?? "N/A"),
            _buildRow(Icons.currency_rupee_rounded, "Currency",
                data["currency"] ?? "N/A"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.videocam, size: 20),
                  const SizedBox(width: 10),
                  const SizedBox(
                      width: 100,
                      child: Text("RC Demo",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    child: Text(data["rc_demo_status"],
                        style: TextStyle(
                            color: data["rc_demo_status"] == 'Pending'
                                ? Colors.red
                                : Colors.green),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            _buildRow(Icons.calendar_today, "Created Date",
                data["created_date"] ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          SizedBox(
              width: 100,
              child: Text("$title:",
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
