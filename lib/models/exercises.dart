import 'package:flutter/material.dart';

class Exercises extends StatefulWidget {
  String token;
  Map object;
  Exercises({required this.token, required this.object});

  @override
  State<Exercises> createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  @override
  Widget build(BuildContext context) {
    return printExercises();
  }

  void _showExerciseModal(Map obj) {
    List filteredMaps = [];
    (widget.object['next'] as List).forEach((underObjects) {
      (underObjects['assigned_attributes'] as List).forEach((map) {
        if (map["id_faze_cvik"] == obj['id_faze_cvik']) {
          filteredMaps.add(map);
        }
      });
    });
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            children: [
              Text(obj['nazev'].toString()),
              ...filteredMaps.map((e) {
                return Row(
                  children: [
                    Text(e['nazev'].toString()),
                    Text(e['hodnota'].toString()),
                  ],
                );
              }).toList(),
            ],
          ),
        );
        //TODO: vypisovat pouze sloupce ktere jsou urceny pro tento sport
        //TODO: funkce pro zmenu atributu
        //TODO: pri pridavani cviku zadat pocatecni hodnoty serii, opakovani, selhani
        //TODO: atributy se dedi, v dalsim treninku budou hodnoty z predchoziho
      },
    );
  }

  Widget printExercises() {
    return SingleChildScrollView(
      child: Column(
        children: (widget.object['assigned_exercise'] as List).map((exercise) {
          return Card(
            child: InkWell(
              onTap: () {
                _showExerciseModal(exercise);
              },
              child: SizedBox(
                width: 300,
                height: 50,
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      exercise['nazev'].toString(),
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
