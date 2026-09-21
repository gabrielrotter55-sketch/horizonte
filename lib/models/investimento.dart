class Investimento {
  final String id;
  final String nome;
  final String ticker;
  final String tipo;
  final String instituicao;
  final String moeda;
  final double quantidade;
  final double precoMedio;
  final double precoAtual;
  final double valorInvestido;
  final double valorAtual;
  final DateTime data;
  final String origem;

  const Investimento({
    required this.id,
    required this.nome,
    required this.ticker,
    required this.tipo,
    required this.instituicao,
    required this.moeda,
    required this.quantidade,
    required this.precoMedio,
    required this.precoAtual,
    required this.valorInvestido,
    required this.valorAtual,
    required this.data,
    required this.origem,
  });

  bool get internacional => moeda.toUpperCase() == 'USD';

  double get resultado => valorAtual - valorInvestido;

  double get rentabilidade {
    if (valorInvestido <= 0) return 0;
    return resultado / valorInvestido;
  }

  Investimento copyWith({
    String? id,
    String? nome,
    String? ticker,
    String? tipo,
    String? instituicao,
    String? moeda,
    double? quantidade,
    double? precoMedio,
    double? precoAtual,
    double? valorInvestido,
    double? valorAtual,
    DateTime? data,
    String? origem,
  }) {
    return Investimento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ticker: ticker ?? this.ticker,
      tipo: tipo ?? this.tipo,
      instituicao: instituicao ?? this.instituicao,
      moeda: moeda ?? this.moeda,
      quantidade: quantidade ?? this.quantidade,
      precoMedio: precoMedio ?? this.precoMedio,
      precoAtual: precoAtual ?? this.precoAtual,
      valorInvestido: valorInvestido ?? this.valorInvestido,
      valorAtual: valorAtual ?? this.valorAtual,
      data: data ?? this.data,
      origem: origem ?? this.origem,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ticker': ticker,
      'tipo': tipo,
      'instituicao': instituicao,
      'moeda': moeda,
      'quantidade': quantidade,
      'precoMedio': precoMedio,
      'precoAtual': precoAtual,
      'valorInvestido': valorInvestido,
      'valorAtual': valorAtual,
      'data': data.toIso8601String(),
      'origem': origem,
    };
  }

  factory Investimento.fromMap(Map<String, dynamic> map) {
    final aplicadoAntigo =
        (map['aplicado'] as num?)?.toDouble() ??
        (map['valorInvestido'] as num?)?.toDouble() ??
        0;
    final atualAntigo =
        (map['valorAtual'] as num?)?.toDouble() ?? 0;

    return Investimento(
      id: map['id'] as String,
      nome: map['nome'] as String? ?? 'Investimento',
      ticker: map['ticker'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'Outros',
      instituicao: map['instituicao'] as String? ?? '',
      moeda: map['moeda'] as String? ?? 'BRL',
      quantidade: (map['quantidade'] as num?)?.toDouble() ?? (aplicadoAntigo > 0 ? 1 : 0),
      precoMedio: (map['precoMedio'] as num?)?.toDouble() ?? aplicadoAntigo,
      precoAtual: (map['precoAtual'] as num?)?.toDouble() ?? atualAntigo,
      valorInvestido: aplicadoAntigo,
      valorAtual: atualAntigo,
      data: DateTime.tryParse(map['data'] as String? ?? '') ?? DateTime.now(),
      origem: map['origem'] as String? ?? 'manual',
    );
  }
}
