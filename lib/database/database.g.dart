// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ContasTable extends Contas with TableInfo<$ContasTable, Conta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saldoInicialMeta = const VerificationMeta(
    'saldoInicial',
  );
  @override
  late final GeneratedColumn<double> saldoInicial = GeneratedColumn<double>(
    'saldo_inicial',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, saldoInicial, tipo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('saldo_inicial')) {
      context.handle(
        _saldoInicialMeta,
        saldoInicial.isAcceptableOrUnknown(
          data['saldo_inicial']!,
          _saldoInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saldoInicialMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      saldoInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo_inicial'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
    );
  }

  @override
  $ContasTable createAlias(String alias) {
    return $ContasTable(attachedDatabase, alias);
  }
}

class Conta extends DataClass implements Insertable<Conta> {
  final int id;
  final String nome;
  final double saldoInicial;
  final String tipo;
  const Conta({
    required this.id,
    required this.nome,
    required this.saldoInicial,
    required this.tipo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['saldo_inicial'] = Variable<double>(saldoInicial);
    map['tipo'] = Variable<String>(tipo);
    return map;
  }

  ContasCompanion toCompanion(bool nullToAbsent) {
    return ContasCompanion(
      id: Value(id),
      nome: Value(nome),
      saldoInicial: Value(saldoInicial),
      tipo: Value(tipo),
    );
  }

  factory Conta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conta(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      saldoInicial: serializer.fromJson<double>(json['saldoInicial']),
      tipo: serializer.fromJson<String>(json['tipo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'saldoInicial': serializer.toJson<double>(saldoInicial),
      'tipo': serializer.toJson<String>(tipo),
    };
  }

  Conta copyWith({int? id, String? nome, double? saldoInicial, String? tipo}) =>
      Conta(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        saldoInicial: saldoInicial ?? this.saldoInicial,
        tipo: tipo ?? this.tipo,
      );
  Conta copyWithCompanion(ContasCompanion data) {
    return Conta(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      saldoInicial: data.saldoInicial.present
          ? data.saldoInicial.value
          : this.saldoInicial,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conta(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, saldoInicial, tipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conta &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.saldoInicial == this.saldoInicial &&
          other.tipo == this.tipo);
}

class ContasCompanion extends UpdateCompanion<Conta> {
  final Value<int> id;
  final Value<String> nome;
  final Value<double> saldoInicial;
  final Value<String> tipo;
  const ContasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.saldoInicial = const Value.absent(),
    this.tipo = const Value.absent(),
  });
  ContasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required double saldoInicial,
    required String tipo,
  }) : nome = Value(nome),
       saldoInicial = Value(saldoInicial),
       tipo = Value(tipo);
  static Insertable<Conta> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<double>? saldoInicial,
    Expression<String>? tipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (saldoInicial != null) 'saldo_inicial': saldoInicial,
      if (tipo != null) 'tipo': tipo,
    });
  }

  ContasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<double>? saldoInicial,
    Value<String>? tipo,
  }) {
    return ContasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (saldoInicial.present) {
      map['saldo_inicial'] = Variable<double>(saldoInicial.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconeMeta = const VerificationMeta('icone');
  @override
  late final GeneratedColumn<String> icone = GeneratedColumn<String>(
    'icone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _corMeta = const VerificationMeta('cor');
  @override
  late final GeneratedColumn<int> cor = GeneratedColumn<int>(
    'cor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receitaMeta = const VerificationMeta(
    'receita',
  );
  @override
  late final GeneratedColumn<bool> receita = GeneratedColumn<bool>(
    'receita',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("receita" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, icone, cor, receita];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('icone')) {
      context.handle(
        _iconeMeta,
        icone.isAcceptableOrUnknown(data['icone']!, _iconeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconeMeta);
    }
    if (data.containsKey('cor')) {
      context.handle(
        _corMeta,
        cor.isAcceptableOrUnknown(data['cor']!, _corMeta),
      );
    } else if (isInserting) {
      context.missing(_corMeta);
    }
    if (data.containsKey('receita')) {
      context.handle(
        _receitaMeta,
        receita.isAcceptableOrUnknown(data['receita']!, _receitaMeta),
      );
    } else if (isInserting) {
      context.missing(_receitaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      icone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icone'],
      )!,
      cor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cor'],
      )!,
      receita: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}receita'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nome;
  final String icone;
  final int cor;
  final bool receita;
  const Categoria({
    required this.id,
    required this.nome,
    required this.icone,
    required this.cor,
    required this.receita,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['icone'] = Variable<String>(icone);
    map['cor'] = Variable<int>(cor);
    map['receita'] = Variable<bool>(receita);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nome: Value(nome),
      icone: Value(icone),
      cor: Value(cor),
      receita: Value(receita),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      icone: serializer.fromJson<String>(json['icone']),
      cor: serializer.fromJson<int>(json['cor']),
      receita: serializer.fromJson<bool>(json['receita']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'icone': serializer.toJson<String>(icone),
      'cor': serializer.toJson<int>(cor),
      'receita': serializer.toJson<bool>(receita),
    };
  }

  Categoria copyWith({
    int? id,
    String? nome,
    String? icone,
    int? cor,
    bool? receita,
  }) => Categoria(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    icone: icone ?? this.icone,
    cor: cor ?? this.cor,
    receita: receita ?? this.receita,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      icone: data.icone.present ? data.icone.value : this.icone,
      cor: data.cor.present ? data.cor.value : this.cor,
      receita: data.receita.present ? data.receita.value : this.receita,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('icone: $icone, ')
          ..write('cor: $cor, ')
          ..write('receita: $receita')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, icone, cor, receita);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.icone == this.icone &&
          other.cor == this.cor &&
          other.receita == this.receita);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> icone;
  final Value<int> cor;
  final Value<bool> receita;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.icone = const Value.absent(),
    this.cor = const Value.absent(),
    this.receita = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required String icone,
    required int cor,
    required bool receita,
  }) : nome = Value(nome),
       icone = Value(icone),
       cor = Value(cor),
       receita = Value(receita);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? icone,
    Expression<int>? cor,
    Expression<bool>? receita,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (icone != null) 'icone': icone,
      if (cor != null) 'cor': cor,
      if (receita != null) 'receita': receita,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? icone,
    Value<int>? cor,
    Value<bool>? receita,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
      receita: receita ?? this.receita,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (icone.present) {
      map['icone'] = Variable<String>(icone.value);
    }
    if (cor.present) {
      map['cor'] = Variable<int>(cor.value);
    }
    if (receita.present) {
      map['receita'] = Variable<bool>(receita.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('icone: $icone, ')
          ..write('cor: $cor, ')
          ..write('receita: $receita')
          ..write(')'))
        .toString();
  }
}

class $CartoesTable extends Cartoes with TableInfo<$CartoesTable, Cartoe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limiteMeta = const VerificationMeta('limite');
  @override
  late final GeneratedColumn<double> limite = GeneratedColumn<double>(
    'limite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechamentoMeta = const VerificationMeta(
    'fechamento',
  );
  @override
  late final GeneratedColumn<int> fechamento = GeneratedColumn<int>(
    'fechamento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vencimentoMeta = const VerificationMeta(
    'vencimento',
  );
  @override
  late final GeneratedColumn<int> vencimento = GeneratedColumn<int>(
    'vencimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    limite,
    fechamento,
    vencimento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cartoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cartoe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('limite')) {
      context.handle(
        _limiteMeta,
        limite.isAcceptableOrUnknown(data['limite']!, _limiteMeta),
      );
    } else if (isInserting) {
      context.missing(_limiteMeta);
    }
    if (data.containsKey('fechamento')) {
      context.handle(
        _fechamentoMeta,
        fechamento.isAcceptableOrUnknown(data['fechamento']!, _fechamentoMeta),
      );
    } else if (isInserting) {
      context.missing(_fechamentoMeta);
    }
    if (data.containsKey('vencimento')) {
      context.handle(
        _vencimentoMeta,
        vencimento.isAcceptableOrUnknown(data['vencimento']!, _vencimentoMeta),
      );
    } else if (isInserting) {
      context.missing(_vencimentoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cartoe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cartoe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      limite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}limite'],
      )!,
      fechamento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fechamento'],
      )!,
      vencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vencimento'],
      )!,
    );
  }

  @override
  $CartoesTable createAlias(String alias) {
    return $CartoesTable(attachedDatabase, alias);
  }
}

