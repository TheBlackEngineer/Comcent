import 'package:flutter/material.dart';

class DeadButton extends StatelessWidget {
  final String label;
  final double width;
  final double height;

  const DeadButton({Key key, @required this.label, this.height, this.width})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      width: width == null ? MediaQuery.of(context).size.width / 1.3 : width,
      height: height == null ? 50.0 : height,
      child: Center(
          child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 17.0),
      )),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
  }
}
