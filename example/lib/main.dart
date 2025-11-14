import 'package:adaptive_nav_bar/adaptive_nav_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AdaptiveNavExampleApp());
}

class AdaptiveNavExampleApp extends StatelessWidget {
  const AdaptiveNavExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const _DemoHome(),
    );
  }
}

class _DemoHome extends StatefulWidget {
  const _DemoHome();

  @override
  State<_DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<_DemoHome> {
  final _controller = AdaptiveNavController();
  int _currentIndex = 0;
  late final List<ScrollController?> _scrollControllers = [
    ScrollController(),
    null,
    null,
    ScrollController(),
  ];

  late final AdaptiveNavConfig _config = AdaptiveNavConfig(
    items: _navItems,
    behavior: const NavBehaviorConfig(
      autoHideOnScroll: true,
      compactScale: 0.58,
      hapticIntensity: NavHapticIntensity.medium,
    ),
    androidStyle: const GlassNavStyle(
      labelBehavior: NavLabelBehavior.always,
      expandedHeight: 86,
      compactHeight: 68,
      indicatorColor: Color(0x33FFFFFF),
      activeLabelColor: Colors.white,
      inactiveLabelColor: Colors.white70,
    ),
    iosStyle: const CupertinoNavStyle(
      activeColor: Colors.indigo,
      inactiveColor: Colors.black,
      labelBehavior: NavLabelBehavior.onlySelected,
    ),
    centerAction: FloatingActionButton(
      onPressed: _controller.toggle,
      child: const Icon(Icons.add),
    ),
    centerActionOffset: 50,
  );

  List<NavItemConfig> get _navItems => const [
    NavItemConfig(
      label: 'Home',
      materialIcon: Icons.home_outlined,
      materialSelectedIcon: Icons.home_rounded,
      cupertinoSymbol: 'house.fill',
      badgeCount: 4,
    ),
    NavItemConfig(
      label: 'Profile',
      materialIcon: Icons.person_outline,
      materialSelectedIcon: Icons.person,
      cupertinoSymbol: 'person.fill',
      badgeCount: 1,
      badgeColor: Colors.pink,
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
  ];

  late final List<Widget> _demoPages = [
    _HomeFeedPage(controller: _scrollControllers[0]!),
    const _InfoPage(
      icon: Icons.person_outline,
      title: 'Profile',
      description:
          'Manage your account, notification preferences, and privacy.',
    ),
    const _InfoPage(
      icon: Icons.favorite_outline,
      title: 'Favorites',
      description: 'Track the items you loved across all platforms.',
    ),
    _SettingsListPage(controller: _scrollControllers[3]!),
  ];

  ScrollController? get _activeScrollController =>
      _scrollControllers[_currentIndex];

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _demoPages[_currentIndex],
      bottomNavigationBar: AdaptiveNavBar(
        config: _config,
        controller: _controller,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        autoHideController: _activeScrollController,
      ),
    );
  }
}

class _HomeFeedPage extends StatelessWidget {
  const _HomeFeedPage({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: 25,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('Card ${index + 1}'),
            subtitle: const Text('Scroll to see the nav collapse & expand.'),
          ),
        );
      },
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsListPage extends StatelessWidget {
  const _SettingsListPage({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final tiles = List.generate(
      12,
      (index) => SwitchListTile(
        title: Text('Setting ${index + 1}'),
        subtitle: const Text('Tap the FAB to toggle the nav size.'),
        value: index.isEven,
        onChanged: (_) {},
      ),
    );
    return ListView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: tiles,
    );
  }
}
