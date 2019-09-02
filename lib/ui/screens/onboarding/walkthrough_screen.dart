import 'dart:async';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/screens/onboarding/onboard_screen.dart';
import 'package:secure_upload/ui/widgets/pager_indicator.dart';
import 'package:secure_upload/ui/widgets/page_dragger.dart';
import 'package:secure_upload/ui/widgets/page_reveal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WalkthroughScreen extends StatefulWidget {
  final SharedPreferences prefs;

  WalkthroughScreen({this.prefs});

  _WalkthroughScreenState createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen>
    with TickerProviderStateMixin {
  OnboardingPages _onboarding = OnboardingPages();
  StreamController<SlideUpdate> _slideUpdateStream;
  AnimatedPageDragger _animatedPageDragger;

  int activeIndex = 0;
  int nextPageIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;

  _WalkthroughScreenState() {
    _slideUpdateStream = StreamController<SlideUpdate>();
    ;

    _slideUpdateStream.stream.listen((SlideUpdate event) {
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
            _animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: slidePercent,
              slideUpdateStream: _slideUpdateStream,
              vSync: this,
            );
          } else {
            _animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: slidePercent,
              slideUpdateStream: _slideUpdateStream,
              vSync: this,
            );

            nextPageIndex = activeIndex;
          }

          _animatedPageDragger.run();
        } else if (event.updateType == UpdateType.animating) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          activeIndex = nextPageIndex;

          slideDirection = SlideDirection.none;
          slidePercent = 0.0;

          _animatedPageDragger.dispose();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
                      viewModel: _onboarding.createStaticPageViewModels(context)[activeIndex],
                    ),
                ),
               Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: globals.onboardIndicatorTopPadding,
                        bottom: globals.onboardIndicatorBottomPadding),
                    child: PagerIndicator(
                      viewModel: PagerIndicatorViewModel(
                        _onboarding.createStaticPageViewModels(context),
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
                  viewModel: _onboarding.createStaticPageViewModels(context)[nextPageIndex],
                  iconPercentVisible: slidePercent * 0.5,
                  textPercentVisible: slidePercent * 0.75,
                  titlePercentVisible: slidePercent,
                  ),
                ),
              ),
            ),
            PageDragger(
              canDragLeftToRight: activeIndex > 0,
              canDragRightToLeft: activeIndex < _onboarding.createStaticPageViewModels(context).length - 1,
              slideUpdateStream: _slideUpdateStream,
            ),
          ],
        ),
      ),
    );
  }
}
