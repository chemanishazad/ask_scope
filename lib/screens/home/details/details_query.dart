import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/screens/home/details/widget/chat_screen.dart';
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

      if (args != null) {
        refId = args['refId'];
        quoteId = args['quoteId'];
        await refreshQueryDetails();
      }
    });
  }

  Future<void> refreshQueryDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedDetails = await ref.read(queryDetailsProvider({
        'refId': refId,
        'quoteId': quoteId,
      }).future);

      final historyData = await ref.read(quoteHistoryProvider({
        'refId': refId,
        'quoteId': quoteId,
      }).future);

      final feasibilityData = await ref.read(feasibilityHistoryProvider({
        'refId': refId,
        'quoteId': quoteId,
      }).future);

      // final queryChat = await ref.read(queryChatProvider({
      //   'quoteId': quoteId,
      // }).future);

      setState(() {
        details = fetchedDetails;
        history = historyData;
        feasibility = feasibilityData;
        // chatData = queryChat;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
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
                                    ScopeDetailsCard(
                                      quote: quoteInfo[0],
                                      onDemoSaved: refreshQueryDetails,
                                    ),
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
                              quoteId: quoteId ?? '',
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
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Html(
                                    data: quoteInfo.isNotEmpty &&
                                            quoteInfo[0]
                                                    ['feasability_comments'] !=
                                                null
                                        ? quoteInfo[0]['feasability_comments']
                                        : "<p>No feasibility comments available.</p>",
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (quoteInfo[0]['feas_file_name'] != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Feasibility Attachment:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildFeasibilityAttachment(
                                              quoteInfo[0]['feas_file_name']),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Divider(height: 20, thickness: 1),
                                const Text(
                                  'Feasibility History',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (feasibility == null ||
                                    feasibility!['historyData'] == null)
                                  const Center(
                                    child: Text(
                                      "No Feasibility history available",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  )
                                else
                                  FeasibilityHistory(history: feasibility),
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

    return GestureDetector(
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
        children: [
          Icon(Icons.link, color: Colors.blue, size: 16),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              "View File",
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