class Cartoe extends DataClass implements Insertable<Cartoe> {
  final int id;
  final String nome;
  final double limite;
  final int fechamento;
  final int vencimento;
  const Cartoe({
    required this.id,
    required this.nome,
    required this.limite,
    required this.fechamento,
    required this.vencimento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['limite'] = Variable<double>(limite);
    map['fechamento'] = Variable<int>(fechamento);
    map['vencimento'] = Variable<int>(vencimento);
    return map;
  }

  CartoesCompanion toCompanion(bool nullToAbsent) {
    return CartoesCompanion(
      id: Value(id),
      nome: Value(nome),
      limite: Value(limite),
      fechamento: Value(fechamento),
      vencimento: Value(vencimento),
    );
  }

  factory Cartoe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cartoe(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      limite: serializer.fromJson<double>(json['limite']),
      fechamento: serializer.fromJson<int>(json['fechamento']),
      vencimento: serializer.fromJson<int>(json['vencimento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'limite': serializer.toJson<double>(limite),
      'fechamento': serializer.toJson<int>(fechamento),
      'vencimento': serializer.toJson<int>(vencimento),
    };
  }

  Cartoe copyWith({
    int? id,
    String? nome,
    double? limite,
    int? fechamento,
    int? vencimento,
  }) => Cartoe(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    limite: limite ?? this.limite,
    fechamento: fechamento ?? this.fechamento,
    vencimento: vencimento ?? this.vencimento,
  );
  Cartoe copyWithCompanion(CartoesCompanion data) {
    return Cartoe(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      limite: data.limite.present ? data.limite.value : this.limite,
      fechamento: data.fechamento.present
          ? data.fechamento.value
          : this.fechamento,
      vencimento: data.vencimento.present
          ? data.vencimento.value
          : this.vencimento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cartoe(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('limite: $limite, ')
          ..write('fechamento: $fechamento, ')
          ..write('vencimento: $vencimento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, limite, fechamento, vencimento);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cartoe &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.limite == this.limite &&
          other.fechamento == this.fechamento &&
          other.vencimento == this.vencimento);
}

class CartoesCompanion extends UpdateCompanion<Cartoe> {
  final Value<int> id;
  final Value<String> nome;
  final Value<double> limite;
  final Value<int> fechamento;
  final Value<int> vencimento;
  const CartoesCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.limite = const Value.absent(),
    this.fechamento = const Value.absent(),
    this.vencimento = const Value.absent(),
  });
  CartoesCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required double limite,
    required int fechamento,
    required int vencimento,
  }) : nome = Value(nome),
       limite = Value(limite),
       fechamento = Value(fechamento),
       vencimento = Value(vencimento);
  static Insertable<Cartoe> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<double>? limite,
    Expression<int>? fechamento,
    Expression<int>? vencimento,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (limite != null) 'limite': limite,
      if (fechamento != null) 'fechamento': fechamento,
      if (vencimento != null) 'vencimento': vencimento,
    });
  }

  CartoesCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<double>? limite,
    Value<int>? fechamento,
    Value<int>? vencimento,
  }) {
    return CartoesCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      limite: limite ?? this.limite,
      fechamento: fechamento ?? this.fechamento,
      vencimento: vencimento ?? this.vencimento,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (limite.present) {
      map['limite'] = Variable<double>(limite.value);
    }
    if (fechamento.present) {
      map['fechamento'] = Variable<int>(fechamento.value);
    }
    if (vencimento.present) {
      map['vencimento'] = Variable<int>(vencimento.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartoesCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('limite: $limite, ')
          ..write('fechamento: $fechamento, ')
          ..write('vencimento: $vencimento')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContasTable contas = $ContasTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $CartoesTable cartoes = $CartoesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contas,
    categorias,
    cartoes,
  ];
}

typedef $$ContasTableCreateCompanionBuilder =
    ContasCompanion Function({
      Value<int> id,
      required String nome,
      required double saldoInicial,
      required String tipo,
    });
typedef $$ContasTableUpdateCompanionBuilder =
    ContasCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<double> saldoInicial,
      Value<String> tipo,
    });

