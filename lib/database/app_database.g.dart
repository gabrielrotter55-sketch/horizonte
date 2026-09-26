// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

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

class $LancamentosTable extends Lancamentos
    with TableInfo<$LancamentosTable, Lancamento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LancamentosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  @override
  late final GeneratedColumn<int> contaId = GeneratedColumn<int>(
    'conta_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    descricao,
    valor,
    receita,
    data,
    categoriaId,
    contaId,
    cartaoId,
    origem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lancamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lancamento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('receita')) {
      context.handle(
        _receitaMeta,
        receita.isAcceptableOrUnknown(data['receita']!, _receitaMeta),
      );
    } else if (isInserting) {
      context.missing(_receitaMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lancamento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lancamento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      receita: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}receita'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_id'],
      ),
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      ),
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      )!,
    );
  }

  @override
  $LancamentosTable createAlias(String alias) {
    return $LancamentosTable(attachedDatabase, alias);
  }
}

class Lancamento extends DataClass implements Insertable<Lancamento> {
  final int id;
  final String descricao;
  final double valor;
  final bool receita;
  final DateTime data;
  final int categoriaId;
  final int? contaId;
  final int? cartaoId;
  final String origem;
  const Lancamento({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.receita,
    required this.data,
    required this.categoriaId,
    this.contaId,
    this.cartaoId,
    required this.origem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descricao'] = Variable<String>(descricao);
    map['valor'] = Variable<double>(valor);
    map['receita'] = Variable<bool>(receita);
    map['data'] = Variable<DateTime>(data);
    map['categoria_id'] = Variable<int>(categoriaId);
    if (!nullToAbsent || contaId != null) {
      map['conta_id'] = Variable<int>(contaId);
    }
    if (!nullToAbsent || cartaoId != null) {
      map['cartao_id'] = Variable<int>(cartaoId);
    }
    map['origem'] = Variable<String>(origem);
    return map;
  }

  LancamentosCompanion toCompanion(bool nullToAbsent) {
    return LancamentosCompanion(
      id: Value(id),
      descricao: Value(descricao),
      valor: Value(valor),
      receita: Value(receita),
      data: Value(data),
      categoriaId: Value(categoriaId),
      contaId: contaId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaId),
      cartaoId: cartaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cartaoId),
      origem: Value(origem),
    );
  }

  factory Lancamento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lancamento(
      id: serializer.fromJson<int>(json['id']),
      descricao: serializer.fromJson<String>(json['descricao']),
      valor: serializer.fromJson<double>(json['valor']),
      receita: serializer.fromJson<bool>(json['receita']),
      data: serializer.fromJson<DateTime>(json['data']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      contaId: serializer.fromJson<int?>(json['contaId']),
      cartaoId: serializer.fromJson<int?>(json['cartaoId']),
      origem: serializer.fromJson<String>(json['origem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descricao': serializer.toJson<String>(descricao),
      'valor': serializer.toJson<double>(valor),
      'receita': serializer.toJson<bool>(receita),
      'data': serializer.toJson<DateTime>(data),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'contaId': serializer.toJson<int?>(contaId),
      'cartaoId': serializer.toJson<int?>(cartaoId),
      'origem': serializer.toJson<String>(origem),
    };
  }

  Lancamento copyWith({
    int? id,
    String? descricao,
    double? valor,
    bool? receita,
    DateTime? data,
    int? categoriaId,
    Value<int?> contaId = const Value.absent(),
    Value<int?> cartaoId = const Value.absent(),
    String? origem,
  }) => Lancamento(
    id: id ?? this.id,
    descricao: descricao ?? this.descricao,
    valor: valor ?? this.valor,
    receita: receita ?? this.receita,
    data: data ?? this.data,
    categoriaId: categoriaId ?? this.categoriaId,
    contaId: contaId.present ? contaId.value : this.contaId,
    cartaoId: cartaoId.present ? cartaoId.value : this.cartaoId,
    origem: origem ?? this.origem,
  );
  Lancamento copyWithCompanion(LancamentosCompanion data) {
    return Lancamento(
      id: data.id.present ? data.id.value : this.id,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      valor: data.valor.present ? data.valor.value : this.valor,
      receita: data.receita.present ? data.receita.value : this.receita,
      data: data.data.present ? data.data.value : this.data,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      origem: data.origem.present ? data.origem.value : this.origem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lancamento(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor, ')
          ..write('receita: $receita, ')
          ..write('data: $data, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('contaId: $contaId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('origem: $origem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    descricao,
    valor,
    receita,
    data,
    categoriaId,
    contaId,
    cartaoId,
    origem,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lancamento &&
          other.id == this.id &&
          other.descricao == this.descricao &&
          other.valor == this.valor &&
          other.receita == this.receita &&
          other.data == this.data &&
          other.categoriaId == this.categoriaId &&
          other.contaId == this.contaId &&
          other.cartaoId == this.cartaoId &&
          other.origem == this.origem);
}

class LancamentosCompanion extends UpdateCompanion<Lancamento> {
  final Value<int> id;
  final Value<String> descricao;
  final Value<double> valor;
  final Value<bool> receita;
  final Value<DateTime> data;
  final Value<int> categoriaId;
  final Value<int?> contaId;
  final Value<int?> cartaoId;
  final Value<String> origem;
  const LancamentosCompanion({
    this.id = const Value.absent(),
    this.descricao = const Value.absent(),
    this.valor = const Value.absent(),
    this.receita = const Value.absent(),
    this.data = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.contaId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.origem = const Value.absent(),
  });
  LancamentosCompanion.insert({
    this.id = const Value.absent(),
    required String descricao,
    required double valor,
    required bool receita,
    required DateTime data,
    required int categoriaId,
    this.contaId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.origem = const Value.absent(),
  }) : descricao = Value(descricao),
       valor = Value(valor),
       receita = Value(receita),
       data = Value(data),
       categoriaId = Value(categoriaId);
  static Insertable<Lancamento> custom({
    Expression<int>? id,
    Expression<String>? descricao,
    Expression<double>? valor,
    Expression<bool>? receita,
    Expression<DateTime>? data,
    Expression<int>? categoriaId,
    Expression<int>? contaId,
    Expression<int>? cartaoId,
    Expression<String>? origem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descricao != null) 'descricao': descricao,
      if (valor != null) 'valor': valor,
      if (receita != null) 'receita': receita,
      if (data != null) 'data': data,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (contaId != null) 'conta_id': contaId,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (origem != null) 'origem': origem,
    });
  }

  LancamentosCompanion copyWith({
    Value<int>? id,
    Value<String>? descricao,
    Value<double>? valor,
    Value<bool>? receita,
    Value<DateTime>? data,
    Value<int>? categoriaId,
    Value<int?>? contaId,
    Value<int?>? cartaoId,
    Value<String>? origem,
  }) {
    return LancamentosCompanion(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      receita: receita ?? this.receita,
      data: data ?? this.data,
      categoriaId: categoriaId ?? this.categoriaId,
      contaId: contaId ?? this.contaId,
      cartaoId: cartaoId ?? this.cartaoId,
      origem: origem ?? this.origem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (receita.present) {
      map['receita'] = Variable<bool>(receita.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (contaId.present) {
      map['conta_id'] = Variable<int>(contaId.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LancamentosCompanion(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor, ')
          ..write('receita: $receita, ')
          ..write('data: $data, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('contaId: $contaId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('origem: $origem')
          ..write(')'))
        .toString();
  }
}

class $FaturasTable extends Faturas with TableInfo<$FaturasTable, Fatura> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaturasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mesReferenciaMeta = const VerificationMeta(
    'mesReferencia',
  );
  @override
  late final GeneratedColumn<int> mesReferencia = GeneratedColumn<int>(
    'mes_referencia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anoReferenciaMeta = const VerificationMeta(
    'anoReferencia',
  );
  @override
  late final GeneratedColumn<int> anoReferencia = GeneratedColumn<int>(
    'ano_referencia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagaMeta = const VerificationMeta('paga');
  @override
  late final GeneratedColumn<bool> paga = GeneratedColumn<bool>(
    'paga',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paga" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dataPagamentoMeta = const VerificationMeta(
    'dataPagamento',
  );
  @override
  late final GeneratedColumn<DateTime> dataPagamento =
      GeneratedColumn<DateTime>(
        'data_pagamento',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cartaoId,
    mesReferencia,
    anoReferencia,
    paga,
    dataPagamento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faturas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fatura> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartaoIdMeta);
    }
    if (data.containsKey('mes_referencia')) {
      context.handle(
        _mesReferenciaMeta,
        mesReferencia.isAcceptableOrUnknown(
          data['mes_referencia']!,
          _mesReferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mesReferenciaMeta);
    }
    if (data.containsKey('ano_referencia')) {
      context.handle(
        _anoReferenciaMeta,
        anoReferencia.isAcceptableOrUnknown(
          data['ano_referencia']!,
          _anoReferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anoReferenciaMeta);
    }
    if (data.containsKey('paga')) {
      context.handle(
        _pagaMeta,
        paga.isAcceptableOrUnknown(data['paga']!, _pagaMeta),
      );
    }
    if (data.containsKey('data_pagamento')) {
      context.handle(
        _dataPagamentoMeta,
        dataPagamento.isAcceptableOrUnknown(
          data['data_pagamento']!,
          _dataPagamentoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fatura map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fatura(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      )!,
      mesReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mes_referencia'],
      )!,
      anoReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ano_referencia'],
      )!,
      paga: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paga'],
      )!,
      dataPagamento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_pagamento'],
      ),
    );
  }

  @override
  $FaturasTable createAlias(String alias) {
    return $FaturasTable(attachedDatabase, alias);
  }
}

class Fatura extends DataClass implements Insertable<Fatura> {
  final int id;
  final int cartaoId;
  final int mesReferencia;
  final int anoReferencia;
  final bool paga;
  final DateTime? dataPagamento;
  const Fatura({
    required this.id,
    required this.cartaoId,
    required this.mesReferencia,
    required this.anoReferencia,
    required this.paga,
    this.dataPagamento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cartao_id'] = Variable<int>(cartaoId);
    map['mes_referencia'] = Variable<int>(mesReferencia);
    map['ano_referencia'] = Variable<int>(anoReferencia);
    map['paga'] = Variable<bool>(paga);
    if (!nullToAbsent || dataPagamento != null) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento);
    }
    return map;
  }

  FaturasCompanion toCompanion(bool nullToAbsent) {
    return FaturasCompanion(
      id: Value(id),
      cartaoId: Value(cartaoId),
      mesReferencia: Value(mesReferencia),
      anoReferencia: Value(anoReferencia),
      paga: Value(paga),
      dataPagamento: dataPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(dataPagamento),
    );
  }

  factory Fatura.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fatura(
      id: serializer.fromJson<int>(json['id']),
      cartaoId: serializer.fromJson<int>(json['cartaoId']),
      mesReferencia: serializer.fromJson<int>(json['mesReferencia']),
      anoReferencia: serializer.fromJson<int>(json['anoReferencia']),
      paga: serializer.fromJson<bool>(json['paga']),
      dataPagamento: serializer.fromJson<DateTime?>(json['dataPagamento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cartaoId': serializer.toJson<int>(cartaoId),
      'mesReferencia': serializer.toJson<int>(mesReferencia),
      'anoReferencia': serializer.toJson<int>(anoReferencia),
      'paga': serializer.toJson<bool>(paga),
      'dataPagamento': serializer.toJson<DateTime?>(dataPagamento),
    };
  }

  Fatura copyWith({
    int? id,
    int? cartaoId,
    int? mesReferencia,
    int? anoReferencia,
    bool? paga,
    Value<DateTime?> dataPagamento = const Value.absent(),
  }) => Fatura(
    id: id ?? this.id,
    cartaoId: cartaoId ?? this.cartaoId,
    mesReferencia: mesReferencia ?? this.mesReferencia,
    anoReferencia: anoReferencia ?? this.anoReferencia,
    paga: paga ?? this.paga,
    dataPagamento: dataPagamento.present
        ? dataPagamento.value
        : this.dataPagamento,
  );
  Fatura copyWithCompanion(FaturasCompanion data) {
    return Fatura(
      id: data.id.present ? data.id.value : this.id,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      mesReferencia: data.mesReferencia.present
          ? data.mesReferencia.value
          : this.mesReferencia,
      anoReferencia: data.anoReferencia.present
          ? data.anoReferencia.value
          : this.anoReferencia,
      paga: data.paga.present ? data.paga.value : this.paga,
      dataPagamento: data.dataPagamento.present
          ? data.dataPagamento.value
          : this.dataPagamento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fatura(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('anoReferencia: $anoReferencia, ')
          ..write('paga: $paga, ')
          ..write('dataPagamento: $dataPagamento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cartaoId,
    mesReferencia,
    anoReferencia,
    paga,
    dataPagamento,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fatura &&
          other.id == this.id &&
          other.cartaoId == this.cartaoId &&
          other.mesReferencia == this.mesReferencia &&
          other.anoReferencia == this.anoReferencia &&
          other.paga == this.paga &&
          other.dataPagamento == this.dataPagamento);
}

class FaturasCompanion extends UpdateCompanion<Fatura> {
  final Value<int> id;
  final Value<int> cartaoId;
  final Value<int> mesReferencia;
  final Value<int> anoReferencia;
  final Value<bool> paga;
  final Value<DateTime?> dataPagamento;
  const FaturasCompanion({
    this.id = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.mesReferencia = const Value.absent(),
    this.anoReferencia = const Value.absent(),
    this.paga = const Value.absent(),
    this.dataPagamento = const Value.absent(),
  });
  FaturasCompanion.insert({
    this.id = const Value.absent(),
    required int cartaoId,
    required int mesReferencia,
    required int anoReferencia,
    this.paga = const Value.absent(),
    this.dataPagamento = const Value.absent(),
  }) : cartaoId = Value(cartaoId),
       mesReferencia = Value(mesReferencia),
       anoReferencia = Value(anoReferencia);
  static Insertable<Fatura> custom({
    Expression<int>? id,
    Expression<int>? cartaoId,
    Expression<int>? mesReferencia,
    Expression<int>? anoReferencia,
    Expression<bool>? paga,
    Expression<DateTime>? dataPagamento,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (mesReferencia != null) 'mes_referencia': mesReferencia,
      if (anoReferencia != null) 'ano_referencia': anoReferencia,
      if (paga != null) 'paga': paga,
      if (dataPagamento != null) 'data_pagamento': dataPagamento,
    });
  }

  FaturasCompanion copyWith({
    Value<int>? id,
    Value<int>? cartaoId,
    Value<int>? mesReferencia,
    Value<int>? anoReferencia,
    Value<bool>? paga,
    Value<DateTime?>? dataPagamento,
  }) {
    return FaturasCompanion(
      id: id ?? this.id,
      cartaoId: cartaoId ?? this.cartaoId,
      mesReferencia: mesReferencia ?? this.mesReferencia,
      anoReferencia: anoReferencia ?? this.anoReferencia,
      paga: paga ?? this.paga,
      dataPagamento: dataPagamento ?? this.dataPagamento,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (mesReferencia.present) {
      map['mes_referencia'] = Variable<int>(mesReferencia.value);
    }
    if (anoReferencia.present) {
      map['ano_referencia'] = Variable<int>(anoReferencia.value);
    }
    if (paga.present) {
      map['paga'] = Variable<bool>(paga.value);
    }
    if (dataPagamento.present) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaturasCompanion(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('anoReferencia: $anoReferencia, ')
          ..write('paga: $paga, ')
          ..write('dataPagamento: $dataPagamento')
          ..write(')'))
        .toString();
  }
}

class $PagamentosFaturasTable extends PagamentosFaturas
    with TableInfo<$PagamentosFaturasTable, PagamentosFatura> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagamentosFaturasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _faturaIdMeta = const VerificationMeta(
    'faturaId',
  );
  @override
  late final GeneratedColumn<int> faturaId = GeneratedColumn<int>(
    'fatura_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  @override
  late final GeneratedColumn<int> contaId = GeneratedColumn<int>(
    'conta_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, faturaId, contaId, valor, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagamentos_faturas';
  @override
  VerificationContext validateIntegrity(
    Insertable<PagamentosFatura> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fatura_id')) {
      context.handle(
        _faturaIdMeta,
        faturaId.isAcceptableOrUnknown(data['fatura_id']!, _faturaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_faturaIdMeta);
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PagamentosFatura map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PagamentosFatura(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      faturaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatura_id'],
      )!,
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_id'],
      ),
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $PagamentosFaturasTable createAlias(String alias) {
    return $PagamentosFaturasTable(attachedDatabase, alias);
  }
}

class PagamentosFatura extends DataClass
    implements Insertable<PagamentosFatura> {
  final int id;
  final int faturaId;
  final int? contaId;
  final double valor;
  final DateTime data;
  const PagamentosFatura({
    required this.id,
    required this.faturaId,
    this.contaId,
    required this.valor,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fatura_id'] = Variable<int>(faturaId);
    if (!nullToAbsent || contaId != null) {
      map['conta_id'] = Variable<int>(contaId);
    }
    map['valor'] = Variable<double>(valor);
    map['data'] = Variable<DateTime>(data);
    return map;
  }

  PagamentosFaturasCompanion toCompanion(bool nullToAbsent) {
    return PagamentosFaturasCompanion(
      id: Value(id),
      faturaId: Value(faturaId),
      contaId: contaId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaId),
      valor: Value(valor),
      data: Value(data),
    );
  }

  factory PagamentosFatura.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PagamentosFatura(
      id: serializer.fromJson<int>(json['id']),
      faturaId: serializer.fromJson<int>(json['faturaId']),
      contaId: serializer.fromJson<int?>(json['contaId']),
      valor: serializer.fromJson<double>(json['valor']),
      data: serializer.fromJson<DateTime>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'faturaId': serializer.toJson<int>(faturaId),
      'contaId': serializer.toJson<int?>(contaId),
      'valor': serializer.toJson<double>(valor),
      'data': serializer.toJson<DateTime>(data),
    };
  }

  PagamentosFatura copyWith({
    int? id,
    int? faturaId,
    Value<int?> contaId = const Value.absent(),
    double? valor,
    DateTime? data,
  }) => PagamentosFatura(
    id: id ?? this.id,
    faturaId: faturaId ?? this.faturaId,
    contaId: contaId.present ? contaId.value : this.contaId,
    valor: valor ?? this.valor,
    data: data ?? this.data,
  );
  PagamentosFatura copyWithCompanion(PagamentosFaturasCompanion data) {
    return PagamentosFatura(
      id: data.id.present ? data.id.value : this.id,
      faturaId: data.faturaId.present ? data.faturaId.value : this.faturaId,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
      valor: data.valor.present ? data.valor.value : this.valor,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PagamentosFatura(')
          ..write('id: $id, ')
          ..write('faturaId: $faturaId, ')
          ..write('contaId: $contaId, ')
          ..write('valor: $valor, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, faturaId, contaId, valor, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PagamentosFatura &&
          other.id == this.id &&
          other.faturaId == this.faturaId &&
          other.contaId == this.contaId &&
          other.valor == this.valor &&
          other.data == this.data);
}

class PagamentosFaturasCompanion extends UpdateCompanion<PagamentosFatura> {
  final Value<int> id;
  final Value<int> faturaId;
  final Value<int?> contaId;
  final Value<double> valor;
  final Value<DateTime> data;
  const PagamentosFaturasCompanion({
    this.id = const Value.absent(),
    this.faturaId = const Value.absent(),
    this.contaId = const Value.absent(),
    this.valor = const Value.absent(),
    this.data = const Value.absent(),
  });
  PagamentosFaturasCompanion.insert({
    this.id = const Value.absent(),
    required int faturaId,
    this.contaId = const Value.absent(),
    required double valor,
    required DateTime data,
  }) : faturaId = Value(faturaId),
       valor = Value(valor),
       data = Value(data);
  static Insertable<PagamentosFatura> custom({
    Expression<int>? id,
    Expression<int>? faturaId,
    Expression<int>? contaId,
    Expression<double>? valor,
    Expression<DateTime>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (faturaId != null) 'fatura_id': faturaId,
      if (contaId != null) 'conta_id': contaId,
      if (valor != null) 'valor': valor,
      if (data != null) 'data': data,
    });
  }

  PagamentosFaturasCompanion copyWith({
    Value<int>? id,
    Value<int>? faturaId,
    Value<int?>? contaId,
    Value<double>? valor,
    Value<DateTime>? data,
  }) {
    return PagamentosFaturasCompanion(
      id: id ?? this.id,
      faturaId: faturaId ?? this.faturaId,
      contaId: contaId ?? this.contaId,
      valor: valor ?? this.valor,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (faturaId.present) {
      map['fatura_id'] = Variable<int>(faturaId.value);
    }
    if (contaId.present) {
      map['conta_id'] = Variable<int>(contaId.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagamentosFaturasCompanion(')
          ..write('id: $id, ')
          ..write('faturaId: $faturaId, ')
          ..write('contaId: $contaId, ')
          ..write('valor: $valor, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $TransferenciasTable extends Transferencias
    with TableInfo<$TransferenciasTable, Transferencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransferenciasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contaOrigemIdMeta = const VerificationMeta(
    'contaOrigemId',
  );
  @override
  late final GeneratedColumn<int> contaOrigemId = GeneratedColumn<int>(
    'conta_origem_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contaDestinoIdMeta = const VerificationMeta(
    'contaDestinoId',
  );
  @override
  late final GeneratedColumn<int> contaDestinoId = GeneratedColumn<int>(
    'conta_destino_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contaOrigemId,
    contaDestinoId,
    valor,
    data,
    descricao,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transferencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transferencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conta_origem_id')) {
      context.handle(
        _contaOrigemIdMeta,
        contaOrigemId.isAcceptableOrUnknown(
          data['conta_origem_id']!,
          _contaOrigemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contaOrigemIdMeta);
    }
    if (data.containsKey('conta_destino_id')) {
      context.handle(
        _contaDestinoIdMeta,
        contaDestinoId.isAcceptableOrUnknown(
          data['conta_destino_id']!,
          _contaDestinoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contaDestinoIdMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transferencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transferencia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contaOrigemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_origem_id'],
      )!,
      contaDestinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_destino_id'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
    );
  }

  @override
  $TransferenciasTable createAlias(String alias) {
    return $TransferenciasTable(attachedDatabase, alias);
  }
}

class Transferencia extends DataClass implements Insertable<Transferencia> {
  final int id;
  final int contaOrigemId;
  final int contaDestinoId;
  final double valor;
  final DateTime data;
  final String descricao;
  const Transferencia({
    required this.id,
    required this.contaOrigemId,
    required this.contaDestinoId,
    required this.valor,
    required this.data,
    required this.descricao,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conta_origem_id'] = Variable<int>(contaOrigemId);
    map['conta_destino_id'] = Variable<int>(contaDestinoId);
    map['valor'] = Variable<double>(valor);
    map['data'] = Variable<DateTime>(data);
    map['descricao'] = Variable<String>(descricao);
    return map;
  }

  TransferenciasCompanion toCompanion(bool nullToAbsent) {
    return TransferenciasCompanion(
      id: Value(id),
      contaOrigemId: Value(contaOrigemId),
      contaDestinoId: Value(contaDestinoId),
      valor: Value(valor),
      data: Value(data),
      descricao: Value(descricao),
    );
  }

  factory Transferencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transferencia(
      id: serializer.fromJson<int>(json['id']),
      contaOrigemId: serializer.fromJson<int>(json['contaOrigemId']),
      contaDestinoId: serializer.fromJson<int>(json['contaDestinoId']),
      valor: serializer.fromJson<double>(json['valor']),
      data: serializer.fromJson<DateTime>(json['data']),
      descricao: serializer.fromJson<String>(json['descricao']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contaOrigemId': serializer.toJson<int>(contaOrigemId),
      'contaDestinoId': serializer.toJson<int>(contaDestinoId),
      'valor': serializer.toJson<double>(valor),
      'data': serializer.toJson<DateTime>(data),
      'descricao': serializer.toJson<String>(descricao),
    };
  }

  Transferencia copyWith({
    int? id,
    int? contaOrigemId,
    int? contaDestinoId,
    double? valor,
    DateTime? data,
    String? descricao,
  }) => Transferencia(
    id: id ?? this.id,
    contaOrigemId: contaOrigemId ?? this.contaOrigemId,
    contaDestinoId: contaDestinoId ?? this.contaDestinoId,
    valor: valor ?? this.valor,
    data: data ?? this.data,
    descricao: descricao ?? this.descricao,
  );
  Transferencia copyWithCompanion(TransferenciasCompanion data) {
    return Transferencia(
      id: data.id.present ? data.id.value : this.id,
      contaOrigemId: data.contaOrigemId.present
          ? data.contaOrigemId.value
          : this.contaOrigemId,
      contaDestinoId: data.contaDestinoId.present
          ? data.contaDestinoId.value
          : this.contaDestinoId,
      valor: data.valor.present ? data.valor.value : this.valor,
      data: data.data.present ? data.data.value : this.data,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transferencia(')
          ..write('id: $id, ')
          ..write('contaOrigemId: $contaOrigemId, ')
          ..write('contaDestinoId: $contaDestinoId, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('descricao: $descricao')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contaOrigemId, contaDestinoId, valor, data, descricao);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transferencia &&
          other.id == this.id &&
          other.contaOrigemId == this.contaOrigemId &&
          other.contaDestinoId == this.contaDestinoId &&
          other.valor == this.valor &&
          other.data == this.data &&
          other.descricao == this.descricao);
}

class TransferenciasCompanion extends UpdateCompanion<Transferencia> {
  final Value<int> id;
  final Value<int> contaOrigemId;
  final Value<int> contaDestinoId;
  final Value<double> valor;
  final Value<DateTime> data;
  final Value<String> descricao;
  const TransferenciasCompanion({
    this.id = const Value.absent(),
    this.contaOrigemId = const Value.absent(),
    this.contaDestinoId = const Value.absent(),
    this.valor = const Value.absent(),
    this.data = const Value.absent(),
    this.descricao = const Value.absent(),
  });
  TransferenciasCompanion.insert({
    this.id = const Value.absent(),
    required int contaOrigemId,
    required int contaDestinoId,
    required double valor,
    required DateTime data,
    required String descricao,
  }) : contaOrigemId = Value(contaOrigemId),
       contaDestinoId = Value(contaDestinoId),
       valor = Value(valor),
       data = Value(data),
       descricao = Value(descricao);
  static Insertable<Transferencia> custom({
    Expression<int>? id,
    Expression<int>? contaOrigemId,
    Expression<int>? contaDestinoId,
    Expression<double>? valor,
    Expression<DateTime>? data,
    Expression<String>? descricao,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contaOrigemId != null) 'conta_origem_id': contaOrigemId,
      if (contaDestinoId != null) 'conta_destino_id': contaDestinoId,
      if (valor != null) 'valor': valor,
      if (data != null) 'data': data,
      if (descricao != null) 'descricao': descricao,
    });
  }

  TransferenciasCompanion copyWith({
    Value<int>? id,
    Value<int>? contaOrigemId,
    Value<int>? contaDestinoId,
    Value<double>? valor,
    Value<DateTime>? data,
    Value<String>? descricao,
  }) {
    return TransferenciasCompanion(
      id: id ?? this.id,
      contaOrigemId: contaOrigemId ?? this.contaOrigemId,
      contaDestinoId: contaDestinoId ?? this.contaDestinoId,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contaOrigemId.present) {
      map['conta_origem_id'] = Variable<int>(contaOrigemId.value);
    }
    if (contaDestinoId.present) {
      map['conta_destino_id'] = Variable<int>(contaDestinoId.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferenciasCompanion(')
          ..write('id: $id, ')
          ..write('contaOrigemId: $contaOrigemId, ')
          ..write('contaDestinoId: $contaDestinoId, ')
          ..write('valor: $valor, ')
          ..write('data: $data, ')
          ..write('descricao: $descricao')
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
  late final $LancamentosTable lancamentos = $LancamentosTable(this);
  late final $FaturasTable faturas = $FaturasTable(this);
  late final $PagamentosFaturasTable pagamentosFaturas =
      $PagamentosFaturasTable(this);
  late final $TransferenciasTable transferencias = $TransferenciasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contas,
    categorias,
    cartoes,
    lancamentos,
    faturas,
    pagamentosFaturas,
    transferencias,
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
              .map(
                (e) => (
                  e.readTable<$ContasTable, Conta>(table),
                  BaseReferences<_$AppDatabase, $ContasTable, Conta>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
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
              .map(
                (e) => (
                  e.readTable<$CategoriasTable, Categoria>(table),
                  BaseReferences<_$AppDatabase, $CategoriasTable, Categoria>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
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
              .map(
                (e) => (
                  e.readTable<$CartoesTable, Cartoe>(table),
                  BaseReferences<_$AppDatabase, $CartoesTable, Cartoe>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
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
typedef $$LancamentosTableCreateCompanionBuilder =
    LancamentosCompanion Function({
      Value<int> id,
      required String descricao,
      required double valor,
      required bool receita,
      required DateTime data,
      required int categoriaId,
      Value<int?> contaId,
      Value<int?> cartaoId,
      Value<String> origem,
    });
typedef $$LancamentosTableUpdateCompanionBuilder =
    LancamentosCompanion Function({
      Value<int> id,
      Value<String> descricao,
      Value<double> valor,
      Value<bool> receita,
      Value<DateTime> data,
      Value<int> categoriaId,
      Value<int?> contaId,
      Value<int?> cartaoId,
      Value<String> origem,
    });

class $$LancamentosTableFilterComposer
    extends Composer<_$AppDatabase, $LancamentosTable> {
  $$LancamentosTableFilterComposer({
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

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get receita => $composableBuilder(
    column: $table.receita,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contaId => $composableBuilder(
    column: $table.contaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LancamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $LancamentosTable> {
  $$LancamentosTableOrderingComposer({
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

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get receita => $composableBuilder(
    column: $table.receita,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contaId => $composableBuilder(
    column: $table.contaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LancamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $LancamentosTable> {
  $$LancamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<bool> get receita =>
      $composableBuilder(column: $table.receita, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contaId =>
      $composableBuilder(column: $table.contaId, builder: (column) => column);

  GeneratedColumn<int> get cartaoId =>
      $composableBuilder(column: $table.cartaoId, builder: (column) => column);

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);
}

class $$LancamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LancamentosTable,
          Lancamento,
          $$LancamentosTableFilterComposer,
          $$LancamentosTableOrderingComposer,
          $$LancamentosTableAnnotationComposer,
          $$LancamentosTableCreateCompanionBuilder,
          $$LancamentosTableUpdateCompanionBuilder,
          (
            Lancamento,
            BaseReferences<_$AppDatabase, $LancamentosTable, Lancamento>,
          ),
          Lancamento,
          PrefetchHooks Function()
        > {
  $$LancamentosTableTableManager(_$AppDatabase db, $LancamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LancamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LancamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LancamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<bool> receita = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<int?> contaId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                Value<String> origem = const Value.absent(),
              }) => LancamentosCompanion(
                id: id,
                descricao: descricao,
                valor: valor,
                receita: receita,
                data: data,
                categoriaId: categoriaId,
                contaId: contaId,
                cartaoId: cartaoId,
                origem: origem,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String descricao,
                required double valor,
                required bool receita,
                required DateTime data,
                required int categoriaId,
                Value<int?> contaId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                Value<String> origem = const Value.absent(),
              }) => LancamentosCompanion.insert(
                id: id,
                descricao: descricao,
                valor: valor,
                receita: receita,
                data: data,
                categoriaId: categoriaId,
                contaId: contaId,
                cartaoId: cartaoId,
                origem: origem,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LancamentosTable, Lancamento>(table),
                  BaseReferences<_$AppDatabase, $LancamentosTable, Lancamento>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LancamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LancamentosTable,
      Lancamento,
      $$LancamentosTableFilterComposer,
      $$LancamentosTableOrderingComposer,
      $$LancamentosTableAnnotationComposer,
      $$LancamentosTableCreateCompanionBuilder,
      $$LancamentosTableUpdateCompanionBuilder,
      (
        Lancamento,
        BaseReferences<_$AppDatabase, $LancamentosTable, Lancamento>,
      ),
      Lancamento,
      PrefetchHooks Function()
    >;
typedef $$FaturasTableCreateCompanionBuilder =
    FaturasCompanion Function({
      Value<int> id,
      required int cartaoId,
      required int mesReferencia,
      required int anoReferencia,
      Value<bool> paga,
      Value<DateTime?> dataPagamento,
    });
typedef $$FaturasTableUpdateCompanionBuilder =
    FaturasCompanion Function({
      Value<int> id,
      Value<int> cartaoId,
      Value<int> mesReferencia,
      Value<int> anoReferencia,
      Value<bool> paga,
      Value<DateTime?> dataPagamento,
    });

class $$FaturasTableFilterComposer
    extends Composer<_$AppDatabase, $FaturasTable> {
  $$FaturasTableFilterComposer({
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

  ColumnFilters<int> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anoReferencia => $composableBuilder(
    column: $table.anoReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paga => $composableBuilder(
    column: $table.paga,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FaturasTableOrderingComposer
    extends Composer<_$AppDatabase, $FaturasTable> {
  $$FaturasTableOrderingComposer({
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

  ColumnOrderings<int> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anoReferencia => $composableBuilder(
    column: $table.anoReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paga => $composableBuilder(
    column: $table.paga,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FaturasTableAnnotationComposer
    extends Composer<_$AppDatabase, $FaturasTable> {
  $$FaturasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cartaoId =>
      $composableBuilder(column: $table.cartaoId, builder: (column) => column);

  GeneratedColumn<int> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anoReferencia => $composableBuilder(
    column: $table.anoReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paga =>
      $composableBuilder(column: $table.paga, builder: (column) => column);

  GeneratedColumn<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => column,
  );
}

class $$FaturasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FaturasTable,
          Fatura,
          $$FaturasTableFilterComposer,
          $$FaturasTableOrderingComposer,
          $$FaturasTableAnnotationComposer,
          $$FaturasTableCreateCompanionBuilder,
          $$FaturasTableUpdateCompanionBuilder,
          (Fatura, BaseReferences<_$AppDatabase, $FaturasTable, Fatura>),
          Fatura,
          PrefetchHooks Function()
        > {
  $$FaturasTableTableManager(_$AppDatabase db, $FaturasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaturasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaturasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaturasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cartaoId = const Value.absent(),
                Value<int> mesReferencia = const Value.absent(),
                Value<int> anoReferencia = const Value.absent(),
                Value<bool> paga = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
              }) => FaturasCompanion(
                id: id,
                cartaoId: cartaoId,
                mesReferencia: mesReferencia,
                anoReferencia: anoReferencia,
                paga: paga,
                dataPagamento: dataPagamento,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cartaoId,
                required int mesReferencia,
                required int anoReferencia,
                Value<bool> paga = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
              }) => FaturasCompanion.insert(
                id: id,
                cartaoId: cartaoId,
                mesReferencia: mesReferencia,
                anoReferencia: anoReferencia,
                paga: paga,
                dataPagamento: dataPagamento,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FaturasTable, Fatura>(table),
                  BaseReferences<_$AppDatabase, $FaturasTable, Fatura>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FaturasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FaturasTable,
      Fatura,
      $$FaturasTableFilterComposer,
      $$FaturasTableOrderingComposer,
      $$FaturasTableAnnotationComposer,
      $$FaturasTableCreateCompanionBuilder,
      $$FaturasTableUpdateCompanionBuilder,
      (Fatura, BaseReferences<_$AppDatabase, $FaturasTable, Fatura>),
      Fatura,
      PrefetchHooks Function()
    >;
typedef $$PagamentosFaturasTableCreateCompanionBuilder =
    PagamentosFaturasCompanion Function({
      Value<int> id,
      required int faturaId,
      Value<int?> contaId,
      required double valor,
      required DateTime data,
    });
typedef $$PagamentosFaturasTableUpdateCompanionBuilder =
    PagamentosFaturasCompanion Function({
      Value<int> id,
      Value<int> faturaId,
      Value<int?> contaId,
      Value<double> valor,
      Value<DateTime> data,
    });

class $$PagamentosFaturasTableFilterComposer
    extends Composer<_$AppDatabase, $PagamentosFaturasTable> {
  $$PagamentosFaturasTableFilterComposer({
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

  ColumnFilters<int> get faturaId => $composableBuilder(
    column: $table.faturaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contaId => $composableBuilder(
    column: $table.contaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PagamentosFaturasTableOrderingComposer
    extends Composer<_$AppDatabase, $PagamentosFaturasTable> {
  $$PagamentosFaturasTableOrderingComposer({
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

  ColumnOrderings<int> get faturaId => $composableBuilder(
    column: $table.faturaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contaId => $composableBuilder(
    column: $table.contaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagamentosFaturasTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagamentosFaturasTable> {
  $$PagamentosFaturasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get faturaId =>
      $composableBuilder(column: $table.faturaId, builder: (column) => column);

  GeneratedColumn<int> get contaId =>
      $composableBuilder(column: $table.contaId, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$PagamentosFaturasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagamentosFaturasTable,
          PagamentosFatura,
          $$PagamentosFaturasTableFilterComposer,
          $$PagamentosFaturasTableOrderingComposer,
          $$PagamentosFaturasTableAnnotationComposer,
          $$PagamentosFaturasTableCreateCompanionBuilder,
          $$PagamentosFaturasTableUpdateCompanionBuilder,
          (
            PagamentosFatura,
            BaseReferences<
              _$AppDatabase,
              $PagamentosFaturasTable,
              PagamentosFatura
            >,
          ),
          PagamentosFatura,
          PrefetchHooks Function()
        > {
  $$PagamentosFaturasTableTableManager(
    _$AppDatabase db,
    $PagamentosFaturasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagamentosFaturasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagamentosFaturasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagamentosFaturasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> faturaId = const Value.absent(),
                Value<int?> contaId = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
              }) => PagamentosFaturasCompanion(
                id: id,
                faturaId: faturaId,
                contaId: contaId,
                valor: valor,
                data: data,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int faturaId,
                Value<int?> contaId = const Value.absent(),
                required double valor,
                required DateTime data,
              }) => PagamentosFaturasCompanion.insert(
                id: id,
                faturaId: faturaId,
                contaId: contaId,
                valor: valor,
                data: data,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagamentosFaturasTable, PagamentosFatura>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PagamentosFaturasTable,
                    PagamentosFatura
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PagamentosFaturasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagamentosFaturasTable,
      PagamentosFatura,
      $$PagamentosFaturasTableFilterComposer,
      $$PagamentosFaturasTableOrderingComposer,
      $$PagamentosFaturasTableAnnotationComposer,
      $$PagamentosFaturasTableCreateCompanionBuilder,
      $$PagamentosFaturasTableUpdateCompanionBuilder,
      (
        PagamentosFatura,
        BaseReferences<
          _$AppDatabase,
          $PagamentosFaturasTable,
          PagamentosFatura
        >,
      ),
      PagamentosFatura,
      PrefetchHooks Function()
    >;
typedef $$TransferenciasTableCreateCompanionBuilder =
    TransferenciasCompanion Function({
      Value<int> id,
      required int contaOrigemId,
      required int contaDestinoId,
      required double valor,
      required DateTime data,
      required String descricao,
    });
typedef $$TransferenciasTableUpdateCompanionBuilder =
    TransferenciasCompanion Function({
      Value<int> id,
      Value<int> contaOrigemId,
      Value<int> contaDestinoId,
      Value<double> valor,
      Value<DateTime> data,
      Value<String> descricao,
    });

class $$TransferenciasTableFilterComposer
    extends Composer<_$AppDatabase, $TransferenciasTable> {
  $$TransferenciasTableFilterComposer({
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

  ColumnFilters<int> get contaOrigemId => $composableBuilder(
    column: $table.contaOrigemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contaDestinoId => $composableBuilder(
    column: $table.contaDestinoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransferenciasTableOrderingComposer
    extends Composer<_$AppDatabase, $TransferenciasTable> {
  $$TransferenciasTableOrderingComposer({
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

  ColumnOrderings<int> get contaOrigemId => $composableBuilder(
    column: $table.contaOrigemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contaDestinoId => $composableBuilder(
    column: $table.contaDestinoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransferenciasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransferenciasTable> {
  $$TransferenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get contaOrigemId => $composableBuilder(
    column: $table.contaOrigemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contaDestinoId => $composableBuilder(
    column: $table.contaDestinoId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);
}

class $$TransferenciasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransferenciasTable,
          Transferencia,
          $$TransferenciasTableFilterComposer,
          $$TransferenciasTableOrderingComposer,
          $$TransferenciasTableAnnotationComposer,
          $$TransferenciasTableCreateCompanionBuilder,
          $$TransferenciasTableUpdateCompanionBuilder,
          (
            Transferencia,
            BaseReferences<_$AppDatabase, $TransferenciasTable, Transferencia>,
          ),
          Transferencia,
          PrefetchHooks Function()
        > {
  $$TransferenciasTableTableManager(
    _$AppDatabase db,
    $TransferenciasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransferenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransferenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransferenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> contaOrigemId = const Value.absent(),
                Value<int> contaDestinoId = const Value.absent(),
                Value<double> valor = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<String> descricao = const Value.absent(),
              }) => TransferenciasCompanion(
                id: id,
                contaOrigemId: contaOrigemId,
                contaDestinoId: contaDestinoId,
                valor: valor,
                data: data,
                descricao: descricao,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int contaOrigemId,
                required int contaDestinoId,
                required double valor,
                required DateTime data,
                required String descricao,
              }) => TransferenciasCompanion.insert(
                id: id,
                contaOrigemId: contaOrigemId,
                contaDestinoId: contaDestinoId,
                valor: valor,
                data: data,
                descricao: descricao,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransferenciasTable, Transferencia>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TransferenciasTable,
                    Transferencia
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransferenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransferenciasTable,
      Transferencia,
      $$TransferenciasTableFilterComposer,
      $$TransferenciasTableOrderingComposer,
      $$TransferenciasTableAnnotationComposer,
      $$TransferenciasTableCreateCompanionBuilder,
      $$TransferenciasTableUpdateCompanionBuilder,
      (
        Transferencia,
        BaseReferences<_$AppDatabase, $TransferenciasTable, Transferencia>,
      ),
      Transferencia,
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
  $$LancamentosTableTableManager get lancamentos =>
      $$LancamentosTableTableManager(_db, _db.lancamentos);
  $$FaturasTableTableManager get faturas =>
      $$FaturasTableTableManager(_db, _db.faturas);
  $$PagamentosFaturasTableTableManager get pagamentosFaturas =>
      $$PagamentosFaturasTableTableManager(_db, _db.pagamentosFaturas);
  $$TransferenciasTableTableManager get transferencias =>
      $$TransferenciasTableTableManager(_db, _db.transferencias);
}
