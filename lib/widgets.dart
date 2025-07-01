import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:initiative_tracker/main.dart';
import 'package:provider/provider.dart';
import 'character.dart';
// import 'main.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    super.key,
    required this.label,
    this.width = 250,
    this.obscure = false,
    this.padding = 10,
    this.maxLen,
    this.controller,
    this.color,
    this.onEdit,
    this.textInputType,
    this.textInputFormatter,
    this.defaultText,
  });

  final String label;
  final String? defaultText;
  final double? width;
  final bool obscure;
  final double padding;
  final int? maxLen;
  final TextEditingController? controller;
  final Function? onEdit;
  final Color? color;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? textInputFormatter;

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<InitiativeAppState>();
    if (defaultText != null) {
      controller?.text = "";
    }
    return Row(
      children: [
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            maxLength: maxLen,
            autocorrect: false,
            obscureText: obscure,
            keyboardType: textInputType,
            inputFormatters: textInputFormatter,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide(width: 0.0)),
              labelText: label,
            ),
            onChanged: (value) => onEdit,
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}

class InitiativeZone extends StatelessWidget {
  const InitiativeZone({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<InitiativeAppState>();
    final TextEditingController charHeath = TextEditingController();

    // Text Controllers for changing name and initiative
    final TextEditingController newInitiative = TextEditingController();
    final TextEditingController newName = TextEditingController();

    final FocusNode _menuFocusNode = FocusNode(debugLabel: 'Menu Button');

    if (appState.characters.isEmpty) {
      return Center(child: Text("Add characters to initiative!"));
    }

    return Expanded(
      child: ListView(
        children: [
          Padding(padding: const EdgeInsets.all(20)),
          for (Character item in appState.characters)
            ListTile(
              // Click on the initiative to change its value
              leading: TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("Changing Initiative"),
                    content: InputWidget(
                      label: "New Initiative",
                      controller: newInitiative,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => {
                          appState.setInitiative(
                            item,
                            int.parse(newInitiative.text),
                          ),
                          newInitiative.clear(),
                          Navigator.pop(context, "Ok"),
                        },
                        child: Text("Ok"),
                      ),
                    ],
                  ),
                ),
                child: Text(item.initiative.toString()),
              ),
              title: OverflowBar(
                spacing: 8,
                children: [
                  Row(
                    children: [
                      // Icon(Icons.arrow_forward),
                      Text(item.name),
                      SizedBox(width: 10),
                      // InputWidget(label: "", controller: charHeath),
                    ],
                  ),
                ],
              ),
              trailing: OverflowBar(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      print("Adding a note to ${item.name}");
                      // TODO: Implement notes
                    },
                    child: Icon(Icons.assignment_add),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      appState.removeCharacter(item);
                    },
                    child: Icon(Icons.delete),
                  ),
                  MenuAnchor(
                    childFocusNode: _menuFocusNode,
                    menuChildren: <Widget>[
                      MenuItemButton(
                        child: Row(
                          children: [
                            Icon(EditCharacterMenuEntry.editName.icon),
                            Text(EditCharacterMenuEntry.editName.label),
                          ],
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Change Name"),
                            content: InputWidget(
                              label: "New Name",
                              controller: newName,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => {
                                  appState.setDisplayName(item, newName.text),
                                  newName.clear(),
                                  Navigator.pop(context, "Ok"),
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      MenuItemButton(
                        child: Row(
                          children: [
                            SettingMenuItem(
                              entry: EditCharacterMenuEntry.editInitiative,
                            ),
                          ],
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Changing Initiative"),
                            content: InputWidget(
                              label: "New Initiative",
                              controller: newInitiative,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => {
                                  appState.setInitiative(
                                    item,
                                    int.parse(newInitiative.text),
                                  ),
                                  newInitiative.clear(),
                                  Navigator.pop(context, "Ok"),
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      MenuItemButton(
                        child: Row(
                          children: [
                            SettingMenuItem(
                              entry: EditCharacterMenuEntry.editName,
                            ),
                          ],
                        ),
                      ),
                    ],
                    builder: // edit character menu
                        (
                          BuildContext context,
                          MenuController controller,
                          Widget? child,
                        ) {
                          return OutlinedButton(
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            child: Icon(Icons.build),
                          );
                        },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SettingMenuItem extends StatelessWidget {
  const SettingMenuItem({super.key, required this.entry});

  final EditCharacterMenuEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(entry.icon), Text(entry.label)]);
  }
}

AlertDialog errorAlert(String errorText, BuildContext context) {
  return AlertDialog(
    title: Text("Error!"),
    content: Text(errorText),
    actions: [
      OutlinedButton(
        onPressed: () => {Navigator.pop(context, 'Ok')},
        child: Text("Ok"),
      ),
    ],
  );
}

enum EditCharacterMenuEntry {
  editName('Edit Name', Icons.edit),
  editInitiative('Edit Initiative', Icons.edit),
  setAsCurrTurn('Set as Current Turn', Icons.arrow_downward);

  const EditCharacterMenuEntry(this.label, this.icon);
  final IconData icon;
  final String label;
}
