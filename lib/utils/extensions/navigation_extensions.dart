import 'package:flutter/material.dart';

extension NavigationExtensions on BuildContext {
  PageRoute<T> _slideRoute<T>(Widget nextPage, {bool isSetTransitionDuration = false}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, anim, secondaryAnim) => nextPage,
      transitionDuration: isSetTransitionDuration ? Duration(seconds: 2) : Duration(milliseconds: 600),
      transitionsBuilder: (context, anim, secondaryAnim, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: anim.drive(tween), child: child);
      },
    );
  }

  Future navigateToNextPage(Widget nextPage, {bool isSetTransitionDuration = false}) =>
      Navigator.of(this).push(_slideRoute(nextPage, isSetTransitionDuration: isSetTransitionDuration));

  Future navigateToNextPageWithReplacement(Widget nextPage, {bool isSetTransitionDuration = false}) =>
      Navigator.of(this).pushReplacement(_slideRoute(nextPage, isSetTransitionDuration: isSetTransitionDuration));

  Future navigateToNextPageWithRemoveUntil(Widget nextPage, {bool isSetTransitionDuration = false}) =>
      Navigator.of(this).pushAndRemoveUntil(_slideRoute(nextPage, isSetTransitionDuration: isSetTransitionDuration), (route) => false);

  void navigateBack([Object? argument]) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop(argument);
    }
  }
}
