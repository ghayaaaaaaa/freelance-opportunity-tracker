import 'package:flutter/material.dart';

import 'data/opportunity_repository.dart';
import 'features/opportunities/opportunities_screen.dart';
import 'features/opportunities/opportunity_view_model.dart';

void main() {
  runApp(const OpportunityTrackerApp());
}

class OpportunityTrackerApp extends StatefulWidget {
  const OpportunityTrackerApp({super.key});

  @override
  State<OpportunityTrackerApp> createState() => _OpportunityTrackerAppState();
}

class _OpportunityTrackerAppState extends State<OpportunityTrackerApp> {
  late final OpportunityViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OpportunityViewModel(PreferencesOpportunityRepository());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF176B63);
    return MaterialApp(
      title: 'Opportunity Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF5F8F7),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        cardTheme: const CardTheme(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            side: BorderSide(color: Color(0x14176B63)),
          ),
        ),
      ),
      home: OpportunitiesScreen(viewModel: _viewModel),
    );
  }
}
