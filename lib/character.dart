import 'errors.dart';

class Character {
  Character({
    required this.name,
    required this.initiative,
    this.maxHp,
    this.currHp,
    this.notes,
  });

  String name;
  int initiative;
  int? maxHp;
  int? currHp;
  String? notes;
  List<String> statuses = [];

  set setName(String newName) {
    name = newName;
  }

  String get getName {
    return name;
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

  bool checkUnique(String charName) {
    for (Character item in list) {
      if (item.name == charName) {
        return false;
      }
    }
    return true;
  }

  int findCharacter(Character charToFind) {
    int charIndex = -1;

    for (int i = 0; i < list.length; i++) {
      if (list[i] == charToFind) {
        charIndex = i;
        break;
      }
    }

    return charIndex;
  }

  bool setInitiative(Character charToChange, int newInitiative) {
    int charIndex = findCharacter(charToChange);
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

  void add(Character newChar) {
    if (newChar.name == "") {
      throw EmptyNameFieldException();
    }
    if (!checkUnique(newChar.name)) {}
    list.add(newChar);
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
}
