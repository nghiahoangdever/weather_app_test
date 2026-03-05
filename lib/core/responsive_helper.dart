import 'package:flutter/material.dart';

/// Breakpoints and responsive utilities for the weather app.
class ResponsiveHelper {
  // Breakpoint thresholds (in logical pixels)
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  /// Returns true if the screen width is in the mobile range (<600dp).
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMaxWidth;

  /// Returns true if the screen width is in the tablet range (600–900dp).
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileMaxWidth && w < tabletMaxWidth;
  }

  /// Returns true if the screen width is in the desktop range (>900dp).
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  /// Maximum width for main content area.
  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 840;
    if (isTablet(context)) return 680;
    return double.infinity; // mobile: full width
  }

  /// Horizontal padding that scales with screen size.
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 20; // mobile default
  }

  /// Number of columns for the stats grid.
  static int statsGridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Number of columns for city list on larger screens.
  static int cityGridColumns(BuildContext context) {
    if (isDesktop(context)) return 2;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Aspect ratio for stats grid items – taller on wider screens.
  static double statsChildAspectRatio(BuildContext context) {
    if (isDesktop(context)) return 1.8;
    if (isTablet(context)) return 1.7;
    return 1.6;
  }
}

/// A wrapper widget that constrains its child to [ResponsiveHelper.contentMaxWidth]
/// and centers it horizontally. On mobile this is a no-op (full width).
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.contentMaxWidth(context);

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (maxWidth == double.infinity) {
      return content;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}
