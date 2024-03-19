import 'package:atlas/pages/APIcalls.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlas/models/phases.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? token;

  List phaseData = [];
  @override
  void initState() {
    super.initState();
    checkToken();
    getData();
  }

  void getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      List phase = await getActivePhase(pref.getString('token')!);
      print(phase);
      // pokud jue list prazdny uzivatel je presmerovan na vybrani sportu
      if (phase.length == 0) {
        context.goNamed('chooseSport');
      }
      //naplneni listu
      setState(() {
        phaseData = phase;
      });
    } catch (e) {
      // pokud neni definovan token uzivatel je presmerovan na obrazovku prihlaseni
      print(e);
      context.goNamed('login');
    }
  }

  void setPhaseData(Map value) {
    setState(() {
      phaseData = [value];
    });
  }

  void checkToken() async {
    // ziska token ze sessiony
    SharedPreferences pref = await SharedPreferences.getInstance();
    // kontrola zda je token prazdy
    if (pref.getString('token') == null) {
      context.goNamed('login');
      return;
    }
    token = pref.getString('token');
  }

  Future<List> getActivePhase(String token) async {
    var phase = await getPhase(token);
    if (phase['status_code'] == 401) {
      throw Exception("Unauthorized");
    }
    return phase['res'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[800],
        title: Text('Home'),
        actions: [],
      ),
      body: Container(
          child: phaseData.isNotEmpty
              ? ListView(
                  children: phaseData
                      .map((obj) => Phases(
                            token: token!,
                            object: obj,
                          ))
                      .toList()
                  /*[
                    Phases(token: token!, objects: phaseData),
                  ]*/
                  ,
                )
              : Container()),
    );
  }
}
