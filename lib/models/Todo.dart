// Todo model for task management
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Todo extends amplify_core.Model {
  static const classType = const _TodoModelType();
  final String id;
  final String? title;
  final String? description;
  final String? userID;
  final String? subject;
  final Priority? priority;
  final bool? completed;
  final DateTime? dueDate;
  final int? estimatedTime;
  final int? actualTime;
  final int? xpReward;
  final DateTime? completedAt;
  final bool? isCompleted;
  final bool? aiSuggested;
  
  @override
  getInstanceType() => classType;
  
  @override
  String getId() => id;
  
  const Todo._internal({
    required this.id,
    this.title,
    this.description,
    this.userID,
    this.subject,
    this.priority,
    this.completed,
    this.dueDate,
    this.estimatedTime,
    this.actualTime,
    this.xpReward,
    this.completedAt,
    this.isCompleted,
    this.aiSuggested,
  });
  
  factory Todo({
    String? id,
    String? title,
    String? description,
    String? userID,
    String? subject,
    Priority? priority,
    bool? completed,
    DateTime? dueDate,
    int? estimatedTime,
    int? actualTime,
    int? xpReward,
    DateTime? completedAt,
    bool? isCompleted,
    bool? aiSuggested,
  }) {
    return Todo._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      description: description,
      userID: userID,
      subject: subject,
      priority: priority,
      completed: completed,
      dueDate: dueDate,
      estimatedTime: estimatedTime,
      actualTime: actualTime,
      xpReward: xpReward,
      completedAt: completedAt,
      isCompleted: isCompleted,
      aiSuggested: aiSuggested,
    );
  }
  
  Todo copyWith({
    String? title,
    String? description,
    String? userID,
    String? subject,
    Priority? priority,
    bool? completed,
    DateTime? dueDate,
    int? estimatedTime,
    int? actualTime,
    int? xpReward,
    DateTime? completedAt,
    bool? isCompleted,
    bool? aiSuggested,
  }) {
    return Todo._internal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      userID: userID ?? this.userID,
      subject: subject ?? this.subject,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTime: actualTime ?? this.actualTime,
      xpReward: xpReward ?? this.xpReward,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      aiSuggested: aiSuggested ?? this.aiSuggested,
    );
  }
  
  Todo.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      description = json['description'],
      userID = json['userID'],
      subject = json['subject'],
      priority = json['priority'] != null ? Priority.values.byName(json['priority']) : null,
      completed = json['completed'],
      dueDate = json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      estimatedTime = json['estimatedTime'],
      actualTime = json['actualTime'],
      xpReward = json['xpReward'],
      completedAt = json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      isCompleted = json['isCompleted'],
      aiSuggested = json['aiSuggested'];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'userID': userID,
    'subject': subject,
    'priority': priority?.name,
    'completed': completed,
    'dueDate': dueDate?.toIso8601String(),
    'estimatedTime': estimatedTime,
    'actualTime': actualTime,
    'xpReward': xpReward,
    'completedAt': completedAt?.toIso8601String(),
    'isCompleted': isCompleted,
    'aiSuggested': aiSuggested,
  };
  
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final USER_ID = amplify_core.QueryField(fieldName: "userID");
  static final COMPLETED = amplify_core.QueryField(fieldName: "completed");
  static final PRIORITY = amplify_core.QueryField(fieldName: "priority");
  static final SUBJECT = amplify_core.QueryField(fieldName: "subject");
  static final DUE_DATE = amplify_core.QueryField(fieldName: "dueDate");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "createdAt");
  
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Todo";
    modelSchemaDefinition.pluralName = "Todos";
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
  });
}

class _TodoModelType extends amplify_core.ModelType<Todo> {
  const _TodoModelType();
  
  @override
  Todo fromJson(Map<String, dynamic> jsonData) {
    return Todo.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Todo';
  }
}

enum Priority { LOW, MEDIUM, HIGH, URGENT }