import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/auth/auth_provider.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/screens/home/filter_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Map<String, dynamic>> allClientData = [];
  List<Map<String, dynamic>> displayedClientData = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchKeywords = '';
  String refId = '';
  String website = '';
  String scopeToken = '';
  String transferAccess = '';
  String tl = '';

  @override
  void initState() {
    super.initState();
    contactMadeQuery();
    ref.refresh(notificationGetProvider);
    loginData();
  }

  Future<void> loginData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      scopeToken = prefs.getString('scopeadmin') ?? '';
      transferAccess = prefs.getString('transferaccess') ?? '';
      tl = prefs.getString('tl') ?? '';
    });
  }

  bool isLoading = false;
  Future<void> contactMadeQuery() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    String? instaId = prefs.getString('instaUserId');
    String? userType = prefs.getString('instaUserType');
    String? teamId = prefs.getString('instaTeamId');

    final response = await ref.read(contactMadeQueryProvider({
      'userId': instaId ?? '',
      'userType': userType ?? '',
      'teamId': teamId ?? '',
      'searchKeywords': searchKeywords,
      'refId': refId,
      'website': website,
    }).future);

    if (response['status'] == true) {
      setState(() {
        allClientData = List<Map<String, dynamic>>.from(response['data']);
        _updateDisplayedData();
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _updateDisplayedData() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    setState(() {
      displayedClientData = allClientData.sublist(startIndex,
          endIndex > allClientData.length ? allClientData.length : endIndex);
    });
  }

  void _changePage(bool isNext) {
    int totalPages = (allClientData.length / itemsPerPage).ceil();
    if (isNext && currentPage < totalPages) {
      setState(() {
        currentPage++;
        _updateDisplayedData();
      });
    } else if (!isNext && currentPage > 1) {
      setState(() {
        currentPage--;
        _updateDisplayedData();
      });
    }
  }

  void _showMenuOptions(BuildContext context) {
    final RenderBox appBarRenderBox = context.findRenderObject() as RenderBox;
    final Offset appBarPosition = appBarRenderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        appBarPosition.dx + appBarRenderBox.size.width,
        appBarPosition.dy + 80,
        appBarPosition.dx + appBarRenderBox.size.width,
        appBarPosition.dy + appBarRenderBox.size.height,
      ),
      items: [
        PopupMenuItem(
          value: 'filter',
          child: ListTile(
            leading: const Icon(Icons.filter_alt),
            title: const Text("Filter"),
            onTap: () {
              Navigator.pop(context);
              _showFilterModal();
            },
          ),
        ),
        if (tl == '1')
          PopupMenuItem(
            value: 'userRequest',
            child: ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text("User Request"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/userRequest');
              },
            ),
          ),
        if (transferAccess == '1')
          PopupMenuItem(
            value: 'transferAccess',
            child: ListTile(
              leading: const Icon(Icons.transfer_within_a_station),
              title: const Text("Transfer Request"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transferRequest').then(
                  (value) {
                    contactMadeQuery();
                  },
                );
              },
            ),
          ),
        if (scopeToken == '1')
          PopupMenuItem(
            value: 'scopeRequest',
            child: ListTile(
              leading: const Icon(Icons.on_device_training_sharp),
              title: const Text("Scope Request"),
              onTap: () {
                Navigator.pushNamed(context, '/scopeRequest');
              },
            ),
          ),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout(context);
            },
          ),
        ),
      ],
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: FilterBar(
            onFilterApplied: (newRefId, newKeyword, newWebsite) {
              setState(() {
                refId = newRefId;
                searchKeywords = newKeyword;
                website = newWebsite;
                currentPage = 1;
              });
              contactMadeQuery();
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = (allClientData.length / itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: currentPage > 1 ? () => _changePage(false) : null,
        ),
        Text("Page $currentPage of $totalPages"),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: currentPage < totalPages ? () => _changePage(true) : null,
        ),
        const SizedBox(width: 20),
        DropdownButton<int>(
          value: itemsPerPage,
          items: [10, 20, 30, 50, 100].map((e) {
            return DropdownMenuItem(value: e, child: Text("$e per page"));
          }).toList(),
          onChanged: (newCount) {
            if (newCount != null) {
              setState(() {
                itemsPerPage = newCount;
                currentPage = 1;
                _updateDisplayedData();
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(notificationGetProvider);
    // print('scopeToken$scopeToken');
    // print('transferAccess$transferAccess');
    // print('tl$tl');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
        title: const Text("Query History",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          asyncData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text("Error: $error")),
              data: (notificationData) {
                final int count = notificationData['unread_count'];

                return IconButton(
                  icon: Badge(
                    label: Text(
                      count.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notificationScreen').then(
                      (value) {
                        ref.invalidate(notificationGetProvider);
                      },
                    );
                  },
                );
              }),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMenuOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedClientData.isEmpty
                    ? const Center(
                        child: Text(
                        "No results found",
                      ))
                    : RefreshIndicator(
                        onRefresh: () => contactMadeQuery(),
                        child: ListView.builder(
                          itemCount: displayedClientData.length,
                          itemBuilder: (context, index) {
                            return Column(children: [
                              const SizedBox(height: 8),
                              _buildClientCard(displayedClientData[index])
                            ]);
                          },
                        ),
                      ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> data) {
    final theme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: cardDecoration(context: context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data["user_name"] ?? "Unknown",
                    style: Theme.of(context).textTheme.headlineMedium),
                Row(
                  children: [
                    Text("#${data["assign_id"] ?? "N/A"}"),
                    const SizedBox(width: 5),
                    InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/scopeCard',
                              arguments: data['assign_id']);
                        },
                        child:
                            Lottie.asset('assets/json/right.json', height: 25)),
                  ],
                ),
              ],
            ),
            const Divider(height: 15, thickness: 1, color: Colors.grey),
            _buildRow(Icons.email, "Email", data["email_id"] ?? "N/A"),
            _buildRow(Icons.phone, "Contact",
                data["phone"].isEmpty ? "N/A" : data["phone"]),
            _buildRow(Icons.public, "Website", data["website_name"] ?? "N/A"),
            _buildRow(Icons.calendar_today, "Date", data["date"] ?? "N/A"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.priority_high),
                    const SizedBox(width: 10),
                    SizedBox(
                        width: 80,
                        child: Text("Priority:", style: theme.headlineMedium)),
                    Text(data["priority"] ?? "N/A",
                        style: theme.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
                if (data['looppanel_transfer_access'] == '0' ||
                    data['looppanel_transfer_access'] == '3')
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                    onPressed: () async {
                      final response = await ref.read(
                          requestAccessProvider({'assignId': data['assign_id']})
                              .future);
                      print(response);

                      if (response['status'] == true) {
                        contactMadeQuery();
                        Fluttertoast.showToast(msg: response['message']);
                      } else {
                        Fluttertoast.showToast(msg: response['error']);
                      }
                      print(data['assign_id']);
                    },
                    child: const Text('Request Access',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                if (data['looppanel_transfer_access'] == '1')
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.yellow),
                    ),
                    onPressed: () {},
                    child: const Text('Request Pending',
                        style: TextStyle(color: Colors.black, fontSize: 10)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, String value) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          SizedBox(
              width: 80, child: Text("$title:", style: theme.headlineMedium)),
          Expanded(
              child: Text(value,
                  style: theme.bodyMedium, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
