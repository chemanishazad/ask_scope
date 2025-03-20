import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/screens/home/details/widget/details_card.dart';
import 'package:loop/screens/home/details/widget/query_history.dart';
import 'package:loop/screens/home/details/widget/scope_details.dart';

class DetailsQuery extends ConsumerStatefulWidget {
  const DetailsQuery({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DetailsQueryState();
}

class _DetailsQueryState extends ConsumerState<DetailsQuery>
    with SingleTickerProviderStateMixin {
  String? refId;
  String? quoteId;
  Map<String, dynamic>? details;
  Map<String, dynamic>? history;
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

          setState(() {
            details = fetchedDetails;
            history = historyData;
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
                                DetailsCard(quote: quoteInfo[0]),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
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
                                    Text(
                                      'History',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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

                          const Center(child: Text("Communication Data")),
                          const Center(child: Text("Feasibility Data")),
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
}
