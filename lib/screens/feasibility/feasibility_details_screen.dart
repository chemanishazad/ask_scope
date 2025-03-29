import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/complete_feasibility_model.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:loop/provider/home/scope_upload_provider.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FeasibilityDetailsScreen extends ConsumerStatefulWidget {
  const FeasibilityDetailsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeasibilityDetailsScreenState();
}

class _FeasibilityDetailsScreenState
    extends ConsumerState<FeasibilityDetailsScreen> {
  Map<String, dynamic>? args;
  Map<String, dynamic>? quote;
  String? userId;
  late final HtmlEditorController _commentController;
  List<File> selectedFiles = [];
  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.files.map((file) => File(file.path!)));
      });
    }
  }

  String? refId;
  String? quoteId;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _commentController = HtmlEditorController();
    final prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('loopUserId');
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fetchedDetails = await ref.read(queryDetailsProvider({
      'refId': args?['ref_id'],
      'quoteId': args?['quote_id'],
    }).future);
    if (fetchedDetails['quoteInfo'] != null) {
      setState(() {
        refId = args?['ref_id'];
        quoteId = args?['quote_id'];
        userId = id;
        quote = fetchedDetails['quoteInfo'].isNotEmpty
            ? fetchedDetails['quoteInfo'][0] as Map<String, dynamic>
            : null;
      });
    } else {
      print("Error: quoteInfo is null or empty");
    }
  }

  void showUserSelectionDialog(BuildContext context, AsyncSnapshot userData) {
    String? selectedUserId;
    final userMap = userData.hasData
        ? {
            for (var tag in userData.data)
              "${tag['fld_first_name']} ${tag['fld_last_name']}":
                  tag['id'].toString(),
          }
        : {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select User to Assign'),
          content: userData.hasData
              ? StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_circle_outlined),
                          ),
                          items: userMap.keys
                              .map((name) => DropdownMenuItem<String>(
                                    value: name,
                                    child: Text(name),
                                  ))
                              .toList(),
                          onChanged: (selectedName) {
                            setState(() {
                              selectedUserId = userMap[selectedName];
                            });
                          },
                          hint: const Text('Select User'),
                        ),
                      ],
                    );
                  },
                )
              : userData.hasError
                  ? Text("Error: ${userData.error}")
                  : const Center(child: CircularProgressIndicator()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedUserId != null) {
                  print("Selected User ID: $selectedUserId");
                  final response = await ref.read(transferUserProvider({
                    'refId': refId ?? '',
                    'quoteId': quoteId ?? '',
                    'userId': selectedUserId ?? '',
                  }).future);

                  if (response['status'] == true) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: response['message']);
                  } else {
                    Fluttertoast.showToast(msg: response['message']);
                  }
                  print(response);
                } else {
                  print("No user selected");
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(quote?['callrecordingpending']);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Palette.themeColor,
          title: const Text('Feasibility Details')),
      body: quote == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: cardDecoration(context: context),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (quote!['tag_names'] != null &&
                              quote!['tag_names'].isNotEmpty)
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    _buildInfoRow('Ref Id', refId),
                                    if (quote?['callrecordingpending'] == '1')
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(Icons.headphones),
                                      ),
                                    if (quote?['edited'] == '1')
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon((Icons.edit)),
                                      ),
                                  ]),
                                  OutlinedButton.icon(
                                    label: const Text('Transfer'),
                                    icon: const Icon(Icons.compare_arrows,
                                        size: 20, color: Colors.green),
                                    onPressed: () {
                                      final userData =
                                          ref.watch(filterUserDropdownProvider);

                                      userData.when(
                                        data: (data) => showUserSelectionDialog(
                                            context,
                                            AsyncSnapshot.withData(
                                                ConnectionState.done, data)),
                                        loading: () => showUserSelectionDialog(
                                            context,
                                            const AsyncSnapshot.waiting()),
                                        error: (err, stack) =>
                                            showUserSelectionDialog(
                                                context,
                                                AsyncSnapshot.withError(
                                                    ConnectionState.done, err)),
                                      );
                                    },
                                  ),
                                ]),
                          _buildTagRow('Tags', quote!['tag_names']),
                          if (quote!['subject_area'] != null &&
                              quote!['subject_area'].isNotEmpty)
                            _buildInfoRow(
                                'Subject Area', quote!['subject_area']),
                          if (quote!['service_name'] != null &&
                              quote!['service_name'].isNotEmpty)
                            _buildInfoRow(
                                'Service Required', quote!['service_name']),
                          if (quote!['plan'] != null)
                            _buildInfoRow('Plan', quote!['plan']),
                          if (quote!['old_plan'] != null)
                            _buildInfoRow('Old Plan', quote!['old_plan']),
                          _buildPlanDescription(
                              quote!['plan_comments'], quote!['word_counts']),
                          if (quote!['comments'] != null &&
                              quote!['comments'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Html(data: quote!['comments']),
                                ],
                              ),
                            ),
                          _buildPriceDetails(),
                          if (quote?['relevant_file'] != null &&
                              quote?['relevant_file'] is List)
                            _buildRelevantFilesSection(
                                quote?['relevant_file'] as List<dynamic>),
                          const SizedBox(height: 8),
                          if (quote?['callrecordingpending'] == '0' ||
                              quote?['callrecordingpendinguser'] == userId)
                            ElevatedButton.icon(
                              onPressed: () async {
                                final response =
                                    await ref.read(markCallRecordProvider({
                                  'refId': refId ?? '',
                                  'quoteId': quoteId ?? '',
                                  'callRecordingPending':
                                      quote?['callrecordingpending'] == '0'
                                          ? '1'
                                          : '0',
                                }).future);

                                print("Response: $response");

                                if (response['status'] == true) {
                                  setState(() {});

                                  Fluttertoast.showToast(
                                      msg: response['message']);
                                  Navigator.pop(context);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: response['message']);
                                }
                              },
                              label: Text(quote?['callrecordingpending'] == '1'
                                  ? 'Remove Call Recording Pending'
                                  : 'Mark Call Recording Pending'),
                              icon: const Icon(Icons.headphones,
                                  color: Colors.white),
                            ),
                          const SizedBox(height: 8),
                          _buildStatusCard(
                              'Quote Status:', quote?['quote_status']),
                          const SizedBox(height: 8),
                          _buildStatusCard('Feasibility Status:',
                              quote?['feasability_status']),
                          if (quote?['feasability_comments'] != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Feasibility Comments:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                                Html(
                                  data: quote?['feasability_comments'],
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          if (quote?['feasability_status'] != 'Completed')
                            const Text(
                              'Feasibility Comments',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          if (quote?['feasability_status'] != 'Completed')
                            HtmlEditor(
                              controller: _commentController,
                              htmlEditorOptions: const HtmlEditorOptions(
                                hint: "Add comment for Basic plan",
                              ),
                              otherOptions: const OtherOptions(
                                height: 200,
                              ),
                              htmlToolbarOptions: const HtmlToolbarOptions(
                                defaultToolbarButtons: [
                                  FontButtons(clearAll: false),
                                  ParagraphButtons(
                                    alignCenter: true,
                                    alignLeft: true,
                                    alignRight: true,
                                    lineHeight: false,
                                    textDirection: false,
                                  ),
                                  InsertButtons(
                                      table: false, video: false, audio: false),
                                ],
                              ),
                            ),
                          if (quote?['feasability_status'] != 'Completed')
                            const SizedBox(height: 8),
                          if (quote?['feasability_status'] != 'Completed')
                            const Text(
                              'Attach File (Optional)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          if (quote?['feasability_status'] != 'Completed')
                            ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(
                                Icons.photo_filter_sharp,
                                color: Colors.white,
                              ),
                              label: const Text("Select Files"),
                            ),
                          if (quote?['feasability_status'] != 'Completed')
                            if (selectedFiles.isNotEmpty)
                              Column(
                                children:
                                    selectedFiles.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  File file = entry.value;

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration:
                                        cardDecoration(context: context),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            file.path.split('/').last,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedFiles.removeAt(index);
                                            });
                                          },
                                          child: const Icon(Icons.delete,
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          if (quote?['feasability_status'] != 'Completed')
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  String comment =
                                      await _commentController.getText();

                                  final response = await ref.read(
                                      completeFeasibilityProvider(
                                              CompleteFeasibilityModel(
                                                  file: selectedFiles,
                                                  refId: refId ?? '',
                                                  quoteId: quoteId ?? '',
                                                  feasibilityComments: comment,
                                                  userId: userId ?? ''))
                                          .future);
                                  if (response['status'] == true) {
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                        msg: response['message']);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: response['message']);
                                  }
                                  print(response);
                                },
                                child: const Text('Submit'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard(String title, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagRow(String title, String? tags) {
    List<String> tagList = tags?.split(',') ?? [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tagList
                .map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Palette.themeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#${tag.trim()}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelevantFilesSection(List<dynamic> files) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Relevant Files',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...files.map((file) {
          final fileMap = file as Map<String, dynamic>;
          return InkWell(
            onTap: () async {
              final uri = Uri.parse(fileMap['file_path']);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                debugPrint('Could not launch ${fileMap['file_path']}');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                fileMap['filename'] ?? 'Unknown File',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPriceDetails() {
    List<String>? initialPrices = quote!['quote_price'] != null
        ? (quote!['quote_price'] as String).split(',')
        : null;
    List<String>? discountPrices = quote!['discount_price'] != null
        ? (quote!['discount_price'] as String).split(',')
        : null;
    List<String>? finalPrices = quote!['final_price'] != null
        ? (quote!['final_price'] as String).split(',')
        : null;

    List<String> planTypes = ["Basic", "Standard", "Advanced"];

    Widget buildPriceRow(String title, List<String> prices, Color bgColor) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Column(
              children: List.generate(prices.length, (index) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${planTypes[index].toUpperCase()}:",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        "INR ${prices[index]}",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (initialPrices != null)
          buildPriceRow(
              "Initial Plan Price", initialPrices, Colors.grey.shade200),
        if (discountPrices != null)
          buildPriceRow(
              "Discounted Price", discountPrices, Colors.grey.shade400),
        if (finalPrices != null)
          buildPriceRow("Final Price", finalPrices, Colors.amber.shade400),
      ],
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            value?.isNotEmpty == true ? value! : "N/A",
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDescription(String? planJson, String? wordCountJson) {
    if (planJson == null || planJson.isEmpty) {
      return const Text(
        "No plan description available",
        style: TextStyle(fontSize: 14, color: Colors.black87),
      );
    }

    Map<String, dynamic> planData = {};
    Map<String, dynamic> wordCounts = {};

    try {
      planData = Map<String, dynamic>.from(jsonDecode(planJson));

      if (wordCountJson != null && wordCountJson.isNotEmpty) {
        Map<String, dynamic> tempWordCounts =
            Map<String, dynamic>.from(jsonDecode(wordCountJson));

        wordCounts = tempWordCounts.map((key, value) {
          if (value == null || value == "null") {
            return MapEntry(key, null);
          }
          if (value is String && int.tryParse(value) != null) {
            return MapEntry(key, int.parse(value));
          }
          if (value is int) {
            return MapEntry(key, value);
          }
          return MapEntry(key, null);
        });
      }
    } catch (e) {
      print("JSON Parsing Error: ${e.toString()}");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: planData.entries.map((entry) {
        String planName = entry.key;
        String description = entry.value;
        int? wordCount = wordCounts[planName];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planName,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Html(data: description),
              if (wordCount != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Word Counts:",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$planName: $wordCount words",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${convertLargeNumberToWords(wordCount)} words',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String convertLargeNumberToWords(int number) {
    return NumberToWord().convert('en-in', number).replaceAll("-", " ");
  }
}
