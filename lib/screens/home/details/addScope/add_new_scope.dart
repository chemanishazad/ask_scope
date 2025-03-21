import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/screens/home/details/addScope/ask_new_feasibility.dart';
import 'package:loop/screens/home/details/addScope/ask_scope_tab.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:file_picker/file_picker.dart';

class AddNewScope extends ConsumerStatefulWidget {
  const AddNewScope({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNewScopeState();
}

class _AddNewScopeState extends ConsumerState<AddNewScope>
    with SingleTickerProviderStateMixin {
  String? selectedCurrencyId;
  String? selectedServiceId;
  String? selectedSubjectId;
  String? selectedTagId;
  String? selectedUserId;
  String? customCurrencyType;
  String? customSubjectType;
  late TabController _tabController;

  bool isBasicSelected = false;
  bool isStandardSelected = false;
  bool isAdvancedSelected = false;
  final HtmlEditorController _basicController = HtmlEditorController();
  final HtmlEditorController _standardController = HtmlEditorController();
  final HtmlEditorController _advancedController = HtmlEditorController();
  final HtmlEditorController _commentController = HtmlEditorController();
  final TextEditingController _basicWordCountController =
      TextEditingController();
  final TextEditingController _standardWordCountController =
      TextEditingController();
  final TextEditingController _advancedWordCountController =
      TextEditingController();
  String _basicWordCountText = "";
  String _standardWordCountText = "";
  String _advancedWordCountText = "";
  List<File> _selectedFiles = [];

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files.map((file) => File(file.path!)));
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _basicWordCountController.addListener(_updateBasicWordCountText);
    _standardWordCountController.addListener(_updateStandardWordCountText);
    _advancedWordCountController.addListener(_updateAdvancedWordCountText);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _clearFormData();
      }
    });
    super.initState();
  }

  void _clearFormData() {
    setState(() {
      selectedCurrencyId = null;
      selectedServiceId = null;
      selectedSubjectId = null;
      selectedTagId = null;
      selectedUserId = null;
      customCurrencyType = null;
      customSubjectType = null;
      isBasicSelected = false;
      isStandardSelected = false;
      isAdvancedSelected = false;
      _basicWordCountText = "";
      _standardWordCountText = "";
      _advancedWordCountText = "";
      _selectedFiles.clear();

      // Clear HTML Editor fields
      _basicController.clear();
      _standardController.clear();
      _advancedController.clear();
      _commentController.clear();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      print('Client Name: ${args['clientName']}');
      print('Ref ID: ${args['refId']}');
    }
  }

  void _updateBasicWordCountText() {
    setState(() {
      int? count = int.tryParse(_basicWordCountController.text);
      _basicWordCountText =
          (count != null) ? NumberToWord().convert('en-in', count) : "";
    });
  }

  void _updateStandardWordCountText() {
    setState(() {
      int? count = int.tryParse(_standardWordCountController.text);
      _standardWordCountText = (count != null)
          ? NumberToWord().convert('en-in', count) // Converts number to words
          : "";
    });
  }

  void _updateAdvancedWordCountText() {
    setState(() {
      int? count = int.tryParse(_advancedWordCountController.text);
      _advancedWordCountText = (count != null)
          ? NumberToWord().convert('en-in', count) // Converts number to words
          : "";
    });
  }

  @override
  void dispose() {
    _basicWordCountController.removeListener(_updateBasicWordCountText);
    _standardWordCountController.removeListener(_updateStandardWordCountText);
    _advancedWordCountController.removeListener(_updateAdvancedWordCountText);
    _basicWordCountController.dispose();
    _standardWordCountController.dispose();
    _advancedWordCountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validation
    if (selectedCurrencyId == null) {
      _showError("Please select a currency.");
      return;
    }
    if (selectedServiceId == null) {
      _showError("Please select a service.");
      return;
    }
    if (selectedSubjectId == null) {
      _showError("Please select a subject.");
      return;
    }
    if (selectedTagId == null) {
      _showError("Please select a tag.");
      return;
    }
    if (!isBasicSelected && !isStandardSelected && !isAdvancedSelected) {
      _showError("Please select at least one plan.");
      return;
    }

    // Print selected values
    print("Selected Currency ID: $selectedCurrencyId");
    print("Selected Service ID: $selectedServiceId");
    print("Selected Subject ID: $selectedSubjectId");
    print("Selected Tag ID: $selectedTagId");
    print("Selected custom currency ID: $customCurrencyType");
    print("Selected custom Subject ID: $customSubjectType");

    print("Basic Plan Selected: $isBasicSelected");
    print("Standard Plan Selected: $isStandardSelected");
    print("Advanced Plan Selected: $isAdvancedSelected");

    // Show success message
    _showSuccess("Form submitted successfully!");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Tab(icon: Icon(Icons.info, size: 18), text: "Ask For Scope"),
              Tab(
                  icon: Icon(Icons.perm_device_info_outlined, size: 18),
                  text: "Ask For Feasibility Check"),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // custom widget
                  AskForScopeTab(
                    selectedCurrencyId: selectedCurrencyId,
                    selectedServiceId: selectedServiceId,
                    selectedSubjectId: selectedSubjectId,
                    customSubjectType: customSubjectType,
                    selectedTagId: selectedTagId,
                    customCurrencyType: customCurrencyType,
                    isBasicSelected: isBasicSelected,
                    isStandardSelected: isStandardSelected,
                    isAdvancedSelected: isAdvancedSelected,
                    basicController: _basicController,
                    standardController: _standardController,
                    advancedController: _advancedController,
                    commentController: _commentController,
                    basicWordCountController: _basicWordCountController,
                    standardWordCountController: _standardWordCountController,
                    advancedWordCountController: _advancedWordCountController,
                    basicWordCountText: _basicWordCountText,
                    standardWordCountText: _standardWordCountText,
                    advancedWordCountText: _advancedWordCountText,
                    selectedFiles: _selectedFiles,
                    onCurrencyChanged: (selectedName) {
                      setState(() {
                        selectedCurrencyId = selectedName;
                      });
                      print(selectedCurrencyId);
                    },
                    onServiceChanged: (selectedName) {
                      setState(() {
                        selectedServiceId = selectedName;
                      });
                      print(selectedServiceId);
                    },
                    onSubjectChanged: (selectedName) {
                      setState(() {
                        selectedSubjectId = selectedName;
                      });
                    },
                    onTagChanged: (selectedName) {
                      setState(() {
                        selectedTagId = selectedName;
                      });
                    },
                    onBasicChanged: (value) {
                      setState(() {
                        isBasicSelected = value!;
                      });
                    },
                    onStandardChanged: (value) {
                      setState(() {
                        isStandardSelected = value!;
                      });
                    },
                    onAdvancedChanged: (value) {
                      setState(() {
                        isAdvancedSelected = value!;
                      });
                    },
                    onCustomCurrencyChanged: (value) {
                      setState(() {
                        customCurrencyType = value;
                      });
                    },
                    onPickFile: _pickFile,
                    onRemoveFile: _removeFile,
                    onSubmit: _submitForm,
                  ),
                  AskForFeasibilityTab(
                    selectedCurrencyId: selectedCurrencyId,
                    selectedServiceId: selectedServiceId,
                    selectedSubjectId: selectedSubjectId,
                    selectedTagId: selectedTagId,
                    customCurrencyType: customCurrencyType,
                    isBasicSelected: isBasicSelected,
                    isStandardSelected: isStandardSelected,
                    isAdvancedSelected: isAdvancedSelected,
                    basicController: _basicController,
                    standardController: _standardController,
                    advancedController: _advancedController,
                    commentController: _commentController,
                    basicWordCountController: _basicWordCountController,
                    standardWordCountController: _standardWordCountController,
                    advancedWordCountController: _advancedWordCountController,
                    basicWordCountText: _basicWordCountText,
                    standardWordCountText: _standardWordCountText,
                    advancedWordCountText: _advancedWordCountText,
                    selectedFiles: _selectedFiles,
                    onCurrencyChanged: (selectedName) {
                      setState(() {
                        selectedCurrencyId = selectedName;
                      });
                    },
                    onServiceChanged: (selectedName) {
                      setState(() {
                        selectedServiceId = selectedName;
                      });
                      print(selectedServiceId);
                    },
                    onSubjectChanged: (selectedName) {
                      setState(() {
                        selectedSubjectId = selectedName;
                      });
                    },
                    onUserChanged: (selectedName) {
                      setState(() {
                        selectedUserId = selectedName;
                      });
                    },
                    onTagChanged: (selectedName) {
                      setState(() {
                        selectedTagId = selectedName;
                      });
                    },
                    onBasicChanged: (value) {
                      setState(() {
                        isBasicSelected = value!;
                      });
                    },
                    onStandardChanged: (value) {
                      setState(() {
                        isStandardSelected = value!;
                      });
                    },
                    onAdvancedChanged: (value) {
                      setState(() {
                        isAdvancedSelected = value!;
                      });
                    },
                    onCustomCurrencyChanged: (value) {
                      setState(() {
                        customCurrencyType = value;
                      });
                    },
                    onPickFile: _pickFile,
                    onRemoveFile: _removeFile,
                    onSubmit: _submitForm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
      ),
    );
  }

  Widget checkboxWithLabel({
    required String label,
    required bool value,
    required Color color,
    required Function(bool?) onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: color,
          onChanged: onChanged,
        ),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
