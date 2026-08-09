import 'package:flutter/material.dart';

import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';
import '../../../shared/utils/formatters.dart';
import 'nova_conta_page.dart';

class ContasPage extends StatelessWidget {
  ContasPage({super.key});

  final repository = ContaRepository(
    DatabaseService.instance.database,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
      ),
      body: StreamBuilder(
        stream: repository.observar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final contas = snapshot.data!;

          if (contas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma conta cadastrada',
              ),
            );
          }

          return ListView.builder(
            itemCount: contas.length,
            itemBuilder: (context, index) {
              final conta = contas[index];

              return FutureBuilder<double>(
                future: repository.saldoAtual(conta.id),
                builder: (context, saldoSnapshot) {
                  if (!saldoSnapshot.hasData) {
                    return ListTile(
                      title: Text(conta.nome),
                      subtitle: Text(conta.tipo),
                      trailing: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  final saldo = saldoSnapshot.data!;

                  return ListTile(
                    title: Text(conta.nome),
                    subtitle: Text(conta.tipo),
                    trailing: Text(
                      Formatters.moeda(saldo),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: saldo >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NovaContaPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}