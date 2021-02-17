import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // return either Home or Authenticate screen if user is signed in or out
    if (user == null) {
      return Authenticate();
    } else {
      return PreHome();
    }
  }
}
