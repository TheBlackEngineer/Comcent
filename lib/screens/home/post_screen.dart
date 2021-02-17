import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  static CommunityProvider _provider;
  List photoUrls = [];
  List videoUrls = [];
  String postBody = '';
  String title = '';
  String topic = '';
  File sampleImage;
  List<File> images = [];
  List<File> videos = [];
  int maxImageNo = 10;
  String snackBarMessage = 'Selection full. Tap on a file to deselect it';
  TextEditingController _controller = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  PanelController panelController = PanelController();
  final _formKey = GlobalKey<FormState>();
  String randomPostID;
  User user;

  bool canPost;
  bool shouldShowBanner = true;

  final TextStyle whiteText = TextStyle(color: Colors.white);

  List<String> _topics = topics;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<CommunityProvider>(context, listen: false);
    randomPostID = FirebaseFirestore.instance.collection('posts').doc().id;
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    canPost = !_provider.person.canPost;
    _topics.sort();
    user = Provider.of<User>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create a post',
            style: TextStyle(color: Theme.of(context).primaryColor)),
        actions: [
          FlatButton(
            onPressed: () async {
              if (_provider.person.canPost &&
                  title.isNotEmpty &&
                  postBody.isNotEmpty &&
                  topic.isNotEmpty &&
                  _formKey.currentState.validate()) {
                await EasyLoading.show(
                    status: 'Posting...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: true);

                String response = await uploadPost();

                Navigator.pop(context);

                response != null
                    ? EasyLoading.showSuccess('Post successful',
                        dismissOnTap: true)
                    : EasyLoading.showError('Post unsuccessful',
                        dismissOnTap: true);

                EasyLoading.dismiss();
              }
            },
            child: Text(
              'Post',
              style: TextStyle(
                color: (_provider.person.canPost &&
                        title.isNotEmpty &&
                        postBody.isNotEmpty &&
                        topic.isNotEmpty)
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // show banner to user's who aren't allowed to make a post
              canPost && shouldShowBanner
                  ? buildMaterialBanner()
                  : SizedBox.shrink(),

              // user name, text field, profile picture
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      // profile image and user name
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _provider.person.profilePhoto != null
                            ? CircularProfileAvatar(
                                _provider.person.profilePhoto,
                                placeHolder: (context, url) {
                                  return Container(
                                    color: Colors.grey,
                                  );
                                },
                                radius: MediaQuery.of(context).size.width / 18,
                              )
                            : CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(
                            _provider.person.firstName +
                                ' ' +
                                _provider.person.lastName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17.0)),
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      Profile(userID: _provider.person.id)));
                        },
                      ),

                      // post title and topic selection
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // title
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _provider.person.isLeader
                                            ? SizedBox.shrink()
                                            : Text('Title'),
                                        _provider.person.isLeader
                                            ? SizedBox.shrink()
                                            : SizedBox(height: 3.0),

                                        // title text field
                                        Form(
                                          key: _formKey,
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: _titleController,
                                            validator: (value) => _provider
                                                    .person.isLeader
                                                ? null
                                                : (value.contains('We') ||
                                                        value.contains('Our'))
                                                    ? null
                                                    : "Start with 'We' or 'Our'",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: _provider
                                                      .person.isLeader
                                                  ? 'Title'
                                                  : "#Start with 'We' or 'Our'",
                                              hintStyle: TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                title = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // topic
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10.0)),
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: DropDown(
                                  showUnderline: false,
                                  hint: Text('Topic'),
                                  items: _topics,
                                  onChanged: (value) {
                                    setState(() {
                                      topic = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // post body
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _controller,
                        scrollPhysics:
                            ScrollPhysics(parent: BouncingScrollPhysics()),
                        maxLines: 100,
                        style: TextStyle(
                          fontSize: 21.0,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText:
                              'What are your thoughts, ${_provider.person.firstName}?',
                        ),
                        onChanged: (value) {
                          setState(() {
                            postBody = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // media actions
              Container(
                margin: const EdgeInsets.only(bottom: 16.0, top: 5.0),
                child: images.isEmpty && videos.isEmpty
                    ? SizedBox.shrink()
                    : Container(
                        height: 100.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          children: [
                            // image files
                            ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        images.removeAt(index);
                                        setState(() {});
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
                                          child: Image.file(images[index]),
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                            // videos
                            ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: videos.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        videos.removeAt(index);
                                        setState(() {});
                                      },
                                      child: FutureBuilder(
                                        future: generateVideoThumbnail(
                                            videos[index]),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final _image =
                                                Image.memory(snapshot.data);
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: _image,
                                            );
                                          } else {
                                            return Center(
                                              child:
                                                  CupertinoActivityIndicator(),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
              ),

              // space between files and slider
              SizedBox(height: 40.0),
            ],
          ),

          // sliding up panel
          SlidingUpPanel(
            minHeight: 50.0,
            maxHeight: 290.0,
            backdropEnabled: true,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            controller: panelController,
            panel: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                      height: 10.0,
                      width: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onTap: () async {
                      await panelController.open();
                    },
                  ),
                ),

                SizedBox(height: 30.0),

                // take a photo
                CustomListTile(
                  iconData: CupertinoIcons.camera,
                  label: 'Camera',
                  onTap: () {
                    panelController.close();
                    takePhoto();
                  },
                ),

                // add picture from gallery
                CustomListTile(
                  iconData: CupertinoIcons.photo,
                  label: 'Gallery',
                  onTap: () {
                    panelController.close();
                    pickImages();
                  },
                ),

                // add video from gallery
                CustomListTile(
                  iconData: CupertinoIcons.videocam,
                  label: 'Video',
                  onTap: () {
                    panelController.close();
                    addVideoFromGallery();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  MaterialBanner buildMaterialBanner() {
    return MaterialBanner(
      backgroundColor: Colors.black,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
            'Dear ' +
                _provider.person.firstName +
                ', kindly note that you cannot make a post until your account has been verified.',
            style: whiteText),
      ),
      leading: Icon(
        Icons.warning,
        color: Colors.white,
      ),
      actions: [
        // close banner
        FlatButton(
          child: Text('Close', style: whiteText),
          onPressed: () {
            setState(() {
              shouldShowBanner = false;
            });
          },
        ),
      ],
    );
  }

  // take photo with camera
  Future takePhoto() async {
    bool itemLimitReached = images.length + videos.length < 10;
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      sampleImage = pickedFile != null ? File(pickedFile.path) : null;
      sampleImage != null
          ? itemLimitReached
              ? images.add(sampleImage)
              : showSnackBar(message: snackBarMessage, context: context)
          : print('Sample image is null');
    });
  }

  // pick images from gallery
  Future<void> pickImages() async {
    bool itemLimitNotReached = images.length + videos.length < 10;

    try {
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: true);
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path)).toList();
        setState(() {
          itemLimitNotReached
              ? images.addAll(files)
              : showSnackBar(message: snackBarMessage, context: context);
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

  // pick video
  void addVideoFromGallery() async {
    bool itemLimitReached = images.length + videos.length < 10;

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

  // generate video thumbnail
  Future<Uint8List> generateVideoThumbnail(File videofile) async {
    return await VideoThumbnail.thumbnailData(
      video: videofile.path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 100,
      maxWidth:
          100, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
  }

  // upload the images/videos to firebase storage and get the download url
  Future<String> postFileGetUrl(
      {File file, String suffix, String xtension}) async {
    String fileName = randomPostID + '-' + suffix + xtension;
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Posts/$fileName');
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downloadUrl.toString();
    return url;
  }

  // upload method for File objects
  Future uploadPost() async {
    List visibleTo = _provider.person.followers + [user.uid];

    if (images.isNotEmpty) {
      // upload images first
      for (int i = 0; i < images.length; i++) {
        await postFileGetUrl(file: images[i], suffix: 'I$i', xtension: '.img')
            .then((url) {
          photoUrls.add(url);
        });
      }
    }

    if (videos.isNotEmpty) {
      // upload videos next
      for (int i = 0; i < videos.length; i++) {
        await postFileGetUrl(file: videos[i], suffix: 'V$i', xtension: '.vid')
            .then((url) {
          videoUrls.add(url);
        });
      }
    }

    // then upload document to firestore
    Post post = Post(
      title: title.trim(),
      body: postBody.trim(),
      topic: topic,
      photoAttachments: photoUrls,
      videoAttachments: videoUrls,
      ownerID: user.uid,
      postID: randomPostID,
      community: _provider.person.community,
      comments: [],
      visibleTo: visibleTo,
      usersWhoLiked: [],
      bookmarkedBy: [],
    );

    FirestoreService firestoreService = FirestoreService(uid: user.uid);

    await firestoreService.addPost(post: post);

    await FirestoreService.bookmarksCollection
        .doc(randomPostID)
        .set({'usersWhoBookmarked': []});

    return firestoreService.addToUserPosts(post: post);
  }
}
