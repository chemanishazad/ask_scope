import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/home_provider.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:url_launcher/url_launcher.dart';

class ScopeDetailsCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> quote;
  const ScopeDetailsCard({super.key, required this.quote});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScopeDetailsCardState();
}

class _ScopeDetailsCardState extends ConsumerState<ScopeDetailsCard> {
  @override
  Widget build(BuildContext context) {
    print(widget.quote['assign_id']);
    return Container(
        width: double.infinity,
        decoration: cardDecoration(context: context),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: _buildInfoRow(
                      'Ref ID', '# ${widget.quote['assign_id']}')),
              if (widget.quote['callrecordingpending'] == '1')
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.headphones),
                ),
              if (widget.quote['edited'] == '1')
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon((Icons.edit)),
                ),
            ]),
            if (widget.quote['tag_names'] != null &&
                widget.quote['tag_names'].isNotEmpty)
              _buildTagRow('Tags', widget.quote['tag_names']),
            if (widget.quote['subject_area'] != null &&
                widget.quote['subject_area'].isNotEmpty)
              _buildInfoRow('Subject Area', widget.quote['subject_area']),
            if (widget.quote['service_name'] != null &&
                widget.quote['service_name'].isNotEmpty)
              _buildInfoRow('Service Required', widget.quote['service_name']),
            if (widget.quote['plan'] != null)
              _buildInfoRow('Plan', widget.quote['plan']),
            if (widget.quote['old_plan'] != null)
              _buildInfoRow('Old Plan', widget.quote['old_plan']),
            _buildPlanDescription(
                widget.quote['plan_comments'], widget.quote['word_counts']),
            if (widget.quote['comments'] != null &&
                widget.quote['comments'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Html(
                      data: widget.quote['comments'],
                    ),
                  ],
                ),
              ),
            _buildPriceDetails(),
            if (widget.quote['relevant_file'] is List)
              _buildRelevantFilesSection(List<Map<String, dynamic>>.from(
                  widget.quote['relevant_file'])),
            if (widget.quote['quote_status'] == 'Submitted')
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/askDiscount',
                      arguments: widget.quote);
                },
                label: const Text('Ask Discount'),
                icon: const Icon(Icons.discount_outlined, color: Colors.white),
              ),
            if (widget.quote['callrecordingpending'] == '0' ||
                widget.quote['callrecordingpendinguser'] ==
                    widget.quote['user_id'])
              ElevatedButton.icon(
                onPressed: () async {
                  final response = await ref.read(markCallRecordProvider({
                    'refId': widget.quote['assign_id'] ?? '',
                    'quoteId': widget.quote['quoteid'] ?? '',
                    'callRecordingPending':
                        widget.quote['callrecordingpending'] == '0' ? '1' : '0',
                  }).future);

                  print("Response: $response");

                  if (response['status'] == true) {
                    setState(() {});

                    Fluttertoast.showToast(msg: response['message']);
                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(msg: response['message']);
                  }
                },
                label: Text(widget.quote['callrecordingpending'] == '1'
                    ? 'Remove Call Recording Pending'
                    : 'Mark Call Recording Pending'),
                icon: const Icon(Icons.headphones, color: Colors.white),
              ),
            const SizedBox(height: 8),
          ],
        ));
  }

  Widget _buildRelevantFilesSection(List<Map<String, dynamic>> files) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Relevant Files',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...files.map((file) => InkWell(
              onTap: () async {
                final uri = Uri.parse(file['file_path']);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint('Could not launch ${file['file_path']}');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  file['filename'] ?? 'Unknown File',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildPriceDetails() {
    List<String>? initialPrices = widget.quote['quote_price'] != null
        ? (widget.quote['quote_price'] as String).split(',')
        : null;
    List<String>? discountPrices = widget.quote['discount_price'] != null
        ? (widget.quote['discount_price'] as String).split(',')
        : null;
    List<String>? finalPrices = widget.quote['final_price'] != null
        ? (widget.quote['final_price'] as String).split(',')
        : null;

    List<String> selectedPlans = widget.quote['plan'] != null
        ? (widget.quote['plan'] as String).split(',')
        : [];

    Map<String, dynamic> comments = {};
    if (widget.quote['new_comments'] != null) {
      try {
        comments =
            jsonDecode(widget.quote['new_comments']) as Map<String, dynamic>;
      } catch (e) {
        print("Error decoding new_comments: $e");
      }
    }

    List<String> allPlans = ["Basic", "Standard", "Advanced"];

    List<String> orderedFinalPrices = List.filled(selectedPlans.length, "N/A");
    for (int i = 0;
        i < selectedPlans.length && i < (finalPrices?.length ?? 0);
        i++) {
      orderedFinalPrices[i] = finalPrices![i];
    }

    Widget buildPriceRow(String title, List<String>? prices, Color bgColor,
        {bool strikeThrough = false, bool filterByPlan = false}) {
      if (prices == null) return const SizedBox.shrink();

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
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Column(
              children: List.generate(selectedPlans.length, (index) {
                String plan = selectedPlans[index];
                String comment = comments[plan] ?? "No comments available";
                String priceText =
                    index < prices.length ? prices[index] : 'N/A';

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${plan.toUpperCase()}:",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          Text(
                            "INR $priceText",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              decoration: strikeThrough
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          comment,
                          style: const TextStyle(color: Colors.grey),
                        ),
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
              "Initial Plan Price", initialPrices, Colors.grey.shade200,
              strikeThrough: true),
        if (discountPrices != null)
          buildPriceRow(
              "Discounted Price", discountPrices, Colors.grey.shade400,
              strikeThrough: true, filterByPlan: true),
        if (finalPrices != null)
          buildPriceRow(
              "Final Price", orderedFinalPrices, Colors.amber.shade400),
      ],
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
}
