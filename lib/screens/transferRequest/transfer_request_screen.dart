import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferRequestScreen extends ConsumerStatefulWidget {
  const TransferRequestScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransferRequestScreenState();
}

class _TransferRequestScreenState extends ConsumerState<TransferRequestScreen> {
  String tlUsers = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getString('tl_users') ?? '';

    if (!mounted) return;

    setState(() {
      tlUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(tlTransferRequestProvider(tlUsers));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Transfer Requests"),
      ),
      body: asyncData.when(
        data: (data) {
          final list = data['data'] ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text("No transfer requests."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final fullName =
                  "${item['fld_first_name'] ?? ''} ${item['fld_last_name'] ?? ''}";
              final refId = item['ref_id'] ?? 'N/A';
              final createdOn = item['created_on'] ?? 'N/A';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ref ID: $refId"),
                        Text("Requested On: $createdOn"),
                      ],
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.blue),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/requestDetails', arguments: {
                      'refId': refId,
                      'quoteId': '',
                      'name': fullName
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
