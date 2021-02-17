import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.rotatingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0;
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<SubCommunity> subs = [];
  List<Person> users = [];
  List<Post> posts = [];
  Widget startingScreen = SizedBox.shrink();

  void getSubCommunities() async {
    List<QueryDocumentSnapshot> subCommunitySnapshots = await FirestoreService
        .subCommunitiesCollection
        .get()
        .then((QuerySnapshot snapshot) {
      return snapshot.docs;
    });

    List<SubCommunity> subs = [];

    for (DocumentSnapshot documentSnapshot in subCommunitySnapshots) {
      subs.add(SubCommunity.fromDocument(documentSnapshot));
    }

    setState(() {
      this.subs = subs;
    });
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      setState(() {
        startingScreen = Wrapper();
      });
    } else {
      setState(() {
        startingScreen = IntroSlider();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
    getSubCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: AuthService().firebaseUser,
        ),
        ChangeNotifierProvider(
          create: (context) => SignUpModel(),
        ),
        ChangeNotifierProvider(
            create: (context) => CommunityProvider(communities: subs)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Comcent',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: startingScreen,
        builder: (BuildContext context, Widget child) {
          /// make sure that loading can be displayed in front of all other widgets
          return FlutterEasyLoading(child: child);
        },
      ),
    );
  }
}
