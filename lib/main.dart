import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'character.dart';
import 'widgets.dart';
import 'errors.dart';

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
        title: 'Initiative Tracker 2.0',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 11, 89, 179),
          ),
        ),
        home: InitiativeTrackerHomePage(),
      ),
    );
  }
}

class InitiativeAppState extends ChangeNotifier {
  var characters = CharacterList();

  Color get nameTextBoxColor => _nameTextBoxColor;
  Color _nameTextBoxColor = Colors.black;
  set nameTextBoxColor(Color newColor) {
    _nameTextBoxColor = newColor;
    notifyListeners();
  }

  void addCharacter(
    String charName,
    int charInit,
    int? charCurrHp,
    int? charMaxHp,
    String? charNotes,
  ) {
    if (characters.checkUnique(charName)) {
      var newChar = Character(name: charName, initiative: charInit);
      characters.add(newChar);
      print("Characters: ${characters.toString()}");
      notifyListeners();
    } else {
      print("Not adding character - non-unique name");
    }
  }

  void removeCharacter(Character charToRemove) {
    characters.remove(charToRemove);
    notifyListeners();
  }

  void setInitiative(Character charToChange, int newInitiative) {
    bool success = characters.setInitiative(charToChange, newInitiative);
    if (success) {
      notifyListeners();
    }
  }

  void setDisplayName(Character charToChange, String newName) {
    charToChange.name = newName;
    notifyListeners();
  }

  void createNoteSection() {
    // TODO
    print("Characters: ${characters.toString()}");
  }
}

class InitiativeTrackerHomePage extends StatefulWidget {
  const InitiativeTrackerHomePage({super.key});

  @override
  State<InitiativeTrackerHomePage> createState() =>
      _InitiativeTrackerHomePageState();
}

class _InitiativeTrackerHomePageState extends State<InitiativeTrackerHomePage> {
  final TextEditingController charName = TextEditingController();
  final TextEditingController charInit = TextEditingController();
  final TextEditingController charMaxHp = TextEditingController();
  final TextEditingController charCurrHp = TextEditingController();
  final charNotes = ""; // TODO: Implement Notes

  // Color get nameTextBoxColor => _nameTextBoxColor;
  // Color _nameTextBoxColor = Colors.black;
  // set nameTextBoxColor(Color newColor) {
  //   if (_nameTextBoxColor != newColor) {
  //     setState(() {
  //       _nameTextBoxColor = newColor;
  //     });
  //   }
  // }

  @override
  void dispose() {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text("Initiative Tracker 2.0")),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsetsGeometry.directional(top: 10)),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(padding: EdgeInsetsGeometry.all(10)),
              InputWidget(
                label: "Name",
                controller: charName,
                color: appState.nameTextBoxColor,
              ),
              InputWidget(
                label: "Initiative",
                width: 100,
                controller: charInit,
                textInputType: TextInputType.number,
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              InputWidget(
                label: "Curr. HP",
                width: 100,
                controller: charCurrHp,
                textInputType: TextInputType.number,
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              InputWidget(
                label: "Max HP",
                width: 100,
                controller: charMaxHp,
                textInputType: TextInputType.number,
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              OutlinedButton(
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
              // Add To Initiative Button
              OutlinedButton(
                onPressed: () {
                  int parsedInit;
                  try {
                    parsedInit = int.parse(charInit.text);
                  } on FormatException {
                    // TODO Make this handle an error!
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
                      charNotes,
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
                },
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 5),
                    Text("Add to Initiative"),
                  ],
                ),
              ),
            ],
          ),
          InitiativeZone(),
        ],
      ),
    );
  }
}
