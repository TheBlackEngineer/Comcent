import 'package:flutter/material.dart';

class SendMessageButton extends StatelessWidget {
  final Function onPressed;

  const SendMessageButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 6.0,
      height: 50.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.centerRight,
          colors: <Color>[
            Colors.teal[500],
            Colors.teal[100],
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
                child: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ))),
      ),
    );
  }
}
