import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:atlas/pages/APIcalls.dart';
import 'package:go_router/go_router.dart';
import 'package:atlas/models/exercises.dart';
import 'package:atlas/models/attributes.dart';
import 'package:flutter/services.dart';

class Phases extends StatefulWidget {
  String token;
  Map object;
  Phases({required this.token, required this.object});

  @override
  State<Phases> createState() => _PhasesState();
}

class _PhasesState extends State<Phases> {
  bool isEditable = false;
  List sub_sport = [];
  List exercise = [];
  List attributes = [];
  bool _showChildren = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void updateObject(Map object) {
    setState(() {
      widget.object = widget.object;
    });
  }

  Widget processObjects(String token, Map object, context) {
    TextEditingController _controller = TextEditingController();
    _controller.text = object['nazev'];
    return Column(children: [
      // Button ktery vrati uzivatele na vyssi vrstvu
      if (_showChildren)
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showChildren = !_showChildren;
                });
              },
              child: Text(object['nazev']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[200]),
            ),
          ],
        ),
      // zobrazi atributy ( pouze u cviku) hned nahore
      if (_showChildren)
        object['assigned_exercise'].isNotEmpty
            ? Exercises(token: token, object: object)
            : Container(),
      _showChildren
          ? Container()
          : ListTile(
              title: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    isEditable
                        ? Container()
                        : IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => setState(() {
                              isEditable = true;
                            }),
                          ),
                    isEditable
                        ? Flexible(
                            child: EditableText(
                              controller: _controller,
                              focusNode: FocusNode(),
                              onChanged: (value) {},
                              onSubmitted: (value) {
                                changePhase(token, object["id_faze"],
                                    nazevFaze: value);
                                setState(() {
                                  isEditable = false;
                                  object['nazev'] = value;
                                });
                              },
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black),
                              cursorColor: Colors.blue,
                              backgroundCursorColor: Colors.blue,
                              autocorrect: true,
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                            ),
                          )
                        // Pokud neni list cviku prazdny tak vypise ve jmene vsechy cviky
                        // pokud ano vypise jmeno pouze faze
                        : (object['assigned_exercise'] as List).isNotEmpty
                            ? Text(_controller.text +
                                " - " +
                                (object['assigned_exercise'] as List)
                                    .map((map) => map["nazev"].toString())
                                    .join(" + "))
                            : Text(_controller.text)
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      (object['sub_sport'] as List).isNotEmpty
                          ? ElevatedButton(
                              onPressed: () =>
                                  _showSports(context, object, token),
                              child: Text('Přidat fázi'),
                            )
                          : Container(),
                      (object['exercise'] as List).isNotEmpty
                          ? ElevatedButton(
                              onPressed: () =>
                                  _showExercise(context, object, token),
                              child: Text('Přidat cvik'),
                            )
                          : Container(),
                      (object['attributes'] as List).isNotEmpty
                          ? ElevatedButton(
                              onPressed: () =>
                                  _showAtributes(context, object, token),
                              child: Text('Přidat atribut'),
                            )
                          : Container(),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            changePhase(token, object["id_faze"], active: 0);
                            object = {};
                          });
                        },
                        child: Text('Odebrat fázi'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[200]),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                print('clicked!');
                // prepne _showChildren, tim ukaze dalsi vrstvu
                setState(() {
                  _showChildren = !_showChildren;
                });
              },
            ),

      // Vypise kazdou podrazenou fazi jako dalsi classu Phase
      // Kazda Phase si uchovava svuj vlastni stav
      if (_showChildren)
        object['next'].isNotEmpty
            ? Column(
                children: (object['next'] as List<dynamic>)
                    .map<Widget>((obj) => Phases(
                          token: token,
                          object: obj,
                        ))
                    .toList(),
              )
            : Container(),

      object['assigned_attributes'].isNotEmpty
          ? Attributes(token: token, attributes: object['assigned_attributes'])
          : Container(),
    ]);
    /*return ListView(
      shrinkWrap: true,
      children: objects.map<Widget>(
        (obj) {
          TextEditingController _controller = TextEditingController();
          _controller.text = obj['nazev'];
          bool _showChildren = false;
          return Column(children: [
            _showChildren
                ? Container()
                : ListTile(
                    title: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              isEditable
                                  ? Container()
                                  : IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => setState(() {
                                        isEditable = true;
                                      }),
                                    ),
                              isEditable
                                  ? Flexible(
                                      child: EditableText(
                                        controller: _controller,
                                        focusNode: FocusNode(),
                                        onChanged: (value) {},
                                        onSubmitted: (value) {
                                          changePhase(token, obj["id_faze"],
                                              nazevFaze: value);
                                          setState(() {
                                            isEditable = false;
                                            obj['nazev'] = value;
                                          });
                                        },
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
                                        cursorColor: Colors.blue,
                                        backgroundCursorColor: Colors.blue,
                                        autocorrect: true,
                                        maxLines: 1,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    )
                                  : Text(_controller.text),
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            (obj['sub_sport'] as List).isNotEmpty
                                ? ElevatedButton(
                                    onPressed: () =>
                                        _showSports(context, obj, token),
                                    child: Text('Přidat fázi'),
                                  )
                                : Container(),
                            (obj['exercise'] as List).isNotEmpty
                                ? ElevatedButton(
                                    onPressed: () =>
                                        _showExercise(context, obj, token),
                                    child: Text('Přidat cvik'),
                                  )
                                : Container(),
                            (obj['attributes'] as List).isNotEmpty
                                ? ElevatedButton(
                                    onPressed: () =>
                                        _showAtributes(context, obj, token),
                                    child: Text('Přidat atribut'),
                                  )
                                : Container(),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  changePhase(token, obj["id_faze"], active: 0);
                                  widget.objects.removeWhere((item) =>
                                      item["id_faze"] == obj["id_faze"]);
                                });
                              },
                              child: Text('Odebrat fázi'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[200]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      print('clicked!');
                      //widget.expandedList.addExpandedList(obj);
                      //print(obj['next']);
                      setState(() {
                        _showChildren = !_showChildren;
                      });
                    },
                  ),
            if (_showChildren)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showChildren = !_showChildren;
                      });
                    },
                    child: Text(obj['nazev']),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[200]),
                  ),
                ],
              ),

            /*IconButton(
                    onPressed: () {
                      setState(() {
                        toggleChildren();
                      });
                    },
                    icon: Icon(Icons.backspace)),
              Text(obj['nazev']),*/
            if (_showChildren)
              obj['next'].isNotEmpty
                  ? Phases(
                      token: token,
                      objects: obj['next'],
                    )
                  : Container(),
            if (_showChildren)
              obj['assigned_exercise'].isNotEmpty
                  ? Exercises(token: token, object: obj)
                  : Container(),
            if (_showChildren)
              obj['assigned_attributes'].isNotEmpty
                  ? Attributes(
                      token: token, attributes: obj['assigned_attributes'])
                  : Container(),
          ]);
        },
      ).toList(),
    );*/
  }

  void _showSports(BuildContext context, Map phase, String token) {
    Map? selected = phase['sub_sport'][0];
    List subSport = phase['sub_sport'];

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Vyberte fázi'),
                SizedBox(height: 16),
                DropdownButton<Map>(
                  items: subSport.map((sport) {
                    return DropdownMenuItem<Map>(
                      value: sport,
                      child: Text(sport['nazev']),
                    );
                  }).toList(),
                  value: selected,
                  onChanged: (Map? value) {
                    setState(() {
                      selected = value;
                    });
                  },
                  // definuje co se ma vypsat na displayi
                ),
                // Inside your build method:

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Zavřít'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Map res = await setSport(token, selected!['id_sport'],
                            phase['id_zkusenost'], selected!['nazev'],
                            id_nadrazeny_sport: phase['id_faze']);
                        if (res['status_code'] != 200) {
                          context.goNamed('login');
                          return;
                        } else {
                          setState(() {
                            phase['next'].add(jsonDecode(res['body']));
                            updateObject(phase);
                          });
                        }

                        Navigator.pop(context);
                      },
                      child: Text('Přidat'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showExercise(BuildContext context, Map obj, String token) {
    exercise = obj['exercise'];
    Map? selectedCvik = exercise[0];

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Vyberte Cvik'),
                SizedBox(height: 16),

                // Inside your build method:
                exercise.isNotEmpty
                    ? DropdownButton<Map>(
                        items: exercise!.map((sport) {
                          return DropdownMenuItem<Map>(
                            value: sport,
                            child: Text(sport['nazev']),
                          );
                        }).toList(),
                        value: selectedCvik,
                        onChanged: (Map? value) {
                          setState(() {
                            selectedCvik = value;
                          });
                        },
                        // definuje co se ma vypsat na displayi
                      )
                    : Container(),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Zavřít'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Map res = await setExerciseForPhase(
                            token, selectedCvik?['id_cvik'], obj['id_faze']);
                        if (res['status_code'] != 200) {
                          context.goNamed('login');
                          return;
                        } else {
                          setState(() {
                            obj['assigned_exercise']
                                .add(jsonDecode(res['body']));
                            (obj['next'] as List).forEach((value) {
                              List assignedExerciseList =
                                  value['assigned_exercise_for_attributes'];
                              assignedExerciseList.add(jsonDecode(res['body']));
                            });
                            updateObject(obj);
                          });
                        }

                        Navigator.pop(context);
                      },
                      child: Text('Přidat'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // Pridani atributu tzn opakovani, selhani
  void _showAtributes(BuildContext context, Map obj, String token) {
    attributes = obj['attributes'];
    List finalList = [];
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Column(
                  children: (obj['assigned_exercise_for_attributes'] as List)
                      .map((assignedExercise) {
                    return Column(children: [
                      Text(assignedExercise["nazev"]),
                      ...attributes.map((sport) {
                        return TextField(
                          decoration:
                              new InputDecoration(labelText: sport['nazev']),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onSubmitted: (value) {
                            finalList.add({
                              'hodnota': value,
                              'id_faze_cvik': assignedExercise["id_faze_cvik"],
                              'id_atribut': sport['id_atribut'],
                              'id_atribut_nadrazeny':
                                  sport['id_atribut_nadrazeny']
                            });
                          }, // Only numbers can be entered
                        );
                      }).toList(),
                    ]);
                  }).toList(),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Zavřít'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Map res = await setAttributeForPhase(
                            token, finalList, obj['id_faze']);
                        if (res['status_code'] == 401) {
                          context.goNamed('login');
                          return;
                        }
                        obj['assigned_attributes'] = jsonDecode(res['body']);
                        updateObject(obj);
                        Navigator.pop(context);
                      },
                      child: Text('Přidat'),
                    ),
                  ],
                ),
              ]
                  // definuje co se ma vypsat na displayi
                  ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return processObjects(widget.token, widget.object, context);
  }
}
