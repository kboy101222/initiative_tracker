import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'character.dart';
import 'widgets.dart';
import 'errors.dart';
import 'logging.dart';

final log = Logger();

void main() {
  runApp(const InitiativeTracker());
}

class InitiativeTracker extends StatelessWidget {
  const InitiativeTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InitiativeAppState(),
      child: MaterialApp(
        title: 'Initiative Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            // seedColor: const Color.fromARGB(255, 11, 89, 179),
            seedColor: Colors.blueGrey,
            onPrimaryContainer: Colors.blueAccent,
            surface: Colors.white,
          ),
        ),
        home: InitiativeTrackerHomePage(),
      ),
    );
  }
}

class InitiativeAppState extends ChangeNotifier {
  var characters = CharacterList();

  // Turn tracking
  bool showStartInitiativeButton = false;
  bool showNextTurnButton = false;
  bool initiativeStarted = false;
  int _currentTurn = 0;

  void startInitiative(bool hasBegun) {
    initiativeStarted = hasBegun;
    setTurn(0);
    showNextTurnButton = true;
    showStartInitiativeButton = false;
    notifyListeners();
  }

  void setTurn(int turn, {bool isTurn = true}) {
    if (turn < characters.length) {
      characters[_currentTurn].isTurn = false;
      _currentTurn = turn;
      characters[_currentTurn].isTurn = isTurn;
      notifyListeners();
    }
  }

  int nextTurn() {
    if (!initiativeStarted) {
      throw InitiativeNotStartedException();
    }

    if (getTurn() < characters.length - 1) {
      setTurn(_currentTurn + 1);
      return getTurn();
    } else {
      setTurn(0);
      return 0;
    }
  }

  int getTurn() {
    return _currentTurn;
  }

  // Character functions
  void addCharacter(
    // Add a new Character
    String characterName,
    int characterInit,
    int? characterCurrHp,
    int? characterMaxHp,
    String? characterNotes,
  ) {
    final newCharacter = Character(
      name: characterName,
      initiative: characterInit,
      id: generateId(),
    );
    log.info(
      "Adding new character ${newCharacter.name} with Id ${newCharacter.id}",
    );
    log.info("Checking if character name is unique...");
    var characterNameList = characters.findAllCharacters(characterName);
    if (characterNameList.isEmpty) {
      characters.add(newCharacter);
      // notifyListeners();
      log.success("Character name was unique, adding.");
    } else {
      log.info(
        "Name was not unique. There were a total of ${characterNameList.length} characters found. Appending numbers to the end",
      );
      var i = 0;
      for (; i < characterNameList.length;) {
        int characterIndex = characterNameList[i];
        Character currentCharacter = characters[characterIndex];
        currentCharacter.displayName = "${currentCharacter.name} #${i + 1}";
        i++;
      }
      newCharacter.displayName = "${newCharacter.name} #${i + 1}";
      characters.add(newCharacter);
      // notifyListeners();
    }
    checkShowStartInitiativeButton();
    notifyListeners();
  }

  void removeCharacter(Character charToRemove) {
    // Remove an existing Character.
    log.info("Removing ${charToRemove.name} with Id ${charToRemove.id}");
    characters.remove(charToRemove);
    checkShowStartInitiativeButton();
    notifyListeners();
  }

  void setCharacterInitiative(Character charToChange, int newInitiative) {
    // Sets a Character's initiative
    log.info("Setting ${charToChange.name}'s initiative to $newInitiative");
    int currentTurnIndex = 0;
    if (initiativeStarted) {
      currentTurnIndex = getTurn();
      setTurn(currentTurnIndex, isTurn: false);
    }
    bool success = characters.setInitiative(charToChange, newInitiative);
    if (success) {
      if (initiativeStarted) {
        setTurn(currentTurnIndex);
      }
      notifyListeners();
    }
  }

  void setCharacterName(Character charToChange, String newName) {
    // Sets a Character's name
    log.info("Setting ${charToChange.name}'s name to $newName");
    charToChange.name = newName;
    notifyListeners();
  }

  // TODO: Implement
  void createNoteSection({Character? charToChange}) {
    // Creates a note for a character
    if (charToChange == null) {
      log.info("Creating a new note");
    } else {
      log.info("Creating a new note for ${charToChange.name}");
    }
  }

  void checkShowStartInitiativeButton() {
    // Only show "Start Initiative" when there's at least 1 character in the list
    if (characters.list.isEmpty) {
      showStartInitiativeButton = false;
      showNextTurnButton = false;
      notifyListeners();
    } else {
      showStartInitiativeButton = true;
      notifyListeners();
    }
  }

  // Greenscreen Features
  bool isGreenScreenEnabled = false;

