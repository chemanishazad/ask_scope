import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';

class FeasibilityScreen extends ConsumerStatefulWidget {
  const FeasibilityScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeasibilityScreenState();
}

class _FeasibilityScreenState extends ConsumerState<FeasibilityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
      ),
    );
  }
}
