# adaptive_nav_bar

Adaptive glass-inspired bottom navigation that automatically switches between a Material 3 glass bar and a native Cupertino tab bar.  
Features include:

- Scroll-aware expand/shrink behavior with haptic feedback controls
- Per-item color overrides, badges, and custom label behavior
- Glass blur/background tuning plus optional center action slot
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

## License

MIT © Mesut
