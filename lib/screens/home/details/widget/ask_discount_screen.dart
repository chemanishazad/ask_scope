import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';
import 'package:loop/provider/home/askDiscountApiModel.dart';
import 'package:loop/provider/home/scope_upload_provider.dart';

class AskDiscountScreen extends ConsumerStatefulWidget {
  const AskDiscountScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AskDiscountScreenState();
}

class _AskDiscountScreenState extends ConsumerState<AskDiscountScreen> {
  bool isPTPClient = false;
  double minRequiredAmount = 0;
  List<String> allPlans = ["Basic", "Standard", "Advanced"];
  String selectedPlansString = "";
  List<String>? finalPrices;
  List<File> selectedFiles = [];
  String? refId;
  String? quoteId;
  String? oldPlan;

  TextEditingController ptpAmountController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.files.map((file) => File(file.path!)));
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    setState(() {
      refId = args?['assign_id'];
      quoteId = args?['quoteid'];
      oldPlan = args?['old_plan'];
    });

    if (args != null) {
      _initializeData(args);
    }
  }

  void _initializeData(Map<String, dynamic> quoteData) {
    // Extract selected plans from API response
    if (quoteData["plan"] != null) {
      selectedPlansString = quoteData["plan"];
    }

    // Extract final prices from API response
    if (quoteData["final_price"] != null) {
      finalPrices = (quoteData["final_price"] as String).split(",");
    }

    if (finalPrices != null && finalPrices!.isNotEmpty) {
      List<double> prices =
          finalPrices!.map((e) => double.tryParse(e) ?? 0).toList();
      double minFinalPrice =
          prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0;
      minRequiredAmount = minFinalPrice * 0.7;
    }

    setState(() {});
  }

  void _togglePlan(String plan) {
    List<String> selectedPlans =
        selectedPlansString.isNotEmpty ? selectedPlansString.split(",") : [];

    if (selectedPlans.contains(plan)) {
      selectedPlans.remove(plan); // Deselect
    } else {
      selectedPlans.add(plan); // Select
    }

    setState(() {
      selectedPlansString = selectedPlans
          .join(","); // Convert list back to comma-separated string
    });
  }

  Future<void> _validateAndSubmit() async {
    if (isPTPClient) {
      double enteredAmount = double.tryParse(ptpAmountController.text) ?? 0;
      if (enteredAmount < minRequiredAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Minimum required amount is INR ${minRequiredAmount.toStringAsFixed(2)}")),
        );
        return;
      }
    }
    final response = await ref.read(askDiscountProvider(AskDiscountModel(
            file: selectedFiles,
            refId: refId ?? '',
            quoteId: quoteId ?? '',
            comments: commentsController.text,
            amount: ptpAmountController.text,
            oldPlans: oldPlan ?? '',
            selectedPlan: selectedPlansString,
            ptp: isPTPClient ? "yes" : "no"))
        .future);

    if (response['status'] == 'success') {
      Navigator.pop(context);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: response['message']);
    } else {
      Fluttertoast.showToast(msg: response['message']);
    }
    // Proceed with submission
    print("Selected Plans: $selectedPlansString");
    print("Selected Price: ${ptpAmountController.text}");
    print("Form submitted successfully!");
  }

  @override
  Widget build(BuildContext context) {
    List<String> selectedPlans =
        selectedPlansString.isNotEmpty ? selectedPlansString.split(",") : [];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Palette.themeColor,
          title: const Text(
            "Ask Discount",
            style: TextStyle(color: Colors.white),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isPTPClient,
                    onChanged: (value) {
                      setState(() {
                        isPTPClient = value ?? false;
                      });
                    },
                  ),
                  const Text("PTP Client"),
                ],
              ),

              // PTP Amount Input
              TextFormField(
                controller: ptpAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "PTP Amount",
                  prefixText: "INR ",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              title("Plans"),
              Column(
                children: allPlans.map((plan) {
                  return CheckboxListTile(
                    value: selectedPlans.contains(plan),
                    onChanged: (isChecked) => _togglePlan(plan),
                    title: Text(plan),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
              title("Comments"),
              TextFormField(
                controller: commentsController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your comments...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),

              title("Upload File"),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(
                  Icons.photo_filter_sharp,
                  color: Colors.white,
                ),
                label: const Text("Select Files"),
              ),
              if (selectedFiles.isNotEmpty)
                Column(
                  children: selectedFiles.asMap().entries.map((entry) {
                    int index = entry.key;
                    File file = entry.value;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: cardDecoration(context: context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              file.path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedFiles.removeAt(index);
                              });
                            },
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
