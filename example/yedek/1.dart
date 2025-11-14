import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ResponsiveScale {
  static const double _designWidth = 390;
  static const double _designHeight = 844;

  static double _widthFactor = 1;
  static double _heightFactor = 1;
  static double _radiusFactor = 1;
  static double _textFactor = 1;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _widthFactor = size.width / _designWidth;
    _heightFactor = size.height / _designHeight;
    _radiusFactor = (_widthFactor + _heightFactor) / 2;
    _textFactor = _widthFactor;
  }

  static double adaptive_w(num value) => value * _widthFactor;
  static double adaptive_h(num value) => value * _heightFactor;
  static double adaptive_r(num value) => value * _radiusFactor;
  static double adaptive_sp(num value) => value * _textFactor;
}

extension ResponsiveNum on num {
  double get adaptive_w => ResponsiveScale.adaptive_w(this);
  double get adaptive_h => ResponsiveScale.adaptive_h(this);
  double get adaptive_r => ResponsiveScale.adaptive_r(this);
  double get adaptive_sp => ResponsiveScale.adaptive_sp(this);
}

class NavItemConfig {
  final String label;
  final IconData materialIcon;
  final IconData? materialSelectedIcon;
  final String cupertinoSymbol;
  final Color? activeColor;
  final Color? inactiveColor;
  final int badgeCount;
  final Color? badgeColor;

  const NavItemConfig({
    required this.label,
    required this.materialIcon,
    this.materialSelectedIcon,
    required this.cupertinoSymbol,
    this.activeColor,
    this.inactiveColor,
    this.badgeCount = 0,
    this.badgeColor,
  });
}

enum NavHapticIntensity { none, light, medium, heavy }

class NavBehaviorConfig {
  final bool autoHideOnScroll;
  final bool expandOnTap;
  final double compactScale;
  final Duration animationDuration;
  final Duration opacityDuration;
  final NavHapticIntensity hapticIntensity;

  const NavBehaviorConfig({
    this.autoHideOnScroll = true,
    this.expandOnTap = true,
    this.compactScale = 0.6,
    this.animationDuration = const Duration(milliseconds: 260),
    this.opacityDuration = const Duration(milliseconds: 200),
    this.hapticIntensity = NavHapticIntensity.light,
  });
}

enum NavLabelBehavior { always, onlySelected, never }

extension NavLabelBehaviorX on NavLabelBehavior {
  NavigationDestinationLabelBehavior toMaterialBehavior() {
    switch (this) {
      case NavLabelBehavior.always:
        return NavigationDestinationLabelBehavior.alwaysShow;
      case NavLabelBehavior.onlySelected:
        return NavigationDestinationLabelBehavior.onlyShowSelected;
      case NavLabelBehavior.never:
        return NavigationDestinationLabelBehavior.alwaysHide;
    }
  }
}

class GlassNavStyle {
  final double expandedHeight;
  final double compactHeight;
  final double expandedBorderRadius;
  final double compactBorderRadius;
  final double blurSigma;
  final double expandedBaseAlpha;
  final double compactBaseAlpha;
  final double expandedIndicatorAlpha;
  final double compactIndicatorAlpha;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final Color? activeLabelColor;
  final Color? inactiveLabelColor;
  final NavLabelBehavior labelBehavior;
  final TextStyle? labelTextStyle;
  final TextStyle? selectedLabelTextStyle;
  final double? labelLetterSpacing;

  const GlassNavStyle({
    this.expandedHeight = 82,
    this.compactHeight = 70,
    this.expandedBorderRadius = 28,
    this.compactBorderRadius = 18,
    this.blurSigma = 45,
    this.expandedBaseAlpha = 0.065,
    this.compactBaseAlpha = 0.028,
    this.expandedIndicatorAlpha = 0.27,
    this.compactIndicatorAlpha = 0.16,
    this.backgroundColor,
    this.backgroundGradient,
    this.indicatorColor,
    this.indicatorShape,
    this.activeLabelColor,
    this.inactiveLabelColor,
    this.labelBehavior = NavLabelBehavior.always,
    this.labelTextStyle,
    this.selectedLabelTextStyle,
    this.labelLetterSpacing,
  });
}

