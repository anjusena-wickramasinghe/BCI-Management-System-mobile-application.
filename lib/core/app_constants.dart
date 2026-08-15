/// Canonical status labels used by records and enrolments.
class AppStatus {
  AppStatus._();

  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String enrolled = 'Enrolled';

  static const List<String> recordStatuses = <String>[active, inactive];
}
