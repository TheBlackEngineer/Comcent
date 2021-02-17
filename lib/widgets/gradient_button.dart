import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final Function onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final bool elevated;

  const GradientButton({
    Key key,
    @required this.label,
    this.gradient,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius,
    this.elevated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: elevated == null ? EdgeInsets.symmetric(vertical: 10.0) : EdgeInsets.zero,
      width: width == null ? MediaQuery.of(context).size.width / 1.3 : width,
      height: height == null ? 50.0 : height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.teal[700],
            Colors.teal[400],
            Colors.teal[200],
          ],
        ),
        boxShadow: [
          elevated == null
              ? BoxShadow(
                  color: Colors.grey[500],
                  offset: Offset(0.0, 1.5),
                  blurRadius: 1.5,
                )
              : BoxShadow(color: Colors.transparent),
        ],
        borderRadius:
            BorderRadius.circular(borderRadius == null ? 30.0 : borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 17.0),
              ),
            )),
      ),
    );
  }
}
