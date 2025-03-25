import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/provider/home/scope_upload_provider.dart';
import '../../../core/components/custom_multiselect.dart';

class UpdateTagScreen extends ConsumerStatefulWidget {
  const UpdateTagScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UpdateTagScreenState();
}

class _UpdateTagScreenState extends ConsumerState<UpdateTagScreen> {
  String selectedTagIds = '';
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

      if (args != null && args['tags'] != null) {
        final tags = args['tags'];

        if (tags is String) {
          selectedTagIds = tags.trim();
        } else if (tags is List) {
          selectedTagIds = tags.map((e) => e.toString()).join(',');
        }
      }

      isInitialized = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagData = ref.watch(tagsDropdownProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Tag",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Palette.themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tagData.when(
              data: (currencies) {
                final tagMap = {
                  for (var tag in currencies)
                    tag['tag_name'].toString(): tag['id'].toString(),
                };

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title('Select Tags'),
                    const SizedBox(height: 10),
                    CustomMultiSelectDropDown(
                      dropdownWidth: MediaQuery.sizeOf(context).width,
                      icon: Icons.tag,
                      items: tagMap,
                      title: 'Select Tags',
                      initialValues: selectedTagIds.isNotEmpty
                          ? selectedTagIds
                              .split(',') // Convert back to list for UI
                          : [],
                      onSelectionChanged: (selectedIds) {
                        setState(() {
                          selectedTagIds =
                              selectedIds.join(','); // Convert list to string
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
                    : const Text(" Update Tag "),
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
    if (selectedTagIds.isNotEmpty) {
      try {
        final response = await ref.read(tagUpdateProvider({
          'refId': refId,
          'quoteId': quoteId,
          'tags': selectedTagIds,
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
