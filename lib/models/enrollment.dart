class Enrollment {
  const Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrolledOn,
    required this.status,
  });

  final String id;
  final String studentId;
  final String courseId;
  final String enrolledOn;
  final String status;
}
