/// Shared identity contract so CRUD stores can work with any entity.
abstract class Identifiable {
  String get id;
}
