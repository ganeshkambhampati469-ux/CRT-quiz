import 'package:flutter/material.dart';
import 'constants.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 3;
    if (width >= 720) return 2;
    return 1;
  }

  static double getContentPadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
  }
}