  void toggleGreenscreen() {
    isGreenScreenEnabled = !(isGreenScreenEnabled);
    log.info("Toggling Greenscreen");
    notifyListeners();
  }
}

class InitiativeTrackerHomePage extends StatefulWidget {
  const InitiativeTrackerHomePage({super.key});

  @override
  State<InitiativeTrackerHomePage> createState() =>
      _InitiativeTrackerHomePageState();
}

class _InitiativeTrackerHomePageState extends State<InitiativeTrackerHomePage> {
  // Controllers to get and set various TextField values for the top bar
  final TextEditingController charName = TextEditingController();
  final TextEditingController charInit = TextEditingController();
  final TextEditingController charMaxHp = TextEditingController();
  final TextEditingController charCurrHp = TextEditingController();
  final charNotes = ""; // TODO: Implement Notes
  // List of statuses effects. Will later be retrieved from the database once implemented.
  final List<String> statusEffects = [];

  final int currentTurn = 0;
  bool initiativeBegun = false;

  @override
  void dispose() {
    log.info("Disposing of TextEditingController");
    charName.dispose();
    charInit.dispose();
    charMaxHp.dispose();
    charCurrHp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<InitiativeAppState>();
    if (charName.text == "") {}
    return Scaffold(
      appBar: AppBar(
        // Top Bar
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text("Initiative Tracker")),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsetsGeometry.directional(top: 10)),
          Row(
            // Add Character Bar
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(padding: EdgeInsetsGeometry.all(10)),
              InputWidget(label: "Name", controller: charName), // Name Input
              InputWidget(
                // Initiative Input
                label: "Initiative",
                width: 100,
                controller: charInit,
                textInputType: TextInputType.number,
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              InputWidget(
                // Current HP Input
                label: "Curr. HP",
                width: 100,
                controller: charCurrHp,
                textInputType: TextInputType.number,
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              InputWidget(
                // Max HP Input
                label: "Max HP",
                width: 100,
                controller: charMaxHp,
                textInputType: TextInputType.number,
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              OutlinedButton(
                // Create Note
                onPressed: appState.createNoteSection,
                child: Row(
                  children: [
                    Icon(Icons.assignment_add),
                    SizedBox(width: 5),
                    Text("Add Note"),
                  ],
                ),
              ),
              SizedBox(width: 10),
              OutlinedButton(
                // Add To Initiative Button
                onPressed: () {
                  addToInitiative(
                    appState,
                    context,
                    charInit,
                    charCurrHp,
                    charMaxHp,
                    charName,
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 5),
                    Text("Add to Initiative"),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Visibility(
                // Start Initiative Button
                visible: appState.showStartInitiativeButton,
                child: OutlinedButton(
                  onPressed: () => {
                    if (!appState.initiativeStarted)
                      {appState.startInitiative(true)}
                    else
                      {appState.setTurn(0)},
                  },
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 5),
                      Text("Start Initiative"),
                    ],
                  ),
                ),
              ),
              Visibility(
                // Next Turn Button
                visible: appState.showNextTurnButton,
                child: OutlinedButton(
                  onPressed: () => {appState.nextTurn()},
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward),
                      SizedBox(width: 5),
                      Text("Next Turn"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          InitiativeZone(), // Handles the layout for the initiative items
        ],
      ),
      bottomNavigationBar: ActionBar(),
    );
  }
}

// Used to generate a (hopefully) unique Id for a character
int generateId() {
  return Random().nextInt(2 ^ 32);
}

// Logic to add a new Character to the list
// Became too long and unweidly to keep in the build() function
void addToInitiative(
  InitiativeAppState appState,
  BuildContext context,
  charInit,
  TextEditingController charCurrHp,
  TextEditingController charMaxHp,
  TextEditingController charName,
) {
  int parsedInit;
  try {
    parsedInit = int.parse(charInit.text);
  } on FormatException {
    parsedInit = 0;
  }
  int parsedCurrHp;
  try {
    parsedCurrHp = int.parse(charCurrHp.text);
  } on FormatException {
    parsedCurrHp = 0;
  }
  int parsedMaxHp;
  try {
    parsedMaxHp = int.parse(charMaxHp.text);
  } on FormatException {
    parsedMaxHp = 0;
  }

  try {
    appState.addCharacter(
      charName.text,
      parsedInit,
      parsedCurrHp,
      parsedMaxHp,
      "",
    );

    charName.clear();
    charInit.clear();
    charCurrHp.clear();
    charMaxHp.clear();
  } on EmptyNameFieldException catch (e) {
    showDialog(
      context: context,
      builder: (context) => errorAlert(e.toString(), context),
    );
  }
}
