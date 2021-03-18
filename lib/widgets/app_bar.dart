import 'package:flutter/material.dart';

AppBar appBar(
    {@required String title,
    onPressed,
    Color backgroundColor,
    @required BuildContext context}) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(color: Theme.of(context).primaryColor),
    ),
    elevation: 0.0,
    leading: onPressed != null
        ? IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textSelectionColor,
            ),
            onPressed: onPressed,
          )
        : SizedBox.shrink(),
  );
}
