import 'dart:async';
import 'package:secure_upload/data/utils.dart' as utils;
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/screens/my_onboard_screen.dart';
import 'package:secure_upload/ui/widgets/pager_indicator.dart';
import 'package:secure_upload/ui/widgets/page_dragger.dart';
import 'package:secure_upload/ui/widgets/page_reveal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyWalkthroughScreen extends StatefulWidget {
  final SharedPreferences prefs;

  MyWalkthroughScreen({this.prefs});

  _MyWalkthroughScreenState createState() => new _MyWalkthroughScreenState();
}

class _MyWalkthroughScreenState extends State<MyWalkthroughScreen>
    with TickerProviderStateMixin {
  StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger animatedPageDragger;
  GlobalKey _keyLogoSize = GlobalKey();

  int activeIndex = 0;
  int nextPageIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;

  _MyWalkthroughScreenState() {
    slideUpdateStream = new StreamController<SlideUpdate>();
    ;

    slideUpdateStream.stream.listen((SlideUpdate event) {
      setState(() {
        if (event.updateType == UpdateType.dragging) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;

          if (slideDirection == SlideDirection.leftToRight) {
            nextPageIndex = activeIndex - 1;
          } else if (slideDirection == SlideDirection.rightToLeft) {
            nextPageIndex = activeIndex + 1;
          } else {
            nextPageIndex = activeIndex;
          }
        } else if (event.updateType == UpdateType.doneDragging) {
          if (slidePercent > 0.5) {
            animatedPageDragger = new AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vSync: this,
            );
          } else {
            animatedPageDragger = new AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vSync: this,
            );

            nextPageIndex = activeIndex;
          }

          animatedPageDragger.run();
        } else if (event.updateType == UpdateType.animating) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          activeIndex = nextPageIndex;

          slideDirection = SlideDirection.none;
          slidePercent = 0.0;

          animatedPageDragger.dispose();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea (
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded (
                    child: Page(
                      viewModel: createStaticPageViewModels(context)[activeIndex],
                    ),
                ),
               Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: globals.onboardIndicatorTopPadding,
                        bottom: globals.onboardIndicatorBottomPadding),
                    child: PagerIndicator(
                      viewModel: new PagerIndicatorViewModel(
                        createStaticPageViewModels(context),
                        activeIndex,
                        slideDirection,
                        slidePercent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            PageReveal(
              revealPercent: slidePercent,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: EdgeInsets.only(bottom: globals.indicatorMaxHeight + globals.onboardIndicatorBottomPadding + globals.onboardIndicatorTopPadding),
                  child: Page(
                  viewModel: createStaticPageViewModels(context)[nextPageIndex],
                  iconPercentVisible: slidePercent * 0.5,
                  textPercentVisible: slidePercent * 0.75,
                  titlePercentVisible: slidePercent,
                  ),
                ),
              ),
            ),
            PageDragger(
              canDragLeftToRight: activeIndex > 0,
              canDragRightToLeft: activeIndex < createStaticPageViewModels(context).length - 1,
              slideUpdateStream: this.slideUpdateStream,
            ),
          ],
        ),
      ),
    );
  }
}
