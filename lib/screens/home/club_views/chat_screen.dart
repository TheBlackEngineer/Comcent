import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:comcent/imports.dart';

User user;
String message = '';

class ChatScreen extends StatefulWidget {
  final Club club;

  ChatScreen({Key key, this.club}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  CommunityProvider communityProvider;
  ScrollController scrollController;
  AnimationController animationController;

  final TextEditingController _controller = TextEditingController();

  String _docPath = '...';
  List<File> images = [];
  List<File> videos = [];
  List<File> documents = [];
  List<String> documentNames = [];
  final String snackBarMessage = 'Selection full. Tap on a file to deselect it';

  @override
  void initState() {
    super.initState();
    communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    scrollController = ScrollController();
    animationController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 0,
    );
    scrollController.addListener(() {
      switch (scrollController.position.userScrollDirection) {
        case ScrollDirection.forward:
          animationController.reverse();
          break;
        case ScrollDirection.reverse:
          animationController.forward();
          break;
        case ScrollDirection.idle:
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    animationController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // choice actions
    void choiceAction(String choice) {
      if (choice == Constants.ClubInfo) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ClubInfo(
                      club: widget.club,
                    )));
      } else if (choice == Constants.ExitClub) {
        _showDialog(context);
      } else {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ClubMedia(
                      club: widget.club,
                    )));
      }
    }

    user = Provider.of<User>(context);

    return KeyboardDismisser(
      gestures: [GestureType.onPanDown],
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.0,
          title: GestureDetector(
            child: Column(
              children: [
                // club image
                Hero(
                  tag: widget.club.clubPhoto.toString(),
                  child: widget.club.clubPhoto != null
                      ? CircularProfileAvatar(
                          widget.club.clubPhoto,
                          radius: 18.0,
                        )
                      : CircleAvatar(
                          radius: 18.0,
                          child: Icon(Icons.group),
                        ),
                ),

                // spacer
                SizedBox(height: 3.0),

                // club name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.club.name,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15.0),
                    ),

                    // spacer
                    SizedBox(width: 1.0),

                    // right chevron
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 11.0,
                    ),
                  ],
                ),

                // spacer
                SizedBox(height: 5.0),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ClubInfo(
                    club: widget.club,
                  ),
                ),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 3.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              icon:
                  Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return Constants.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: Column(
          children: [
            // messages
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService.clubsCollection
                    .doc(widget.club.id)
                    .collection('messages')
                    .orderBy('sendTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<DocumentSnapshot> docs = snapshot.data.docs;
                  List<MessageTile> messages = docs
                      .map((doc) => MessageTile(
                            message: Message.fromDocument(doc),
                          ))
                      .toList();

                  return messages.isNotEmpty
                      ? GroupedListView<dynamic, dynamic>(
                          elements: messages,
                          groupBy: (messageTile) {
                            DateTime myDateTime =
                                (messageTile.message.sendTime).toDate();
                            DateTime today = DateTime.now();
                            String chatDate =
                                DateFormat.MMMMd().format(myDateTime);
                            String todaysDate =
                                DateFormat.MMMMd().format(today);
                            // if the chat date is equal to the current date,
                            // return the string 'Today'
                            bool isToday = chatDate == todaysDate;
                            return isToday ? 'Today' : chatDate;
                          },
                          itemBuilder: (context, dynamic element) => element,
                          groupSeparatorBuilder: (groupByValue) => Center(
                            child: Container(
                              child: Text(groupByValue.toString(),
                                  textAlign: TextAlign.center),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15.0),
                              margin: EdgeInsets.only(top: 15.0, bottom: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          sort: false,
                          floatingHeader: true,
                          physics: BouncingScrollPhysics(),
                          controller: scrollController,
                          reverse: true,
                        )
                      : Center(
                          child: Text('No messages yet',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 15.0)),
                        );
                },
              ),
            ),

            // textfield and send button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                children: [
                  // number of files selected
                  images.isEmpty && videos.isEmpty && documents.isEmpty
                      ? SizedBox.shrink()
                      : Container(
                          height: 40.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            children: [
                              // assets and images
                              images.isNotEmpty
                                  ? Chip(
                                      label: Text(
                                          images.length.toString() + ' images'),
                                      deleteIcon: Icon(Icons.clear),
                                      onDeleted: () {
                                        images.clear();
                                        setState(() {});
                                      },
                                    )
                                  : SizedBox.shrink(),

                              SizedBox(width: 8.0),

                              // videos
                              videos.isNotEmpty
                                  ? Chip(
                                      label: Text(
                                          videos.length.toString() + ' videos'),
                                      deleteIcon: Icon(Icons.clear),
                                      onDeleted: () {
                                        videos.clear();
                                        setState(() {});
                                      },
                                    )
                                  : SizedBox.shrink(),

                              SizedBox(width: 8.0),

                              // documents
                              documents.isNotEmpty
                                  ? Chip(
                                      label: Text(documents.length.toString() +
                                          ' documents'),
                                      deleteIcon: Icon(Icons.clear),
                                      onDeleted: () {
                                        documents.clear();
                                        setState(() {});
                                      },
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),

                  // textfield and send message button
                  Row(
                    children: [
                      // add media button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              CupertinoIcons.link,
                              color: Colors.black,
                            ),
                          ),
                          onTap: openBottomSheet,
                        ),
                      ),

                      // textfield
                      Expanded(
                          child: Container(
                        child: TextField(
                          controller: _controller,
                          onChanged: (value) {
                            setState(() {
                              message = value;
                            });
                          },
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Enter message here',
                            hintStyle: TextStyle(color: Colors.blue),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.only(
                                top: 15.0, bottom: 15.0, left: 25.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      )),

                      // send message button
                      SendMessageButton(onPressed: () {
                        if (_controller.text.trim().isNotEmpty ||
                            (images + documents + videos).isNotEmpty) {
                          sendMessage();
                        } else {
                          showSnackBar(
                              message: "Can't send empty message",
                              context: context);
                        }
                      })
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FadeTransition(
          opacity: animationController,
          child: ScaleTransition(
            scale: animationController,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Container(
                height: 40.0,
                width: 40.0,
                child: FloatingActionButton(
                  backgroundColor: Colors.grey[200],
                  tooltip: 'Jump to bottom',
                  elevation: 28.0,
                  child: Icon(AntDesign.arrowdown, color: Colors.black),
                  onPressed: () {
                    scrollController.animateTo(
                      scrollController.position.minScrollExtent,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  
  }

  // message template
  Message messageTemplate(
      String messageID, String messageBody, String messageType) {
    return Message(
      type: messageType,
      userName: communityProvider.person.firstName +
          ' ' +
          communityProvider.person.lastName,
      clubID: widget.club.id,
      senderID: user.uid,
      messageID: messageID,
      messageBody: messageBody,
    );
  }

  // pick images from gallery
  Future<void> pickImages() async {
    try {
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: true);
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path)).toList();
        setState(() {
          images.addAll(files);
        });
      }
    } on PlatformException catch (e) {
      showSnackBar(
          message: "Unsupported operation + ${e.toString()}", context: context);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  // take photo with camera
  Future takePhoto() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        images.add(File(pickedFile.path));
      }
    });
  }

  // pick video
  void addVideoFromGallery() async {
    bool itemLimitReached = videos.length < 10;
    try {
      FilePickerResult result =
          await FilePicker.platform.pickFiles(type: FileType.video);

      if (result != null) {
        setState(() {
          itemLimitReached
              ? videos.add(File(result.files.single.path))
              : showSnackBar(message: snackBarMessage, context: context);
        });
      } else {
        print('No video was selected');
      }
    } on PlatformException catch (e) {
      showSnackBar(
          message: "Unsupported operation + ${e.toString()}", context: context);
    }

    if (!mounted) return;
  }

  // pick document
  void pickDocument() async {
    try {
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      _docPath = result.files.single.path;
    } on PlatformException catch (e) {
      showSnackBar(
          message: "Unsupported operation + ${e.toString()}", context: context);
    }

    if (!mounted) return;
    setState(() {
      documentNames.add(_docPath.split('/').last);
      _docPath != null
          ? documents.add(File(_docPath))
          : print('No document was selected');
    });
  }

  // show bottom sheet for user to pick profile
  Future openBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // camera
                  BottomSheetItem(
                    label: 'Camera',
                    iconData: CupertinoIcons.camera,
                    onTap: () {
                      Navigator.pop(context);
                      takePhoto();
                    },
                  ),

                  // gallery
                  BottomSheetItem(
                    label: 'Gallery',
                    iconData: CupertinoIcons.photo,
                    onTap: () {
                      Navigator.pop(context);
                      pickImages();
                    },
                  ),
                ],
              ),

              // spacer
              SizedBox(height: 25.0),

              // row 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // video
                  BottomSheetItem(
                    label: 'Video',
                    iconData: CupertinoIcons.videocam, 
                    onTap: () {
                      Navigator.pop(context);
                      addVideoFromGallery();
                    },
                  ),

                  // document
                  BottomSheetItem(
                    label: 'Document',
                    iconData: Entypo.documents,
                    onTap: () {
                      Navigator.pop(context);
                      pickDocument();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void sendMessage() async {
    if (_controller.text.isNotEmpty) {
      FirestoreService.sendMessage(widget.club.id,
          messageTemplate(Uuid().v4(), message, MessageType.Normal));
      _controller.clear();
    }

    // upload images if any
    if (images.isNotEmpty) {
      // show sending attachments
      await EasyLoading.show(
          status: 'One sec...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: true);
      for (int i = 0; i < images.length; i++) {
        String messageID = Uuid().v4();
        await postFileGetUrl(messageID: messageID, file: images[i]).then((url) {
          FirestoreService.sendMessage(widget.club.id,
              messageTemplate(messageID, url, MessageType.Image));
        });
      }
      EasyLoading.dismiss();
      setState(() {
        images.clear();
      });
    }

    // upload videos if any
    if (videos.isNotEmpty) {
      await EasyLoading.show(
          status: 'One sec...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: true);
      for (int i = 0; i < videos.length; i++) {
        String messageID = Uuid().v4();
        await postFileGetUrl(messageID: messageID, file: videos[i]).then((url) {
          FirestoreService.sendMessage(widget.club.id,
              messageTemplate(messageID, url, MessageType.Video));
        });
      }
      EasyLoading.dismiss();
      setState(() {
        videos.clear();
      });
    }

    // upload documents if any
    if (documents.isNotEmpty) {
      await EasyLoading.show(
          status: 'One sec...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: true);
      for (int i = 0; i < documents.length; i++) {
        String messageID = Uuid().v4();
        await postFileGetUrl(messageID: messageID, file: documents[i])
            .then((url) {
          FirestoreService.sendMessage(
              widget.club.id,
              messageTemplate(messageID, url + '<<>>' + documentNames[i],
                  MessageType.Document));
        });
      }
      EasyLoading.dismiss();
      setState(() {
        documents.clear();
      });
    }

    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _showDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(widget.club.creator != user.uid
                ? 'Exit club'
                : 'Creators of clubs cannot exit the club while it is active'),
            content: Text(widget.club.creator != user.uid
                ? 'Are you sure you want to exit club?'
                : 'You may delete the club if you wish to exit it.'),
            actions: [
              CupertinoDialogAction(
                child: Text(widget.club.creator != user.uid ? 'Yes' : 'Okay'),
                isDestructiveAction:
                    widget.club.creator != user.uid ? true : false,
                onPressed: widget.club.creator != user.uid
                    ? () async {
                        FirestoreService.removeClubMember(
                                user.uid, widget.club.id)
                            .then((value) {
                          Navigator.pop(ctx);
                          showSnackBar(
                              message: 'Exited club', context: context);
                        });
                      }
                    : () => Navigator.pop(ctx),
              ),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(ctx);
                },
              )
            ],
          );
        });
  }

  // upload the images/videos to firebase storage and get the download url
  Future<String> postFileGetUrl({File file, String messageID}) async {
    String fileName = messageID;
    final StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('MessageFiles/${widget.club.id}/$fileName');
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downloadUrl.toString();
    return url;
  }
}

class BottomSheetItem extends StatelessWidget {
  final Function onTap;
  final String label;
  final IconData iconData;
  const BottomSheetItem({
    @required this.onTap,
    Key key,
    @required this.label,
    @required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // icon
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: Center(child: Icon(iconData)),
            padding: EdgeInsets.all(12.0),
          ),

          // spacer
          SizedBox(height: 6.0),

          // label
          Text(label),
        ],
      ),
    );
  }
}
