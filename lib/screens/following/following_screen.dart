import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:lottie/lottie.dart';

class FollowingScreen extends ConsumerStatefulWidget {
  const FollowingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FollowingScreenState();
}

class _FollowingScreenState extends ConsumerState<FollowingScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredData = [];

  void search(String query, List<Map<String, dynamic>> data) {
    setState(() {
      filteredData = data
          .where((item) =>
              item["ref_id"]
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item["client_name"]
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(followingProvider);
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(followingProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
        title: const Text(
          "Following",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: asyncData.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          final List<Map<String, dynamic>> formattedData =
              List<Map<String, dynamic>>.from(data);

          filteredData =
              filteredData.isEmpty ? List.from(formattedData) : filteredData;

          return Column(
            children: [
              _buildSearchBox(formattedData),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredData.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final item = filteredData[index];
                    return _buildClientCard(item);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text("Error: $error"),
        ),
      ),
    );
  }

  /// **Search Box Widget**
  Widget _buildSearchBox(List<Map<String, dynamic>> data) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Search by Ref ID",
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (query) => search(query, data),
        ),
      ),
    );
  }

  /// **Client Card UI**
  Widget _buildClientCard(Map<String, dynamic> data) {
    Color statusColor = data["demodone"] == "1" ? Colors.green : Colors.red;
    String demoStatusText = data["demodone"] == "1" ? "Done" : "Pending";

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
                Text("Ref Id: ${data["ref_id"]}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(
                      data["demodone"] == "1"
                          ? Icons.check_circle
                          : Icons.hourglass_empty,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "RC Demo: $demoStatusText",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildDetailRow(Icons.person, "Client", data["client_name"]),
            _buildDetailRow(Icons.work, "Service", data["service_name"]),
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                      Icons.monetization_on, "Currency", data["currency"]),
                ),
                Lottie.asset('assets/json/right.json', height: 20),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  /// **Helper for Row Details**
  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 6),
          SizedBox(
              width: 100,
              child: Text("$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Text(value ?? 'N/A', overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
