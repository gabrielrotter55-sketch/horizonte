class MetaDeposito {
  final String id;
  final String metaId;
  final String pessoa;
  final double valor;
  final DateTime data;
  final String descricao;
  final String origem;

  const MetaDeposito({
    required this.id,
    required this.metaId,
    required this.pessoa,
    required this.valor,
    required this.data,
    required this.descricao,
    required this.origem,
  });

  MetaDeposito copyWith({
    String? id,
    String? metaId,
    String? pessoa,
    double? valor,
    DateTime? data,
    String? descricao,
    String? origem,
  }) {
    return MetaDeposito(
      id: id ?? this.id,
      metaId: metaId ?? this.metaId,
      pessoa: pessoa ?? this.pessoa,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      origem: origem ?? this.origem,
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
      };

  factory MetaDeposito.fromMap(Map<String, dynamic> map) {
    return MetaDeposito(
      id: map['id'] as String,
      metaId: map['metaId'] as String,
      pessoa: map['pessoa'] as String? ?? 'Gabriel',
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      data: DateTime.tryParse(map['data'] as String? ?? '') ?? DateTime.now(),
      descricao: map['descricao'] as String? ?? '',
      origem: map['origem'] as String? ?? 'manual',
    );
  }
}
