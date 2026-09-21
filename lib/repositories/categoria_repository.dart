import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CategoriaRepository {
  final AppDatabase db;

  CategoriaRepository(this.db);

  Future<List<Categoria>> buscarTodas() {
    return db.select(db.categorias).get();
  }

  Stream<List<Categoria>> observar() {
    return db.select(db.categorias).watch();
  }

  Future<int> salvar(CategoriasCompanion categoria) {
    return db.into(db.categorias).insert(categoria);
  }

  Future<int> atualizar({
    required int id,
    required String nome,
    required String icone,
    required int cor,
    required bool receita,
  }) {
    return (db.update(db.categorias)
          ..where((t) => t.id.equals(id)))
        .write(
      CategoriasCompanion(
        nome: Value(nome),
        icone: Value(icone),
        cor: Value(cor),
        receita: Value(receita),
      ),
    );
  }

  Future<int> excluir(int id) {
    return (db.delete(db.categorias)
          ..where((t) => t.id.equals(id)))
        .go();
  }
  Future<void> garantirCategoriasDeReceitaPadrao() async {
    final existentes = await buscarTodas();
    final nomes = existentes.map((item) => item.nome.trim().toLowerCase()).toSet();

    const padroes = <Map<String, dynamic>>[
      {'nome': 'Salário', 'icone': '💼', 'cor': 0xFF2E8B57},
      {'nome': 'Adiantamento salarial', 'icone': '💳', 'cor': 0xFF2E8B57},
      {'nome': 'Horas extras', 'icone': '⏱️', 'cor': 0xFF2E8B57},
      {'nome': 'Comissão', 'icone': '📈', 'cor': 0xFF2E8B57},
      {'nome': 'Bônus', 'icone': '🎁', 'cor': 0xFF2E8B57},
      {'nome': 'Renda extra', 'icone': '💰', 'cor': 0xFF2E8B57},
      {'nome': 'Freelance / Prestação de serviços', 'icone': '🧰', 'cor': 0xFF2E8B57},
      {'nome': 'Rendimentos de investimentos', 'icone': '📊', 'cor': 0xFF2563EB},
      {'nome': 'Dividendos', 'icone': '💵', 'cor': 0xFF2563EB},
      {'nome': 'Juros', 'icone': '🏦', 'cor': 0xFF2563EB},
      {'nome': 'Rendimentos de renda fixa', 'icone': '🛡️', 'cor': 0xFF2563EB},
      {'nome': 'Rendimentos de fundos', 'icone': '📦', 'cor': 0xFF2563EB},
      {'nome': 'Aluguel recebido', 'icone': '🏠', 'cor': 0xFF0F766E},
      {'nome': 'Pensão', 'icone': '🤝', 'cor': 0xFF0F766E},
      {'nome': 'Aposentadoria', 'icone': '🌱', 'cor': 0xFF0F766E},
      {'nome': 'Benefícios', 'icone': '🎫', 'cor': 0xFF0F766E},
      {'nome': 'Cashback', 'icone': '↩️', 'cor': 0xFFEA580C},
      {'nome': 'Reembolso', 'icone': '🧾', 'cor': 0xFFEA580C},
      {'nome': 'Outras receitas', 'icone': '✨', 'cor': 0xFFEA580C},
      {'nome': 'Serviços de informática', 'icone': '💻', 'cor': 0xFF6C4AB6},
      {'nome': 'Manutenção de computadores', 'icone': '🔧', 'cor': 0xFF6C4AB6},
      {'nome': 'Serviços técnicos', 'icone': '⚙️', 'cor': 0xFF6C4AB6},
      {'nome': 'Projetos / trabalhos extras', 'icone': '📋', 'cor': 0xFF6C4AB6},
      {'nome': 'Renda de negócio', 'icone': '🏪', 'cor': 0xFF6C4AB6},
      {'nome': 'Rendimentos da carteira', 'icone': '📚', 'cor': 0xFF6C4AB6},
      {'nome': 'Aportes recebidos', 'icone': '➕', 'cor': 0xFF6C4AB6},
    ];

    for (final padrao in padroes) {
      final nome = padrao['nome'] as String;
      if (nomes.contains(nome.toLowerCase())) continue;

      await salvar(
        CategoriasCompanion.insert(
          nome: nome,
          icone: padrao['icone'] as String,
          cor: padrao['cor'] as int,
          receita: true,
        ),
      );
      nomes.add(nome.toLowerCase());
    }
  }

}