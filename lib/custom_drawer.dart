import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  final Widget child;

  const CustomDrawer({Key key, @required this.child}) : super(key: key);

  static CustomDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<CustomDrawerState>();

  @override
  CustomDrawerState createState() => new CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  static const Duration toggleDuration = Duration(milliseconds: 250);
  static const double maxSlide = 350;
  static const double minDragStartEdge = 60;
  static const double maxDragStartEdge = maxSlide - 16;
  AnimationController _animationController;
  bool _canBeDragged = false;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: CustomDrawerState.toggleDuration,
    );
    _animation = new CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
      reverseCurve: Curves.easeInQuad,
    );
  }

  void close() => _animationController.reverse();

  void open() => _animationController.forward();

  void toggleDrawer() => _animationController.isCompleted ? close() : open();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // maxSlide = MediaQuery.of(context).size.width;
    print(_animation.value);
    return WillPopScope(
      onWillPop: () async {
        if (_animationController.isCompleted) {
          close();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        // onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _animationController,
          child: widget.child,
          builder: (context, child) {
            double animValue = _animation.value;
            final slideAmount = maxSlide * animValue;
            final contentScale = 1.0 - (0.3 * animValue);
            return Stack(
              children: <Widget>[
                Transform(
                  transform: Matrix4.identity()
                    ..translate(
                        slideAmount - MediaQuery.of(context).size.width),
                  child: MyDrawer(
                    maxSlide: maxSlide,
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()..translate(slideAmount),
                  // ..scale(contentScale, contentScale),
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _animationController.isCompleted ? close : null,
                    child: Opacity(
                      child: Container(
                        color: Colors.black,
                        child: child,
                      ),
                      // opacity: 0.8 * animValue,
                      opacity: 1 - (_animationController.value * 0.75),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = _animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = _animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  // void _onDragUpdate(DragUpdateDetails details) {
  //   if (_canBeDragged) {
  //     double delta = details.primaryDelta / maxSlide;
  //     _animation.value += delta;
  //   }
  // }

  void _onDragEnd(DragEndDetails details) {
    //I have no idea what it means, copied from Drawer
    double _kMinFlingVelocity = 365.0;

    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      _animationController.fling(velocity: visualVelocity);
    } else if (_animation.value < 0.5) {
      close();
    } else {
      open();
    }
  }
}

class MyDrawer extends StatelessWidget {
  double maxSlide;
  MyDrawer({@required maxSlide});

  @override
  Widget build(BuildContext context) {
    if (maxSlide == null) {
      maxSlide = MediaQuery.of(context).size.width;
    }
    return Material(
      color: Colors.blueAccent,
      child: SafeArea(
        child: Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: Container(
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.horizontal(
            //     right: Radius.circular(
            //       16,
            //     ),
            //   ),
            // ),
            margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Image.asset(
                //   'assets/flutter_europe_white.png',
                //   width: 200,
                // ),
                // SizedBox(height: 100),

                Padding(
                  child: Center(
                    child: FlutterLogo(
                      size: 150,
                      style: FlutterLogoStyle.stacked,
                      textColor: Colors.white,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 24,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.new_releases),
                  title: Text('News'),
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Favourites'),
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Map'),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
