import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:atlas/pages/APIcalls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypt/crypt.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  ApiCalls api = ApiCalls();

  final _formKey = GlobalKey<FormState>();
  final nameControler = TextEditingController();
  final emailControler = TextEditingController();
  final passControler = TextEditingController();

  bool obscurePassword = true;
  String? error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void signUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map result = await api.signIn(
        passControler.text, nameControler.text, emailControler.text);
    try {
      pref.setString('token', result['access_token']);
      context.goNamed('root');
    } catch (e) {
      error = result['error'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[800],
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                context.goNamed('login');
              },
              child: Icon(Icons.keyboard_backspace_sharp),
            ),
            Text('Vytvořit účet'),
          ],
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              context.goNamed('root');
            },
            child: Icon(Icons.home),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
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
                controller: nameControler,
                decoration: const InputDecoration(
                  labelText: 'Zadejte uživatelské jméno',
                  hintText: 'Přezdívka, v aplikaci',
                  prefixIcon: Icon(Icons.assignment_ind_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Zadejte uživatelské jméno";
                  }
                  return null;
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
                      signUser();
                    });
                  }
                },
                child: Text('Odeslat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
