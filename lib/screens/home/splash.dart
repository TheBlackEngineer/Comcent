import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:comcent/imports.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context)
          .pushReplacement(CupertinoPageRoute(builder: (context) => Wrapper()));
    } else {
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => IntroSlider()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class IntroSlider extends StatefulWidget {
  @override
  _IntroSliderState createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  int _currentPage = 0;
  static final PageController _pageController = PageController();
  
  // pages
  final List _pages = [
    SliderItem(
        index: 0,
        image: slider1Image,
        title: slider1Title,
        description: slider1Desc,
        onPressed: () => nextFunction()),
    SliderItem(
        index: 1,
        image: slider2Image,
        title: slider2Title,
        description: slider2Desc,
        onPressed: () => nextFunction()),
    SliderItem(
        index: 2,
        image: slider3Image,
        title: slider3Title,
        description: slider3Desc,
        onPressed: () => nextFunction()),
    SliderItem(
      index: 3,
      image: slider4Image,
      title: slider4Title,
      description: slider4Desc,
    ),
  ];

  onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  static nextFunction() {
    _pageController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.linearToEaseOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            physics: BouncingScrollPhysics(),
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (value) => onPageChanged(value),
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
        ],
      ),
    );
  }
}

class SliderItem extends StatefulWidget {
  final int index;
  final String image;
  final String title;
  final String description;
  final Function onPressed;

  const SliderItem(
      {Key key,
      this.index,
      this.image,
      this.title,
      this.description,
      this.onPressed})
      : super(key: key);

  @override
  _SliderItemState createState() => _SliderItemState();
}

class _SliderItemState extends State<SliderItem> {
  SharedPreferences prefs;

  // navigate to getting started screen
  getStarted() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => Authenticate(),
      ),
    );
  }

  // initialize shared preferences
  _initPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // image
                Image.asset(
                  widget.image,
                  height: MediaQuery.of(context).size.width / 1.7,
                ),

                SizedBox(height: 15.0),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 15.0),

                    // description
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 17.0, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // next and skip tour
          Column(
            children: [
              // next button
              GradientButton(
                label: widget.index != 3 ? 'Next' : 'Get started',
                elevated: false,
                width: MediaQuery.of(context).size.width / 1.7,
                onPressed: widget.index != 3
                    ? widget.onPressed
                    : () async {
                        await prefs.setBool('seen', true);
                        getStarted();
                      },
              ),

              SizedBox(height: 20.0),

              // skip tour
              widget.index != 3
                  ? GestureDetector(
                      child: Text(
                        'Skip tour',
                        style: TextStyle(color: Colors.black54),
                      ),
                      onTap: () async {
                        await prefs.setBool('seen', true);
                        getStarted();
                      },
                    )
                  : SizedBox.shrink(),

              SizedBox(height: 30.0),
            ],
          )
        ],
      ),
    );
  }
}
