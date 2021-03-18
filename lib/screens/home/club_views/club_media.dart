import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

Club openClub;

class ClubMedia extends StatelessWidget {
  final Club club;

  const ClubMedia({Key key, this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    openClub = this.club;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            'Club media',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context)),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.black,
            indicator: BubbleTabIndicator(
              indicatorHeight: 30.0,
              indicatorColor: Colors.grey[200],
              tabBarIndicatorSize: TabBarIndicatorSize.label,
            ),
            tabs: [
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ImagesTab(),
            VideosTab(),
            DocumentsTab(),
          ],
        ),
      ),
    );
  }
}

class ImagesTab extends StatefulWidget {
  @override
  _ImagesTabState createState() => _ImagesTabState();
}

class _ImagesTabState extends State<ImagesTab>
    with AutomaticKeepAliveClientMixin {
  Future _images;

  Future loadImages() async {
    QuerySnapshot quereySnapshot = await FirestoreService.clubsCollection
        .doc(openClub.id)
        .collection('messages')
        .where('type', isEqualTo: MessageType.Image)
        .get();
    return quereySnapshot.docs;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _images = loadImages();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _images,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        List docs = snapshot.data;
        return docs.isNotEmpty
            ? StaggeredGridView.countBuilder(
                physics: BouncingScrollPhysics(),
                crossAxisCount: 4,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Message message = Message.fromDocument(docs[index]);
                  return Showcase(
                    message: message,
                  );
                },
                staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
                mainAxisSpacing: 24.0,
                crossAxisSpacing: 12.0,
                padding: EdgeInsets.all(12.0),
              )
            : Center(
                child: Text(
                  'No images',
                  style: TextStyle(color: Colors.grey),
                ),
              );
      },
    );
  }
}

class Showcase extends StatelessWidget {
  final Message message;
  Showcase({@required this.message});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OpenContainer(
          closedElevation: 0.0,
          closedColor: Theme.of(context).scaffoldBackgroundColor,
          openBuilder: (context, action) => Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ),
            body: Center(
              child: ImageView(
                imageUrl: message.messageBody.split('<<>>').first,
              ),
            ),
          ),
          closedBuilder: (context, action) => ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: CachedNetworkImage(
              imageUrl: message.messageBody.split('<<>>').first,
            ),
          ),
        ),
      ],
    );
  }
}

class VideosTab extends StatefulWidget {
  @override
  _VideosTabState createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab>
    with AutomaticKeepAliveClientMixin {
  Future _videos;

  Future loadVideos() async {
    QuerySnapshot quereySnapshot = await FirestoreService.clubsCollection
        .doc(openClub.id)
        .collection('messages')
        .where('type', isEqualTo: MessageType.Video)
        .get();
    return quereySnapshot.docs;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _videos = loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _videos,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        List docs = snapshot.data;
        return docs.isNotEmpty
            ? ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Message message = Message.fromDocument(docs[index]);
                  return ChewieListItem(
                    showControls: true,
                    videoPlayerController: VideoPlayerController.network(
                      message.messageBody.split('<<>>').first,
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'No videos',
                  style: TextStyle(color: Colors.grey),
                ),
              );
      },
    );
  }
}

class DocumentsTab extends StatefulWidget {
  @override
  _DocumentsTabState createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab>
    with AutomaticKeepAliveClientMixin {
  Future _documents;

  Future loadDocs() async {
    QuerySnapshot quereySnapshot = await FirestoreService.clubsCollection
        .doc(openClub.id)
        .collection('messages')
        .where('type', isEqualTo: MessageType.Document)
        .get();
    return quereySnapshot.docs;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _documents = loadDocs();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _documents,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        List docs = snapshot.data;
        return docs.isNotEmpty
            ? ListView.separated(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                itemCount: docs.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  Message message = Message.fromDocument(docs[index]);
                  return ListTile(
                    title: Text(message.messageBody.split('<<>>')[1]),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            PDFScreen(message.messageBody.split('<<>>').first),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'No documents',
                  style: TextStyle(color: Colors.grey),
                ),
              );
      },
    );
  }
}
