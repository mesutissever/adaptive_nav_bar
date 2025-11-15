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

class iOS26NavStyle {
  final double barHeight;
  final double borderRadius;
  final double blurSigma;
  final double backgroundAlpha;
  final double borderAlpha;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? selectedBackgroundColor;
  final double selectedBackgroundAlpha;
  final double selectedBorderRadius;
  final NavLabelBehavior labelBehavior;
  final TextStyle? labelTextStyle;
  final TextStyle? selectedLabelTextStyle;
  final double iconSize;
  final double itemSpacing;
  final double verticalPadding;
  final double horizontalPadding;

  const iOS26NavStyle({
    this.barHeight = 80,
    this.borderRadius = 32,
    this.blurSigma = 30,
    this.backgroundAlpha = 0.92,
    this.borderAlpha = 0.15,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.selectedBackgroundColor,
    this.selectedBackgroundAlpha = 0.15,
    this.selectedBorderRadius = 24,
    this.labelBehavior = NavLabelBehavior.always,
    this.labelTextStyle,
    this.selectedLabelTextStyle,
    this.iconSize = 24,
    this.itemSpacing = 4,
    this.verticalPadding = 8,
    this.horizontalPadding = 12,
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
  final TextStyle? selectedLabelTextStyle;
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
    this.selectedLabelTextStyle,
    this.labelLetterSpacing,
  });
}

typedef DetachedItemBuilder =
    Widget Function(BuildContext context, NavItemConfig item, bool isSelected);

class AdaptiveNavConfig {
  final List<NavItemConfig> items;
  final NavBehaviorConfig behavior;
  final iOS26NavStyle ios26Style;
  final CupertinoNavStyle iosStyle;
  final bool preferCupertinoStyle;
  final Widget? centerAction;
  final double centerActionOffset;
  final Widget? trailingAction;
  final EdgeInsets? trailingActionPadding;
  final int cupertinoTrailingNativeCount;
  final double cupertinoSplitSpacing;

  // Detached button system - parametrik olarak istediğiniz butonları ayrı yapabilirsiniz
  final List<int>
  detachedIndexes; // Ayrı gösterilecek buton index'leri (örn: [3] veya [2, 3])
  final DetachedItemBuilder? detachedItemBuilder; // Custom builder
  final EdgeInsets? detachedItemPadding; // Detached butonların padding'i
  final double detachedItemSpacing; // Detached butonlar arası boşluk
  final double detachedItemSize; // Detached buton boyutu

  @Deprecated('Use detachedIndexes instead')
  final int? detachedIndex; // Geriye dönük uyumluluk için

  AdaptiveNavConfig({
    required this.items,
    this.behavior = const NavBehaviorConfig(),
    this.ios26Style = const iOS26NavStyle(),
    this.iosStyle = const CupertinoNavStyle(),
    this.preferCupertinoStyle = false,
    this.centerAction,
    this.centerActionOffset = 0,
    this.trailingAction,
    this.trailingActionPadding,
    this.cupertinoTrailingNativeCount = 0,
    this.cupertinoSplitSpacing = 8,
    this.detachedIndex,
    List<int>? detachedIndexes,
    this.detachedItemBuilder,
    this.detachedItemPadding,
    this.detachedItemSpacing = 12,
    this.detachedItemSize = 58,
  }) : detachedIndexes =
           detachedIndexes ?? (detachedIndex != null ? [detachedIndex] : []),
       assert(items.length >= 2, 'At least two nav items are required.');
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
  int? _lastInlineSelectionIndex;
  Set<int> _activeDetachedIndexes = <int>{};

  AdaptiveNavConfig get _config => widget.config;
  List<NavItemConfig> get _navItems => _config.items;
  int get _selectedIndex {
    if (_navItems.isEmpty) return 0;
    final maxIndex = _navItems.length - 1;
    return widget.selectedIndex.clamp(0, maxIndex).toInt();
  }

  NavBehaviorConfig get _behavior => _config.behavior;
  iOS26NavStyle get _ios26Style => _config.ios26Style;
  CupertinoNavStyle get _cupertinoStyle => _config.iosStyle;
  AdaptiveNavController? get _controller => widget.controller;
  bool get _shouldUseCupertinoLook =>
      _config.preferCupertinoStyle || _isCupertinoPlatform;

