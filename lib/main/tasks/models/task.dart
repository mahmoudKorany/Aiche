class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final double progress;
  final bool isCompleted;
  final int? notificationId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.progress = 0.0,
    this.isCompleted = false,
    this.notificationId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    double? progress,
    bool? isCompleted,
    int? notificationId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  // Convert Task to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'progress': progress,
      'isCompleted': isCompleted ? 1 : 0, // Convert boolean to int (0/1)
      'notificationId': notificationId,
    };
  }

  // Create Task from Map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      progress: json['progress'],
      isCompleted: json['isCompleted'] == 1, // Convert int (0/1) to boolean
      notificationId: json['notificationId'],
    );
  }
}
