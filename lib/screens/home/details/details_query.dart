import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/screens/home/details/widget/chat_screen.dart';
import 'package:loop/screens/home/details/widget/details_card.dart';
import 'package:loop/screens/home/details/widget/feasibility_history.dart';
import 'package:loop/screens/home/details/widget/query_history.dart';
import 'package:loop/screens/home/details/widget/scope_details.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsQuery extends ConsumerStatefulWidget {
  const DetailsQuery({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DetailsQueryState();
}

class _DetailsQueryState extends ConsumerState<DetailsQuery>
    with SingleTickerProviderStateMixin {
  String? refId;
  String? quoteId;
  String? id;
  Map<String, dynamic>? details;
  Map<String, dynamic>? chatData;
  Map<String, dynamic>? history;
  Map<String, dynamic>? feasibility;
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      print(args);

      if (args != null) {
        try {
          final fetchedDetails = await ref.read(queryDetailsProvider({
            'refId': args['refId'],
            'quoteId': args['quoteId'],
          }).future);

          final historyData = await ref.read(quoteHistoryProvider({
            'refId': args['refId'],
            'quoteId': args['quoteId'],
          }).future);

          final feasibilityData = await ref.read(feasibilityHistoryProvider({
            'refId': args['refId'],
            'quoteId': args['quoteId'],
          }).future);

          final queryChat = await ref.read(queryChatProvider({
            'quoteId': args['quoteId'],
          }).future);

          setState(() {
            refId = args['refId'];
            quoteId = args['quoteId'];

            chatData = queryChat;
            details = fetchedDetails;
            history = historyData;
            feasibility = feasibilityData;
            // id = fetchedDetails['quoteInfo']['user_id'];
            isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? quoteInfo = details?['quoteInfo'];
    setState(() {
      id = quoteInfo?[0]['user_id'];
    });
    print(id);
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text("Error: $errorMessage"))
                : (quoteInfo == null || quoteInfo.isEmpty)
                    ? const Center(child: Text("No details found"))
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            history!['historyData'].isEmpty
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
                              chat: chatData?['data'],
                              quoteId: quoteId ?? '',
                              userId: id ?? ''),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Feasibility Comments'),
                                Html(
                                  data: quoteInfo.isNotEmpty &&
                                          quoteInfo[0]
                                                  ['feasability_comments'] !=
                                              null
                                      ? quoteInfo[0]['feasability_comments']
                                      : "<p>No feasibility comments available.</p>",
                                ),
                                Text(
                                  quoteInfo.isNotEmpty &&
                                          quoteInfo[0]['feasability_status'] !=
                                              null
                                      ? quoteInfo[0]['feasability_status']
                                      : "No status available",
                                ),
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
                                        feasibility!['historyData'] != null
                                    ? const Center(
                                        child: Text(
                                            "No Feasibility history available"),
                                      )
                                    : FeasibilityHistory(history: feasibility),
                              ],
                            ),
                          )
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
