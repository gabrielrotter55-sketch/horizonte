class PatrimonioFisico {
  final String id;
  final String nome;
  final String tipo;
  final double valorAquisicao;
  final double valorAtual;
  final double saldoDevedor;
  final double parcelaFinanciamento;
  final int? vencimentoFinanciamento;
  final String instituicaoFinanciamento;
  final DateTime? dataAquisicao;
  final String observacao;

  const PatrimonioFisico({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.valorAquisicao,
    required this.valorAtual,
    required this.saldoDevedor,
    required this.parcelaFinanciamento,
    required this.vencimentoFinanciamento,
    required this.instituicaoFinanciamento,
    required this.dataAquisicao,
    required this.observacao,
  });

  double get patrimonioLiquido => valorAtual - saldoDevedor;

  bool get financiado => saldoDevedor > 0;

  PatrimonioFisico copyWith({
    String? id,
    String? nome,
    String? tipo,
    double? valorAquisicao,
    double? valorAtual,
    double? saldoDevedor,
    double? parcelaFinanciamento,
    int? vencimentoFinanciamento,
    bool limparVencimento = false,
    String? instituicaoFinanciamento,
    DateTime? dataAquisicao,
    bool limparDataAquisicao = false,
    String? observacao,
  }) {
    return PatrimonioFisico(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      valorAquisicao: valorAquisicao ?? this.valorAquisicao,
      valorAtual: valorAtual ?? this.valorAtual,
      saldoDevedor: saldoDevedor ?? this.saldoDevedor,
      parcelaFinanciamento:
          parcelaFinanciamento ?? this.parcelaFinanciamento,
      vencimentoFinanciamento: limparVencimento
          ? null
          : (vencimentoFinanciamento ?? this.vencimentoFinanciamento),
      instituicaoFinanciamento:
          instituicaoFinanciamento ?? this.instituicaoFinanciamento,
      dataAquisicao: limparDataAquisicao
          ? null
          : (dataAquisicao ?? this.dataAquisicao),
      observacao: observacao ?? this.observacao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'valorAquisicao': valorAquisicao,
      'valorAtual': valorAtual,
      'saldoDevedor': saldoDevedor,
      'parcelaFinanciamento': parcelaFinanciamento,
      'vencimentoFinanciamento': vencimentoFinanciamento,
      'instituicaoFinanciamento': instituicaoFinanciamento,
      'dataAquisicao': dataAquisicao?.toIso8601String(),
      'observacao': observacao,
    };
  }

  factory PatrimonioFisico.fromMap(Map<String, dynamic> map) {
    return PatrimonioFisico(
      id: map['id'] as String,
      nome: map['nome'] as String? ?? 'Patrimônio',
      tipo: map['tipo'] as String? ?? 'Outro',
      valorAquisicao: (map['valorAquisicao'] as num?)?.toDouble() ?? 0,
      valorAtual: (map['valorAtual'] as num?)?.toDouble() ?? 0,
      saldoDevedor: (map['saldoDevedor'] as num?)?.toDouble() ?? 0,
      parcelaFinanciamento:
          (map['parcelaFinanciamento'] as num?)?.toDouble() ?? 0,
      vencimentoFinanciamento:
          (map['vencimentoFinanciamento'] as num?)?.toInt(),
      instituicaoFinanciamento:
          map['instituicaoFinanciamento'] as String? ?? '',
      dataAquisicao: map['dataAquisicao'] == null
          ? null
          : DateTime.tryParse(map['dataAquisicao'] as String),
      observacao: map['observacao'] as String? ?? '',
    );
  }
}
