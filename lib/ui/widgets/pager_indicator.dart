import 'package:flutter/material.dart';
import 'package:secure_upload/data/global.dart' as globals;
import 'package:secure_upload/ui/screens/my_onboard_screen.dart';
import 'dart:ui';

class PagerIndicator extends StatelessWidget {
  final PagerIndicatorViewModel viewModel;

  PagerIndicator({
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    List<PageBubble> bubbles = [];
    for (var i = 0; i < viewModel.pages.length; ++i) {
      final page = viewModel.pages[i];

      var percentActive;
      if (i == viewModel.activeIndex) {
        percentActive = 1.0 - viewModel.slidePercent;
      } else if (i == viewModel.activeIndex - 1 &&
          viewModel.slideDirection == SlideDirection.leftToRight) {
        percentActive = viewModel.slidePercent;
      } else if (i == viewModel.activeIndex + 1 &&
          viewModel.slideDirection == SlideDirection.rightToLeft) {
        percentActive = viewModel.slidePercent;
      } else {
        percentActive = 0.0;
      }

      bool isHollow = i > viewModel.activeIndex ||
          (i == viewModel.activeIndex &&
              viewModel.slideDirection == SlideDirection.leftToRight);

      bubbles.add(
        new PageBubble(
          viewModel: new PagerBubbleViewModel(
            const Color(0x88FFFFFF),
            isHollow,
            percentActive,
          ),
        ),
      );
    }

    final BUBBLE_WIDTH = 45.0;
    final baseTranslation =
        ((viewModel.pages.length * BUBBLE_WIDTH) / 2) - (BUBBLE_WIDTH / 2);
    var translation = baseTranslation - (viewModel.activeIndex * BUBBLE_WIDTH);

    if (viewModel.slideDirection == SlideDirection.leftToRight) {
      translation += BUBBLE_WIDTH * viewModel.slidePercent;
    } else if (viewModel.slideDirection == SlideDirection.rightToLeft) {
      translation -= BUBBLE_WIDTH * viewModel.slidePercent;
    }

    return Container(
        child: Column(
      children: [
        Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bubbles,
            ),
          ),
        ),
      ],
    ));
  }
}

enum SlideDirection {
  leftToRight,
  rightToLeft,
  none,
}

class PagerIndicatorViewModel {
  final List<PageViewModel> pages;
  final int activeIndex;
  final SlideDirection slideDirection;
  final double slidePercent;

  PagerIndicatorViewModel(
    this.pages,
    this.activeIndex,
    this.slideDirection,
    this.slidePercent,
  );
}

class PageBubble extends StatelessWidget {
  final PagerBubbleViewModel viewModel;

  PageBubble({
    this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
        width: globals.paperIndicatorWidth,
        height: globals.pagerIndicatorHeight,
        child: new Center(
            child: new Container(
          width: lerpDouble(globals.indicatorMinWidth,
              globals.indicatorMaxWidth, viewModel.activePercent),
          height: lerpDouble(globals.indicatorMinHeight,
              globals.indicatorMaxHeight, viewModel.activePercent),
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isHollow
                  ? viewModel.color
                      .withAlpha((0x88 * viewModel.activePercent).round())
                  : viewModel.color,
              border: new Border.all(
                color: viewModel.isHollow
                    ? viewModel.color.withAlpha(
                        (0x88 * (1 - viewModel.activePercent)).round())
                    : Colors.transparent,
                width: 3.0,
              )),
        )));
  }
}

class PagerBubbleViewModel {
  final Color color;
  final bool isHollow;
  final double activePercent;

  PagerBubbleViewModel(
    this.color,
    this.isHollow,
    this.activePercent,
  );
}
