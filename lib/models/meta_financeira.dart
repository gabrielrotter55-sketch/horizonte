class MetaFinanceira {
  final String id;
  final String nome;
  final double objetivo;
  final double acumulado;
  final DateTime? prazo;
  final int cor;
  final DateTime criadoEm;
  final bool conjunta;
  final double saldoInicialGabriel;
  final double saldoInicialNatalia;
  final double rendimentoInicial;
  final String? grupoId;
  final String? grupoNome;

  const MetaFinanceira({
    required this.id,
    required this.nome,
    required this.objetivo,
    required this.acumulado,
    required this.prazo,
    required this.cor,
    required this.criadoEm,
    this.conjunta = false,
    this.saldoInicialGabriel = 0,
    this.saldoInicialNatalia = 0,
    this.rendimentoInicial = 0,
    this.grupoId,
    this.grupoNome,
  });

  double get progresso => objetivo <= 0 ? 0 : (acumulado / objetivo).clamp(0, 1).toDouble();
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
    bool? conjunta,
    double? saldoInicialGabriel,
    double? saldoInicialNatalia,
    double? rendimentoInicial,
    String? grupoId,
    String? grupoNome,
    bool limparGrupo = false,
  }) => MetaFinanceira(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    objetivo: objetivo ?? this.objetivo,
    acumulado: acumulado ?? this.acumulado,
    prazo: limparPrazo ? null : (prazo ?? this.prazo),
    cor: cor ?? this.cor,
    criadoEm: criadoEm ?? this.criadoEm,
    conjunta: conjunta ?? this.conjunta,
    saldoInicialGabriel: saldoInicialGabriel ?? this.saldoInicialGabriel,
    saldoInicialNatalia: saldoInicialNatalia ?? this.saldoInicialNatalia,
    rendimentoInicial: rendimentoInicial ?? this.rendimentoInicial,
    grupoId: limparGrupo ? null : (grupoId ?? this.grupoId),
    grupoNome: limparGrupo ? null : (grupoNome ?? this.grupoNome),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'nome': nome, 'objetivo': objetivo, 'acumulado': acumulado,
    'prazo': prazo?.toIso8601String(), 'cor': cor, 'criadoEm': criadoEm.toIso8601String(),
    'conjunta': conjunta,
    'saldoInicialGabriel': saldoInicialGabriel,
    'saldoInicialNatalia': saldoInicialNatalia,
    'rendimentoInicial': rendimentoInicial,
    'grupoId': grupoId,
    'grupoNome': grupoNome,
  };

  factory MetaFinanceira.fromMap(Map<String, dynamic> map) => MetaFinanceira(
    id: map['id'] as String,
    nome: map['nome'] as String,
    objetivo: (map['objetivo'] as num).toDouble(),
    acumulado: (map['acumulado'] as num).toDouble(),
    prazo: map['prazo'] == null ? null : DateTime.tryParse(map['prazo'] as String),
    cor: (map['cor'] as num?)?.toInt() ?? 0xFF6C4AB6,
    criadoEm: DateTime.tryParse(map['criadoEm'] as String? ?? '') ?? DateTime.now(),
    conjunta: map['conjunta'] as bool? ?? false,
    saldoInicialGabriel: (map['saldoInicialGabriel'] as num?)?.toDouble() ?? 0,
    saldoInicialNatalia: (map['saldoInicialNatalia'] as num?)?.toDouble() ?? 0,
    rendimentoInicial: (map['rendimentoInicial'] as num?)?.toDouble() ?? 0,
    grupoId: map['grupoId'] as String?,
    grupoNome: map['grupoNome'] as String?,
  );
}
