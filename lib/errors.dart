class EmptyNameFieldException implements Exception {
  @override
  String toString() => 'The name cannot be empty!';
}

class CharacterNotFoundException implements Exception {
  @override
  String toString() => 'The character you searched for was not found';
}

class InitiativeNotStartedException implements Exception {
  @override
  String toString() => 'Initiative must be started before setting a turn!';
}
