class EmptyNameFieldException implements Exception {
  @override
  String toString() => 'The name cannot be empty!';
}

class CharacterNotFoundException implements Exception {
  @override
  String toString() => 'The character you searched for was not found';
}
