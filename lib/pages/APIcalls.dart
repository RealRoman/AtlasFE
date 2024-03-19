import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypt/crypt.dart';

class ApiCalls {
  ApiCalls();

  Future<Map> signIn(String password, String name, String email) async {
    // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
    final url = Uri.parse('http://10.0.2.2:8000/signIn/');
    // objekt uzivatele
    final body = jsonEncode({
      'email': email,
      'username': name,
      'password': password,
    });
    // pocka na odpoved
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    // dle status kodu vrati vysledek
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 403:
        return {'error': 'Uživatel s tímto emailem již existuje'};
      default:
        return jsonDecode(response.body);
    }
  }

  Future<Map> logIn(String password, String email) async {
    // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
    final url = Uri.parse('http://10.0.2.2:8000/token/');
    // objekt uzivatele

    final body = {
      'username': email,
      'password': password,
      'grant_type': 'password', // Required for OAuth2PasswordRequestForm
    };
    print('login');
    final response = await http.post(
      url,
      body: body,
    );
    // dle status kodu vrati vysledek
    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(response.body);
        return jsonDecode(response.body);
      case 401:
        return {'error': 'Špatný email, nebo heslo.'};
      default:
        return jsonDecode(response.body);
    }
  }
}

Future<Map> getPhase(String token) async {
  // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
  final url = Uri.parse('http://10.0.2.2:8000/getActivePhase/');
  // objekt uzivatele
  final headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  final response = await http.get(url, headers: headers);
  // dle status kodu vrati vysledek
  return {'status_code': response.statusCode, 'res': jsonDecode(response.body)};
}

Future<Map> getSports() async {
  // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
  final url = Uri.parse('http://10.0.2.2:8000/getSports/');
  // objekt uzivatele
  final headers = {
    'accept': 'application/json',
  };

  final response = await http.get(url, headers: headers);
  // dle status kodu vrati vysledek
  switch (response.statusCode) {
    case 200:
      return jsonDecode(response.body);
    default:
      return jsonDecode(response.body);
  }
}

Future<Map> setSport(
    String token, int selectedSport, int selectedExp, String nazevFaze,
    {dynamic id_nadrazeny_sport}) async {
  // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
  final url = Uri.parse('http://10.0.2.2:8000/setSport/');
  // objekt uzivatele
  final headers = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  print('honza je kár');
  final body = jsonEncode({
    'nazev': nazevFaze,
    'id_faze_nadrazene': id_nadrazeny_sport,
    'id_sport': selectedSport,
    'id_zkusenost': selectedExp,
  });
  final response = await http.post(url, headers: headers, body: body);
  // dle status kodu vrati vysledek
  switch (response.statusCode) {
    case 200:
      Map res = {'status_code': response.statusCode, 'body': response.body};
      return res;
    default:
      print(response.statusCode);
      Map res = {'status_code': response.statusCode, 'error': response.body};
      return res;
  }
}

Future<Map> changePhase(String token, int id_faze,
    {int? selectedSport,
    int? selectedExp,
    String? nazevFaze,
    dynamic? id_ndarazene_faze,
    int? active}) async {
  // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
  final url = Uri.parse('http://10.0.2.2:8000/patchPhase/$id_faze/');
  // objekt uzivatele
  final headers = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final Map<String, dynamic> data = {
    'nazev': nazevFaze,
    'id_faze_nadrazene': id_ndarazene_faze,
    'id_sport': selectedSport,
    'id_zkusenost': selectedExp,
    'active': active,
  };

  data.removeWhere((key, value) => value == null);

  final body = jsonEncode(data);
  final response = await http.patch(url, headers: headers, body: body);
  // dle status kodu vrati vysledek
  switch (response.statusCode) {
    case 200:
      Map res = {'status_code': response.statusCode, 'body': response.body};
      return res;
    default:
      Map res = {'status_code': response.statusCode, 'error': response.body};
      return res;
  }
}

Future<Map> setExerciseForPhase(
  String token,
  int selectedExercise,
  int selectedPhase,
) async {
  // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
  final url = Uri.parse('http://10.0.2.2:8000/setPhaseExercise/');
  // objekt uzivatele
  final headers = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body =
      jsonEncode({'id_faze': selectedPhase, 'id_cvik': selectedExercise});
  final response = await http.post(url, headers: headers, body: body);
  // dle status kodu vrati vysledek
  switch (response.statusCode) {
    case 200:
      Map res = {'status_code': response.statusCode, 'body': response.body};
      return res;
    default:
      Map res = {'status_code': response.statusCode, 'error': response.body};
      return res;
  }
}

Future<Map> setAttributeForPhase(
  String token,
  List selectedAttributes,
  int selectedPhase,
) async {
  print(selectedAttributes);
  // zazada na adresu fastapi, v devu musi byt adresa lokalni iú
  final url =
      Uri.parse('http://10.0.2.2:8000/setPhaseAttribut/Phase/$selectedPhase/');
  // objekt uzivatele
  final headers = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = jsonEncode({'attributes': selectedAttributes});
  print(body);
  final response = await http.post(url, headers: headers, body: body);
  // dle status kodu vrati vysledek
  switch (response.statusCode) {
    case 200:
      Map res = {'status_code': response.statusCode, 'body': response.body};
      return res;
    default:
      Map res = {'status_code': response.statusCode, 'error': response.body};
      return res;
  }
}
