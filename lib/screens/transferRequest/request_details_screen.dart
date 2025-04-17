import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/screens/home/details/widget/chat_screen.dart';
import 'package:loop/screens/home/details/widget/feasibility_history.dart';
import 'package:loop/screens/home/details/widget/query_history.dart';
import 'package:loop/screens/home/details/widget/scope_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailsScreen extends ConsumerStatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends ConsumerState<RequestDetailsScreen>
    with SingleTickerProviderStateMixin {
  String? refId;
  String? quoteId;
  String? id;
  String name = '';

  Map<String, dynamic>? details;
  Map<String, dynamic>? chatData;
  Map<String, dynamic>? history;
  Map<String, dynamic>? feasibility;
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;
  String userId = '';
  @override
  void initState() {
    super.initState();
    loadData();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      print('args$args');

      if (args != null) {
        try {
          final fetchedDetails = await ref.read(queryDetailsProvider({
            'refId': args['refId'],
            'quoteId': args['quoteId'],
          }).future);

          final fetchedQuoteInfo = fetchedDetails['quoteInfo'];
          final fetchedQuoteId = fetchedQuoteInfo.isNotEmpty
              ? fetchedQuoteInfo[0]['quoteid']
              : null;

          setState(() {
            refId = args['refId'];
            name = args['name'];
            quoteId = fetchedQuoteId;
            details = fetchedDetails;
          });
          print('fetchedDetails$fetchedDetails');
          final historyData = await ref.read(quoteHistoryProvider({
            'refId': refId,
            'quoteId': quoteId,
          }).future);

          final feasibilityData = await ref.read(feasibilityHistoryProvider({
            'refId': refId,
            'quoteId': quoteId,
          }).future);

          final queryChat = await ref.read(queryChatProvider({
            'quoteId': quoteId,
          }).future);

          setState(() {
            isLoading = false;
            chatData = queryChat;
            history = historyData;
            feasibility = feasibilityData;
          });
        } catch (error) {
          setState(() {
            errorMessage = error.toString();
            isLoading = false;
          });
        }
      }
    });
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('loopUserId');
    setState(() {
      userId = id!;
    });
    print('id$id');
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? quoteInfo = details?['quoteInfo'];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Palette.themeColor,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.info, size: 18), text: "Details"),
              Tab(icon: Icon(Icons.chat, size: 18), text: "Communication"),
              Tab(
                  icon: Icon(Icons.assignment_turned_in, size: 18),
                  text: "Feasibility"),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (quoteInfo == null || quoteInfo.isEmpty)
                      ? const Center(child: Text("No Previous Requests"))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            // First Tab: Details with History
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // DetailsCard(quote: quoteInfo[0]),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Scope Details',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ScopeDetailsCard(quote: quoteInfo[0]),
                                      const SizedBox(height: 12),
                                      history == null ||
                                              history!['historyData'] == null
                                          ? const Center(
                                              child: Text(
                                                  "No communication history available"),
                                            )
                                          : QueryHistory(history: history),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            ChatScreen(
                                refId: refId ?? '',
                                quoteId: (details?['quoteInfo']?.isNotEmpty ??
                                        false)
                                    ? details!['quoteInfo'][0]['quoteid'] ?? ''
                                    : '',
                                userId: id ?? ''),
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Feasibility Comments',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Html(
                                    data: quoteInfo.isNotEmpty &&
                                            quoteInfo[0]
                                                    ['feasability_comments'] !=
                                                null
                                        ? quoteInfo[0]['feasability_comments']
                                        : "<p>No feasibility comments available.</p>",
                                  ),
                                  if (quoteInfo[0]['feas_file_name'] != null)
                                    Row(
                                      children: [
                                        const Text('Feasibility Attachment :'),
                                        _buildFeasibilityAttachment(
                                            quoteInfo[0]['feas_file_name']),
                                      ],
                                    ),
                                  const SizedBox(height: 12),
                                  if (feasibility == null ||
                                      feasibility!['historyData'] != null)
                                    const Text(
                                      'Feasibility History',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  feasibility == null ||
                                          feasibility!['historyData'] == null
                                      ? const Center(
                                          child: Text(
                                              "No Feasibility history available"),
                                        )
                                      : FeasibilityHistory(
                                          history: feasibility),
                                ],
                              ),
                            )
                          ],
                        ),
            ),
          ),
          if (!isLoading)
            _buildApprovalBar(
              name: name,
              onApprove: () async {
                final res = await ref.read(approveTransferUserProvider({
                  'refId': refId ?? '',
                  'status': 'approve',
                  'userId': quoteInfo?[0]['user_id']
                }).future);
                print("Approved");
                if (res['status'] == true) {
                  Fluttertoast.showToast(msg: res['message']);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(msg: res['message']);
                }
              },
              onReject: () async {
                final res = await ref.read(approveTransferUserProvider({
                  'refId': refId ?? '',
                  'status': 'reject',
                  'userId': userId
                }).future);
                print("Rejected");
                if (res['status'] == true) {
                  Fluttertoast.showToast(msg: res['message']);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(msg: res['message']);
                }
                print(res);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildApprovalBar({
    required String name,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Colors.grey, width: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: "$name ",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: "is requesting access"),
                  ],
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.block, color: Colors.red, size: 18),
              label: const Text(
                "Reject",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onApprove,
              icon:
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
              label: const Text(
                "Approve",
                style: TextStyle(color: Colors.green, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFeasibilityAttachment(String? fileUrl) {
    if (fileUrl == null || fileUrl.isEmpty) {
      return const Text("No Feasibility Attachment");
    }

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse(fileUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not open the file")),
            );
          }
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.link, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "View File",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
