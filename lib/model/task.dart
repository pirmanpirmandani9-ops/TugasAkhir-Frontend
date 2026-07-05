class Task {
  final int id;
  final String title;
  final String description;
  final String deadline;
  final String status;

  Task({required this.id, required this.title, required this.description, required this.deadline, required this.status});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'],
      status: json['status'] ?? 'pending',
    );
  }
}