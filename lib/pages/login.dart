import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypt/crypt.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlas/pages/APIcalls.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ApiCalls api = ApiCalls();

  final _formKey = GlobalKey<FormState>();
  final emailControler = TextEditingController();
  final passControler = TextEditingController();

  String? error;
  bool obscurePassword = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void logIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map result = await api.logIn(passControler.text, emailControler.text);
    try {
      pref.setString('token', result['access_token']);
      context.goNamed('root');
    } catch (e) {
      print(e);
      error = result['error'];
      //passControler.text = "";
      //emailControler.text = "";
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[800],
        title: Text('Login'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              context.pushNamed('signin');
            },
            child: Icon(Icons.fiber_new_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.00),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (error != null)
                Text(error!, style: TextStyle(color: Colors.redAccent)),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Zadejte email',
                  hintText: 'Váš email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                controller: emailControler,
                validator: (value) {
                  final RegExp emailRegex = RegExp(
                      r'^[\w-]+(?:\.[\w-]+)*@(?:[\w-]+\.)+[a-zA-Z]{2,7}$');

                  if (value == null || value.isEmpty) {
                    return "Prosím, vyplňte pole";
                  } else if (!emailRegex.hasMatch(value)) {
                    return "Prosím zdaejte validní email";
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                controller: passControler,
                obscureText: obscurePassword,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  labelText: 'Zadejte Heslo',
                  hintText: 'Vaše heslo',
                  prefixIcon: Icon(Icons.password_rounded),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    child: Icon(obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Zadejte heslo";
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      logIn();
                    });
                  }
                },
                child: Text('Přihlasit se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
