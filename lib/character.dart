import 'dart:math';

import 'errors.dart';

class Character {
  Character({
    required this.name,
    required this.initiative,
    required this.id,
    this.maxHp,
    this.currHp,
    this.notes,
    String? displayName,
  }) : _displayName = displayName;

  String name;
  int initiative;
  int? maxHp;
  int? currHp;
  String? notes;
  List<String> statuses = [];
  bool isTurn = false;
  int id;
  String? _displayName;

  set setName(String newName) {
    name = newName;
  }

  String get getName {
    return name;
  }

  set displayName(String newName) {
    _displayName = newName;
  }

  String get displayName {
    String _displayName;
    if (this._displayName == null) {
      _displayName = "";
    } else {
      _displayName = this._displayName!;
    }
    return _displayName;
  }

  void generateNewId() {
    id = Random().nextInt(double.maxFinite.toInt());
  }

  void changeHp(int amount) {
    if (currHp != null) {
      currHp = currHp! + amount;
    } else {
      currHp = 1;
    }
  }

  void setCurrHp(int amount) {
    currHp = amount;
  }

  void changeNotes(String noteString) {
    notes = noteString;
  }

  @override
  int get hashCode => Object.hash(name, initiative);

  @override
  bool operator ==(Object other) =>
      other is Character &&
      name == other.name &&
      initiative == other.initiative;
}

class CharacterList extends Iterable<Character> {
  CharacterList();

  List<Character> list = [];

  bool checkUnique(int characterId) {
    if (findFirstCharacter(characterId: characterId) == -1) {
      return true;
    }
    return false;
  }

  int findFirstCharacter({
    Character? characterClass,
    int? characterId,
    String? characterName,
  }) {
    int charIndex = -1;

    if (characterClass != null) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] == characterClass) {
          if (characterId != null && list[i].id == characterId) {
            charIndex = i;
            break;
          } else if (characterId != null) {
            continue;
          }
          charIndex = i;
          break;
        }
      }
    } else if (characterId != null) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == characterId) {
          charIndex = i;
          break;
        }
      }
    }

    return charIndex;
  }

  List<int> findAllCharacters(String characterName) {
    List<int> foundItems = [];
    for (var i = 0; i < list.length; i++) {
      if (list[i].name == characterName) {
        foundItems.add(i);
      }
    }
    return foundItems;
  }

  bool setInitiative(Character charToChange, int newInitiative) {
    int charIndex = findFirstCharacter(characterClass: charToChange);
    if (charIndex != -1) {
      list[charIndex].initiative = newInitiative;
      sort();
      return true;
    } else {
      return false;
    }
  }

  void sort() {
    list.sort((a, b) => b.initiative - a.initiative);
  }

  void add(Character newCharacter) {
    if (newCharacter.name == "") {
      throw EmptyNameFieldException();
    }
    while (!checkUnique(newCharacter.id)) {
      newCharacter.generateNewId();
    }
    list.add(newCharacter);
    sort();
  }

  void remove(Character charToRemove) {
    list.remove(charToRemove);
  }

  @override
  String toString() {
    var retString = "";
    for (int i = 0; i < list.length; i++) {
      String charName = list[i].name;
      if (i == 0) {
        retString = "$charName [${list[i].initiative}]";
      } else {
        retString = "$retString, $charName [${list[i].initiative}]";
      }
    }
    return retString;
  }

  @override
  Iterator<Character> get iterator => list.iterator;

  Character operator [](int index) => list[index];
}
