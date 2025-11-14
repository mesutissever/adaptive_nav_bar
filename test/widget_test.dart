import 'package:adaptive_nav_bar/adaptive_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdaptiveNavBar renders provided destinations',
      (WidgetTester tester) async {
    final config = AdaptiveNavConfig(
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
      ],
      behavior: const NavBehaviorConfig(autoHideOnScroll: false),
    );

    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: IndexedStack(
                index: selectedIndex,
                children: const [
                  Center(child: Text('Home Page')),
                  Center(child: Text('Profile Page')),
                ],
              ),
              bottomNavigationBar: AdaptiveNavBar(
                config: config,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile Page'), findsOneWidget);
  });
}
