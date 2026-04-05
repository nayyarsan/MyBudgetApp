// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _balanceCentsMeta =
      const VerificationMeta('balanceCents');
  @override
  late final GeneratedColumn<int> balanceCents = GeneratedColumn<int>(
      'balance_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _institutionMeta =
      const VerificationMeta('institution');
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
      'institution', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        balanceCents,
        institution,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('balance_cents')) {
      context.handle(
          _balanceCentsMeta,
          balanceCents.isAcceptableOrUnknown(
              data['balance_cents']!, _balanceCentsMeta));
    }
    if (data.containsKey('institution')) {
      context.handle(
          _institutionMeta,
          institution.isAcceptableOrUnknown(
              data['institution']!, _institutionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      balanceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_cents'])!,
      institution: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}institution']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final String type;
  final int balanceCents;
  final String? institution;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const Account(
      {required this.id,
      required this.name,
      required this.type,
      required this.balanceCents,
      this.institution,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['balance_cents'] = Variable<int>(balanceCents);
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      balanceCents: Value(balanceCents),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      balanceCents: serializer.fromJson<int>(json['balanceCents']),
      institution: serializer.fromJson<String?>(json['institution']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'balanceCents': serializer.toJson<int>(balanceCents),
      'institution': serializer.toJson<String?>(institution),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Account copyWith(
          {int? id,
          String? name,
          String? type,
          int? balanceCents,
          Value<String?> institution = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        balanceCents: balanceCents ?? this.balanceCents,
        institution: institution.present ? institution.value : this.institution,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      balanceCents: data.balanceCents.present
          ? data.balanceCents.value
          : this.balanceCents,
      institution:
          data.institution.present ? data.institution.value : this.institution,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('institution: $institution, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, balanceCents, institution,
      createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.balanceCents == this.balanceCents &&
          other.institution == this.institution &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> balanceCents;
  final Value<String?> institution;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balanceCents = const Value.absent(),
    this.institution = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.balanceCents = const Value.absent(),
    this.institution = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  })  : name = Value(name),
        type = Value(type);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? balanceCents,
    Expression<String>? institution,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (balanceCents != null) 'balance_cents': balanceCents,
      if (institution != null) 'institution': institution,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  AccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? type,
      Value<int>? balanceCents,
      Value<String?>? institution,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balanceCents: balanceCents ?? this.balanceCents,
      institution: institution ?? this.institution,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (balanceCents.present) {
      map['balance_cents'] = Variable<int>(balanceCents.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('institution: $institution, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $CategoryGroupsTable extends CategoryGroups
    with TableInfo<$CategoryGroupsTable, CategoryGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder, isDeleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_groups';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryGroup> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryGroup(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $CategoryGroupsTable createAlias(String alias) {
    return $CategoryGroupsTable(attachedDatabase, alias);
  }
}

class CategoryGroup extends DataClass implements Insertable<CategoryGroup> {
  final int id;
  final String name;
  final int sortOrder;
  final bool isDeleted;
  const CategoryGroup(
      {required this.id,
      required this.name,
      required this.sortOrder,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CategoryGroupsCompanion toCompanion(bool nullToAbsent) {
    return CategoryGroupsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      isDeleted: Value(isDeleted),
    );
  }

  factory CategoryGroup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryGroup(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  CategoryGroup copyWith(
          {int? id, String? name, int? sortOrder, bool? isDeleted}) =>
      CategoryGroup(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  CategoryGroup copyWithCompanion(CategoryGroupsCompanion data) {
    return CategoryGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.isDeleted == this.isDeleted);
}

class CategoryGroupsCompanion extends UpdateCompanion<CategoryGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> isDeleted;
  const CategoryGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  CategoryGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    this.isDeleted = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CategoryGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  CategoryGroupsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<bool>? isDeleted}) {
    return CategoryGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES category_groups (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _rolloverMeta =
      const VerificationMeta('rollover');
  @override
  late final GeneratedColumn<bool> rollover = GeneratedColumn<bool>(
      'rollover', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("rollover" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _goalAmountCentsMeta =
      const VerificationMeta('goalAmountCents');
  @override
  late final GeneratedColumn<int> goalAmountCents = GeneratedColumn<int>(
      'goal_amount_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _goalDateMeta =
      const VerificationMeta('goalDate');
  @override
  late final GeneratedColumn<DateTime> goalDate = GeneratedColumn<DateTime>(
      'goal_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _goalTypeMeta =
      const VerificationMeta('goalType');
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
      'goal_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        name,
        rollover,
        goalAmountCents,
        goalDate,
        goalType,
        sortOrder,
        createdAt,
        updatedAt,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rollover')) {
      context.handle(_rolloverMeta,
          rollover.isAcceptableOrUnknown(data['rollover']!, _rolloverMeta));
    }
    if (data.containsKey('goal_amount_cents')) {
      context.handle(
          _goalAmountCentsMeta,
          goalAmountCents.isAcceptableOrUnknown(
              data['goal_amount_cents']!, _goalAmountCentsMeta));
    }
    if (data.containsKey('goal_date')) {
      context.handle(_goalDateMeta,
          goalDate.isAcceptableOrUnknown(data['goal_date']!, _goalDateMeta));
    }
    if (data.containsKey('goal_type')) {
      context.handle(_goalTypeMeta,
          goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      rollover: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}rollover'])!,
      goalAmountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_amount_cents']),
      goalDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}goal_date']),
      goalType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_type']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final int groupId;
  final String name;
  final bool rollover;
  final int? goalAmountCents;
  final DateTime? goalDate;
  final String? goalType;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  const Category(
      {required this.id,
      required this.groupId,
      required this.name,
      required this.rollover,
      this.goalAmountCents,
      this.goalDate,
      this.goalType,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_id'] = Variable<int>(groupId);
    map['name'] = Variable<String>(name);
    map['rollover'] = Variable<bool>(rollover);
    if (!nullToAbsent || goalAmountCents != null) {
      map['goal_amount_cents'] = Variable<int>(goalAmountCents);
    }
    if (!nullToAbsent || goalDate != null) {
      map['goal_date'] = Variable<DateTime>(goalDate);
    }
    if (!nullToAbsent || goalType != null) {
      map['goal_type'] = Variable<String>(goalType);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
      rollover: Value(rollover),
      goalAmountCents: goalAmountCents == null && nullToAbsent
          ? const Value.absent()
          : Value(goalAmountCents),
      goalDate: goalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(goalDate),
      goalType: goalType == null && nullToAbsent
          ? const Value.absent()
          : Value(goalType),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      rollover: serializer.fromJson<bool>(json['rollover']),
      goalAmountCents: serializer.fromJson<int?>(json['goalAmountCents']),
      goalDate: serializer.fromJson<DateTime?>(json['goalDate']),
      goalType: serializer.fromJson<String?>(json['goalType']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int>(groupId),
      'name': serializer.toJson<String>(name),
      'rollover': serializer.toJson<bool>(rollover),
      'goalAmountCents': serializer.toJson<int?>(goalAmountCents),
      'goalDate': serializer.toJson<DateTime?>(goalDate),
      'goalType': serializer.toJson<String?>(goalType),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Category copyWith(
          {int? id,
          int? groupId,
          String? name,
          bool? rollover,
          Value<int?> goalAmountCents = const Value.absent(),
          Value<DateTime?> goalDate = const Value.absent(),
          Value<String?> goalType = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted}) =>
      Category(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        name: name ?? this.name,
        rollover: rollover ?? this.rollover,
        goalAmountCents: goalAmountCents.present
            ? goalAmountCents.value
            : this.goalAmountCents,
        goalDate: goalDate.present ? goalDate.value : this.goalDate,
        goalType: goalType.present ? goalType.value : this.goalType,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      rollover: data.rollover.present ? data.rollover.value : this.rollover,
      goalAmountCents: data.goalAmountCents.present
          ? data.goalAmountCents.value
          : this.goalAmountCents,
      goalDate: data.goalDate.present ? data.goalDate.value : this.goalDate,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('rollover: $rollover, ')
          ..write('goalAmountCents: $goalAmountCents, ')
          ..write('goalDate: $goalDate, ')
          ..write('goalType: $goalType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, name, rollover, goalAmountCents,
      goalDate, goalType, sortOrder, createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.rollover == this.rollover &&
          other.goalAmountCents == this.goalAmountCents &&
          other.goalDate == this.goalDate &&
          other.goalType == this.goalType &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<int> groupId;
  final Value<String> name;
  final Value<bool> rollover;
  final Value<int?> goalAmountCents;
  final Value<DateTime?> goalDate;
  final Value<String?> goalType;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.rollover = const Value.absent(),
    this.goalAmountCents = const Value.absent(),
    this.goalDate = const Value.absent(),
    this.goalType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int groupId,
    required String name,
    this.rollover = const Value.absent(),
    this.goalAmountCents = const Value.absent(),
    this.goalDate = const Value.absent(),
    this.goalType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
  })  : groupId = Value(groupId),
        name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? name,
    Expression<bool>? rollover,
    Expression<int>? goalAmountCents,
    Expression<DateTime>? goalDate,
    Expression<String>? goalType,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (rollover != null) 'rollover': rollover,
      if (goalAmountCents != null) 'goal_amount_cents': goalAmountCents,
      if (goalDate != null) 'goal_date': goalDate,
      if (goalType != null) 'goal_type': goalType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? groupId,
      Value<String>? name,
      Value<bool>? rollover,
      Value<int?>? goalAmountCents,
      Value<DateTime?>? goalDate,
      Value<String?>? goalType,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      rollover: rollover ?? this.rollover,
      goalAmountCents: goalAmountCents ?? this.goalAmountCents,
      goalDate: goalDate ?? this.goalDate,
      goalType: goalType ?? this.goalType,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rollover.present) {
      map['rollover'] = Variable<bool>(rollover.value);
    }
    if (goalAmountCents.present) {
      map['goal_amount_cents'] = Variable<int>(goalAmountCents.value);
    }
    if (goalDate.present) {
      map['goal_date'] = Variable<DateTime>(goalDate.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('rollover: $rollover, ')
          ..write('goalAmountCents: $goalAmountCents, ')
          ..write('goalDate: $goalDate, ')
          ..write('goalType: $goalType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $MonthlyBudgetsTable extends MonthlyBudgets
    with TableInfo<$MonthlyBudgetsTable, MonthlyBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
      'month', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedCentsMeta =
      const VerificationMeta('assignedCents');
  @override
  late final GeneratedColumn<int> assignedCents = GeneratedColumn<int>(
      'assigned_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _rolledOverCentsMeta =
      const VerificationMeta('rolledOverCents');
  @override
  late final GeneratedColumn<int> rolledOverCents = GeneratedColumn<int>(
      'rolled_over_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, categoryId, month, assignedCents, rolledOverCents, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_budgets';
  @override
  VerificationContext validateIntegrity(Insertable<MonthlyBudget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('assigned_cents')) {
      context.handle(
          _assignedCentsMeta,
          assignedCents.isAcceptableOrUnknown(
              data['assigned_cents']!, _assignedCentsMeta));
    }
    if (data.containsKey('rolled_over_cents')) {
      context.handle(
          _rolledOverCentsMeta,
          rolledOverCents.isAcceptableOrUnknown(
              data['rolled_over_cents']!, _rolledOverCentsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {categoryId, month},
      ];
  @override
  MonthlyBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyBudget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month'])!,
      assignedCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}assigned_cents'])!,
      rolledOverCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rolled_over_cents'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MonthlyBudgetsTable createAlias(String alias) {
    return $MonthlyBudgetsTable(attachedDatabase, alias);
  }
}

class MonthlyBudget extends DataClass implements Insertable<MonthlyBudget> {
  final int id;
  final int categoryId;
  final String month;
  final int assignedCents;
  final int rolledOverCents;
  final DateTime updatedAt;
  const MonthlyBudget(
      {required this.id,
      required this.categoryId,
      required this.month,
      required this.assignedCents,
      required this.rolledOverCents,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['month'] = Variable<String>(month);
    map['assigned_cents'] = Variable<int>(assignedCents);
    map['rolled_over_cents'] = Variable<int>(rolledOverCents);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MonthlyBudgetsCompanion toCompanion(bool nullToAbsent) {
    return MonthlyBudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      month: Value(month),
      assignedCents: Value(assignedCents),
      rolledOverCents: Value(rolledOverCents),
      updatedAt: Value(updatedAt),
    );
  }

  factory MonthlyBudget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyBudget(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      month: serializer.fromJson<String>(json['month']),
      assignedCents: serializer.fromJson<int>(json['assignedCents']),
      rolledOverCents: serializer.fromJson<int>(json['rolledOverCents']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'month': serializer.toJson<String>(month),
      'assignedCents': serializer.toJson<int>(assignedCents),
      'rolledOverCents': serializer.toJson<int>(rolledOverCents),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MonthlyBudget copyWith(
          {int? id,
          int? categoryId,
          String? month,
          int? assignedCents,
          int? rolledOverCents,
          DateTime? updatedAt}) =>
      MonthlyBudget(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        month: month ?? this.month,
        assignedCents: assignedCents ?? this.assignedCents,
        rolledOverCents: rolledOverCents ?? this.rolledOverCents,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MonthlyBudget copyWithCompanion(MonthlyBudgetsCompanion data) {
    return MonthlyBudget(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      month: data.month.present ? data.month.value : this.month,
      assignedCents: data.assignedCents.present
          ? data.assignedCents.value
          : this.assignedCents,
      rolledOverCents: data.rolledOverCents.present
          ? data.rolledOverCents.value
          : this.rolledOverCents,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyBudget(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('month: $month, ')
          ..write('assignedCents: $assignedCents, ')
          ..write('rolledOverCents: $rolledOverCents, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, categoryId, month, assignedCents, rolledOverCents, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyBudget &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.month == this.month &&
          other.assignedCents == this.assignedCents &&
          other.rolledOverCents == this.rolledOverCents &&
          other.updatedAt == this.updatedAt);
}

class MonthlyBudgetsCompanion extends UpdateCompanion<MonthlyBudget> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> month;
  final Value<int> assignedCents;
  final Value<int> rolledOverCents;
  final Value<DateTime> updatedAt;
  const MonthlyBudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.month = const Value.absent(),
    this.assignedCents = const Value.absent(),
    this.rolledOverCents = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MonthlyBudgetsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String month,
    this.assignedCents = const Value.absent(),
    this.rolledOverCents = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : categoryId = Value(categoryId),
        month = Value(month);
  static Insertable<MonthlyBudget> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? month,
    Expression<int>? assignedCents,
    Expression<int>? rolledOverCents,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (month != null) 'month': month,
      if (assignedCents != null) 'assigned_cents': assignedCents,
      if (rolledOverCents != null) 'rolled_over_cents': rolledOverCents,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MonthlyBudgetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? month,
      Value<int>? assignedCents,
      Value<int>? rolledOverCents,
      Value<DateTime>? updatedAt}) {
    return MonthlyBudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      assignedCents: assignedCents ?? this.assignedCents,
      rolledOverCents: rolledOverCents ?? this.rolledOverCents,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (assignedCents.present) {
      map['assigned_cents'] = Variable<int>(assignedCents.value);
    }
    if (rolledOverCents.present) {
      map['rolled_over_cents'] = Variable<int>(rolledOverCents.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('month: $month, ')
          ..write('assignedCents: $assignedCents, ')
          ..write('rolledOverCents: $rolledOverCents, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _amountCentsMeta =
      const VerificationMeta('amountCents');
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
      'amount_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payeeMeta = const VerificationMeta('payee');
  @override
  late final GeneratedColumn<String> payee = GeneratedColumn<String>(
      'payee', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clearedMeta =
      const VerificationMeta('cleared');
  @override
  late final GeneratedColumn<bool> cleared = GeneratedColumn<bool>(
      'cleared', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("cleared" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurringMeta =
      const VerificationMeta('recurring');
  @override
  late final GeneratedColumn<bool> recurring = GeneratedColumn<bool>(
      'recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurringIntervalMeta =
      const VerificationMeta('recurringInterval');
  @override
  late final GeneratedColumn<String> recurringInterval =
      GeneratedColumn<String>('recurring_interval', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _importedFromMeta =
      const VerificationMeta('importedFrom');
  @override
  late final GeneratedColumn<String> importedFrom = GeneratedColumn<String>(
      'imported_from', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _toAccountIdMeta =
      const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<int> toAccountId = GeneratedColumn<int>(
      'to_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        categoryId,
        amountCents,
        payee,
        date,
        memo,
        type,
        cleared,
        recurring,
        recurringInterval,
        nextDueDate,
        importedFrom,
        createdAt,
        updatedAt,
        toAccountId,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
          _amountCentsMeta,
          amountCents.isAcceptableOrUnknown(
              data['amount_cents']!, _amountCentsMeta));
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('payee')) {
      context.handle(
          _payeeMeta, payee.isAcceptableOrUnknown(data['payee']!, _payeeMeta));
    } else if (isInserting) {
      context.missing(_payeeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('cleared')) {
      context.handle(_clearedMeta,
          cleared.isAcceptableOrUnknown(data['cleared']!, _clearedMeta));
    }
    if (data.containsKey('recurring')) {
      context.handle(_recurringMeta,
          recurring.isAcceptableOrUnknown(data['recurring']!, _recurringMeta));
    }
    if (data.containsKey('recurring_interval')) {
      context.handle(
          _recurringIntervalMeta,
          recurringInterval.isAcceptableOrUnknown(
              data['recurring_interval']!, _recurringIntervalMeta));
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    }
    if (data.containsKey('imported_from')) {
      context.handle(
          _importedFromMeta,
          importedFrom.isAcceptableOrUnknown(
              data['imported_from']!, _importedFromMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
          _toAccountIdMeta,
          toAccountId.isAcceptableOrUnknown(
              data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      amountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_cents'])!,
      payee: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      cleared: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}cleared'])!,
      recurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}recurring'])!,
      recurringInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurring_interval']),
      nextDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_due_date']),
      importedFrom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imported_from']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      toAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}to_account_id']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int accountId;
  final int? categoryId;
  final int amountCents;
  final String payee;
  final DateTime date;
  final String? memo;
  final String type;
  final bool cleared;
  final bool recurring;
  final String? recurringInterval;
  final DateTime? nextDueDate;
  final String? importedFrom;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? toAccountId;
  final bool isDeleted;
  const Transaction(
      {required this.id,
      required this.accountId,
      this.categoryId,
      required this.amountCents,
      required this.payee,
      required this.date,
      this.memo,
      required this.type,
      required this.cleared,
      required this.recurring,
      this.recurringInterval,
      this.nextDueDate,
      this.importedFrom,
      required this.createdAt,
      required this.updatedAt,
      this.toAccountId,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['amount_cents'] = Variable<int>(amountCents);
    map['payee'] = Variable<String>(payee);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['type'] = Variable<String>(type);
    map['cleared'] = Variable<bool>(cleared);
    map['recurring'] = Variable<bool>(recurring);
    if (!nullToAbsent || recurringInterval != null) {
      map['recurring_interval'] = Variable<String>(recurringInterval);
    }
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate);
    }
    if (!nullToAbsent || importedFrom != null) {
      map['imported_from'] = Variable<String>(importedFrom);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<int>(toAccountId);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amountCents: Value(amountCents),
      payee: Value(payee),
      date: Value(date),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      type: Value(type),
      cleared: Value(cleared),
      recurring: Value(recurring),
      recurringInterval: recurringInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringInterval),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      importedFrom: importedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(importedFrom),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      isDeleted: Value(isDeleted),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      payee: serializer.fromJson<String>(json['payee']),
      date: serializer.fromJson<DateTime>(json['date']),
      memo: serializer.fromJson<String?>(json['memo']),
      type: serializer.fromJson<String>(json['type']),
      cleared: serializer.fromJson<bool>(json['cleared']),
      recurring: serializer.fromJson<bool>(json['recurring']),
      recurringInterval:
          serializer.fromJson<String?>(json['recurringInterval']),
      nextDueDate: serializer.fromJson<DateTime?>(json['nextDueDate']),
      importedFrom: serializer.fromJson<String?>(json['importedFrom']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      toAccountId: serializer.fromJson<int?>(json['toAccountId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'amountCents': serializer.toJson<int>(amountCents),
      'payee': serializer.toJson<String>(payee),
      'date': serializer.toJson<DateTime>(date),
      'memo': serializer.toJson<String?>(memo),
      'type': serializer.toJson<String>(type),
      'cleared': serializer.toJson<bool>(cleared),
      'recurring': serializer.toJson<bool>(recurring),
      'recurringInterval': serializer.toJson<String?>(recurringInterval),
      'nextDueDate': serializer.toJson<DateTime?>(nextDueDate),
      'importedFrom': serializer.toJson<String?>(importedFrom),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'toAccountId': serializer.toJson<int?>(toAccountId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Transaction copyWith(
          {int? id,
          int? accountId,
          Value<int?> categoryId = const Value.absent(),
          int? amountCents,
          String? payee,
          DateTime? date,
          Value<String?> memo = const Value.absent(),
          String? type,
          bool? cleared,
          bool? recurring,
          Value<String?> recurringInterval = const Value.absent(),
          Value<DateTime?> nextDueDate = const Value.absent(),
          Value<String?> importedFrom = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<int?> toAccountId = const Value.absent(),
          bool? isDeleted}) =>
      Transaction(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        amountCents: amountCents ?? this.amountCents,
        payee: payee ?? this.payee,
        date: date ?? this.date,
        memo: memo.present ? memo.value : this.memo,
        type: type ?? this.type,
        cleared: cleared ?? this.cleared,
        recurring: recurring ?? this.recurring,
        recurringInterval: recurringInterval.present
            ? recurringInterval.value
            : this.recurringInterval,
        nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
        importedFrom:
            importedFrom.present ? importedFrom.value : this.importedFrom,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amountCents:
          data.amountCents.present ? data.amountCents.value : this.amountCents,
      payee: data.payee.present ? data.payee.value : this.payee,
      date: data.date.present ? data.date.value : this.date,
      memo: data.memo.present ? data.memo.value : this.memo,
      type: data.type.present ? data.type.value : this.type,
      cleared: data.cleared.present ? data.cleared.value : this.cleared,
      recurring: data.recurring.present ? data.recurring.value : this.recurring,
      recurringInterval: data.recurringInterval.present
          ? data.recurringInterval.value
          : this.recurringInterval,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      importedFrom: data.importedFrom.present
          ? data.importedFrom.value
          : this.importedFrom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      toAccountId:
          data.toAccountId.present ? data.toAccountId.value : this.toAccountId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountCents: $amountCents, ')
          ..write('payee: $payee, ')
          ..write('date: $date, ')
          ..write('memo: $memo, ')
          ..write('type: $type, ')
          ..write('cleared: $cleared, ')
          ..write('recurring: $recurring, ')
          ..write('recurringInterval: $recurringInterval, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('importedFrom: $importedFrom, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      accountId,
      categoryId,
      amountCents,
      payee,
      date,
      memo,
      type,
      cleared,
      recurring,
      recurringInterval,
      nextDueDate,
      importedFrom,
      createdAt,
      updatedAt,
      toAccountId,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.amountCents == this.amountCents &&
          other.payee == this.payee &&
          other.date == this.date &&
          other.memo == this.memo &&
          other.type == this.type &&
          other.cleared == this.cleared &&
          other.recurring == this.recurring &&
          other.recurringInterval == this.recurringInterval &&
          other.nextDueDate == this.nextDueDate &&
          other.importedFrom == this.importedFrom &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.toAccountId == this.toAccountId &&
          other.isDeleted == this.isDeleted);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int?> categoryId;
  final Value<int> amountCents;
  final Value<String> payee;
  final Value<DateTime> date;
  final Value<String?> memo;
  final Value<String> type;
  final Value<bool> cleared;
  final Value<bool> recurring;
  final Value<String?> recurringInterval;
  final Value<DateTime?> nextDueDate;
  final Value<String?> importedFrom;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> toAccountId;
  final Value<bool> isDeleted;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.payee = const Value.absent(),
    this.date = const Value.absent(),
    this.memo = const Value.absent(),
    this.type = const Value.absent(),
    this.cleared = const Value.absent(),
    this.recurring = const Value.absent(),
    this.recurringInterval = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.importedFrom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    this.categoryId = const Value.absent(),
    required int amountCents,
    required String payee,
    required DateTime date,
    this.memo = const Value.absent(),
    required String type,
    this.cleared = const Value.absent(),
    this.recurring = const Value.absent(),
    this.recurringInterval = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.importedFrom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.isDeleted = const Value.absent(),
  })  : accountId = Value(accountId),
        amountCents = Value(amountCents),
        payee = Value(payee),
        date = Value(date),
        type = Value(type);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<int>? amountCents,
    Expression<String>? payee,
    Expression<DateTime>? date,
    Expression<String>? memo,
    Expression<String>? type,
    Expression<bool>? cleared,
    Expression<bool>? recurring,
    Expression<String>? recurringInterval,
    Expression<DateTime>? nextDueDate,
    Expression<String>? importedFrom,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? toAccountId,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (payee != null) 'payee': payee,
      if (date != null) 'date': date,
      if (memo != null) 'memo': memo,
      if (type != null) 'type': type,
      if (cleared != null) 'cleared': cleared,
      if (recurring != null) 'recurring': recurring,
      if (recurringInterval != null) 'recurring_interval': recurringInterval,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (importedFrom != null) 'imported_from': importedFrom,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? accountId,
      Value<int?>? categoryId,
      Value<int>? amountCents,
      Value<String>? payee,
      Value<DateTime>? date,
      Value<String?>? memo,
      Value<String>? type,
      Value<bool>? cleared,
      Value<bool>? recurring,
      Value<String?>? recurringInterval,
      Value<DateTime?>? nextDueDate,
      Value<String?>? importedFrom,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int?>? toAccountId,
      Value<bool>? isDeleted}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amountCents: amountCents ?? this.amountCents,
      payee: payee ?? this.payee,
      date: date ?? this.date,
      memo: memo ?? this.memo,
      type: type ?? this.type,
      cleared: cleared ?? this.cleared,
      recurring: recurring ?? this.recurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      importedFrom: importedFrom ?? this.importedFrom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      toAccountId: toAccountId ?? this.toAccountId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (payee.present) {
      map['payee'] = Variable<String>(payee.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (cleared.present) {
      map['cleared'] = Variable<bool>(cleared.value);
    }
    if (recurring.present) {
      map['recurring'] = Variable<bool>(recurring.value);
    }
    if (recurringInterval.present) {
      map['recurring_interval'] = Variable<String>(recurringInterval.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (importedFrom.present) {
      map['imported_from'] = Variable<String>(importedFrom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<int>(toAccountId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountCents: $amountCents, ')
          ..write('payee: $payee, ')
          ..write('date: $date, ')
          ..write('memo: $memo, ')
          ..write('type: $type, ')
          ..write('cleared: $cleared, ')
          ..write('recurring: $recurring, ')
          ..write('recurringInterval: $recurringInterval, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('importedFrom: $importedFrom, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $NetWorthSnapshotsTable extends NetWorthSnapshots
    with TableInfo<$NetWorthSnapshotsTable, NetWorthSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetWorthSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalAssetsCentsMeta =
      const VerificationMeta('totalAssetsCents');
  @override
  late final GeneratedColumn<int> totalAssetsCents = GeneratedColumn<int>(
      'total_assets_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalLiabilitiesCentsMeta =
      const VerificationMeta('totalLiabilitiesCents');
  @override
  late final GeneratedColumn<int> totalLiabilitiesCents = GeneratedColumn<int>(
      'total_liabilities_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _netWorthCentsMeta =
      const VerificationMeta('netWorthCents');
  @override
  late final GeneratedColumn<int> netWorthCents = GeneratedColumn<int>(
      'net_worth_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, totalAssetsCents, totalLiabilitiesCents, netWorthCents];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'net_worth_snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<NetWorthSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_assets_cents')) {
      context.handle(
          _totalAssetsCentsMeta,
          totalAssetsCents.isAcceptableOrUnknown(
              data['total_assets_cents']!, _totalAssetsCentsMeta));
    } else if (isInserting) {
      context.missing(_totalAssetsCentsMeta);
    }
    if (data.containsKey('total_liabilities_cents')) {
      context.handle(
          _totalLiabilitiesCentsMeta,
          totalLiabilitiesCents.isAcceptableOrUnknown(
              data['total_liabilities_cents']!, _totalLiabilitiesCentsMeta));
    } else if (isInserting) {
      context.missing(_totalLiabilitiesCentsMeta);
    }
    if (data.containsKey('net_worth_cents')) {
      context.handle(
          _netWorthCentsMeta,
          netWorthCents.isAcceptableOrUnknown(
              data['net_worth_cents']!, _netWorthCentsMeta));
    } else if (isInserting) {
      context.missing(_netWorthCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetWorthSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetWorthSnapshot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      totalAssetsCents: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_assets_cents'])!,
      totalLiabilitiesCents: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_liabilities_cents'])!,
      netWorthCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}net_worth_cents'])!,
    );
  }

  @override
  $NetWorthSnapshotsTable createAlias(String alias) {
    return $NetWorthSnapshotsTable(attachedDatabase, alias);
  }
}

class NetWorthSnapshot extends DataClass
    implements Insertable<NetWorthSnapshot> {
  final int id;
  final DateTime date;
  final int totalAssetsCents;
  final int totalLiabilitiesCents;
  final int netWorthCents;
  const NetWorthSnapshot(
      {required this.id,
      required this.date,
      required this.totalAssetsCents,
      required this.totalLiabilitiesCents,
      required this.netWorthCents});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['total_assets_cents'] = Variable<int>(totalAssetsCents);
    map['total_liabilities_cents'] = Variable<int>(totalLiabilitiesCents);
    map['net_worth_cents'] = Variable<int>(netWorthCents);
    return map;
  }

  NetWorthSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return NetWorthSnapshotsCompanion(
      id: Value(id),
      date: Value(date),
      totalAssetsCents: Value(totalAssetsCents),
      totalLiabilitiesCents: Value(totalLiabilitiesCents),
      netWorthCents: Value(netWorthCents),
    );
  }

  factory NetWorthSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetWorthSnapshot(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalAssetsCents: serializer.fromJson<int>(json['totalAssetsCents']),
      totalLiabilitiesCents:
          serializer.fromJson<int>(json['totalLiabilitiesCents']),
      netWorthCents: serializer.fromJson<int>(json['netWorthCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'totalAssetsCents': serializer.toJson<int>(totalAssetsCents),
      'totalLiabilitiesCents': serializer.toJson<int>(totalLiabilitiesCents),
      'netWorthCents': serializer.toJson<int>(netWorthCents),
    };
  }

  NetWorthSnapshot copyWith(
          {int? id,
          DateTime? date,
          int? totalAssetsCents,
          int? totalLiabilitiesCents,
          int? netWorthCents}) =>
      NetWorthSnapshot(
        id: id ?? this.id,
        date: date ?? this.date,
        totalAssetsCents: totalAssetsCents ?? this.totalAssetsCents,
        totalLiabilitiesCents:
            totalLiabilitiesCents ?? this.totalLiabilitiesCents,
        netWorthCents: netWorthCents ?? this.netWorthCents,
      );
  NetWorthSnapshot copyWithCompanion(NetWorthSnapshotsCompanion data) {
    return NetWorthSnapshot(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      totalAssetsCents: data.totalAssetsCents.present
          ? data.totalAssetsCents.value
          : this.totalAssetsCents,
      totalLiabilitiesCents: data.totalLiabilitiesCents.present
          ? data.totalLiabilitiesCents.value
          : this.totalLiabilitiesCents,
      netWorthCents: data.netWorthCents.present
          ? data.netWorthCents.value
          : this.netWorthCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSnapshot(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalAssetsCents: $totalAssetsCents, ')
          ..write('totalLiabilitiesCents: $totalLiabilitiesCents, ')
          ..write('netWorthCents: $netWorthCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, date, totalAssetsCents, totalLiabilitiesCents, netWorthCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetWorthSnapshot &&
          other.id == this.id &&
          other.date == this.date &&
          other.totalAssetsCents == this.totalAssetsCents &&
          other.totalLiabilitiesCents == this.totalLiabilitiesCents &&
          other.netWorthCents == this.netWorthCents);
}

class NetWorthSnapshotsCompanion extends UpdateCompanion<NetWorthSnapshot> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> totalAssetsCents;
  final Value<int> totalLiabilitiesCents;
  final Value<int> netWorthCents;
  const NetWorthSnapshotsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.totalAssetsCents = const Value.absent(),
    this.totalLiabilitiesCents = const Value.absent(),
    this.netWorthCents = const Value.absent(),
  });
  NetWorthSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int totalAssetsCents,
    required int totalLiabilitiesCents,
    required int netWorthCents,
  })  : date = Value(date),
        totalAssetsCents = Value(totalAssetsCents),
        totalLiabilitiesCents = Value(totalLiabilitiesCents),
        netWorthCents = Value(netWorthCents);
  static Insertable<NetWorthSnapshot> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? totalAssetsCents,
    Expression<int>? totalLiabilitiesCents,
    Expression<int>? netWorthCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (totalAssetsCents != null) 'total_assets_cents': totalAssetsCents,
      if (totalLiabilitiesCents != null)
        'total_liabilities_cents': totalLiabilitiesCents,
      if (netWorthCents != null) 'net_worth_cents': netWorthCents,
    });
  }

  NetWorthSnapshotsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<int>? totalAssetsCents,
      Value<int>? totalLiabilitiesCents,
      Value<int>? netWorthCents}) {
    return NetWorthSnapshotsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      totalAssetsCents: totalAssetsCents ?? this.totalAssetsCents,
      totalLiabilitiesCents:
          totalLiabilitiesCents ?? this.totalLiabilitiesCents,
      netWorthCents: netWorthCents ?? this.netWorthCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalAssetsCents.present) {
      map['total_assets_cents'] = Variable<int>(totalAssetsCents.value);
    }
    if (totalLiabilitiesCents.present) {
      map['total_liabilities_cents'] =
          Variable<int>(totalLiabilitiesCents.value);
    }
    if (netWorthCents.present) {
      map['net_worth_cents'] = Variable<int>(netWorthCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalAssetsCents: $totalAssetsCents, ')
          ..write('totalLiabilitiesCents: $totalLiabilitiesCents, ')
          ..write('netWorthCents: $netWorthCents')
          ..write(')'))
        .toString();
  }
}

class $BudgetSnapshotsTable extends BudgetSnapshots
    with TableInfo<$BudgetSnapshotsTable, BudgetSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
      'month', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedCentsMeta =
      const VerificationMeta('assignedCents');
  @override
  late final GeneratedColumn<int> assignedCents = GeneratedColumn<int>(
      'assigned_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _spentCentsMeta =
      const VerificationMeta('spentCents');
  @override
  late final GeneratedColumn<int> spentCents = GeneratedColumn<int>(
      'spent_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, categoryId, month, assignedCents, spentCents, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('assigned_cents')) {
      context.handle(
          _assignedCentsMeta,
          assignedCents.isAcceptableOrUnknown(
              data['assigned_cents']!, _assignedCentsMeta));
    }
    if (data.containsKey('spent_cents')) {
      context.handle(
          _spentCentsMeta,
          spentCents.isAcceptableOrUnknown(
              data['spent_cents']!, _spentCentsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {categoryId, month},
      ];
  @override
  BudgetSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetSnapshot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month'])!,
      assignedCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}assigned_cents'])!,
      spentCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}spent_cents'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BudgetSnapshotsTable createAlias(String alias) {
    return $BudgetSnapshotsTable(attachedDatabase, alias);
  }
}

class BudgetSnapshot extends DataClass implements Insertable<BudgetSnapshot> {
  final int id;
  final int categoryId;
  final String month;
  final int assignedCents;
  final int spentCents;
  final DateTime createdAt;
  const BudgetSnapshot(
      {required this.id,
      required this.categoryId,
      required this.month,
      required this.assignedCents,
      required this.spentCents,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['month'] = Variable<String>(month);
    map['assigned_cents'] = Variable<int>(assignedCents);
    map['spent_cents'] = Variable<int>(spentCents);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BudgetSnapshotsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      month: Value(month),
      assignedCents: Value(assignedCents),
      spentCents: Value(spentCents),
      createdAt: Value(createdAt),
    );
  }

  factory BudgetSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetSnapshot(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      month: serializer.fromJson<String>(json['month']),
      assignedCents: serializer.fromJson<int>(json['assignedCents']),
      spentCents: serializer.fromJson<int>(json['spentCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'month': serializer.toJson<String>(month),
      'assignedCents': serializer.toJson<int>(assignedCents),
      'spentCents': serializer.toJson<int>(spentCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BudgetSnapshot copyWith(
          {int? id,
          int? categoryId,
          String? month,
          int? assignedCents,
          int? spentCents,
          DateTime? createdAt}) =>
      BudgetSnapshot(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        month: month ?? this.month,
        assignedCents: assignedCents ?? this.assignedCents,
        spentCents: spentCents ?? this.spentCents,
        createdAt: createdAt ?? this.createdAt,
      );
  BudgetSnapshot copyWithCompanion(BudgetSnapshotsCompanion data) {
    return BudgetSnapshot(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      month: data.month.present ? data.month.value : this.month,
      assignedCents: data.assignedCents.present
          ? data.assignedCents.value
          : this.assignedCents,
      spentCents:
          data.spentCents.present ? data.spentCents.value : this.spentCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetSnapshot(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('month: $month, ')
          ..write('assignedCents: $assignedCents, ')
          ..write('spentCents: $spentCents, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, categoryId, month, assignedCents, spentCents, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetSnapshot &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.month == this.month &&
          other.assignedCents == this.assignedCents &&
          other.spentCents == this.spentCents &&
          other.createdAt == this.createdAt);
}

class BudgetSnapshotsCompanion extends UpdateCompanion<BudgetSnapshot> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> month;
  final Value<int> assignedCents;
  final Value<int> spentCents;
  final Value<DateTime> createdAt;
  const BudgetSnapshotsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.month = const Value.absent(),
    this.assignedCents = const Value.absent(),
    this.spentCents = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BudgetSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String month,
    this.assignedCents = const Value.absent(),
    this.spentCents = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : categoryId = Value(categoryId),
        month = Value(month);
  static Insertable<BudgetSnapshot> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? month,
    Expression<int>? assignedCents,
    Expression<int>? spentCents,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (month != null) 'month': month,
      if (assignedCents != null) 'assigned_cents': assignedCents,
      if (spentCents != null) 'spent_cents': spentCents,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BudgetSnapshotsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? month,
      Value<int>? assignedCents,
      Value<int>? spentCents,
      Value<DateTime>? createdAt}) {
    return BudgetSnapshotsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      assignedCents: assignedCents ?? this.assignedCents,
      spentCents: spentCents ?? this.spentCents,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (assignedCents.present) {
      map['assigned_cents'] = Variable<int>(assignedCents.value);
    }
    if (spentCents.present) {
      map['spent_cents'] = Variable<int>(spentCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('month: $month, ')
          ..write('assignedCents: $assignedCents, ')
          ..write('spentCents: $spentCents, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PendingRecurringQueueTable extends PendingRecurringQueue
    with TableInfo<$PendingRecurringQueueTable, PendingRecurringQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingRecurringQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sourceTransactionIdMeta =
      const VerificationMeta('sourceTransactionId');
  @override
  late final GeneratedColumn<int> sourceTransactionId = GeneratedColumn<int>(
      'source_transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sourceTransactionId, dueDate, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_recurring_queue';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingRecurringQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_transaction_id')) {
      context.handle(
          _sourceTransactionIdMeta,
          sourceTransactionId.isAcceptableOrUnknown(
              data['source_transaction_id']!, _sourceTransactionIdMeta));
    } else if (isInserting) {
      context.missing(_sourceTransactionIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingRecurringQueueData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingRecurringQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sourceTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}source_transaction_id'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingRecurringQueueTable createAlias(String alias) {
    return $PendingRecurringQueueTable(attachedDatabase, alias);
  }
}

class PendingRecurringQueueData extends DataClass
    implements Insertable<PendingRecurringQueueData> {
  final int id;
  final int sourceTransactionId;
  final DateTime dueDate;
  final DateTime createdAt;
  const PendingRecurringQueueData(
      {required this.id,
      required this.sourceTransactionId,
      required this.dueDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_transaction_id'] = Variable<int>(sourceTransactionId);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingRecurringQueueCompanion toCompanion(bool nullToAbsent) {
    return PendingRecurringQueueCompanion(
      id: Value(id),
      sourceTransactionId: Value(sourceTransactionId),
      dueDate: Value(dueDate),
      createdAt: Value(createdAt),
    );
  }

  factory PendingRecurringQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingRecurringQueueData(
      id: serializer.fromJson<int>(json['id']),
      sourceTransactionId:
          serializer.fromJson<int>(json['sourceTransactionId']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceTransactionId': serializer.toJson<int>(sourceTransactionId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingRecurringQueueData copyWith(
          {int? id,
          int? sourceTransactionId,
          DateTime? dueDate,
          DateTime? createdAt}) =>
      PendingRecurringQueueData(
        id: id ?? this.id,
        sourceTransactionId: sourceTransactionId ?? this.sourceTransactionId,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingRecurringQueueData copyWithCompanion(
      PendingRecurringQueueCompanion data) {
    return PendingRecurringQueueData(
      id: data.id.present ? data.id.value : this.id,
      sourceTransactionId: data.sourceTransactionId.present
          ? data.sourceTransactionId.value
          : this.sourceTransactionId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingRecurringQueueData(')
          ..write('id: $id, ')
          ..write('sourceTransactionId: $sourceTransactionId, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceTransactionId, dueDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingRecurringQueueData &&
          other.id == this.id &&
          other.sourceTransactionId == this.sourceTransactionId &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt);
}

class PendingRecurringQueueCompanion
    extends UpdateCompanion<PendingRecurringQueueData> {
  final Value<int> id;
  final Value<int> sourceTransactionId;
  final Value<DateTime> dueDate;
  final Value<DateTime> createdAt;
  const PendingRecurringQueueCompanion({
    this.id = const Value.absent(),
    this.sourceTransactionId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingRecurringQueueCompanion.insert({
    this.id = const Value.absent(),
    required int sourceTransactionId,
    required DateTime dueDate,
    this.createdAt = const Value.absent(),
  })  : sourceTransactionId = Value(sourceTransactionId),
        dueDate = Value(dueDate);
  static Insertable<PendingRecurringQueueData> custom({
    Expression<int>? id,
    Expression<int>? sourceTransactionId,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceTransactionId != null)
        'source_transaction_id': sourceTransactionId,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingRecurringQueueCompanion copyWith(
      {Value<int>? id,
      Value<int>? sourceTransactionId,
      Value<DateTime>? dueDate,
      Value<DateTime>? createdAt}) {
    return PendingRecurringQueueCompanion(
      id: id ?? this.id,
      sourceTransactionId: sourceTransactionId ?? this.sourceTransactionId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceTransactionId.present) {
      map['source_transaction_id'] = Variable<int>(sourceTransactionId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingRecurringQueueCompanion(')
          ..write('id: $id, ')
          ..write('sourceTransactionId: $sourceTransactionId, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaidAccountsTable extends PlaidAccounts
    with TableInfo<$PlaidAccountsTable, PlaidAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaidAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _plaidAccountIdMeta =
      const VerificationMeta('plaidAccountId');
  @override
  late final GeneratedColumn<String> plaidAccountId = GeneratedColumn<String>(
      'plaid_account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _internalAccountIdMeta =
      const VerificationMeta('internalAccountId');
  @override
  late final GeneratedColumn<int> internalAccountId = GeneratedColumn<int>(
      'internal_account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _institutionNameMeta =
      const VerificationMeta('institutionName');
  @override
  late final GeneratedColumn<String> institutionName = GeneratedColumn<String>(
      'institution_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maskMeta = const VerificationMeta('mask');
  @override
  late final GeneratedColumn<String> mask = GeneratedColumn<String>(
      'mask', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 4),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, plaidAccountId, internalAccountId, institutionName, mask, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plaid_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<PlaidAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plaid_account_id')) {
      context.handle(
          _plaidAccountIdMeta,
          plaidAccountId.isAcceptableOrUnknown(
              data['plaid_account_id']!, _plaidAccountIdMeta));
    } else if (isInserting) {
      context.missing(_plaidAccountIdMeta);
    }
    if (data.containsKey('internal_account_id')) {
      context.handle(
          _internalAccountIdMeta,
          internalAccountId.isAcceptableOrUnknown(
              data['internal_account_id']!, _internalAccountIdMeta));
    } else if (isInserting) {
      context.missing(_internalAccountIdMeta);
    }
    if (data.containsKey('institution_name')) {
      context.handle(
          _institutionNameMeta,
          institutionName.isAcceptableOrUnknown(
              data['institution_name']!, _institutionNameMeta));
    } else if (isInserting) {
      context.missing(_institutionNameMeta);
    }
    if (data.containsKey('mask')) {
      context.handle(
          _maskMeta, mask.isAcceptableOrUnknown(data['mask']!, _maskMeta));
    } else if (isInserting) {
      context.missing(_maskMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaidAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaidAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      plaidAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}plaid_account_id'])!,
      internalAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}internal_account_id'])!,
      institutionName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}institution_name'])!,
      mask: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mask'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $PlaidAccountsTable createAlias(String alias) {
    return $PlaidAccountsTable(attachedDatabase, alias);
  }
}

class PlaidAccount extends DataClass implements Insertable<PlaidAccount> {
  final int id;
  final String plaidAccountId;
  final int internalAccountId;
  final String institutionName;
  final String mask;
  final DateTime? syncedAt;
  const PlaidAccount(
      {required this.id,
      required this.plaidAccountId,
      required this.internalAccountId,
      required this.institutionName,
      required this.mask,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plaid_account_id'] = Variable<String>(plaidAccountId);
    map['internal_account_id'] = Variable<int>(internalAccountId);
    map['institution_name'] = Variable<String>(institutionName);
    map['mask'] = Variable<String>(mask);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  PlaidAccountsCompanion toCompanion(bool nullToAbsent) {
    return PlaidAccountsCompanion(
      id: Value(id),
      plaidAccountId: Value(plaidAccountId),
      internalAccountId: Value(internalAccountId),
      institutionName: Value(institutionName),
      mask: Value(mask),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory PlaidAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaidAccount(
      id: serializer.fromJson<int>(json['id']),
      plaidAccountId: serializer.fromJson<String>(json['plaidAccountId']),
      internalAccountId: serializer.fromJson<int>(json['internalAccountId']),
      institutionName: serializer.fromJson<String>(json['institutionName']),
      mask: serializer.fromJson<String>(json['mask']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plaidAccountId': serializer.toJson<String>(plaidAccountId),
      'internalAccountId': serializer.toJson<int>(internalAccountId),
      'institutionName': serializer.toJson<String>(institutionName),
      'mask': serializer.toJson<String>(mask),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  PlaidAccount copyWith(
          {int? id,
          String? plaidAccountId,
          int? internalAccountId,
          String? institutionName,
          String? mask,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      PlaidAccount(
        id: id ?? this.id,
        plaidAccountId: plaidAccountId ?? this.plaidAccountId,
        internalAccountId: internalAccountId ?? this.internalAccountId,
        institutionName: institutionName ?? this.institutionName,
        mask: mask ?? this.mask,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  PlaidAccount copyWithCompanion(PlaidAccountsCompanion data) {
    return PlaidAccount(
      id: data.id.present ? data.id.value : this.id,
      plaidAccountId: data.plaidAccountId.present
          ? data.plaidAccountId.value
          : this.plaidAccountId,
      internalAccountId: data.internalAccountId.present
          ? data.internalAccountId.value
          : this.internalAccountId,
      institutionName: data.institutionName.present
          ? data.institutionName.value
          : this.institutionName,
      mask: data.mask.present ? data.mask.value : this.mask,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaidAccount(')
          ..write('id: $id, ')
          ..write('plaidAccountId: $plaidAccountId, ')
          ..write('internalAccountId: $internalAccountId, ')
          ..write('institutionName: $institutionName, ')
          ..write('mask: $mask, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, plaidAccountId, internalAccountId, institutionName, mask, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaidAccount &&
          other.id == this.id &&
          other.plaidAccountId == this.plaidAccountId &&
          other.internalAccountId == this.internalAccountId &&
          other.institutionName == this.institutionName &&
          other.mask == this.mask &&
          other.syncedAt == this.syncedAt);
}

class PlaidAccountsCompanion extends UpdateCompanion<PlaidAccount> {
  final Value<int> id;
  final Value<String> plaidAccountId;
  final Value<int> internalAccountId;
  final Value<String> institutionName;
  final Value<String> mask;
  final Value<DateTime?> syncedAt;
  const PlaidAccountsCompanion({
    this.id = const Value.absent(),
    this.plaidAccountId = const Value.absent(),
    this.internalAccountId = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.mask = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  PlaidAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String plaidAccountId,
    required int internalAccountId,
    required String institutionName,
    required String mask,
    this.syncedAt = const Value.absent(),
  })  : plaidAccountId = Value(plaidAccountId),
        internalAccountId = Value(internalAccountId),
        institutionName = Value(institutionName),
        mask = Value(mask);
  static Insertable<PlaidAccount> custom({
    Expression<int>? id,
    Expression<String>? plaidAccountId,
    Expression<int>? internalAccountId,
    Expression<String>? institutionName,
    Expression<String>? mask,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plaidAccountId != null) 'plaid_account_id': plaidAccountId,
      if (internalAccountId != null) 'internal_account_id': internalAccountId,
      if (institutionName != null) 'institution_name': institutionName,
      if (mask != null) 'mask': mask,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  PlaidAccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? plaidAccountId,
      Value<int>? internalAccountId,
      Value<String>? institutionName,
      Value<String>? mask,
      Value<DateTime?>? syncedAt}) {
    return PlaidAccountsCompanion(
      id: id ?? this.id,
      plaidAccountId: plaidAccountId ?? this.plaidAccountId,
      internalAccountId: internalAccountId ?? this.internalAccountId,
      institutionName: institutionName ?? this.institutionName,
      mask: mask ?? this.mask,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plaidAccountId.present) {
      map['plaid_account_id'] = Variable<String>(plaidAccountId.value);
    }
    if (internalAccountId.present) {
      map['internal_account_id'] = Variable<int>(internalAccountId.value);
    }
    if (institutionName.present) {
      map['institution_name'] = Variable<String>(institutionName.value);
    }
    if (mask.present) {
      map['mask'] = Variable<String>(mask.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaidAccountsCompanion(')
          ..write('id: $id, ')
          ..write('plaidAccountId: $plaidAccountId, ')
          ..write('internalAccountId: $internalAccountId, ')
          ..write('institutionName: $institutionName, ')
          ..write('mask: $mask, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $PendingReviewTransactionsTable extends PendingReviewTransactions
    with TableInfo<$PendingReviewTransactionsTable, PendingReviewTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingReviewTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _plaidTransactionIdMeta =
      const VerificationMeta('plaidTransactionId');
  @override
  late final GeneratedColumn<String> plaidTransactionId =
      GeneratedColumn<String>('plaid_transaction_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES accounts (id)'));
  static const VerificationMeta _amountCentsMeta =
      const VerificationMeta('amountCents');
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
      'amount_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _payeeMeta = const VerificationMeta('payee');
  @override
  late final GeneratedColumn<String> payee = GeneratedColumn<String>(
      'payee', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pairedPlaidTransactionIdMeta =
      const VerificationMeta('pairedPlaidTransactionId');
  @override
  late final GeneratedColumn<String> pairedPlaidTransactionId =
      GeneratedColumn<String>('paired_plaid_transaction_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        plaidTransactionId,
        accountId,
        amountCents,
        date,
        payee,
        reason,
        pairedPlaidTransactionId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_review_transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingReviewTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plaid_transaction_id')) {
      context.handle(
          _plaidTransactionIdMeta,
          plaidTransactionId.isAcceptableOrUnknown(
              data['plaid_transaction_id']!, _plaidTransactionIdMeta));
    } else if (isInserting) {
      context.missing(_plaidTransactionIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
          _amountCentsMeta,
          amountCents.isAcceptableOrUnknown(
              data['amount_cents']!, _amountCentsMeta));
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payee')) {
      context.handle(
          _payeeMeta, payee.isAcceptableOrUnknown(data['payee']!, _payeeMeta));
    } else if (isInserting) {
      context.missing(_payeeMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('paired_plaid_transaction_id')) {
      context.handle(
          _pairedPlaidTransactionIdMeta,
          pairedPlaidTransactionId.isAcceptableOrUnknown(
              data['paired_plaid_transaction_id']!,
              _pairedPlaidTransactionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingReviewTransaction map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingReviewTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      plaidTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}plaid_transaction_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      amountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_cents'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      payee: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payee'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      pairedPlaidTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}paired_plaid_transaction_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PendingReviewTransactionsTable createAlias(String alias) {
    return $PendingReviewTransactionsTable(attachedDatabase, alias);
  }
}

class PendingReviewTransaction extends DataClass
    implements Insertable<PendingReviewTransaction> {
  final int id;
  final String plaidTransactionId;
  final int accountId;
  final int amountCents;
  final DateTime date;
  final String payee;
  final String reason;
  final String? pairedPlaidTransactionId;
  final DateTime createdAt;
  const PendingReviewTransaction(
      {required this.id,
      required this.plaidTransactionId,
      required this.accountId,
      required this.amountCents,
      required this.date,
      required this.payee,
      required this.reason,
      this.pairedPlaidTransactionId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plaid_transaction_id'] = Variable<String>(plaidTransactionId);
    map['account_id'] = Variable<int>(accountId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['date'] = Variable<DateTime>(date);
    map['payee'] = Variable<String>(payee);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || pairedPlaidTransactionId != null) {
      map['paired_plaid_transaction_id'] =
          Variable<String>(pairedPlaidTransactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingReviewTransactionsCompanion toCompanion(bool nullToAbsent) {
    return PendingReviewTransactionsCompanion(
      id: Value(id),
      plaidTransactionId: Value(plaidTransactionId),
      accountId: Value(accountId),
      amountCents: Value(amountCents),
      date: Value(date),
      payee: Value(payee),
      reason: Value(reason),
      pairedPlaidTransactionId: pairedPlaidTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairedPlaidTransactionId),
      createdAt: Value(createdAt),
    );
  }

  factory PendingReviewTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingReviewTransaction(
      id: serializer.fromJson<int>(json['id']),
      plaidTransactionId:
          serializer.fromJson<String>(json['plaidTransactionId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      date: serializer.fromJson<DateTime>(json['date']),
      payee: serializer.fromJson<String>(json['payee']),
      reason: serializer.fromJson<String>(json['reason']),
      pairedPlaidTransactionId:
          serializer.fromJson<String?>(json['pairedPlaidTransactionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plaidTransactionId': serializer.toJson<String>(plaidTransactionId),
      'accountId': serializer.toJson<int>(accountId),
      'amountCents': serializer.toJson<int>(amountCents),
      'date': serializer.toJson<DateTime>(date),
      'payee': serializer.toJson<String>(payee),
      'reason': serializer.toJson<String>(reason),
      'pairedPlaidTransactionId':
          serializer.toJson<String?>(pairedPlaidTransactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingReviewTransaction copyWith(
          {int? id,
          String? plaidTransactionId,
          int? accountId,
          int? amountCents,
          DateTime? date,
          String? payee,
          String? reason,
          Value<String?> pairedPlaidTransactionId = const Value.absent(),
          DateTime? createdAt}) =>
      PendingReviewTransaction(
        id: id ?? this.id,
        plaidTransactionId: plaidTransactionId ?? this.plaidTransactionId,
        accountId: accountId ?? this.accountId,
        amountCents: amountCents ?? this.amountCents,
        date: date ?? this.date,
        payee: payee ?? this.payee,
        reason: reason ?? this.reason,
        pairedPlaidTransactionId: pairedPlaidTransactionId.present
            ? pairedPlaidTransactionId.value
            : this.pairedPlaidTransactionId,
        createdAt: createdAt ?? this.createdAt,
      );
  PendingReviewTransaction copyWithCompanion(
      PendingReviewTransactionsCompanion data) {
    return PendingReviewTransaction(
      id: data.id.present ? data.id.value : this.id,
      plaidTransactionId: data.plaidTransactionId.present
          ? data.plaidTransactionId.value
          : this.plaidTransactionId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountCents:
          data.amountCents.present ? data.amountCents.value : this.amountCents,
      date: data.date.present ? data.date.value : this.date,
      payee: data.payee.present ? data.payee.value : this.payee,
      reason: data.reason.present ? data.reason.value : this.reason,
      pairedPlaidTransactionId: data.pairedPlaidTransactionId.present
          ? data.pairedPlaidTransactionId.value
          : this.pairedPlaidTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingReviewTransaction(')
          ..write('id: $id, ')
          ..write('plaidTransactionId: $plaidTransactionId, ')
          ..write('accountId: $accountId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('payee: $payee, ')
          ..write('reason: $reason, ')
          ..write('pairedPlaidTransactionId: $pairedPlaidTransactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plaidTransactionId, accountId,
      amountCents, date, payee, reason, pairedPlaidTransactionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingReviewTransaction &&
          other.id == this.id &&
          other.plaidTransactionId == this.plaidTransactionId &&
          other.accountId == this.accountId &&
          other.amountCents == this.amountCents &&
          other.date == this.date &&
          other.payee == this.payee &&
          other.reason == this.reason &&
          other.pairedPlaidTransactionId == this.pairedPlaidTransactionId &&
          other.createdAt == this.createdAt);
}

class PendingReviewTransactionsCompanion
    extends UpdateCompanion<PendingReviewTransaction> {
  final Value<int> id;
  final Value<String> plaidTransactionId;
  final Value<int> accountId;
  final Value<int> amountCents;
  final Value<DateTime> date;
  final Value<String> payee;
  final Value<String> reason;
  final Value<String?> pairedPlaidTransactionId;
  final Value<DateTime> createdAt;
  const PendingReviewTransactionsCompanion({
    this.id = const Value.absent(),
    this.plaidTransactionId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.date = const Value.absent(),
    this.payee = const Value.absent(),
    this.reason = const Value.absent(),
    this.pairedPlaidTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingReviewTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String plaidTransactionId,
    required int accountId,
    required int amountCents,
    required DateTime date,
    required String payee,
    required String reason,
    this.pairedPlaidTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : plaidTransactionId = Value(plaidTransactionId),
        accountId = Value(accountId),
        amountCents = Value(amountCents),
        date = Value(date),
        payee = Value(payee),
        reason = Value(reason);
  static Insertable<PendingReviewTransaction> custom({
    Expression<int>? id,
    Expression<String>? plaidTransactionId,
    Expression<int>? accountId,
    Expression<int>? amountCents,
    Expression<DateTime>? date,
    Expression<String>? payee,
    Expression<String>? reason,
    Expression<String>? pairedPlaidTransactionId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plaidTransactionId != null)
        'plaid_transaction_id': plaidTransactionId,
      if (accountId != null) 'account_id': accountId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (date != null) 'date': date,
      if (payee != null) 'payee': payee,
      if (reason != null) 'reason': reason,
      if (pairedPlaidTransactionId != null)
        'paired_plaid_transaction_id': pairedPlaidTransactionId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingReviewTransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? plaidTransactionId,
      Value<int>? accountId,
      Value<int>? amountCents,
      Value<DateTime>? date,
      Value<String>? payee,
      Value<String>? reason,
      Value<String?>? pairedPlaidTransactionId,
      Value<DateTime>? createdAt}) {
    return PendingReviewTransactionsCompanion(
      id: id ?? this.id,
      plaidTransactionId: plaidTransactionId ?? this.plaidTransactionId,
      accountId: accountId ?? this.accountId,
      amountCents: amountCents ?? this.amountCents,
      date: date ?? this.date,
      payee: payee ?? this.payee,
      reason: reason ?? this.reason,
      pairedPlaidTransactionId:
          pairedPlaidTransactionId ?? this.pairedPlaidTransactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plaidTransactionId.present) {
      map['plaid_transaction_id'] = Variable<String>(plaidTransactionId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (payee.present) {
      map['payee'] = Variable<String>(payee.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (pairedPlaidTransactionId.present) {
      map['paired_plaid_transaction_id'] =
          Variable<String>(pairedPlaidTransactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingReviewTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('plaidTransactionId: $plaidTransactionId, ')
          ..write('accountId: $accountId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('payee: $payee, ')
          ..write('reason: $reason, ')
          ..write('pairedPlaidTransactionId: $pairedPlaidTransactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoryGroupsTable categoryGroups = $CategoryGroupsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $MonthlyBudgetsTable monthlyBudgets = $MonthlyBudgetsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $NetWorthSnapshotsTable netWorthSnapshots =
      $NetWorthSnapshotsTable(this);
  late final $BudgetSnapshotsTable budgetSnapshots =
      $BudgetSnapshotsTable(this);
  late final $PendingRecurringQueueTable pendingRecurringQueue =
      $PendingRecurringQueueTable(this);
  late final $PlaidAccountsTable plaidAccounts = $PlaidAccountsTable(this);
  late final $PendingReviewTransactionsTable pendingReviewTransactions =
      $PendingReviewTransactionsTable(this);
  late final AccountsDao accountsDao = AccountsDao(this as AppDatabase);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final TransactionsDao transactionsDao =
      TransactionsDao(this as AppDatabase);
  late final BudgetDao budgetDao = BudgetDao(this as AppDatabase);
  late final BudgetSnapshotsDao budgetSnapshotsDao =
      BudgetSnapshotsDao(this as AppDatabase);
  late final RecurringQueueDao recurringQueueDao =
      RecurringQueueDao(this as AppDatabase);
  late final PlaidDao plaidDao = PlaidDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        categoryGroups,
        categories,
        monthlyBudgets,
        transactions,
        netWorthSnapshots,
        budgetSnapshots,
        pendingRecurringQueue,
        plaidAccounts,
        pendingReviewTransactions
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  required String type,
  Value<int> balanceCents,
  Value<String?> institution,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<int> balanceCents,
  Value<String?> institution,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaidAccountsTable, List<PlaidAccount>>
      _plaidAccountsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.plaidAccounts,
              aliasName: $_aliasNameGenerator(
                  db.accounts.id, db.plaidAccounts.internalAccountId));

  $$PlaidAccountsTableProcessedTableManager get plaidAccountsRefs {
    final manager = $$PlaidAccountsTableTableManager($_db, $_db.plaidAccounts)
        .filter(
            (f) => f.internalAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_plaidAccountsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PendingReviewTransactionsTable,
      List<PendingReviewTransaction>> _pendingReviewTransactionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pendingReviewTransactions,
          aliasName: $_aliasNameGenerator(
              db.accounts.id, db.pendingReviewTransactions.accountId));

  $$PendingReviewTransactionsTableProcessedTableManager
      get pendingReviewTransactionsRefs {
    final manager = $$PendingReviewTransactionsTableTableManager(
            $_db, $_db.pendingReviewTransactions)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_pendingReviewTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balanceCents => $composableBuilder(
      column: $table.balanceCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get institution => $composableBuilder(
      column: $table.institution, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  Expression<bool> plaidAccountsRefs(
      Expression<bool> Function($$PlaidAccountsTableFilterComposer f) f) {
    final $$PlaidAccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plaidAccounts,
        getReferencedColumn: (t) => t.internalAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaidAccountsTableFilterComposer(
              $db: $db,
              $table: $db.plaidAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pendingReviewTransactionsRefs(
      Expression<bool> Function(
              $$PendingReviewTransactionsTableFilterComposer f)
          f) {
    final $$PendingReviewTransactionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pendingReviewTransactions,
            getReferencedColumn: (t) => t.accountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PendingReviewTransactionsTableFilterComposer(
                  $db: $db,
                  $table: $db.pendingReviewTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balanceCents => $composableBuilder(
      column: $table.balanceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get institution => $composableBuilder(
      column: $table.institution, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get balanceCents => $composableBuilder(
      column: $table.balanceCents, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
      column: $table.institution, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> plaidAccountsRefs<T extends Object>(
      Expression<T> Function($$PlaidAccountsTableAnnotationComposer a) f) {
    final $$PlaidAccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.plaidAccounts,
        getReferencedColumn: (t) => t.internalAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaidAccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.plaidAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pendingReviewTransactionsRefs<T extends Object>(
      Expression<T> Function(
              $$PendingReviewTransactionsTableAnnotationComposer a)
          f) {
    final $$PendingReviewTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pendingReviewTransactions,
            getReferencedColumn: (t) => t.accountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PendingReviewTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pendingReviewTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function(
        {bool plaidAccountsRefs, bool pendingReviewTransactionsRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> balanceCents = const Value.absent(),
            Value<String?> institution = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            type: type,
            balanceCents: balanceCents,
            institution: institution,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String type,
            Value<int> balanceCents = const Value.absent(),
            Value<String?> institution = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            type: type,
            balanceCents: balanceCents,
            institution: institution,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {plaidAccountsRefs = false,
              pendingReviewTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (plaidAccountsRefs) db.plaidAccounts,
                if (pendingReviewTransactionsRefs) db.pendingReviewTransactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plaidAccountsRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            PlaidAccount>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._plaidAccountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .plaidAccountsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.internalAccountId == item.id),
                        typedResults: items),
                  if (pendingReviewTransactionsRefs)
                    await $_getPrefetchedData<Account, $AccountsTable, PendingReviewTransaction>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._pendingReviewTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .pendingReviewTransactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function(
        {bool plaidAccountsRefs, bool pendingReviewTransactionsRefs})>;
typedef $$CategoryGroupsTableCreateCompanionBuilder = CategoryGroupsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<int> sortOrder,
  Value<bool> isDeleted,
});
typedef $$CategoryGroupsTableUpdateCompanionBuilder = CategoryGroupsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<bool> isDeleted,
});

final class $$CategoryGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $CategoryGroupsTable, CategoryGroup> {
  $$CategoryGroupsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CategoriesTable, List<Category>>
      _categoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.categories,
              aliasName: $_aliasNameGenerator(
                  db.categoryGroups.id, db.categories.groupId));

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoryGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryGroupsTable> {
  $$CategoryGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  Expression<bool> categoriesRefs(
      Expression<bool> Function($$CategoriesTableFilterComposer f) f) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoryGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryGroupsTable> {
  $$CategoryGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$CategoryGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryGroupsTable> {
  $$CategoryGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> categoriesRefs<T extends Object>(
      Expression<T> Function($$CategoriesTableAnnotationComposer a) f) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoryGroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryGroupsTable,
    CategoryGroup,
    $$CategoryGroupsTableFilterComposer,
    $$CategoryGroupsTableOrderingComposer,
    $$CategoryGroupsTableAnnotationComposer,
    $$CategoryGroupsTableCreateCompanionBuilder,
    $$CategoryGroupsTableUpdateCompanionBuilder,
    (CategoryGroup, $$CategoryGroupsTableReferences),
    CategoryGroup,
    PrefetchHooks Function({bool categoriesRefs})> {
  $$CategoryGroupsTableTableManager(
      _$AppDatabase db, $CategoryGroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              CategoryGroupsCompanion(
            id: id,
            name: name,
            sortOrder: sortOrder,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              CategoryGroupsCompanion.insert(
            id: id,
            name: name,
            sortOrder: sortOrder,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoryGroupsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (categoriesRefs) db.categories],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (categoriesRefs)
                    await $_getPrefetchedData<CategoryGroup,
                            $CategoryGroupsTable, Category>(
                        currentTable: table,
                        referencedTable: $$CategoryGroupsTableReferences
                            ._categoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryGroupsTableReferences(db, table, p0)
                                .categoriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoryGroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryGroupsTable,
    CategoryGroup,
    $$CategoryGroupsTableFilterComposer,
    $$CategoryGroupsTableOrderingComposer,
    $$CategoryGroupsTableAnnotationComposer,
    $$CategoryGroupsTableCreateCompanionBuilder,
    $$CategoryGroupsTableUpdateCompanionBuilder,
    (CategoryGroup, $$CategoryGroupsTableReferences),
    CategoryGroup,
    PrefetchHooks Function({bool categoriesRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required int groupId,
  required String name,
  Value<bool> rollover,
  Value<int?> goalAmountCents,
  Value<DateTime?> goalDate,
  Value<String?> goalType,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<int> groupId,
  Value<String> name,
  Value<bool> rollover,
  Value<int?> goalAmountCents,
  Value<DateTime?> goalDate,
  Value<String?> goalType,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoryGroupsTable _groupIdTable(_$AppDatabase db) =>
      db.categoryGroups.createAlias(
          $_aliasNameGenerator(db.categories.groupId, db.categoryGroups.id));

  $$CategoryGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$CategoryGroupsTableTableManager($_db, $_db.categoryGroups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MonthlyBudgetsTable, List<MonthlyBudget>>
      _monthlyBudgetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.monthlyBudgets,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.monthlyBudgets.categoryId));

  $$MonthlyBudgetsTableProcessedTableManager get monthlyBudgetsRefs {
    final manager = $$MonthlyBudgetsTableTableManager($_db, $_db.monthlyBudgets)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_monthlyBudgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.transactions.categoryId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BudgetSnapshotsTable, List<BudgetSnapshot>>
      _budgetSnapshotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.budgetSnapshots,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.budgetSnapshots.categoryId));

  $$BudgetSnapshotsTableProcessedTableManager get budgetSnapshotsRefs {
    final manager =
        $$BudgetSnapshotsTableTableManager($_db, $_db.budgetSnapshots)
            .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_budgetSnapshotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rollover => $composableBuilder(
      column: $table.rollover, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goalAmountCents => $composableBuilder(
      column: $table.goalAmountCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get goalDate => $composableBuilder(
      column: $table.goalDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalType => $composableBuilder(
      column: $table.goalType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  $$CategoryGroupsTableFilterComposer get groupId {
    final $$CategoryGroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.categoryGroups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryGroupsTableFilterComposer(
              $db: $db,
              $table: $db.categoryGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> monthlyBudgetsRefs(
      Expression<bool> Function($$MonthlyBudgetsTableFilterComposer f) f) {
    final $$MonthlyBudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.monthlyBudgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MonthlyBudgetsTableFilterComposer(
              $db: $db,
              $table: $db.monthlyBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> budgetSnapshotsRefs(
      Expression<bool> Function($$BudgetSnapshotsTableFilterComposer f) f) {
    final $$BudgetSnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetSnapshots,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetSnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.budgetSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rollover => $composableBuilder(
      column: $table.rollover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goalAmountCents => $composableBuilder(
      column: $table.goalAmountCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get goalDate => $composableBuilder(
      column: $table.goalDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalType => $composableBuilder(
      column: $table.goalType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  $$CategoryGroupsTableOrderingComposer get groupId {
    final $$CategoryGroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.categoryGroups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryGroupsTableOrderingComposer(
              $db: $db,
              $table: $db.categoryGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get rollover =>
      $composableBuilder(column: $table.rollover, builder: (column) => column);

  GeneratedColumn<int> get goalAmountCents => $composableBuilder(
      column: $table.goalAmountCents, builder: (column) => column);

  GeneratedColumn<DateTime> get goalDate =>
      $composableBuilder(column: $table.goalDate, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$CategoryGroupsTableAnnotationComposer get groupId {
    final $$CategoryGroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.categoryGroups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryGroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.categoryGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> monthlyBudgetsRefs<T extends Object>(
      Expression<T> Function($$MonthlyBudgetsTableAnnotationComposer a) f) {
    final $$MonthlyBudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.monthlyBudgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MonthlyBudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.monthlyBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> budgetSnapshotsRefs<T extends Object>(
      Expression<T> Function($$BudgetSnapshotsTableAnnotationComposer a) f) {
    final $$BudgetSnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgetSnapshots,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetSnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgetSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool groupId,
        bool monthlyBudgetsRefs,
        bool transactionsRefs,
        bool budgetSnapshotsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> groupId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> rollover = const Value.absent(),
            Value<int?> goalAmountCents = const Value.absent(),
            Value<DateTime?> goalDate = const Value.absent(),
            Value<String?> goalType = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            groupId: groupId,
            name: name,
            rollover: rollover,
            goalAmountCents: goalAmountCents,
            goalDate: goalDate,
            goalType: goalType,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int groupId,
            required String name,
            Value<bool> rollover = const Value.absent(),
            Value<int?> goalAmountCents = const Value.absent(),
            Value<DateTime?> goalDate = const Value.absent(),
            Value<String?> goalType = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            groupId: groupId,
            name: name,
            rollover: rollover,
            goalAmountCents: goalAmountCents,
            goalDate: goalDate,
            goalType: goalType,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {groupId = false,
              monthlyBudgetsRefs = false,
              transactionsRefs = false,
              budgetSnapshotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (monthlyBudgetsRefs) db.monthlyBudgets,
                if (transactionsRefs) db.transactions,
                if (budgetSnapshotsRefs) db.budgetSnapshots
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$CategoriesTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$CategoriesTableReferences._groupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (monthlyBudgetsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            MonthlyBudget>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._monthlyBudgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .monthlyBudgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (transactionsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (budgetSnapshotsRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable,
                            BudgetSnapshot>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._budgetSnapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .budgetSnapshotsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function(
        {bool groupId,
        bool monthlyBudgetsRefs,
        bool transactionsRefs,
        bool budgetSnapshotsRefs})>;
typedef $$MonthlyBudgetsTableCreateCompanionBuilder = MonthlyBudgetsCompanion
    Function({
  Value<int> id,
  required int categoryId,
  required String month,
  Value<int> assignedCents,
  Value<int> rolledOverCents,
  Value<DateTime> updatedAt,
});
typedef $$MonthlyBudgetsTableUpdateCompanionBuilder = MonthlyBudgetsCompanion
    Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> month,
  Value<int> assignedCents,
  Value<int> rolledOverCents,
  Value<DateTime> updatedAt,
});

final class $$MonthlyBudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $MonthlyBudgetsTable, MonthlyBudget> {
  $$MonthlyBudgetsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.monthlyBudgets.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MonthlyBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlyBudgetsTable> {
  $$MonthlyBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get assignedCents => $composableBuilder(
      column: $table.assignedCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rolledOverCents => $composableBuilder(
      column: $table.rolledOverCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MonthlyBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlyBudgetsTable> {
  $$MonthlyBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get assignedCents => $composableBuilder(
      column: $table.assignedCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rolledOverCents => $composableBuilder(
      column: $table.rolledOverCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MonthlyBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlyBudgetsTable> {
  $$MonthlyBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get assignedCents => $composableBuilder(
      column: $table.assignedCents, builder: (column) => column);

  GeneratedColumn<int> get rolledOverCents => $composableBuilder(
      column: $table.rolledOverCents, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MonthlyBudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MonthlyBudgetsTable,
    MonthlyBudget,
    $$MonthlyBudgetsTableFilterComposer,
    $$MonthlyBudgetsTableOrderingComposer,
    $$MonthlyBudgetsTableAnnotationComposer,
    $$MonthlyBudgetsTableCreateCompanionBuilder,
    $$MonthlyBudgetsTableUpdateCompanionBuilder,
    (MonthlyBudget, $$MonthlyBudgetsTableReferences),
    MonthlyBudget,
    PrefetchHooks Function({bool categoryId})> {
  $$MonthlyBudgetsTableTableManager(
      _$AppDatabase db, $MonthlyBudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlyBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> month = const Value.absent(),
            Value<int> assignedCents = const Value.absent(),
            Value<int> rolledOverCents = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MonthlyBudgetsCompanion(
            id: id,
            categoryId: categoryId,
            month: month,
            assignedCents: assignedCents,
            rolledOverCents: rolledOverCents,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String month,
            Value<int> assignedCents = const Value.absent(),
            Value<int> rolledOverCents = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MonthlyBudgetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            month: month,
            assignedCents: assignedCents,
            rolledOverCents: rolledOverCents,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MonthlyBudgetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$MonthlyBudgetsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$MonthlyBudgetsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MonthlyBudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MonthlyBudgetsTable,
    MonthlyBudget,
    $$MonthlyBudgetsTableFilterComposer,
    $$MonthlyBudgetsTableOrderingComposer,
    $$MonthlyBudgetsTableAnnotationComposer,
    $$MonthlyBudgetsTableCreateCompanionBuilder,
    $$MonthlyBudgetsTableUpdateCompanionBuilder,
    (MonthlyBudget, $$MonthlyBudgetsTableReferences),
    MonthlyBudget,
    PrefetchHooks Function({bool categoryId})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required int accountId,
  Value<int?> categoryId,
  required int amountCents,
  required String payee,
  required DateTime date,
  Value<String?> memo,
  required String type,
  Value<bool> cleared,
  Value<bool> recurring,
  Value<String?> recurringInterval,
  Value<DateTime?> nextDueDate,
  Value<String?> importedFrom,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int?> toAccountId,
  Value<bool> isDeleted,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<int> accountId,
  Value<int?> categoryId,
  Value<int> amountCents,
  Value<String> payee,
  Value<DateTime> date,
  Value<String?> memo,
  Value<String> type,
  Value<bool> cleared,
  Value<bool> recurring,
  Value<String?> recurringInterval,
  Value<DateTime?> nextDueDate,
  Value<String?> importedFrom,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int?> toAccountId,
  Value<bool> isDeleted,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.transactions.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.transactions.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AccountsTable _toAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias(
          $_aliasNameGenerator(db.transactions.toAccountId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get toAccountId {
    final $_column = $_itemColumn<int>('to_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PendingRecurringQueueTable,
      List<PendingRecurringQueueData>> _pendingRecurringQueueRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pendingRecurringQueue,
          aliasName: $_aliasNameGenerator(db.transactions.id,
              db.pendingRecurringQueue.sourceTransactionId));

  $$PendingRecurringQueueTableProcessedTableManager
      get pendingRecurringQueueRefs {
    final manager = $$PendingRecurringQueueTableTableManager(
            $_db, $_db.pendingRecurringQueue)
        .filter((f) =>
            f.sourceTransactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pendingRecurringQueueRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payee => $composableBuilder(
      column: $table.payee, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cleared => $composableBuilder(
      column: $table.cleared, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get recurring => $composableBuilder(
      column: $table.recurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurringInterval => $composableBuilder(
      column: $table.recurringInterval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get importedFrom => $composableBuilder(
      column: $table.importedFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> pendingRecurringQueueRefs(
      Expression<bool> Function($$PendingRecurringQueueTableFilterComposer f)
          f) {
    final $$PendingRecurringQueueTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pendingRecurringQueue,
            getReferencedColumn: (t) => t.sourceTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PendingRecurringQueueTableFilterComposer(
                  $db: $db,
                  $table: $db.pendingRecurringQueue,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payee => $composableBuilder(
      column: $table.payee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cleared => $composableBuilder(
      column: $table.cleared, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get recurring => $composableBuilder(
      column: $table.recurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringInterval => $composableBuilder(
      column: $table.recurringInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get importedFrom => $composableBuilder(
      column: $table.importedFrom,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => column);

  GeneratedColumn<String> get payee =>
      $composableBuilder(column: $table.payee, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get cleared =>
      $composableBuilder(column: $table.cleared, builder: (column) => column);

  GeneratedColumn<bool> get recurring =>
      $composableBuilder(column: $table.recurring, builder: (column) => column);

  GeneratedColumn<String> get recurringInterval => $composableBuilder(
      column: $table.recurringInterval, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<String> get importedFrom => $composableBuilder(
      column: $table.importedFrom, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> pendingRecurringQueueRefs<T extends Object>(
      Expression<T> Function($$PendingRecurringQueueTableAnnotationComposer a)
          f) {
    final $$PendingRecurringQueueTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pendingRecurringQueue,
            getReferencedColumn: (t) => t.sourceTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PendingRecurringQueueTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pendingRecurringQueue,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool accountId,
        bool categoryId,
        bool toAccountId,
        bool pendingRecurringQueueRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<int> amountCents = const Value.absent(),
            Value<String> payee = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> cleared = const Value.absent(),
            Value<bool> recurring = const Value.absent(),
            Value<String?> recurringInterval = const Value.absent(),
            Value<DateTime?> nextDueDate = const Value.absent(),
            Value<String?> importedFrom = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> toAccountId = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amountCents: amountCents,
            payee: payee,
            date: date,
            memo: memo,
            type: type,
            cleared: cleared,
            recurring: recurring,
            recurringInterval: recurringInterval,
            nextDueDate: nextDueDate,
            importedFrom: importedFrom,
            createdAt: createdAt,
            updatedAt: updatedAt,
            toAccountId: toAccountId,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int accountId,
            Value<int?> categoryId = const Value.absent(),
            required int amountCents,
            required String payee,
            required DateTime date,
            Value<String?> memo = const Value.absent(),
            required String type,
            Value<bool> cleared = const Value.absent(),
            Value<bool> recurring = const Value.absent(),
            Value<String?> recurringInterval = const Value.absent(),
            Value<DateTime?> nextDueDate = const Value.absent(),
            Value<String?> importedFrom = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> toAccountId = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amountCents: amountCents,
            payee: payee,
            date: date,
            memo: memo,
            type: type,
            cleared: cleared,
            recurring: recurring,
            recurringInterval: recurringInterval,
            nextDueDate: nextDueDate,
            importedFrom: importedFrom,
            createdAt: createdAt,
            updatedAt: updatedAt,
            toAccountId: toAccountId,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {accountId = false,
              categoryId = false,
              toAccountId = false,
              pendingRecurringQueueRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pendingRecurringQueueRefs) db.pendingRecurringQueue
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable:
                        $$TransactionsTableReferences._accountIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._accountIdTable(db).id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$TransactionsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (toAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toAccountId,
                    referencedTable:
                        $$TransactionsTableReferences._toAccountIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._toAccountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pendingRecurringQueueRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            PendingRecurringQueueData>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._pendingRecurringQueueRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .pendingRecurringQueueRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sourceTransactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool accountId,
        bool categoryId,
        bool toAccountId,
        bool pendingRecurringQueueRefs})>;
typedef $$NetWorthSnapshotsTableCreateCompanionBuilder
    = NetWorthSnapshotsCompanion Function({
  Value<int> id,
  required DateTime date,
  required int totalAssetsCents,
  required int totalLiabilitiesCents,
  required int netWorthCents,
});
typedef $$NetWorthSnapshotsTableUpdateCompanionBuilder
    = NetWorthSnapshotsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> totalAssetsCents,
  Value<int> totalLiabilitiesCents,
  Value<int> netWorthCents,
});

class $$NetWorthSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $NetWorthSnapshotsTable> {
  $$NetWorthSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalAssetsCents => $composableBuilder(
      column: $table.totalAssetsCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLiabilitiesCents => $composableBuilder(
      column: $table.totalLiabilitiesCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get netWorthCents => $composableBuilder(
      column: $table.netWorthCents, builder: (column) => ColumnFilters(column));
}

class $$NetWorthSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $NetWorthSnapshotsTable> {
  $$NetWorthSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalAssetsCents => $composableBuilder(
      column: $table.totalAssetsCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLiabilitiesCents => $composableBuilder(
      column: $table.totalLiabilitiesCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get netWorthCents => $composableBuilder(
      column: $table.netWorthCents,
      builder: (column) => ColumnOrderings(column));
}

class $$NetWorthSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetWorthSnapshotsTable> {
  $$NetWorthSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get totalAssetsCents => $composableBuilder(
      column: $table.totalAssetsCents, builder: (column) => column);

  GeneratedColumn<int> get totalLiabilitiesCents => $composableBuilder(
      column: $table.totalLiabilitiesCents, builder: (column) => column);

  GeneratedColumn<int> get netWorthCents => $composableBuilder(
      column: $table.netWorthCents, builder: (column) => column);
}

class $$NetWorthSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NetWorthSnapshotsTable,
    NetWorthSnapshot,
    $$NetWorthSnapshotsTableFilterComposer,
    $$NetWorthSnapshotsTableOrderingComposer,
    $$NetWorthSnapshotsTableAnnotationComposer,
    $$NetWorthSnapshotsTableCreateCompanionBuilder,
    $$NetWorthSnapshotsTableUpdateCompanionBuilder,
    (
      NetWorthSnapshot,
      BaseReferences<_$AppDatabase, $NetWorthSnapshotsTable, NetWorthSnapshot>
    ),
    NetWorthSnapshot,
    PrefetchHooks Function()> {
  $$NetWorthSnapshotsTableTableManager(
      _$AppDatabase db, $NetWorthSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetWorthSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetWorthSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetWorthSnapshotsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> totalAssetsCents = const Value.absent(),
            Value<int> totalLiabilitiesCents = const Value.absent(),
            Value<int> netWorthCents = const Value.absent(),
          }) =>
              NetWorthSnapshotsCompanion(
            id: id,
            date: date,
            totalAssetsCents: totalAssetsCents,
            totalLiabilitiesCents: totalLiabilitiesCents,
            netWorthCents: netWorthCents,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required int totalAssetsCents,
            required int totalLiabilitiesCents,
            required int netWorthCents,
          }) =>
              NetWorthSnapshotsCompanion.insert(
            id: id,
            date: date,
            totalAssetsCents: totalAssetsCents,
            totalLiabilitiesCents: totalLiabilitiesCents,
            netWorthCents: netWorthCents,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NetWorthSnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NetWorthSnapshotsTable,
    NetWorthSnapshot,
    $$NetWorthSnapshotsTableFilterComposer,
    $$NetWorthSnapshotsTableOrderingComposer,
    $$NetWorthSnapshotsTableAnnotationComposer,
    $$NetWorthSnapshotsTableCreateCompanionBuilder,
    $$NetWorthSnapshotsTableUpdateCompanionBuilder,
    (
      NetWorthSnapshot,
      BaseReferences<_$AppDatabase, $NetWorthSnapshotsTable, NetWorthSnapshot>
    ),
    NetWorthSnapshot,
    PrefetchHooks Function()>;
typedef $$BudgetSnapshotsTableCreateCompanionBuilder = BudgetSnapshotsCompanion
    Function({
  Value<int> id,
  required int categoryId,
  required String month,
  Value<int> assignedCents,
  Value<int> spentCents,
  Value<DateTime> createdAt,
});
typedef $$BudgetSnapshotsTableUpdateCompanionBuilder = BudgetSnapshotsCompanion
    Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> month,
  Value<int> assignedCents,
  Value<int> spentCents,
  Value<DateTime> createdAt,
});

final class $$BudgetSnapshotsTableReferences extends BaseReferences<
    _$AppDatabase, $BudgetSnapshotsTable, BudgetSnapshot> {
  $$BudgetSnapshotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.budgetSnapshots.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BudgetSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetSnapshotsTable> {
  $$BudgetSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get assignedCents => $composableBuilder(
      column: $table.assignedCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spentCents => $composableBuilder(
      column: $table.spentCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetSnapshotsTable> {
  $$BudgetSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get assignedCents => $composableBuilder(
      column: $table.assignedCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spentCents => $composableBuilder(
      column: $table.spentCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetSnapshotsTable> {
  $$BudgetSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get assignedCents => $composableBuilder(
      column: $table.assignedCents, builder: (column) => column);

  GeneratedColumn<int> get spentCents => $composableBuilder(
      column: $table.spentCents, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetSnapshotsTable,
    BudgetSnapshot,
    $$BudgetSnapshotsTableFilterComposer,
    $$BudgetSnapshotsTableOrderingComposer,
    $$BudgetSnapshotsTableAnnotationComposer,
    $$BudgetSnapshotsTableCreateCompanionBuilder,
    $$BudgetSnapshotsTableUpdateCompanionBuilder,
    (BudgetSnapshot, $$BudgetSnapshotsTableReferences),
    BudgetSnapshot,
    PrefetchHooks Function({bool categoryId})> {
  $$BudgetSnapshotsTableTableManager(
      _$AppDatabase db, $BudgetSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> month = const Value.absent(),
            Value<int> assignedCents = const Value.absent(),
            Value<int> spentCents = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BudgetSnapshotsCompanion(
            id: id,
            categoryId: categoryId,
            month: month,
            assignedCents: assignedCents,
            spentCents: spentCents,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String month,
            Value<int> assignedCents = const Value.absent(),
            Value<int> spentCents = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BudgetSnapshotsCompanion.insert(
            id: id,
            categoryId: categoryId,
            month: month,
            assignedCents: assignedCents,
            spentCents: spentCents,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BudgetSnapshotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$BudgetSnapshotsTableReferences._categoryIdTable(db),
                    referencedColumn: $$BudgetSnapshotsTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BudgetSnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetSnapshotsTable,
    BudgetSnapshot,
    $$BudgetSnapshotsTableFilterComposer,
    $$BudgetSnapshotsTableOrderingComposer,
    $$BudgetSnapshotsTableAnnotationComposer,
    $$BudgetSnapshotsTableCreateCompanionBuilder,
    $$BudgetSnapshotsTableUpdateCompanionBuilder,
    (BudgetSnapshot, $$BudgetSnapshotsTableReferences),
    BudgetSnapshot,
    PrefetchHooks Function({bool categoryId})>;
typedef $$PendingRecurringQueueTableCreateCompanionBuilder
    = PendingRecurringQueueCompanion Function({
  Value<int> id,
  required int sourceTransactionId,
  required DateTime dueDate,
  Value<DateTime> createdAt,
});
typedef $$PendingRecurringQueueTableUpdateCompanionBuilder
    = PendingRecurringQueueCompanion Function({
  Value<int> id,
  Value<int> sourceTransactionId,
  Value<DateTime> dueDate,
  Value<DateTime> createdAt,
});

final class $$PendingRecurringQueueTableReferences extends BaseReferences<
    _$AppDatabase, $PendingRecurringQueueTable, PendingRecurringQueueData> {
  $$PendingRecurringQueueTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _sourceTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.pendingRecurringQueue.sourceTransactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get sourceTransactionId {
    final $_column = $_itemColumn<int>('source_transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PendingRecurringQueueTableFilterComposer
    extends Composer<_$AppDatabase, $PendingRecurringQueueTable> {
  $$PendingRecurringQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get sourceTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingRecurringQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingRecurringQueueTable> {
  $$PendingRecurringQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get sourceTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingRecurringQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingRecurringQueueTable> {
  $$PendingRecurringQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get sourceTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingRecurringQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingRecurringQueueTable,
    PendingRecurringQueueData,
    $$PendingRecurringQueueTableFilterComposer,
    $$PendingRecurringQueueTableOrderingComposer,
    $$PendingRecurringQueueTableAnnotationComposer,
    $$PendingRecurringQueueTableCreateCompanionBuilder,
    $$PendingRecurringQueueTableUpdateCompanionBuilder,
    (PendingRecurringQueueData, $$PendingRecurringQueueTableReferences),
    PendingRecurringQueueData,
    PrefetchHooks Function({bool sourceTransactionId})> {
  $$PendingRecurringQueueTableTableManager(
      _$AppDatabase db, $PendingRecurringQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingRecurringQueueTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingRecurringQueueTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingRecurringQueueTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sourceTransactionId = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingRecurringQueueCompanion(
            id: id,
            sourceTransactionId: sourceTransactionId,
            dueDate: dueDate,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sourceTransactionId,
            required DateTime dueDate,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingRecurringQueueCompanion.insert(
            id: id,
            sourceTransactionId: sourceTransactionId,
            dueDate: dueDate,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PendingRecurringQueueTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sourceTransactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sourceTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceTransactionId,
                    referencedTable: $$PendingRecurringQueueTableReferences
                        ._sourceTransactionIdTable(db),
                    referencedColumn: $$PendingRecurringQueueTableReferences
                        ._sourceTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PendingRecurringQueueTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PendingRecurringQueueTable,
        PendingRecurringQueueData,
        $$PendingRecurringQueueTableFilterComposer,
        $$PendingRecurringQueueTableOrderingComposer,
        $$PendingRecurringQueueTableAnnotationComposer,
        $$PendingRecurringQueueTableCreateCompanionBuilder,
        $$PendingRecurringQueueTableUpdateCompanionBuilder,
        (PendingRecurringQueueData, $$PendingRecurringQueueTableReferences),
        PendingRecurringQueueData,
        PrefetchHooks Function({bool sourceTransactionId})>;
typedef $$PlaidAccountsTableCreateCompanionBuilder = PlaidAccountsCompanion
    Function({
  Value<int> id,
  required String plaidAccountId,
  required int internalAccountId,
  required String institutionName,
  required String mask,
  Value<DateTime?> syncedAt,
});
typedef $$PlaidAccountsTableUpdateCompanionBuilder = PlaidAccountsCompanion
    Function({
  Value<int> id,
  Value<String> plaidAccountId,
  Value<int> internalAccountId,
  Value<String> institutionName,
  Value<String> mask,
  Value<DateTime?> syncedAt,
});

final class $$PlaidAccountsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaidAccountsTable, PlaidAccount> {
  $$PlaidAccountsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _internalAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.plaidAccounts.internalAccountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get internalAccountId {
    final $_column = $_itemColumn<int>('internal_account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_internalAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlaidAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaidAccountsTable> {
  $$PlaidAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plaidAccountId => $composableBuilder(
      column: $table.plaidAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get institutionName => $composableBuilder(
      column: $table.institutionName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mask => $composableBuilder(
      column: $table.mask, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get internalAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.internalAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaidAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaidAccountsTable> {
  $$PlaidAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plaidAccountId => $composableBuilder(
      column: $table.plaidAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get institutionName => $composableBuilder(
      column: $table.institutionName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mask => $composableBuilder(
      column: $table.mask, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get internalAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.internalAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaidAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaidAccountsTable> {
  $$PlaidAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plaidAccountId => $composableBuilder(
      column: $table.plaidAccountId, builder: (column) => column);

  GeneratedColumn<String> get institutionName => $composableBuilder(
      column: $table.institutionName, builder: (column) => column);

  GeneratedColumn<String> get mask =>
      $composableBuilder(column: $table.mask, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get internalAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.internalAccountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaidAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaidAccountsTable,
    PlaidAccount,
    $$PlaidAccountsTableFilterComposer,
    $$PlaidAccountsTableOrderingComposer,
    $$PlaidAccountsTableAnnotationComposer,
    $$PlaidAccountsTableCreateCompanionBuilder,
    $$PlaidAccountsTableUpdateCompanionBuilder,
    (PlaidAccount, $$PlaidAccountsTableReferences),
    PlaidAccount,
    PrefetchHooks Function({bool internalAccountId})> {
  $$PlaidAccountsTableTableManager(_$AppDatabase db, $PlaidAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaidAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaidAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaidAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> plaidAccountId = const Value.absent(),
            Value<int> internalAccountId = const Value.absent(),
            Value<String> institutionName = const Value.absent(),
            Value<String> mask = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              PlaidAccountsCompanion(
            id: id,
            plaidAccountId: plaidAccountId,
            internalAccountId: internalAccountId,
            institutionName: institutionName,
            mask: mask,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String plaidAccountId,
            required int internalAccountId,
            required String institutionName,
            required String mask,
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              PlaidAccountsCompanion.insert(
            id: id,
            plaidAccountId: plaidAccountId,
            internalAccountId: internalAccountId,
            institutionName: institutionName,
            mask: mask,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaidAccountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({internalAccountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (internalAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.internalAccountId,
                    referencedTable: $$PlaidAccountsTableReferences
                        ._internalAccountIdTable(db),
                    referencedColumn: $$PlaidAccountsTableReferences
                        ._internalAccountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlaidAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaidAccountsTable,
    PlaidAccount,
    $$PlaidAccountsTableFilterComposer,
    $$PlaidAccountsTableOrderingComposer,
    $$PlaidAccountsTableAnnotationComposer,
    $$PlaidAccountsTableCreateCompanionBuilder,
    $$PlaidAccountsTableUpdateCompanionBuilder,
    (PlaidAccount, $$PlaidAccountsTableReferences),
    PlaidAccount,
    PrefetchHooks Function({bool internalAccountId})>;
typedef $$PendingReviewTransactionsTableCreateCompanionBuilder
    = PendingReviewTransactionsCompanion Function({
  Value<int> id,
  required String plaidTransactionId,
  required int accountId,
  required int amountCents,
  required DateTime date,
  required String payee,
  required String reason,
  Value<String?> pairedPlaidTransactionId,
  Value<DateTime> createdAt,
});
typedef $$PendingReviewTransactionsTableUpdateCompanionBuilder
    = PendingReviewTransactionsCompanion Function({
  Value<int> id,
  Value<String> plaidTransactionId,
  Value<int> accountId,
  Value<int> amountCents,
  Value<DateTime> date,
  Value<String> payee,
  Value<String> reason,
  Value<String?> pairedPlaidTransactionId,
  Value<DateTime> createdAt,
});

final class $$PendingReviewTransactionsTableReferences extends BaseReferences<
    _$AppDatabase, $PendingReviewTransactionsTable, PendingReviewTransaction> {
  $$PendingReviewTransactionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.pendingReviewTransactions.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PendingReviewTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingReviewTransactionsTable> {
  $$PendingReviewTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plaidTransactionId => $composableBuilder(
      column: $table.plaidTransactionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payee => $composableBuilder(
      column: $table.payee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pairedPlaidTransactionId => $composableBuilder(
      column: $table.pairedPlaidTransactionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingReviewTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingReviewTransactionsTable> {
  $$PendingReviewTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plaidTransactionId => $composableBuilder(
      column: $table.plaidTransactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payee => $composableBuilder(
      column: $table.payee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pairedPlaidTransactionId => $composableBuilder(
      column: $table.pairedPlaidTransactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingReviewTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingReviewTransactionsTable> {
  $$PendingReviewTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plaidTransactionId => $composableBuilder(
      column: $table.plaidTransactionId, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get payee =>
      $composableBuilder(column: $table.payee, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get pairedPlaidTransactionId => $composableBuilder(
      column: $table.pairedPlaidTransactionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PendingReviewTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingReviewTransactionsTable,
    PendingReviewTransaction,
    $$PendingReviewTransactionsTableFilterComposer,
    $$PendingReviewTransactionsTableOrderingComposer,
    $$PendingReviewTransactionsTableAnnotationComposer,
    $$PendingReviewTransactionsTableCreateCompanionBuilder,
    $$PendingReviewTransactionsTableUpdateCompanionBuilder,
    (PendingReviewTransaction, $$PendingReviewTransactionsTableReferences),
    PendingReviewTransaction,
    PrefetchHooks Function({bool accountId})> {
  $$PendingReviewTransactionsTableTableManager(
      _$AppDatabase db, $PendingReviewTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingReviewTransactionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingReviewTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingReviewTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> plaidTransactionId = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<int> amountCents = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> payee = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String?> pairedPlaidTransactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingReviewTransactionsCompanion(
            id: id,
            plaidTransactionId: plaidTransactionId,
            accountId: accountId,
            amountCents: amountCents,
            date: date,
            payee: payee,
            reason: reason,
            pairedPlaidTransactionId: pairedPlaidTransactionId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String plaidTransactionId,
            required int accountId,
            required int amountCents,
            required DateTime date,
            required String payee,
            required String reason,
            Value<String?> pairedPlaidTransactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PendingReviewTransactionsCompanion.insert(
            id: id,
            plaidTransactionId: plaidTransactionId,
            accountId: accountId,
            amountCents: amountCents,
            date: date,
            payee: payee,
            reason: reason,
            pairedPlaidTransactionId: pairedPlaidTransactionId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PendingReviewTransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable: $$PendingReviewTransactionsTableReferences
                        ._accountIdTable(db),
                    referencedColumn: $$PendingReviewTransactionsTableReferences
                        ._accountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PendingReviewTransactionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PendingReviewTransactionsTable,
        PendingReviewTransaction,
        $$PendingReviewTransactionsTableFilterComposer,
        $$PendingReviewTransactionsTableOrderingComposer,
        $$PendingReviewTransactionsTableAnnotationComposer,
        $$PendingReviewTransactionsTableCreateCompanionBuilder,
        $$PendingReviewTransactionsTableUpdateCompanionBuilder,
        (PendingReviewTransaction, $$PendingReviewTransactionsTableReferences),
        PendingReviewTransaction,
        PrefetchHooks Function({bool accountId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoryGroupsTableTableManager get categoryGroups =>
      $$CategoryGroupsTableTableManager(_db, _db.categoryGroups);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$MonthlyBudgetsTableTableManager get monthlyBudgets =>
      $$MonthlyBudgetsTableTableManager(_db, _db.monthlyBudgets);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$NetWorthSnapshotsTableTableManager get netWorthSnapshots =>
      $$NetWorthSnapshotsTableTableManager(_db, _db.netWorthSnapshots);
  $$BudgetSnapshotsTableTableManager get budgetSnapshots =>
      $$BudgetSnapshotsTableTableManager(_db, _db.budgetSnapshots);
  $$PendingRecurringQueueTableTableManager get pendingRecurringQueue =>
      $$PendingRecurringQueueTableTableManager(_db, _db.pendingRecurringQueue);
  $$PlaidAccountsTableTableManager get plaidAccounts =>
      $$PlaidAccountsTableTableManager(_db, _db.plaidAccounts);
  $$PendingReviewTransactionsTableTableManager get pendingReviewTransactions =>
      $$PendingReviewTransactionsTableTableManager(
          _db, _db.pendingReviewTransactions);
}
