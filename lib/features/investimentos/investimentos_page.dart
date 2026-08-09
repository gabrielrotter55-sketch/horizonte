import 'package:flutter/material.dart';

class InvestimentosPage extends StatelessWidget {
  const InvestimentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "📈 Investimentos",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}