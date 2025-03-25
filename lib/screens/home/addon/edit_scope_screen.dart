import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/screens/home/addon/widget/edit_scope_model.dart';
import 'package:number_to_words/number_to_words.dart';

class EditScopeScreen extends ConsumerStatefulWidget {
  const EditScopeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditScopeScreenState();
}

class _EditScopeScreenState extends ConsumerState<EditScopeScreen> {
  Map<String, dynamic> formData = {};

  String selectedCurrencyId = "";
  String selectedServiceId = "";
  String selectedSubjectId = "";
  String selectedUserId = "";
  String selectedTagId = "";
  String customCurrencyType = "";
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

  void _initializeEditors() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (formData['plan_comments_Basic'] != null) {
        _basicController.setText(formData['plan_comments_Basic']);
      }
      if (formData['plan_comments_Standard'] != null) {
        _standardController.setText(formData['plan_comments_Standard']);
      }
      if (formData['plan_comments_Advanced'] != null) {
        _advancedController.setText(formData['plan_comments_Advanced']);
      }
      if (formData['comments'] != null) {
        _commentController.setText(formData['comments']);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _basicWordCountController.addListener(_updateBasicWordCountText);
    _standardWordCountController.addListener(_updateStandardWordCountText);
    _advancedWordCountController.addListener(_updateAdvancedWordCountText);

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        formData = Map<String, dynamic>.from(args);
        selectedCurrencyId = formData["currency"] ?? "";
        selectedServiceId = formData["service_id"] ?? "";
        selectedSubjectId = formData["subject_area"] ?? "";
        selectedUserId = formData["user_id"] ?? "";
        customCurrencyType = formData["other_currency"] ?? "";

        String planString = formData["plan"] ?? "";
        isBasicSelected = planString.contains("Basic");
        isStandardSelected = planString.contains("Standard");
        isAdvancedSelected = planString.contains("Advanced");

        _basicWordCountController.text =
            formData["plan_word_counts_Basic"] ?? "";
        _standardWordCountController.text =
            formData["plan_word_counts_Standard"] ?? "";
        _advancedWordCountController.text =
            formData["plan_word_counts_Advanced"] ?? "";
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeEditors();
      });
      _updateBasicWordCountText();
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

  void _submitForm() {
    // Implement form submission logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Palette.themeColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: EditScopeModel(
            selectedCurrencyId: selectedCurrencyId,
            selectedServiceId: selectedServiceId,
            selectedSubjectId: selectedSubjectId,
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
            onCurrencyChanged: (value) =>
                setState(() => selectedCurrencyId = value ?? ""),
            onServiceChanged: (value) =>
                setState(() => selectedServiceId = value ?? ""),
            onSubjectChanged: (value) =>
                setState(() => selectedSubjectId = value ?? ""),
            onUserChanged: (value) =>
                setState(() => selectedUserId = value ?? ""),
            onTagChanged: (value) =>
                setState(() => selectedTagId = value ?? ""),
            onBasicChanged: (value) =>
                setState(() => isBasicSelected = value ?? false),
            onStandardChanged: (value) =>
                setState(() => isStandardSelected = value ?? false),
            onAdvancedChanged: (value) =>
                setState(() => isAdvancedSelected = value ?? false),
            onCustomCurrencyChanged: (value) =>
                setState(() => customCurrencyType = value ?? ""),
            onSubmit: _submitForm,
          ),
        ),
      ),
    );
  }
}