class $$ContasTableFilterComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContasTableOrderingComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<double> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);
}

class $$ContasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContasTable,
          Conta,
          $$ContasTableFilterComposer,
          $$ContasTableOrderingComposer,
          $$ContasTableAnnotationComposer,
          $$ContasTableCreateCompanionBuilder,
          $$ContasTableUpdateCompanionBuilder,
          (Conta, BaseReferences<_$AppDatabase, $ContasTable, Conta>),
          Conta,
          PrefetchHooks Function()
        > {
  $$ContasTableTableManager(_$AppDatabase db, $ContasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<double> saldoInicial = const Value.absent(),
                Value<String> tipo = const Value.absent(),
              }) => ContasCompanion(
                id: id,
                nome: nome,
                saldoInicial: saldoInicial,
                tipo: tipo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required double saldoInicial,
                required String tipo,
              }) => ContasCompanion.insert(
                id: id,
                nome: nome,
                saldoInicial: saldoInicial,
                tipo: tipo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContasTable,
      Conta,
      $$ContasTableFilterComposer,
      $$ContasTableOrderingComposer,
      $$ContasTableAnnotationComposer,
      $$ContasTableCreateCompanionBuilder,
      $$ContasTableUpdateCompanionBuilder,
      (Conta, BaseReferences<_$AppDatabase, $ContasTable, Conta>),
      Conta,
      PrefetchHooks Function()
    >;
typedef $$CategoriasTableCreateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      required String nome,
      required String icone,
      required int cor,
      required bool receita,
    });
