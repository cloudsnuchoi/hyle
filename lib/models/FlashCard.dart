import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class FlashCard extends amplify_core.Model {
  static const classType = const _FlashCardModelType();
  final String id;
  final String? _userId;
  final String? _front;
  final String? _back;
  final String? _deck;
  final String? _tags;
  final int? _interval;
  final double? _easeFactor;
  final int? _repetitions;
  final amplify_core.TemporalDateTime? _nextReview;
  final amplify_core.TemporalDateTime? _lastReviewed;
  final String? _source;
  final bool? _isActive;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;
  
  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  FlashCardModelIdentifier get modelIdentifier {
    return FlashCardModelIdentifier(
      id: id
    );
  }
  
  String? get userId {
    return _userId;
  }
  
  String? get front {
    return _front;
  }
  
  String? get back {
    return _back;
  }
  
  String? get deck {
    return _deck;
  }
  
  String? get tags {
    return _tags;
  }
  
  int? get interval {
    return _interval;
  }
  
  double? get easeFactor {
    return _easeFactor;
  }
  
  int? get repetitions {
    return _repetitions;
  }
  
  amplify_core.TemporalDateTime? get nextReview {
    return _nextReview;
  }
  
  amplify_core.TemporalDateTime? get lastReviewed {
    return _lastReviewed;
  }
  
  String? get source {
    return _source;
  }
  
  bool? get isActive {
    return _isActive;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const FlashCard._internal({required this.id, userId, front, back, deck, tags, interval, easeFactor, repetitions, nextReview, lastReviewed, source, isActive, createdAt, updatedAt}): _userId = userId, _front = front, _back = back, _deck = deck, _tags = tags, _interval = interval, _easeFactor = easeFactor, _repetitions = repetitions, _nextReview = nextReview, _lastReviewed = lastReviewed, _source = source, _isActive = isActive, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory FlashCard({String? id, String? userId, String? front, String? back, String? deck, String? tags, int? interval, double? easeFactor, int? repetitions, amplify_core.TemporalDateTime? nextReview, amplify_core.TemporalDateTime? lastReviewed, String? source, bool? isActive}) {
    return FlashCard._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      userId: userId,
      front: front,
      back: back,
      deck: deck,
      tags: tags,
      interval: interval,
      easeFactor: easeFactor,
      repetitions: repetitions,
      nextReview: nextReview,
      lastReviewed: lastReviewed,
      source: source,
      isActive: isActive);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlashCard &&
      id == other.id &&
      _userId == other._userId &&
      _front == other._front &&
      _back == other._back &&
      _deck == other._deck &&
      _tags == other._tags &&
      _interval == other._interval &&
      _easeFactor == other._easeFactor &&
      _repetitions == other._repetitions &&
      _nextReview == other._nextReview &&
      _lastReviewed == other._lastReviewed &&
      _source == other._source &&
      _isActive == other._isActive;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("FlashCard {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("front=" + "$_front" + ", ");
    buffer.write("back=" + "$_back" + ", ");
    buffer.write("deck=" + "$_deck" + ", ");
    buffer.write("tags=" + "$_tags" + ", ");
    buffer.write("interval=" + (_interval != null ? _interval!.toString() : "null") + ", ");
    buffer.write("easeFactor=" + (_easeFactor != null ? _easeFactor!.toString() : "null") + ", ");
    buffer.write("repetitions=" + (_repetitions != null ? _repetitions!.toString() : "null") + ", ");
    buffer.write("nextReview=" + (_nextReview != null ? _nextReview!.format() : "null") + ", ");
    buffer.write("lastReviewed=" + (_lastReviewed != null ? _lastReviewed!.format() : "null") + ", ");
    buffer.write("source=" + "$_source" + ", ");
    buffer.write("isActive=" + (_isActive != null ? _isActive!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  FlashCard copyWith({String? userId, String? front, String? back, String? deck, String? tags, int? interval, double? easeFactor, int? repetitions, amplify_core.TemporalDateTime? nextReview, amplify_core.TemporalDateTime? lastReviewed, String? source, bool? isActive}) {
    return FlashCard._internal(
      id: id,
      userId: userId ?? this.userId,
      front: front ?? this.front,
      back: back ?? this.back,
      deck: deck ?? this.deck,
      tags: tags ?? this.tags,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      nextReview: nextReview ?? this.nextReview,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      source: source ?? this.source,
      isActive: isActive ?? this.isActive);
  }
  
  FlashCard.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _userId = json['userId'],
      _front = json['front'],
      _back = json['back'],
      _deck = json['deck'],
      _tags = json['tags'],
      _interval = json['interval'],
      _easeFactor = json['easeFactor'],
      _repetitions = json['repetitions'],
      _nextReview = json['nextReview'] != null ? amplify_core.TemporalDateTime.fromString(json['nextReview']) : null,
      _lastReviewed = json['lastReviewed'] != null ? amplify_core.TemporalDateTime.fromString(json['lastReviewed']) : null,
      _source = json['source'],
      _isActive = json['isActive'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'userId': _userId, 'front': _front, 'back': _back, 'deck': _deck, 'tags': _tags, 'interval': _interval, 'easeFactor': _easeFactor, 'repetitions': _repetitions, 'nextReview': _nextReview?.format(), 'lastReviewed': _lastReviewed?.format(), 'source': _source, 'isActive': _isActive, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'userId': _userId,
    'front': _front,
    'back': _back,
    'deck': _deck,
    'tags': _tags,
    'interval': _interval,
    'easeFactor': _easeFactor,
    'repetitions': _repetitions,
    'nextReview': _nextReview,
    'lastReviewed': _lastReviewed,
    'source': _source,
    'isActive': _isActive,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<FlashCardModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<FlashCardModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final FRONT = amplify_core.QueryField(fieldName: "front");
  static final BACK = amplify_core.QueryField(fieldName: "back");
  static final DECK = amplify_core.QueryField(fieldName: "deck");
  static final TAGS = amplify_core.QueryField(fieldName: "tags");
  static final INTERVAL = amplify_core.QueryField(fieldName: "interval");
  static final EASEFACTOR = amplify_core.QueryField(fieldName: "easeFactor");
  static final REPETITIONS = amplify_core.QueryField(fieldName: "repetitions");
  static final NEXTREVIEW = amplify_core.QueryField(fieldName: "nextReview");
  static final LASTREVIEWED = amplify_core.QueryField(fieldName: "lastReviewed");
  static final SOURCE = amplify_core.QueryField(fieldName: "source");
  static final ISACTIVE = amplify_core.QueryField(fieldName: "isActive");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "FlashCard";
    modelSchemaDefinition.pluralName = "FlashCards";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "userId",
        identityClaim: "sub",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["userId"], name: "byUser")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.USERID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.FRONT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.BACK,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.DECK,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.TAGS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.INTERVAL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.EASEFACTOR,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.REPETITIONS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.NEXTREVIEW,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.LASTREVIEWED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.SOURCE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: FlashCard.ISACTIVE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _FlashCardModelType extends amplify_core.ModelType<FlashCard> {
  const _FlashCardModelType();
  
  @override
  FlashCard fromJson(Map<String, dynamic> jsonData) {
    return FlashCard.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'FlashCard';
  }
}

class FlashCardModelIdentifier extends amplify_core.ModelIdentifier<FlashCard> {
  final String id;

  const FlashCardModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'FlashCardModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is FlashCardModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}