  bool get isNavMinimized => _isNavMinimized;

  @override
  void initState() {
    super.initState();
    _controller?._attach(this);
    if (widget.autoHideController != null) {
      _attachScrollController(widget.autoHideController);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScrollControllerAttachment();
  }

  @override
  void didUpdateWidget(covariant AdaptiveNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      _controller?._attach(this);
    }
    if (oldWidget.autoHideController != widget.autoHideController) {
      _updateScrollControllerAttachment();
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

  void _updateScrollControllerAttachment() {
    final override = widget.autoHideController;
    if (override != null) {
      if (_attachedScrollController == override) return;
      _detachScrollController();
      _attachScrollController(override);
      return;
    }
    final primaryController = PrimaryScrollController.maybeOf(context);
    if (_attachedScrollController == primaryController) return;
    _detachScrollController();
    _attachScrollController(primaryController);
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

  bool get _isCupertinoPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get _useCupertinoNativeBar => _isCupertinoPlatform && _isIOS26OrNewer;

  bool get _isIOS26OrNewer {
    if (!_isCupertinoPlatform) return false;
    final version = Platform.operatingSystemVersion;
    final match = RegExp(r'(\d+)').firstMatch(version);
    final major = match != null ? int.tryParse(match.group(1) ?? '') : null;
    return (major ?? 0) >= 26;
  }

  void _handleNavTap(int index) {
    if (!_activeDetachedIndexes.contains(index)) {
      _lastInlineSelectionIndex = index;
    }
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

    // iOS 26+ → Use native CNTabBar
    if (_useCupertinoNativeBar) {
      return _buildNativeiOS26Bar();
    }

    // iOS 26 öncesi veya Android → iOS 26 style taklit
    return _buildCustomiOS26StyleBar();
  }

  Widget _buildNativeiOS26Bar() {
    final allowNativeSplit = true;
    final partition = _partitionNavItems(allowNativeSplit: allowNativeSplit);
    _activeDetachedIndexes = partition.detachedIndexes;
    _ensureInlineSelectionMemo(
      partition.detachedIndexes,
      partition.inlineItems,
    );
    final inlineItems = partition.inlineItems;
    final detachedItems = partition.overlayItems;
    final behavior = _behavior;
    final cupertinoStyle = _cupertinoStyle;
    final inactiveBaseColor = cupertinoStyle.inactiveColor ?? Colors.black;
    final labelBehavior = cupertinoStyle.labelBehavior;
    final trailingAction = widget.config.trailingAction;
    final trailingPadding = widget.config.trailingActionPadding;
    final useNativeSplit = partition.usesNativeSplit;
    final nativeTrailingCount = partition.nativeSplitCount;
    final splitSpacing = widget.config.cupertinoSplitSpacing.adaptive_w;

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

    final inlineSelectedIndex = _inlineSelectedIndex(inlineItems);
    final fallbackInline = _fallbackInlineIndex(inlineItems);
    final currentIndex = inlineSelectedIndex >= 0
        ? inlineSelectedIndex
        : fallbackInline;
    final barLogicalHeight = cupertinoStyle.ios26Height.toDouble();
    final barHeight = ResponsiveScale.adaptive_h(barLogicalHeight);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final hasHomeIndicator = safeBottom > 0;

    final horizontalMargin = 14.adaptive_w;
    final availableWidth =
        MediaQuery.of(context).size.width - 2 * horizontalMargin;
    final activeColor =
        cupertinoStyle.activeColor ?? Theme.of(context).colorScheme.primary;

    final cupertinoItems = inlineItems.map((entry) {
      final index = entry.index;
      final config = entry.config;
      return CNTabBarItem(
        label: resolveLabel(index, config.label),
        icon: CNSymbol(
          config.cupertinoSymbol,
          mode: CNSymbolRenderingMode.monochrome,
          color: config.inactiveColor ?? inactiveBaseColor,
        ),
      );
    }).toList();

    Widget navContent = CNTabBar(
      shrinkCentered: true,
      height: barLogicalHeight,
      backgroundColor: Colors.transparent,
      items: cupertinoItems,
      currentIndex: currentIndex,
      onTap: (value) {
        final target = inlineItems[value].index;
        _handleNavTap(target);
      },
      split: useNativeSplit,
      rightCount: useNativeSplit ? nativeTrailingCount : 1,
      splitSpacing: splitSpacing,
      tint: activeColor,
    );

    Widget navBar = Align(
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
            child: SizedBox(
              width: double.infinity,
              height: barHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  navContent,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: hasHomeIndicator ? 3.adaptive_h : 6.adaptive_h,
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
    );

    navBar = Padding(
      padding: EdgeInsets.only(
        left: horizontalMargin,
        right: horizontalMargin,
        bottom: 8.adaptive_h, // Alt çentikten boşluk
      ),
      child: navBar,
    );

    final overlay = <Widget>[navBar];
    if (trailingAction != null) {
      final defaultBottomOffset = hasHomeIndicator
          ? safeBottom + 6.adaptive_h
          : (_isNavMinimized ? 6.adaptive_h : 12.adaptive_h);
      overlay.add(
        Positioned(
          right: trailingPadding?.right ?? 12.adaptive_w,
          bottom: trailingPadding?.bottom ?? defaultBottomOffset,
          child: trailingAction,
        ),
      );
    }

    // Eğer native split kullanılmıyorsa detached overlay ekle
    if (!useNativeSplit && detachedItems.isNotEmpty) {
      overlay.add(_buildDetachedOverlay(detachedItems));
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: overlay,
    );
  }

  Widget _buildCustomiOS26StyleBar() {
    final partition = _partitionNavItems(allowNativeSplit: false);
    _activeDetachedIndexes = partition.detachedIndexes;
    _ensureInlineSelectionMemo(
      partition.detachedIndexes,
      partition.inlineItems,
    );
    final inlineItems = partition.inlineItems;
    final detachedItems = partition.overlayItems;
    final behavior = _behavior;
    final style = _ios26Style;

    final horizontalMargin = 14.adaptive_w;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final hasHomeIndicator = safeBottom > 0;

    final barHeight = style.barHeight.adaptive_h;
    final borderRadius = BorderRadius.circular(style.borderRadius.adaptive_r);

    final activeColor =
        style.activeColor ?? Theme.of(context).colorScheme.primary;
    final inactiveColor = style.inactiveColor ?? Colors.black87;
    final backgroundColor = style.backgroundColor ?? Colors.white;

    final animDuration = _suppressAnimation
        ? Duration.zero
        : behavior.animationDuration;
    final opacityDuration = _suppressAnimation
        ? Duration.zero
        : behavior.opacityDuration;

    // Detached butonlar için padding
    final detachedPadding = widget.config.detachedItemPadding;
    final detachedRightOffset = detachedPadding?.right ?? 12.adaptive_w;
    final detachedBottomOffset = detachedPadding?.bottom ?? 8.adaptive_h;

    // Settings butonu için navigation bar'dan buton genişliği + ekstra boşluk ayır
    final settingsSpace = detachedItems.isNotEmpty
        ? (widget.config.detachedItemSize.adaptive_w +
              50.adaptive_w) // 58 + 20 = 78px
        : 0.0;

    // Navigation bar - Settings için sağdan 78px boşluk bırak
    final navBarContent = Padding(
      padding: EdgeInsets.only(right: settingsSpace),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: style.blurSigma,
            sigmaY: style.blurSigma,
          ),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: style.backgroundAlpha),
              borderRadius: borderRadius,
              border: Border.all(
                color: Colors.black.withValues(alpha: style.borderAlpha),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: style.verticalPadding.adaptive_h,
                horizontal: style.horizontalPadding.adaptive_w,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < inlineItems.length; i++)
                    Expanded(
                      child: _iOS26TabItem(
                        entry: inlineItems[i],
                        isSelected: inlineItems[i].index == _selectedIndex,
                        onTap: () => _handleNavTap(inlineItems[i].index),
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        style: style,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Navigation bar ve detached butonları Stack ile birleştir
    Widget scaledContent = Stack(
      clipBehavior: Clip.none,
      children: [
        // Navigation bar - sağdan 78px daha dar
        navBarContent,

        // Detached butonlar - navigation bar'ın sağ üstünde overlay
        if (detachedItems.isNotEmpty)
          Positioned(
            right: detachedRightOffset,
            bottom: detachedBottomOffset,
            child: AnimatedOpacity(
              duration: opacityDuration,
              opacity: _isNavMinimized ? 0.8 : 1,
              child: _buildDetachedRow(detachedItems),
            ),
          ),
      ],
    );

    // Tüm container'ı birlikte scale et
    Widget navBar = Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedScale(
        scale: _isNavMinimized ? behavior.compactScale : 1,
        duration: animDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: AnimatedOpacity(
          duration: opacityDuration,
          opacity: _isNavMinimized ? 0.75 : 1,
          child: scaledContent,
        ),
      ),
    );

    navBar = Padding(
      padding: EdgeInsets.only(
        left: horizontalMargin,
        right: horizontalMargin,
        bottom: 15.adaptive_h, // Alt çentikten boşluk
      ),
      child: navBar,
    );

    // Stack ile overlay'ları ekle
    final trailingAction = widget.config.trailingAction;
    final trailingPadding = widget.config.trailingActionPadding;

    final overlayWidgets = <Widget>[navBar];

    // Trailing action ekle
    if (trailingAction != null) {
      final defaultBottomOffset = hasHomeIndicator
          ? safeBottom + 6.adaptive_h
          : (_isNavMinimized ? 6.adaptive_h : 12.adaptive_h);
      overlayWidgets.add(
        Positioned(
          right: trailingPadding?.right ?? 12.adaptive_w,
          bottom: trailingPadding?.bottom ?? defaultBottomOffset,
          child: trailingAction,
        ),
      );
    }

    // Eğer overlay varsa Stack kullan
    if (overlayWidgets.length > 1) {
      return Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: overlayWidgets,
      );
    }

    return navBar;
  }

  // Detached butonların toplam genişliğini hesapla (spacing dahil)
  double _computeDetachedTotalWidth(int detachedCount) {
    if (detachedCount <= 0) return 0;
    final bubbleSize = widget.config.detachedItemSize.adaptive_w;
    final spacing = widget.config.detachedItemSpacing.adaptive_w;
    return detachedCount * bubbleSize + max(0, detachedCount - 1) * spacing;
  }

  // Detached butonları row olarak oluştur
  Widget _buildDetachedRow(List<_IndexedNavItem> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final spacing = widget.config.detachedItemSpacing.adaptive_w;
    final builder =
        widget.config.detachedItemBuilder ?? _defaultDetachedBuilder;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : spacing),
            child: _DetachedNavButton(
              item: entries[i],
              builder: builder,
              isSelected: _selectedIndex == entries[i].index,
              onTap: () => _handleNavTap(entries[i].index),
            ),
          ),
      ],
    );
  }

  _PartitionedNavItems _partitionNavItems({required bool allowNativeSplit}) {
    final detachedSet = _resolveDetachedIndexes();
    final allEntries = [
      for (var i = 0; i < _navItems.length; i++)
        _IndexedNavItem(index: i, config: _navItems[i]),
    ];
    final detachedEntries = [
      for (final entry in allEntries)
        if (detachedSet.contains(entry.index)) entry,
    ];
    bool canUseNativeSplit =
        allowNativeSplit &&
        detachedEntries.isNotEmpty &&
        _formsTrailingBlock(detachedEntries);
    List<_IndexedNavItem> inlineItems;
    List<_IndexedNavItem> overlayItems;
    if (canUseNativeSplit) {
      inlineItems = allEntries;
      overlayItems = const [];
    } else {
      inlineItems = [
        for (final entry in allEntries)
          if (!detachedSet.contains(entry.index)) entry,
      ];
      overlayItems = detachedEntries;
    }
    if (inlineItems.isEmpty) {
      inlineItems = allEntries;
      overlayItems = const [];
      canUseNativeSplit = false;
    }
    return _PartitionedNavItems(
      inlineItems: inlineItems,
      overlayItems: overlayItems,
      detachedIndexes: detachedSet,
      usesNativeSplit: canUseNativeSplit,
      nativeSplitCount: canUseNativeSplit ? detachedEntries.length : 0,
    );
  }

  Set<int> _resolveDetachedIndexes() {
    final resolved = <int>{};

    // Önce yeni detachedIndexes listesini kontrol et
    if (_config.detachedIndexes.isNotEmpty) {
      for (final index in _config.detachedIndexes) {
        if (index >= 0 && index < _navItems.length) {
          resolved.add(index);
        }
      }
      return resolved;
    }

    // Fallback: cupertinoTrailingNativeCount kullan
    final fallbackCount = min(_config.cupertinoTrailingNativeCount, 1);
    if (fallbackCount <= 0) return resolved;
    final count = min(
      fallbackCount,
      _navItems.isNotEmpty ? _navItems.length : 0,
    );
    final start = (_navItems.length - count).clamp(0, _navItems.length).toInt();
    for (var i = start; i < _navItems.length; i++) {
      resolved.add(i);
    }
    return resolved;
  }

  bool _formsTrailingBlock(List<_IndexedNavItem> entries) {
    if (entries.isEmpty) return false;
    final sorted = entries.map((e) => e.index).toList()..sort();
    final count = sorted.length;
    for (var i = 0; i < count; i++) {
      if (sorted[i] != _navItems.length - count + i) {
        return false;
      }
    }
    return true;
  }

  void _ensureInlineSelectionMemo(
    Set<int> detachedSet,
    List<_IndexedNavItem> inlineItems,
  ) {
    if (!detachedSet.contains(_selectedIndex)) {
      _lastInlineSelectionIndex = _selectedIndex;
      return;
    }
    final current = _lastInlineSelectionIndex;
    final isValid =
        current != null &&
        !detachedSet.contains(current) &&
        inlineItems.any((entry) => entry.index == current);
    if (!isValid) {
      _lastInlineSelectionIndex = inlineItems.isNotEmpty
          ? inlineItems.first.index
          : null;
    }
  }

  int _inlineSelectedIndex(List<_IndexedNavItem> inlineItems) {
    return inlineItems.indexWhere((entry) => entry.index == _selectedIndex);
  }

  int _fallbackInlineIndex(List<_IndexedNavItem> inlineItems) {
    if (inlineItems.isEmpty) return 0;
    final memo = _lastInlineSelectionIndex;
    if (memo == null) return 0;
    final idx = inlineItems.indexWhere((entry) => entry.index == memo);
    return idx >= 0 ? idx : 0;
  }

  double _computeDetachedRightGap(
    int detachedCount, {
    bool clampToBar = false,
    double? clampWidth,
  }) {
    if (detachedCount <= 0) return 0;
    final bubbleSize = widget.config.detachedItemSize.adaptive_w;
    final spacing = widget.config.detachedItemSpacing.adaptive_w;
    final paddingRight =
        widget.config.detachedItemPadding?.right ?? 16.adaptive_w;
    final totalWidth =
        detachedCount * bubbleSize + max(0, detachedCount - 1) * spacing;
    final gap = paddingRight + totalWidth;
    if (!clampToBar) return gap;
    final maxWidth = clampWidth ?? MediaQuery.of(context).size.width;
    final maxPadding = maxWidth * 0.4;
    return min(gap, maxPadding);
  }

  Widget _buildDetachedOverlay(List<_IndexedNavItem> entries) {
    // Bu metod sadece iOS 26 native bar için kullanılıyor
    // Burada da detached butonlar navigation bar ile birlikte scale olmalı
    if (entries.isEmpty) return const SizedBox.shrink();

    final padding = widget.config.detachedItemPadding;
    final baseBottomOffset = padding?.bottom ?? 20.adaptive_h;
    final rightOffset = padding?.right ?? 12.adaptive_w;
    final spacing = widget.config.detachedItemSpacing.adaptive_w;
    final builder =
        widget.config.detachedItemBuilder ?? _defaultDetachedBuilder;
    final behavior = _behavior;

    return Positioned(
      right: rightOffset,
      bottom: baseBottomOffset,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : spacing),
              child: _DetachedNavButton(
                item: entries[i],
                builder: builder,
                isSelected: _selectedIndex == entries[i].index,
                onTap: () => _handleNavTap(entries[i].index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _defaultDetachedBuilder(
    BuildContext context,
    NavItemConfig item,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = item.activeColor ?? colorScheme.primary;
    final gradient = isSelected
        ? LinearGradient(
            colors: [primary, primary.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(225, 248, 248, 248),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final iconData = isSelected
        ? (item.materialSelectedIcon ?? item.materialIcon)
        : item.materialIcon;
    final iconColor = isSelected
        ? Colors.white
        : item.inactiveColor ?? Colors.black87;
    final bubbleSize = widget.config.detachedItemSize.adaptive_w;
    final borderColor = isSelected
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.45);
    final shadowColor = isSelected
        ? primary.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.12);
    return SizedBox(
      width: bubbleSize,
      height: bubbleSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.8 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: isSelected ? 22 : 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(iconData, color: iconColor, size: 24.adaptive_r),
            ),
          ),
          if (item.badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: _BadgeBubble(
                count: item.badgeCount,
                color: item.badgeColor ?? primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _iOS26TabBar extends StatelessWidget {
  const _iOS26TabBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.style,
    required this.hasHomeIndicator,
  });

  final List<_IndexedNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;
  final Color inactiveColor;
  final iOS26NavStyle style;
  final bool hasHomeIndicator;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: style.verticalPadding.adaptive_h,
        horizontal: style.horizontalPadding.adaptive_w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _iOS26TabItem(
                entry: items[i],
                isSelected: items[i].index == selectedIndex,
                onTap: () => onTap(items[i].index),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}

class _iOS26TabItem extends StatelessWidget {
  const _iOS26TabItem({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.style,
  });

  final _IndexedNavItem entry;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final iOS26NavStyle style;

  @override
  Widget build(BuildContext context) {
    final config = entry.config;
    final resolvedActiveColor = config.activeColor ?? activeColor;
    final resolvedInactiveColor = config.inactiveColor ?? inactiveColor;

    final selectedBgColor =
        style.selectedBackgroundColor ?? resolvedActiveColor;
    final backgroundColor = isSelected
        ? selectedBgColor.withValues(alpha: style.selectedBackgroundAlpha)
        : Colors.transparent;

    final iconData = isSelected
        ? (config.materialSelectedIcon ?? config.materialIcon)
        : config.materialIcon;

    final iconColor = isSelected ? resolvedActiveColor : resolvedInactiveColor;

    final showLabel =
        style.labelBehavior == NavLabelBehavior.always ||
        (style.labelBehavior == NavLabelBehavior.onlySelected && isSelected);

    final baseLabelStyle = TextStyle(
      fontSize: 11.adaptive_sp,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      color: isSelected
          ? resolvedActiveColor
          : resolvedInactiveColor.withValues(alpha: 0.75),
    );

    var labelStyle = baseLabelStyle;
    final styleOverride = isSelected
        ? style.selectedLabelTextStyle
        : style.labelTextStyle;

    if (styleOverride != null) {
      labelStyle = labelStyle.merge(styleOverride);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          vertical: showLabel ? 8.adaptive_h : 12.adaptive_h,
          horizontal: 8.adaptive_w,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            style.selectedBorderRadius.adaptive_r,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  iconData,
                  color: iconColor,
                  size: style.iconSize.adaptive_r,
                ),
                if (config.badgeCount > 0)
                  Positioned(
                    right: -12,
                    top: -6,
                    child: _BadgeBubble(
                      count: config.badgeCount,
                      color: config.badgeColor ?? resolvedActiveColor,
                    ),
                  ),
              ],
            ),
            if (showLabel) ...[
              SizedBox(height: style.itemSpacing.adaptive_h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: labelStyle,
                child: Text(
                  config.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
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

class _DetachedNavButton extends StatelessWidget {
  const _DetachedNavButton({
    required this.item,
    required this.builder,
    required this.isSelected,
    required this.onTap,
  });

  final _IndexedNavItem item;
  final DetachedItemBuilder builder;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: builder(context, item.config, isSelected),
    );
  }
}

class _IndexedNavItem {
  const _IndexedNavItem({required this.index, required this.config});

  final int index;
  final NavItemConfig config;
}

class _PartitionedNavItems {
  const _PartitionedNavItems({
    required this.inlineItems,
    required this.overlayItems,
    required this.detachedIndexes,
    required this.usesNativeSplit,
    required this.nativeSplitCount,
  });

  final List<_IndexedNavItem> inlineItems;
  final List<_IndexedNavItem> overlayItems;
  final Set<int> detachedIndexes;
  final bool usesNativeSplit;
  final int nativeSplitCount;
}
