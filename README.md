# adaptive_nav_bar

Adaptive glass-inspired bottom navigation that automatically switches between a custom iOS 26-style pill and the real native `CupertinoNative` tab bar on physical iOS devices.  
Features include:

- Scroll-aware expand/shrink behavior with haptic feedback controls
- Per-item color overrides, badges, and custom label behavior
- Tunable iOS 26 pill style (blur, radius, colors, padding) for Android & older iOS versions
- Native `CupertinoNative` integration for iOS 26+ with split trailing actions
- Material glass fallback plus optional detached bubbles with in-bubble labels, center buttons, and trailing widgets
- Multiple detached nav items via `detachedIndexes`

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_nav_bar: ^0.1.0
``` 

Then run `flutter pub get`.

## Quick Start

```dart
import 'package:adaptive_nav_bar/adaptive_nav_bar.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  int _index = 0;
  final _config = AdaptiveNavConfig(
    items: const [
      NavItemConfig(
        label: 'Home',
        materialIcon: Icons.home_outlined,
        materialSelectedIcon: Icons.home,
        cupertinoSymbol: 'house.fill',
      ),
      NavItemConfig(
        label: 'Profile',
        materialIcon: Icons.person_outline,
        materialSelectedIcon: Icons.person,
        cupertinoSymbol: 'person.fill',
      ),
      NavItemConfig(
        label: 'Favorites',
        materialIcon: Icons.favorite_border,
        materialSelectedIcon: Icons.favorite,
        cupertinoSymbol: 'heart.fill',
      ),
      NavItemConfig(
        label: 'Settings',
        materialIcon: Icons.settings_outlined,
        materialSelectedIcon: Icons.settings,
        cupertinoSymbol: 'gearshape.fill',
      ),
    ],
  behavior: const NavBehaviorConfig(
    autoHideOnScroll: true,
    compactScale: 0.58,
  ),
    ios26Style: const iOS26NavStyle(
      barHeight: 82,
      activeColor: Colors.indigo,
      inactiveColor: Colors.black87,
      backgroundColor: Colors.white,
      borderRadius: 32,
      blurSigma: 30,
    ),
  iosStyle: const CupertinoNavStyle(
    activeColor: Colors.indigo,
    inactiveColor: Colors.black87,
    ios26Height: 82,
    legacyHeight: 76,
    indicatorPadding: 6,
  ),
  // Float the Settings tab as a bubble; icon + label sit inside and auto-scale to fit.
  detachedIndexes: const [3],
  detachedItemPadding: const EdgeInsets.only(right: 20, bottom: 20),
  detachedItemSpacing: 12,
  detachedItemSize: 56,
);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Center(child: Text('Home')),
      const Center(child: Text('Profile')),
      const Center(child: Text('Favorites')),
      const Center(child: Text('Settings')),
    ];

    return MaterialApp(
      home: Scaffold(
        extendBody: true,
        body: pages[_index],
        bottomNavigationBar: AdaptiveNavBar(
          config: _config,
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
        ),
      ),
    );
  }
}
```

For a richer showcase (with scroll hijack, badges, center action, etc.) run the bundled example:

```bash
cd example
flutter run
```

> Tip: To keep the auto-hide behavior, pass the same `ScrollController` you use in your scrollable body to `AdaptiveNavBar(autoHideController: ...)`.

## Platform behaviour

- **iOS 26+** &nbsp;→&nbsp; Uses Apple’s native tab bar via [`cupertino_native`](https://pub.dev/packages/cupertino_native). Trailing items detach into the system split view if you mark them as detached and they sit at the end.
- **Android, web, and older iOS** &nbsp;→&nbsp; Render the Flutter-driven `iOS26NavStyle`, which mimics the new pill layout (blur, border, labels, etc.) while keeping detached bubbles and actions consistent.

## Detaching multiple nav items

Use `detachedIndexes` to float one or more items outside the bar:

```dart
AdaptiveNavConfig(
  items: _items,
  detachedIndexes: const [2, 3], // Favorites + Settings as bubbles
  detachedItemPadding: const EdgeInsets.only(right: 28, bottom: 22),
  detachedItemSpacing: 16,
  detachedItemSize: 58,
  detachedItemBuilder: (context, item, isSelected) {
    return _CustomBubble(item: item, isSelected: isSelected);
  },
);
```

`detachedIndex` is still accepted for backwards compatibility, but `detachedIndexes` is more flexible.

## Customising the iOS 26 look

`iOS26NavStyle` lets you tweak the faux iOS bar when you are on Android or older iOS builds:

```dart
const iOS26NavStyle(
  barHeight: 84,
  borderRadius: 34,
  blurSigma: 40,
  backgroundAlpha: 0.9,
  selectedBackgroundAlpha: 0.2,
  activeColor: Colors.indigo,
  inactiveColor: Colors.black87,
  labelTextStyle: TextStyle(fontWeight: FontWeight.w500),
  selectedLabelTextStyle: TextStyle(fontWeight: FontWeight.w600),
  iconSize: 24,
  itemSpacing: 4,
  verticalPadding: 10,
  horizontalPadding: 12,
);
```

You can mix these with `CupertinoNavStyle` overrides for the genuine native bar so both experiences stay in sync.

## License

MIT © Mesut
