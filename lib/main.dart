import 'package:atlas/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:atlas/pages/home.dart';
import 'package:atlas/pages/sign_in.dart';
import 'package:atlas/pages/ChooseSport.dart';

void main() {
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        name: 'root',
        path: "/",
        builder: (context, state) => Home(),
      ),
      GoRoute(
        name: 'login',
        path: "/login",
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        name: 'signin',
        path: "/signIn",
        builder: (context, state) => const SignIn(),
      ),
      GoRoute(
        name: 'chooseSport',
        path: "/chooseSport",
        builder: (context, state) => const ChooseSport(),
      ),
    ],
  );

  runApp(MaterialApp.router(
    routerConfig: _router,
  ));
}
