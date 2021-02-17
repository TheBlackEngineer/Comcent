import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class LeadershipBadge extends StatelessWidget {
  final double size;

  const LeadershipBadge({Key key, this.size}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(FontAwesome5Solid.award,
          color: Colors.blueAccent, size: this.size == null ? 18.0 : this.size),
    );
  }
}
