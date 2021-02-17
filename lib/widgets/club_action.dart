import 'package:flutter/material.dart';

class ClubAction extends StatelessWidget {
  final IconData iconData;
  final String label;
  final Function onTap;

  const ClubAction({Key key, this.iconData, this.label, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // card icon
              Icon(
                iconData,
                color: Theme.of(context).primaryColor,
              ),

              SizedBox(width: 8.0),

              // card label
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
