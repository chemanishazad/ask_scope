import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:lottie/lottie.dart';

class UserFeasibilityScreen extends ConsumerStatefulWidget {
  const UserFeasibilityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserFeasibilityScreenState();
}

class _UserFeasibilityScreenState extends ConsumerState<UserFeasibilityScreen> {
  String userId = '';
  List<Map<String, dynamic>> summaryList = [];
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ModalRoute.of(context)?.settings.arguments as String?;
    if (user != null && user.isNotEmpty) {
      userId = user;
      summary();
    }
  }

  Future<void> summary() async {
    setState(() => isLoading = true);

    try {
      final response =
          await ref.read(userFeasibilityProvider({'userId': userId}).future);

      if (response['status'] == true &&
          response['data'] != null &&
          response['data'] is List) {
        final List<dynamic> rawList = response['data'];
        summaryList = rawList
            .map((item) => item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item))
            .toList();
      } else {
        summaryList = [];
      }
    } catch (e) {
      debugPrint("Error fetching summary: $e");
      summaryList = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = summaryList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feasibility List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Palette.themeColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildFeasibilityCard(item);
                  },
                ),
    );
  }

  Widget _buildFeasibilityCard(Map<String, dynamic> item) {
    return Container(
      decoration: cardDecoration(context: context),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Lottie Animation
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.numbers, color: Colors.blue),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 100,
                      child: Text(
                        'Ref ID:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['ref_id'],
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/feasibilityDetails',
                    arguments: item,
                  ).then((value) {});
                },
                child: Lottie.asset('assets/json/right.json', height: 30),
              )
            ],
          ),
          _buildRow(Icons.assignment, 'Scope ID:', item['id']),
          _buildStatusRow(Icons.hourglass_empty, 'Feasibility:',
              item['feasability_status']),
          _buildRow(Icons.design_services, 'Service:', item['service_name']),
          _buildRow(Icons.currency_exchange, 'Currency:', item['currency']),
          _buildStatusRow(Icons.verified, 'RC Demo:',
              item['demodone'] == '0' ? 'Pending' : 'Completed'),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, String? status) {
    bool isPending = status == 'Pending';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: isPending ? Colors.red : Colors.green),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isPending
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPending ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
