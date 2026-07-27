class Course {
  const Course({
    required this.id,
    required this.title,
    required this.program,
    required this.credits,
    required this.lecturer,
    required this.status,
  });

  final String id;
  final String title;
  final String program;
  final int credits;
  final String lecturer;
  final String status;

  Course copyWith({
    String? id,
    String? title,
    String? program,
    int? credits,
    String? lecturer,
    String? status,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      program: program ?? this.program,
      credits: credits ?? this.credits,
      lecturer: lecturer ?? this.lecturer,
      status: status ?? this.status,
    );
  }
}
