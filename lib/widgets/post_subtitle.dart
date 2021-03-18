import 'package:comcent/imports.dart';

import 'package:flutter/material.dart';

class PostTitleAndSubtitle extends StatelessWidget {
  final ExpandableController expandableController;
  final String postTitle, postBody;

  PostTitleAndSubtitle(
      {@required this.expandableController,
      @required this.postTitle,
      @required this.postBody});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: MediaQuery.of(context).size.width / 17,
      ),
      subtitle: ExpandablePanel(
        controller: this.expandableController,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post title
            Text(
              this.postTitle,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textSelectionColor),
            ),

            // spacer
            SizedBox(height: 5.0),
          ],
        ),
        collapsed: GestureDetector(
          child: Linkify(
            text: this.postBody,
            maxLines: 3,
            overflow: TextOverflow.fade,
            options: LinkifyOptions(looseUrl: true),
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
          ),
          onTap: () => expandableController.toggle(),
        ),
        expanded: GestureDetector(
          child: Linkify(
            text: this.postBody,
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
          ),
          onTap: () => expandableController.toggle(),
        ),
        // ignore: deprecated_member_use
        hasIcon: false,
      ),
    );
  }
}