typedef $$CategoriasTableUpdateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<String> icone,
      Value<int> cor,
      Value<bool> receita,
    });

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get receita => $composableBuilder(
    column: $table.receita,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cor => $composableBuilder(
    column: $table.cor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get receita => $composableBuilder(
    column: $table.receita,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get icone =>
      $composableBuilder(column: $table.icone, builder: (column) => column);

  GeneratedColumn<int> get cor =>
      $composableBuilder(column: $table.cor, builder: (column) => column);

  GeneratedColumn<bool> get receita =>
      $composableBuilder(column: $table.receita, builder: (column) => column);
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (
            Categoria,
            BaseReferences<_$AppDatabase, $CategoriasTable, Categoria>,
          ),
          Categoria,
          PrefetchHooks Function()
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> icone = const Value.absent(),
                Value<int> cor = const Value.absent(),
                Value<bool> receita = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nome: nome,
                icone: icone,
                cor: cor,
                receita: receita,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required String icone,
                required int cor,
                required bool receita,
              }) => CategoriasCompanion.insert(
                id: id,
                nome: nome,
                icone: icone,
                cor: cor,
                receita: receita,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, BaseReferences<_$AppDatabase, $CategoriasTable, Categoria>),
      Categoria,
      PrefetchHooks Function()
    >;
typedef $$CartoesTableCreateCompanionBuilder =
    CartoesCompanion Function({
      Value<int> id,
      required String nome,
      required double limite,
      required int fechamento,
      required int vencimento,
    });
typedef $$CartoesTableUpdateCompanionBuilder =
    CartoesCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<double> limite,
      Value<int> fechamento,
      Value<int> vencimento,
    });

class $$CartoesTableFilterComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechamento => $composableBuilder(
    column: $table.fechamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CartoesTableOrderingComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get limite => $composableBuilder(
    column: $table.limite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechamento => $composableBuilder(
    column: $table.fechamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<double> get limite =>
      $composableBuilder(column: $table.limite, builder: (column) => column);

  GeneratedColumn<int> get fechamento => $composableBuilder(
    column: $table.fechamento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vencimento => $composableBuilder(
    column: $table.vencimento,
    builder: (column) => column,
  );
}

class $$CartoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartoesTable,
          Cartoe,
          $$CartoesTableFilterComposer,
          $$CartoesTableOrderingComposer,
          $$CartoesTableAnnotationComposer,
          $$CartoesTableCreateCompanionBuilder,
          $$CartoesTableUpdateCompanionBuilder,
          (Cartoe, BaseReferences<_$AppDatabase, $CartoesTable, Cartoe>),
          Cartoe,
          PrefetchHooks Function()
        > {
  $$CartoesTableTableManager(_$AppDatabase db, $CartoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<double> limite = const Value.absent(),
                Value<int> fechamento = const Value.absent(),
                Value<int> vencimento = const Value.absent(),
              }) => CartoesCompanion(
                id: id,
                nome: nome,
                limite: limite,
                fechamento: fechamento,
                vencimento: vencimento,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required double limite,
                required int fechamento,
                required int vencimento,
              }) => CartoesCompanion.insert(
                id: id,
                nome: nome,
                limite: limite,
                fechamento: fechamento,
                vencimento: vencimento,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CartoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartoesTable,
      Cartoe,
      $$CartoesTableFilterComposer,
      $$CartoesTableOrderingComposer,
      $$CartoesTableAnnotationComposer,
      $$CartoesTableCreateCompanionBuilder,
      $$CartoesTableUpdateCompanionBuilder,
      (Cartoe, BaseReferences<_$AppDatabase, $CartoesTable, Cartoe>),
      Cartoe,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContasTableTableManager get contas =>
      $$ContasTableTableManager(_db, _db.contas);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$CartoesTableTableManager get cartoes =>
      $$CartoesTableTableManager(_db, _db.cartoes);
}
