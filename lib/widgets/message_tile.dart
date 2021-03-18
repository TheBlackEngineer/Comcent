import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class MessageTile extends StatefulWidget {
  final Message message;

  const MessageTile({Key key, this.message}) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    bool isMe = widget.message.senderID == user.uid;
    Timestamp timestamp = widget.message.sendTime;
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.jm().format(dateTime);
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: Padding(
        padding: isMe
            ? const EdgeInsets.only(right: 15.0)
            : const EdgeInsets.only(left: 15.0),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            // sender of message
            !isMe
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      widget.message.userName,
                      style: TextStyle(
                          color: Colors.teal[800], fontWeight: FontWeight.w500),
                    ),
                  )
                : Text(''),

            // message body and time
            isMe
                ? FocusedMenuHolder(
                    child: buildMessageContent(
                        widget.message, isMe, formattedTime),
                    onPressed: () {},
                    menuWidth: MediaQuery.of(context).size.width * 0.50,
                    menuItemExtent: 45,
                    menuBoxDecoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    duration: Duration(milliseconds: 100),
                    menuOffset:
                        10.0, // Offset value to show menuItem from the selected item

                    menuItems: <FocusedMenuItem>[
                      // copy to clipboard
                      FocusedMenuItem(
                        title: Text(
                          widget.message.type != MessageType.Normal
                              ? 'Copy link'
                              : 'Copy',
                          style: TextStyle(color: Colors.black),
                        ),
                        trailingIcon: Icon(
                          Icons.paste,
                        ),
                        onPressed: () => Clipboard.setData(
                          ClipboardData(text: widget.message.messageBody),
                        ).then((value) => showSnackBar(
                            message: 'Copied to clipboard', context: context)),
                      ),

                      // delete
                      FocusedMenuItem(
                          title: Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          trailingIcon: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            // delete message
                            await FirestoreService.clubsCollection
                                .doc(widget.message.clubID)
                                .collection('messages')
                                .doc(widget.message.messageID)
                                .delete();

                            // delete any file in storage
                            if (widget.message.type != MessageType.Normal) {
                              await FirestoreService.deleteFile(
                                fileName: widget.message.messageID,
                                fileType: 'Message',
                                clubID: widget.message.clubID,
                              );
                            }
                          }),
                    ],
                  )
                : FocusedMenuHolder(
                    menuWidth: MediaQuery.of(context).size.width * 0.50,
                    menuItemExtent: 45,
                    menuOffset: 10.0,
                    menuBoxDecoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(80.0))),
                    duration: Duration(milliseconds: 100),
                    onPressed: () {},
                    child: buildMessageContent(
                        widget.message, isMe, formattedTime),
                    menuItems: <FocusedMenuItem>[
                      // copy to clipboard
                      FocusedMenuItem(
                        title: Text(
                          widget.message.type == MessageType.Normal
                              ? 'Copy'
                              : 'Copy link',
                          style: TextStyle(color: Colors.black),
                        ),
                        trailingIcon: Icon(
                          Icons.paste,
                        ),
                        onPressed: () => Clipboard.setData(
                          ClipboardData(text: widget.message.messageBody),
                        ).then((value) => showSnackBar(
                            message: 'Copied to clipboard', context: context)),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  buildMessageContent(Message message, bool isMe, String formattedTime) {
    if (message.type == MessageType.Normal) {
      Widget textMessageWidget = Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 3.0, bottom: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 10,
              child: Column(
                children: [
                  // message text
                  Linkify(
                    text: widget.message.messageBody,
                    softWrap: true,
                    options: LinkifyOptions(looseUrl: true),
                    style: TextStyle(
                      color: isMe ? Colors.teal[800] : Colors.white,
                      fontSize: 16.0,
                    ),
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                  ),

                  // spacer
                  SizedBox(height: 5.0),
                ],
              ),
            ),

            // placeholder text
            Flexible(
                flex: 1,
                child: Text(
                  'place',
                  style: TextStyle(color: Colors.transparent),
                )),
          ],
        ),
      );
      return MessageBodyAndTime(
          isMe: isMe, child: textMessageWidget, formattedTime: formattedTime);
    } else if (message.type == MessageType.Image) {
      Widget imageMessageWidget = GestureDetector(
        child: Stack(
          children: [
            // image
            FadeInImage(
              placeholder: AssetImage('assets/illustrations/placeholder.png'),
              image: CachedNetworkImageProvider(
                message.messageBody.split('<<>>').first,
                maxWidth: (MediaQuery.of(context).size.width) ~/ 2,
              ),
            ),

            // Time sent
            Positioned(
              child: Text(
                formattedTime.toLowerCase().split(' ').first +
                    formattedTime.toLowerCase().split(' ')[1],
                style: TextStyle(
                    color: isMe ? Colors.teal[800] : Colors.white,
                    fontSize: 13.0),
              ),
              right: 8.0,
              bottom: 4.0,
            )
          ],
        ),
        // expand image on tap
        onTap: () => Navigator.push(
          context,
          TransparentCupertinoPageRoute(
            builder: (context) => ImageView(
              imageUrl: message.messageBody.split('<<>>').first,
            ),
          ),
        ),
      );
      return imageMessageWidget;
    } else if (message.type == MessageType.Video) {
      Widget videoMessageWidget = GestureDetector(
          child: Container(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                // spacer
                SizedBox(height: 15.0),

                // icon and label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: isMe ? Colors.grey : Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Video',
                      style: TextStyle(
                          fontSize: 16,
                          color: isMe ? Colors.teal : Colors.white),
                    ),
                  ],
                ),

                // spacer
                SizedBox(height: 8),

                // play icon
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                  ),
                ),

                // spacer
                SizedBox(height: 25.0),
              ],
            ),
          ),
          onTap: () => showVideoPlayer(
              context, message.messageBody.split('<<>>').first));
      return MessageBodyAndTime(
          isMe: isMe, child: videoMessageWidget, formattedTime: formattedTime);
    } else {
      Widget documentMessageWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: GestureDetector(
          child: Column(
            children: <Widget>[
              // icon and label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // document icon
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.file_copy_outlined,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Document',
                    style: TextStyle(
                        fontSize: 16, color: isMe ? Colors.teal : Colors.white),
                  ),
                ],
              ),

              // spacer
              SizedBox(height: 8),

              // document title
              Text(
                message.messageBody.split('<<>>')[1],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isMe ? Colors.black : Colors.white,
                ),
              ),

              // spacer
              SizedBox(height: 25.0),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) =>
                  PDFScreen(message.messageBody.split('<<>>').first),
            ),
          ),
        ),
      );
      return MessageBodyAndTime(
          isMe: isMe,
          child: documentMessageWidget,
          formattedTime: formattedTime);
    }
  }

  void showVideoPlayer(parentContext, String videoUrl) async {
    await showModalBottomSheet(
        context: parentContext,
        builder: (BuildContext bc) {
          return ChewieListItem(
            videoPlayerController: VideoPlayerController.network(videoUrl),
          );
        });
  }
}

class MessageBodyAndTime extends StatelessWidget {
  final bool isMe;
  final Widget child;
  final String formattedTime;

  const MessageBodyAndTime({
    Key key,
    @required this.isMe,
    @required this.child,
    @required this.formattedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.5),
      child: SpeechBubble(
        borderRadius: 8.0,
        nipLocation: isMe ? NipLocation.RIGHT : NipLocation.LEFT,
        color: isMe ? Colors.white : Colors.teal[800],
        child: Stack(
          children: <Widget>[
            // message content
            child,
            // time
            Positioned(
              child: Text(
                formattedTime.toLowerCase().split(' ').first +
                    formattedTime.toLowerCase().split(' ')[1],
                style: TextStyle(
                    color: isMe ? Colors.teal[800] : Colors.white,
                    fontSize: 13.0),
              ),
              right: 8.0,
              bottom: 4.0,
            )
          ],
        ),
      ),
    );
  }
}
