import 'package:flutter/material.dart';

class LancamentosPage extends StatelessWidget {
  const LancamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "💸 Lançamentos",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}