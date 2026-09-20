class Task {
  final int id;
  final String title;
  final Map<String, dynamic>? content;
  final String createdOn;
  final String statusFlag;

  Task({
    required this.id,
    required this.title,
    this.content,
    required this.createdOn,
    required this.statusFlag,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      content: json['content'] as Map<String, dynamic>?,
      createdOn: json['createdOn'],
      statusFlag: json['status_flag'],
    );
  }
}
