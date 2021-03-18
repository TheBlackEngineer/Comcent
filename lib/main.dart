import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:comcent/providers/app_theme_provider.dart';
import 'package:comcent/widgets/sharedPreferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var savedThemeMode = await AdaptiveTheme.getThemeMode();
  int lastAppTheme = await SharedPreferencesHelper.getLastAppTheme();
  runApp(MyApp(
    savedThemeMode: savedThemeMode,
    lastAppTheme: lastAppTheme,
  ));
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
  final savedThemeMode;
  final lastAppTheme;
  const MyApp({@required this.savedThemeMode, this.lastAppTheme});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<SubCommunity> subs = [];
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
      print(subs.length.toString() + ' sub-communities found');
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
          ChangeNotifierProvider<AppThemeProvider>(
            create: (context) =>
                AppThemeProvider(widget.lastAppTheme, widget.savedThemeMode),
          )
        ],
        child: AdaptiveTheme(
          builder: (light, dark) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Comcent',
              theme: light,
              darkTheme: dark,
              home: startingScreen,
              builder: (BuildContext context, Widget child) {
                // Make sure that loader can be displayed above all widgets
                return FlutterEasyLoading(child: child);
              },
            );
          },
          initial: widget.savedThemeMode ?? AdaptiveThemeMode.system,
          light: ThemeData.light().copyWith(
            brightness: Brightness.light,
            textSelectionColor: Colors.black,
            primaryColor: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: AppBarTheme(
              centerTitle: true,
              brightness: Brightness.light,
              color: Colors.transparent,
              textTheme: Theme.of(context).textTheme,
              elevation: 0.0,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          dark: ThemeData.dark().copyWith(
            canvasColor: Color(0xFF3A3B3C),
            scaffoldBackgroundColor: Color(0xFF18191A),
            brightness: Brightness.dark,
            textSelectionColor: Colors.white,
            primaryColor: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: AppBarTheme(
              centerTitle: true,
              brightness: Brightness.dark,
              color: Colors.transparent,
              textTheme: AppBarTheme.of(context).textTheme,
              elevation: 0.0,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ));
  }
}