class CupertinoNavStyle {
  final double ios26Height;
  final double legacyHeight;
  final double indicatorPadding;
  final double legacyExpandedPadding;
  final double legacyCompactPadding;
  final Color? activeColor;
  final Color? inactiveColor;
  final NavLabelBehavior labelBehavior;
  final TextStyle? labelTextStyle;
  final double? labelLetterSpacing;

  const CupertinoNavStyle({
    this.ios26Height = 80,
    this.legacyHeight = 64,
    this.indicatorPadding = 2,
    this.legacyExpandedPadding = 14,
    this.legacyCompactPadding = 4,
    this.activeColor,
    this.inactiveColor,
    this.labelBehavior = NavLabelBehavior.always,
    this.labelTextStyle,
    this.labelLetterSpacing,
  });
}

class AdaptiveNavConfig {
  final List<NavItemConfig> items;
  final NavBehaviorConfig behavior;
  final GlassNavStyle androidStyle;
  final CupertinoNavStyle iosStyle;
  final Widget? centerAction;
  final double centerActionOffset;

  AdaptiveNavConfig({
    required this.items,
    this.behavior = const NavBehaviorConfig(),
    this.androidStyle = const GlassNavStyle(),
    this.iosStyle = const CupertinoNavStyle(),
    this.centerAction,
    this.centerActionOffset = 0,
  }) : assert(items.length >= 2, 'At least two nav items are required.');
}

class AdaptiveNavController {
  _AdaptiveNavBarState? _state;
  bool? _pendingMinimized;
  bool _lastKnownMinimized = false;

  bool get isAttached => _state != null;
  bool get isMinimized =>
      _state?.isNavMinimized ?? _pendingMinimized ?? _lastKnownMinimized;

  void expand() => _setMinimized(false);
  void shrink() => _setMinimized(true);
  void toggle() => _setMinimized(!isMinimized);

  void _setMinimized(bool value) {
    _lastKnownMinimized = value;
    final state = _state;
    if (state != null) {
      state._setNavMinimizedFromController(value);
    } else {
      _pendingMinimized = value;
    }
  }

  void _attach(_AdaptiveNavBarState state) {
    _state = state;
    _lastKnownMinimized = state.isNavMinimized;
    if (_pendingMinimized != null) {
      state._setNavMinimizedFromController(_pendingMinimized!);
      _pendingMinimized = null;
    }
  }

