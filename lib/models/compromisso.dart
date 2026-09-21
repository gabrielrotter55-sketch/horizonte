
enum TipoCompromisso { mensal, anual, esporadico }

enum StatusCompromisso { pendente, pago }

class Compromisso {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;
  final TipoCompromisso tipo;
  final String categoria;
  final String favorecido;
  final StatusCompromisso status;
  final String? observacao;
  final DateTime? pagoEm;

  const Compromisso({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.tipo,
    required this.categoria,
    required this.favorecido,
    required this.status,
    required this.observacao,
    required this.pagoEm,
  });

  bool get recorrente => tipo != TipoCompromisso.esporadico;

  Compromisso copyWith({
    String? id,
    String? descricao,
    double? valor,
    DateTime? data,
    TipoCompromisso? tipo,
    String? categoria,
    String? favorecido,
    StatusCompromisso? status,
    String? observacao,
    DateTime? pagoEm,
    bool limparPagoEm = false,
  }) {
    return Compromisso(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      favorecido: favorecido ?? this.favorecido,
      status: status ?? this.status,
      observacao: observacao ?? this.observacao,
      pagoEm: limparPagoEm ? null : (pagoEm ?? this.pagoEm),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'descricao': descricao,
        'valor': valor,
        'data': data.toIso8601String(),
        'tipo': tipo.name,
        'categoria': categoria,
        'favorecido': favorecido,
        'status': status.name,
        'observacao': observacao,
        'pagoEm': pagoEm?.toIso8601String(),
      };

  factory Compromisso.fromMap(Map<String, dynamic> map) {
    return Compromisso(
      id: map['id'] as String,
      descricao: map['descricao'] as String? ?? 'Compromisso',
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      data: DateTime.tryParse(map['data'] as String? ?? '') ?? DateTime.now(),
      tipo: TipoCompromisso.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => TipoCompromisso.esporadico,
      ),
      categoria: map['categoria'] as String? ?? 'Outras despesas',
      favorecido: map['favorecido'] as String? ?? '',
      status: StatusCompromisso.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StatusCompromisso.pendente,
      ),
      observacao: map['observacao'] as String?,
      pagoEm: map['pagoEm'] == null
          ? null
          : DateTime.tryParse(map['pagoEm'] as String),
    );
  }
}
