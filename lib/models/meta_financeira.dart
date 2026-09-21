class MetaFinanceira {
  final String id;
  final String nome;
  final double objetivo;
  final double acumulado;
  final DateTime? prazo;
  final int cor;
  final DateTime criadoEm;

  const MetaFinanceira({
    required this.id,
    required this.nome,
    required this.objetivo,
    required this.acumulado,
    required this.prazo,
    required this.cor,
    required this.criadoEm,
  });

  double get progresso {
    if (objetivo <= 0) return 0;
    return (acumulado / objetivo).clamp(0, 1).toDouble();
  }

  bool get concluida => objetivo > 0 && acumulado >= objetivo;

  MetaFinanceira copyWith({
    String? id,
    String? nome,
    double? objetivo,
    double? acumulado,
    DateTime? prazo,
    bool limparPrazo = false,
    int? cor,
    DateTime? criadoEm,
  }) {
    return MetaFinanceira(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      objetivo: objetivo ?? this.objetivo,
      acumulado: acumulado ?? this.acumulado,
      prazo: limparPrazo ? null : (prazo ?? this.prazo),
      cor: cor ?? this.cor,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'objetivo': objetivo,
      'acumulado': acumulado,
      'prazo': prazo?.toIso8601String(),
      'cor': cor,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory MetaFinanceira.fromMap(Map<String, dynamic> map) {
    return MetaFinanceira(
      id: map['id'] as String,
      nome: map['nome'] as String,
      objetivo: (map['objetivo'] as num).toDouble(),
      acumulado: (map['acumulado'] as num).toDouble(),
      prazo: map['prazo'] == null
          ? null
          : DateTime.tryParse(map['prazo'] as String),
      cor: (map['cor'] as num?)?.toInt() ?? 0xFF6C4AB6,
      criadoEm: DateTime.tryParse(map['criadoEm'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
