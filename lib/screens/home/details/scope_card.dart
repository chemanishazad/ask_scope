import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';

class ScopeCard extends ConsumerStatefulWidget {
  const ScopeCard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScopeCardState();
}

class _ScopeCardState extends ConsumerState<ScopeCard> {
  List<Map<String, dynamic>> quotes = [];
  bool isLoading = true;
  String? errorMessage;
  String? refId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (refId != args) {
      refId = args;
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (refId != null) {
      setState(() => isLoading = true);
      try {
        final fetchedDetails = await ref.read(queryDetailsProvider({
          'refId': refId!,
          'quoteId': '',
        }).future);

        setState(() {
          quotes = List<Map<String, dynamic>>.from(
              fetchedDetails['quoteInfo'] ?? []);
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          errorMessage = error.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.pushNamed(context, '/addNewScope', arguments: {
            'clientName': quotes[0]['client_name'],
            'refId': quotes[0]['assign_id'],
          });
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text("Error: $errorMessage"))
              : ListView.builder(
                  cacheExtent: 800,
                  padding: const EdgeInsets.all(12),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quotes[index];
                    return QuoteCard(quote: quote, onUpdate: _fetchData);
                  },
                ),
    );
  }
}

class QuoteCard extends StatelessWidget {
  final Map<String, dynamic> quote;
  final VoidCallback onUpdate;

  const QuoteCard({super.key, required this.quote, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(context: context),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long,
                  size: 18, color: Palette.themeColor),
              const SizedBox(width: 8),
              const SizedBox(
                width: 100,
                child: Text("Ref No:",
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  quote['assign_id'] ?? '',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (quote['edited'] == '1')
                IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'This data already edited');
                    },
                    icon: const Icon(Icons.edit)),
              if (quote['ownership_transferred'] == '1')
                IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(
                          msg:
                              'Ownership transferred from ${quote['old_user_name']}');
                    },
                    icon: const Icon(Icons.transfer_within_a_station_sharp)),
            ],
          ),
          InfoRow(
              icon: Icons.confirmation_number,
              label: "Quote ID:",
              value: quote['quoteid']),
          InfoRow(icon: Icons.category, label: "Plan:", value: quote['plan']),
          InfoRow(
              icon: Icons.design_services,
              label: "Service Name:",
              value: quote['service_name']),
          InfoRow(
              icon: Icons.pending,
              label: "Quote Status:",
              value: quote['status']),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(Icons.remove_red_eye_outlined, () {
                Navigator.pushNamed(context, '/detailsQuery', arguments: {
                  'refId': quote['assign_id'],
                  'quoteId': quote['quoteid'],
                }).then((_) => onUpdate());
              }),
              _buildActionButton(Icons.edit, () {
                Navigator.pushNamed(context, '/editScopeScreen',
                        arguments: quote)
                    .then((_) => onUpdate());
              }),
              _buildActionButton(Icons.tag, () {
                // print(quote);

                Navigator.pushNamed(context, '/updateTagScreen', arguments: {
                  'refId': quote['assign_id'],
                  'tags': quote['tags'],
                  'quoteId': quote['quoteid'],
                }).then((_) => onUpdate());
              }),
              _buildActionButton(Icons.manage_accounts_outlined, () {
                Navigator.pushNamed(context, '/updateFollowerScreen',
                    arguments: {
                      'refId': quote['assign_id'],
                      'followers': quote['followers'],
                      'quoteId': quote['quoteid'],
                    }).then((_) => onUpdate());
              }),
              _buildActionButton(Icons.share, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: Palette.themeColor),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const InfoRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Palette.themeColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
