import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/provider/home/scope_upload_provider.dart';
import '../../../core/components/custom_multiselect.dart';

class UpdateFollowerScreen extends ConsumerStatefulWidget {
  const UpdateFollowerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UpdateFollowerScreenState();
}

class _UpdateFollowerScreenState extends ConsumerState<UpdateFollowerScreen> {
  String selectedFollowersIds = '';
  String refId = '';
  String quoteId = '';
  bool isInitialized = false;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        refId = args?['refId'];
        quoteId = args?['quoteId'];
      });

      if (args != null && args['followers'] != null) {
        final followers = args['followers'];

        if (followers is String) {
          selectedFollowersIds = followers.trim();
        } else if (followers is List) {
          selectedFollowersIds = followers.map((e) => e.toString()).join(',');
        }
      }

      isInitialized = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(filterUserDropdownProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Followers",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Palette.themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userData.when(
              data: (currencies) {
                final tagMap = {
                  for (var tag in currencies)
                    '${tag['fld_first_name']} ${tag['fld_last_name']}':
                        tag['id'].toString(),
                };

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title('Select Followers'),
                    const SizedBox(height: 10),
                    CustomMultiSelectDropDown(
                      dialogTitle: 'Select Followers',
                      dropdownWidth: MediaQuery.sizeOf(context).width,
                      icon: Icons.tag,
                      items: tagMap,
                      title: 'Select Followers',
                      initialValues: selectedFollowersIds.isNotEmpty
                          ? selectedFollowersIds.split(',')
                          : [],
                      onSelectionChanged: (selectedIds) {
                        setState(() {
                          selectedFollowersIds = selectedIds.join(',');
                        });
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text("Error: ${err.toString()}"),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateTag();
                },
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(" Update Followers "),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTag() async {
    setState(() {
      isLoading = true;
    });
    if (selectedFollowersIds.isNotEmpty) {
      try {
        final response = await ref.read(followerUpdateProvider({
          'refId': refId,
          'quoteId': quoteId,
          'followers': selectedFollowersIds,
          'notification': 'no'
        }).future);

        if (response['status'] == true) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(response['message'] ?? "Tags updated successfully.")),
          );
          Navigator.pop(context);
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? "Failed to update tags.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one tag.")),
      );
    }
  }

  Widget title(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
