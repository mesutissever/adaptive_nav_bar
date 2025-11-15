# adaptive_nav_bar

Adaptive glass-inspired bottom navigation that automatically switches between a Material 3 glass bar and a native Cupertino tab bar.  
Features include:

- Scroll-aware expand/shrink behavior with haptic feedback controls
- Per-item color overrides, badges, and custom label behavior
- Glass blur/background tuning plus optional center/trailing action slots
- Native split trailing actions on iOS 26+ (e.g. Cupertino search pill) with Flutter fallback elsewhere
- Native `CupertinoNative` integration for iOS 26+ and legacy layouts

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
    // Optional floating action
    centerAction: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
    // Detach the last item and show it as a floating search bubble
    detachedIndex: 3,
    detachedItemPadding: const EdgeInsets.only(right: 16, bottom: 18),
    detachedItemSpacing: 14,
    detachedItemSize: 58,
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

When `detachedIndex` points to a trailing item (only one can be detached), iOS 26+ devices render the native split trailing pill (perfect for Search). On Android or older iOS builds the package automatically falls back to the Flutter-defined detached bubble so behavior stays consistent. (If the index is not the last item, the widget will fall back to the Flutter bubble everywhere.) If you omit `detachedIndex`, you can still place any bespoke widget via the legacy `trailingAction`.

Use `detachedItemPadding`, `detachedItemSpacing`, and `detachedItemSize` to fine-tune how the floating bubble sits relative to the glass bar on legacy platforms.

## License

MIT © Mesut
