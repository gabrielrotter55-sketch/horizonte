class MetaDeposito {
  final String id;
  final String metaId;
  final String pessoa;
  final double valor;
  final DateTime data;
  final String descricao;
  final String origem;
  final int? contaId;

  /// Natureza do lançamento:
  /// - aporte: dinheiro efetivamente adicionado à reserva
  /// - rendeu: rendimento gerado pela própria reserva
  final String tipo;

  const MetaDeposito({
    required this.id,
    required this.metaId,
    required this.pessoa,
    required this.valor,
    required this.data,
    required this.descricao,
    required this.origem,
    required this.tipo,
    this.contaId,
  });

  bool get isAporte => tipo == 'aporte';

  bool get isRendimento => tipo == 'rendeu';

  MetaDeposito copyWith({
    String? id,
    String? metaId,
    String? pessoa,
    double? valor,
    DateTime? data,
    String? descricao,
    String? origem,
    String? tipo,
    int? contaId,
  }) {
    return MetaDeposito(
      id: id ?? this.id,
      metaId: metaId ?? this.metaId,
      pessoa: pessoa ?? this.pessoa,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      origem: origem ?? this.origem,
      tipo: tipo ?? this.tipo,
      contaId: contaId ?? this.contaId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'metaId': metaId,
        'pessoa': pessoa,
        'valor': valor,
        'data': data.toIso8601String(),
        'descricao': descricao,
        'origem': origem,
        'tipo': tipo,
        'contaId': contaId,
      };

  factory MetaDeposito.fromMap(Map<String, dynamic> map) {
    return MetaDeposito(
      id: map['id'] as String,
      metaId: map['metaId'] as String,
      // Rendimentos pertencem à própria meta, não a uma pessoa.
      pessoa: (map['tipo'] as String? ?? 'aporte') == 'rendeu'
          ? 'Meta'
          : (map['pessoa'] as String? ?? 'Gabriel'),
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      data: DateTime.tryParse(map['data'] as String? ?? '') ?? DateTime.now(),
      descricao: map['descricao'] as String? ?? '',
      origem: map['origem'] as String? ?? 'manual',
      contaId: (map['contaId'] as num?)?.toInt(),

      // Compatibilidade com os registros antigos:
      // tudo que já existia será considerado aporte.
      tipo: map['tipo'] as String? ?? 'aporte',
    );
  }
}