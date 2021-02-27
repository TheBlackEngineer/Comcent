import 'package:flutter/material.dart';

AppBar appBar(
    {@required String title,
    onPressed,
    Color backgroundColor,
    @required BuildContext context}) {
  return AppBar(
    brightness: Brightness.light,
    title: Text(
      title,
      style: TextStyle(color: Theme.of(context).primaryColor),
    ),
    centerTitle: true,
    elevation: 0.0,
    backgroundColor:
        backgroundColor == null ? Colors.transparent : backgroundColor,
    leading: onPressed != null
        ? IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: onPressed,
          )
        : SizedBox.shrink(),
  );
}
