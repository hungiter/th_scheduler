import "package:flutter/material.dart";

class ResponsiveHomePage extends StatelessWidget {
  final Widget mobileHomePage;
  final Widget tabletHomePage;
  final Widget desktopHomePage;

  const ResponsiveHomePage(
      {super.key,
      required this.mobileHomePage,
      required this.tabletHomePage,
      required this.desktopHomePage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 500) {
        return mobileHomePage;
      } else if (constraints.maxWidth < 1100) {
        return tabletHomePage;
      } else {
        return desktopHomePage;
      }
    });
  }
}
