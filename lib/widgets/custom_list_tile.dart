import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData iconData;
  final String label;
  final Function onTap;

  const CustomListTile({Key key, this.iconData, this.label, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // icon
            CircleAvatar(
              radius: 25.0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Icon(iconData),
                ),
              ),
            ),

            // spacer
            SizedBox(width: 12.0),

            // label
            Text(label),
          ],
        ),
        subtitle: Divider(),
      ),
    );
  }
}
