import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:url_launcher/url_launcher.dart';

class ScopeDetailsCard extends StatelessWidget {
  final Map<String, dynamic> quote;

  const ScopeDetailsCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: cardDecoration(context: context),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (quote['tag_names'] != null && quote['tag_names'].isNotEmpty)
              _buildTagRow('Tags', quote['tag_names']),
            if (quote['subject_area'] != null &&
                quote['subject_area'].isNotEmpty)
              _buildInfoRow('Subject Area', quote['subject_area']),
            if (quote['service_name'] != null &&
                quote['service_name'].isNotEmpty)
              _buildInfoRow('Service Required', quote['service_name']),
            if (quote['plan'] != null) _buildInfoRow('Plan', quote['plan']),
            if (quote['old_plan'] != null)
              _buildInfoRow('Old Plan', quote['old_plan']),
            _buildPlanDescription(quote['plan_comments'], quote['word_counts']),
            if (quote['comments'] != null && quote['comments'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Html(
                      data: quote['comments'],
                    ),
                  ],
                ),
              ),
            _buildPriceDetails(),
            if (quote['relevant_file'] is List)
              _buildRelevantFilesSection(
                  List<Map<String, dynamic>>.from(quote['relevant_file'])),
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
    List<String>? initialPrices = quote['quote_price'] != null
        ? (quote['quote_price'] as String).split(',')
        : null;
    List<String>? discountPrices = quote['discount_price'] != null
        ? (quote['discount_price'] as String).split(',')
        : null;
    List<String>? finalPrices = quote['final_price'] != null
        ? (quote['final_price'] as String).split(',')
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

        // Convert all values to integers safely
        wordCounts = tempWordCounts.map((key, value) {
          if (value == null || value == "null") {
            return MapEntry(key, null); // Handle nulls
          }
          if (value is String && int.tryParse(value) != null) {
            return MapEntry(key, int.parse(value)); // Convert string to int
          }
          if (value is int) {
            return MapEntry(key, value);
          }
          return MapEntry(key, null); // Fallback if type is unexpected
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
                        convertLargeNumberToWords(wordCount),
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