  void _detach(_AdaptiveNavBarState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class AdaptiveNavBar extends StatefulWidget {
  const AdaptiveNavBar({
    super.key,
    required this.config,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.controller,
    this.autoHideController,
  });

  final AdaptiveNavConfig config;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final AdaptiveNavController? controller;
  final ScrollController? autoHideController;

  @override
  State<AdaptiveNavBar> createState() => _AdaptiveNavBarState();
}

class _AdaptiveNavBarState extends State<AdaptiveNavBar> {
  bool _isNavMinimized = false;
  double _lastScrollOffset = 0;
  ScrollController? _attachedScrollController;
  bool _suppressAnimation = false;

  AdaptiveNavConfig get _config => widget.config;
  List<NavItemConfig> get _navItems => _config.items;
  int get _selectedIndex {
    if (_navItems.isEmpty) return 0;
    final maxIndex = _navItems.length - 1;
    return widget.selectedIndex.clamp(0, maxIndex).toInt();
  }

  NavBehaviorConfig get _behavior => _config.behavior;
  GlassNavStyle get _glassStyle => _config.androidStyle;
  CupertinoNavStyle get _cupertinoStyle => _config.iosStyle;
  AdaptiveNavController? get _controller => widget.controller;

  bool get isNavMinimized => _isNavMinimized;

  @override
  void initState() {
    super.initState();
    _controller?._attach(this);
    _attachScrollController(widget.autoHideController);
  }

  @override
  void didUpdateWidget(covariant AdaptiveNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      _controller?._attach(this);
    }
    if (oldWidget.autoHideController != widget.autoHideController) {
      _detachScrollController();
      _attachScrollController(widget.autoHideController);
    }
  }

  @override
  void dispose() {
    _controller?._detach(this);
    _detachScrollController();
    super.dispose();
  }

  void _attachScrollController(ScrollController? controller) {
    if (controller == null) return;
    _attachedScrollController = controller;
    _lastScrollOffset = controller.hasClients ? controller.position.pixels : 0;
    controller.addListener(_handleScroll);
  }

  void _detachScrollController() {
    _attachedScrollController?.removeListener(_handleScroll);
    _attachedScrollController = null;
  }

  void _handleScroll() {
    final controller = _attachedScrollController;
    if (controller == null || !_behavior.autoHideOnScroll) return;
    if (!controller.hasClients) return;
    final offset = controller.position.pixels;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;
    if (delta > 4 && !_isNavMinimized) {
      setState(() => _isNavMinimized = true);
    } else if (delta < -4 && _isNavMinimized) {
      setState(() => _isNavMinimized = false);
    }
  }

  bool get _useCupertinoNativeBar =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get _isIOS26OrNewer {
    if (!_useCupertinoNativeBar) return false;
    final version = Platform.operatingSystemVersion;
    final match = RegExp(r'(\d+)').firstMatch(version);
    final major = match != null ? int.tryParse(match.group(1) ?? '') : null;
    return (major ?? 0) >= 26;
  }

  void _handleNavTap(int index) {
    final currentIndex = widget.selectedIndex;
    if (index != currentIndex) {
      if (_behavior.expandOnTap && _isNavMinimized) {
        setState(() => _isNavMinimized = false);
      }
      setState(() => _suppressAnimation = true);
      widget.onDestinationSelected(index);
      _triggerHapticFeedback();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _suppressAnimation) {
          setState(() => _suppressAnimation = false);
        }
      });
    } else if (_behavior.expandOnTap && _isNavMinimized) {
      setState(() => _isNavMinimized = false);
      _triggerHapticFeedback();
    }
  }

  void _triggerHapticFeedback() {
    switch (_behavior.hapticIntensity) {
      case NavHapticIntensity.none:
        return;
      case NavHapticIntensity.light:
        HapticFeedback.lightImpact();
        break;
      case NavHapticIntensity.medium:
        HapticFeedback.mediumImpact();
        break;
      case NavHapticIntensity.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  void _setNavMinimizedFromController(bool value) {
    if (_isNavMinimized == value) return;
    setState(() {
      _isNavMinimized = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveScale.init(context);
    final glassStyle = _glassStyle;
    final borderRadius = BorderRadius.circular(
      (_isNavMinimized
              ? glassStyle.compactBorderRadius
              : glassStyle.expandedBorderRadius)
          .adaptive_r,
    );
    final glassHeight =
        (_isNavMinimized ? glassStyle.compactHeight : glassStyle.expandedHeight)
            .adaptive_h;
    final animDuration = _suppressAnimation
        ? Duration.zero
        : _behavior.animationDuration;
    final opacityDuration = _suppressAnimation
        ? Duration.zero
        : _behavior.opacityDuration;
    return _useCupertinoNativeBar
        ? _buildCupertinoNativeBar()
        : _buildGlassBottomBar(
            borderRadius,
            glassHeight,
            _behavior,
            animDuration,
            opacityDuration,
          );
  }

  Widget _buildGlassBottomBar(
    BorderRadius borderRadius,
    double barHeight,
    NavBehaviorConfig behavior,
    Duration animDuration,
    Duration opacityDuration,
  ) {
    final centerAction = widget.config.centerAction;
    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedContainer(
            duration: animDuration,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              bottom: _isNavMinimized ? 4.adaptive_h : 10.adaptive_h,
            ),
            child: AnimatedScale(
              scale: _isNavMinimized ? behavior.compactScale : 1,
              duration: animDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                duration: opacityDuration,
                opacity: _isNavMinimized ? 0.7 : 1,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    _isNavMinimized ? 10.adaptive_h : 4.adaptive_h,
                  ),
                  child: SizedBox(
                    height: barHeight,
                    child: _GlassBottomNavigationBar(
                      borderRadius: borderRadius,
                      selectedIndex: _selectedIndex,
                      onTap: _handleNavTap,
                      isCompact: _isNavMinimized,
                      items: _navItems,
                      style: _glassStyle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (centerAction != null)
            Positioned(
              bottom: widget.config.centerActionOffset,
              child: centerAction!,
            ),
        ],
      ),
    );
  }

  Widget _buildCupertinoNativeBar() {
    final behavior = _behavior;
    final cupertinoStyle = _cupertinoStyle;
    final inactiveBaseColor = cupertinoStyle.inactiveColor ?? Colors.black;
    final labelBehavior = cupertinoStyle.labelBehavior;
    String resolveLabel(int index, String label) {
      switch (labelBehavior) {
        case NavLabelBehavior.always:
          return label;
        case NavLabelBehavior.onlySelected:
          return index == _selectedIndex ? label : '';
        case NavLabelBehavior.never:
          return '';
      }
    }

    final cupertinoItems = _navItems.asMap().entries.map((entry) {
      final index = entry.key;
      final config = entry.value;
      return CNTabBarItem(
        label: resolveLabel(index, config.label),
        icon: CNSymbol(
          config.cupertinoSymbol,
          mode: CNSymbolRenderingMode.monochrome,
          color: config.inactiveColor ?? inactiveBaseColor,
        ),
      );
    }).toList();
    final currentIndex = _selectedIndex;
    final barLogicalHeight = _isIOS26OrNewer ? 80.0 : 85.0;
    final barHeight = ResponsiveScale.adaptive_h(barLogicalHeight);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final hasHomeIndicator = safeBottom > 0;
    final legacyPadding = hasHomeIndicator
        ? EdgeInsets.zero
        : EdgeInsets.only(
            top: _isNavMinimized ? 4.adaptive_h : 16.adaptive_h,
            bottom: _isNavMinimized ? 4.adaptive_h : 6.adaptive_h,
          );
    final baseLabelStyle = TextStyle(
      color: inactiveBaseColor.withValues(alpha: 0.75),
      fontSize: 11.adaptive_sp,
    );
    var labelTextStyle = baseLabelStyle;
    final labelOverride = cupertinoStyle.labelTextStyle;
    if (labelOverride != null) {
      labelTextStyle = labelTextStyle.merge(labelOverride);
    }
    final letterSpacing = cupertinoStyle.labelLetterSpacing;
    if (letterSpacing != null) {
      labelTextStyle = labelTextStyle.copyWith(letterSpacing: letterSpacing);
    }
    final legacyDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(28.adaptive_r),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1.4,
      ),
      gradient: hasHomeIndicator
          ? null
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white12, Colors.white10],
            ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedScale(
        scale: _isNavMinimized ? behavior.compactScale : 1,
        duration: behavior.animationDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: behavior.opacityDuration,
          opacity: _isNavMinimized ? 0.75 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.adaptive_r),
            child: CupertinoTheme(
              data: CupertinoThemeData(
                primaryColor:
                    cupertinoStyle.activeColor ??
                    Theme.of(context).colorScheme.primary,
                textTheme: CupertinoTextThemeData(
                  tabLabelTextStyle: labelTextStyle,
                ),
              ),
              child: DecoratedBox(
                decoration: hasHomeIndicator
                    ? const BoxDecoration()
                    : legacyDecoration,
                child: SizedBox(
                  width: double.infinity,
                  height: barHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: legacyPadding,
                        child: CNTabBar(
                          shrinkCentered: true,
                          height: barLogicalHeight,
                          backgroundColor: Colors.transparent,
                          items: cupertinoItems,
                          currentIndex: currentIndex,
                          onTap: _handleNavTap,
                          split: false,
                          tint:
                              cupertinoStyle.activeColor ??
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 0,
                              right: 0,
                              top: hasHomeIndicator
                                  ? 3.adaptive_h
                                  : 6.adaptive_h,
                            ),
                            child: Row(
                              children: [
                                for (final item in _navItems)
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: item.badgeCount > 0
                                          ? _BadgeBubble(
                                              count: item.badgeCount,
                                              color:
                                                  item.badgeColor ??
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBottomNavigationBar extends StatelessWidget {
  const _GlassBottomNavigationBar({
    required this.borderRadius,
    required this.selectedIndex,
    required this.onTap,
    required this.isCompact,
    required this.items,
    required this.style,
  });

  final BorderRadius borderRadius;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isCompact;
  final List<NavItemConfig> items;
  final GlassNavStyle style;

  @override
  Widget build(BuildContext context) {
    final baseAlpha = isCompact
        ? style.compactBaseAlpha
        : style.expandedBaseAlpha;
    final indicatorAlpha = isCompact
        ? style.compactIndicatorAlpha
        : style.expandedIndicatorAlpha;
    final outlineAlpha = isCompact ? 0.18 : 0.4;
    final highlightOpacity = isCompact ? 0.12 : 0.22;
    final noiseOpacity = isCompact ? 0.007 : 0.014;
    final indicatorColor =
        style.indicatorColor ??
        Colors.black.withValues(alpha: isCompact ? 0.06 : 0.08);
    final indicatorShape = style.indicatorShape ?? const StadiumBorder();
    final activeLabelColor =
        style.activeLabelColor ?? Theme.of(context).colorScheme.primary;
    final inactiveLabelColor = style.inactiveLabelColor ?? Colors.black87;
    TextStyle _resolveLabelStyle(Set<WidgetState> states) {
      final selected = states.contains(WidgetState.selected);
      final base =
          Theme.of(context).textTheme.labelSmall ??
          TextStyle(
            fontSize: 11.adaptive_sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
      var textStyle = base.copyWith(
        fontSize: base.fontSize ?? 11.adaptive_sp,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? activeLabelColor : inactiveLabelColor,
      );
      final override = selected
          ? style.selectedLabelTextStyle
          : style.labelTextStyle;
      if (override != null) {
        textStyle = textStyle.merge(override);
      }
      final letterSpacing = style.labelLetterSpacing;
      if (letterSpacing != null) {
        textStyle = textStyle.copyWith(letterSpacing: letterSpacing);
      }
      return textStyle;
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: style.blurSigma,
              sigmaY: style.blurSigma,
            ),
            child: const SizedBox.expand(),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: style.backgroundGradient == null
                  ? (style.backgroundColor ??
                        Colors.white.withValues(alpha: baseAlpha))
                  : null,
              gradient: style.backgroundGradient,

              border: Border.all(
                color: Colors.white.withValues(alpha: outlineAlpha),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.3 * highlightOpacity),
                    Colors.white.withValues(alpha: 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          CustomPaint(
            painter: _NoisePainter(opacity: noiseOpacity),
            size: Size.infinite,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.adaptive_w,
              vertical: 8.adaptive_h,
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 64.adaptive_h,
                indicatorColor: indicatorColor,
                indicatorShape: indicatorShape,
                labelTextStyle: WidgetStateProperty.resolveWith(
                  _resolveLabelStyle,
                ),
                iconTheme: WidgetStateProperty.all(
                  IconThemeData(size: 22.adaptive_r),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onTap,
                backgroundColor: Colors.transparent,
                labelBehavior: style.labelBehavior.toMaterialBehavior(),
                destinations: [
                  for (final item in items)
                    NavigationDestination(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconTheme.merge(
                            data: IconThemeData(
                              color: item.inactiveColor ?? Colors.black,
                            ),
                            child: Icon(item.materialIcon, size: 22.adaptive_r),
                          ),
                          if (item.badgeCount > 0)
                            Positioned(
                              right: -15,
                              top: -6,
                              child: _BadgeBubble(
                                count: item.badgeCount,
                                color:
                                    item.badgeColor ??
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      selectedIcon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconTheme.merge(
                            data: IconThemeData(
                              color:
                                  item.activeColor ??
                                  Theme.of(context).colorScheme.primary,
                            ),
                            child: Icon(
                              item.materialSelectedIcon ?? item.materialIcon,
                              size: 22.adaptive_r,
                            ),
                          ),
                          if (item.badgeCount > 0)
                            Positioned(
                              right: -15,
                              top: -6,
                              child: _BadgeBubble(
                                count: item.badgeCount,
                                color:
                                    item.badgeColor ??
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      label: item.label,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeBubble extends StatelessWidget {
  const _BadgeBubble({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final display = count > 99 ? '99+' : '$count';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.adaptive_w,
        vertical: 2.adaptive_h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.adaptive_r),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.adaptive_sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  const _NoisePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(2024);
    final paint = Paint();
    final dots = (size.width * size.height / 1200).clamp(80, 220);
    for (var i = 0; i < dots; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final dotOpacity = (opacity + rand.nextDouble() * opacity).clamp(
        0.0,
        0.08,
      );
      paint.color = Colors.white.withValues(alpha: dotOpacity);
      canvas.drawCircle(Offset(dx, dy), rand.nextDouble() * 0.9 + 0.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) =>
      opacity != oldDelegate.opacity;
}
