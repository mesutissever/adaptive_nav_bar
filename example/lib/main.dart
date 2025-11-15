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
    // iOS 26 Style - Tüm platformlarda kullanılır (iOS 26+ hariç, o native kullanır)
    ios26Style: const iOS26NavStyle(
      barHeight: 82, // Tab bar yüksekliği
      borderRadius: 32, // Kenar yuvarlaklığı
      blurSigma: 30, // Blur efekti yoğunluğu
      backgroundAlpha: 0.92, // Arka plan saydamlığı
      borderAlpha: 0.15, // Çerçeve saydamlığı
      selectedBackgroundAlpha: 0.15, // Seçili tab arka plan saydamlığı
      selectedBorderRadius: 24, // Seçili tab yuvarlaklığı
      activeColor: Colors.blue, // Seçili tab rengi
      inactiveColor: Colors.black87, // Seçili olmayan tab rengi
      backgroundColor: Colors.white, // Ana arka plan rengi
      labelBehavior: NavLabelBehavior.always, // Label gösterimi
      iconSize: 24, // İkon boyutu
      itemSpacing: 4, // Icon-label arası boşluk
      verticalPadding: 8, // Dikey padding
      horizontalPadding: 12, // Yatay padding
    ),
    // iOS 26+ için native CNTabBar kullanılırken bu ayarlar aktif olur
    iosStyle: const CupertinoNavStyle(
      activeColor: Colors.indigo,
      inactiveColor: Colors.black,
      ios26Height: 82,
      legacyHeight: 78,
      legacyExpandedPadding: 16,
      legacyCompactPadding: 6,
      indicatorPadding: 6,
      labelBehavior: NavLabelBehavior.always,
      labelTextStyle: TextStyle(fontWeight: FontWeight.w500),
      selectedLabelTextStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    // ⭐ PARAMETRİK DETACHED BUTTON SİSTEMİ ⭐
    // İstediğiniz butonları ayrı gösterebilirsiniz
    // Örnek 1: Sadece Settings butonunu ayrı yap
    detachedIndexes: const [3], // Son buton (Settings) ayrı gösterilir
    // Örnek 2: Birden fazla buton ayrı yapmak için
    // detachedIndexes: const [2, 3],  // Favorites ve Settings ayrı

    // Örnek 3: Hiçbir buton ayrı olmasın
    // detachedIndexes: const [],

    // Detached butonların görünümünü özelleştirin
    detachedItemPadding: const EdgeInsets.only(right: 28, bottom: 22),
    detachedItemSpacing: 14,
    detachedItemSize: 58,

    // İsterseniz custom builder ile tamamen özel tasarım yapabilirsiniz
    // detachedItemBuilder: (context, item, isSelected) {
    //   return Container(...); // Kendi tasarımınız
    // },
  );

  List<NavItemConfig> get _navItems => const [
    NavItemConfig(
      label: 'Home',
      materialIcon: Icons.home_outlined,
      materialSelectedIcon: Icons.home_rounded,
      cupertinoSymbol: 'house.fill',
      badgeCount: 4, // Badge sayısı
    ),
    NavItemConfig(
      label: 'Profile',
      materialIcon: Icons.person_outline,
      materialSelectedIcon: Icons.person,
      cupertinoSymbol: 'person.fill',
      badgeCount: 1,
      badgeColor: Colors.pink, // Badge özel rengi
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
      backgroundColor: Colors.grey.shade200,
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
