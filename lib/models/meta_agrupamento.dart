class MetaAgrupamento {
  final String id;
  final String nome;
  final List<String> metaIds;

  const MetaAgrupamento({required this.id, required this.nome, required this.metaIds});

  MetaAgrupamento copyWith({String? id, String? nome, List<String>? metaIds}) =>
      MetaAgrupamento(id: id ?? this.id, nome: nome ?? this.nome, metaIds: metaIds ?? this.metaIds);

  Map<String, dynamic> toMap() => {'id': id, 'nome': nome, 'metaIds': metaIds};

  factory MetaAgrupamento.fromMap(Map<String, dynamic> map) => MetaAgrupamento(
        id: map['id'] as String,
        nome: map['nome'] as String? ?? 'Grupo',
        metaIds: (map['metaIds'] as List<dynamic>? ?? const []).whereType<String>().toList(),
      );
}
