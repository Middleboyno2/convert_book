import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:doantotnghiep/presentation/pages/auth/login.dart';
import 'package:doantotnghiep/presentation/pages/community.dart';
import 'package:doantotnghiep/presentation/pages/library.dart';
import 'package:doantotnghiep/presentation/pages/profile.dart';
import 'package:flutter/material.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  int _selectedIndex = 0;

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const LibraryPage(),
    const CommunityPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        indicatorColor: Kolors.kGold2,
        selectedIndex: _selectedIndex,
        animationDuration: Duration(milliseconds: 300),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
          height: 60,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.library_books),
            selectedIcon: Icon(Icons.library_books_outlined),
            label: appLocalizations.translate('navigation.lib'),
          ),
          NavigationDestination(
            icon: Icon(Icons.forum),
            selectedIcon: Icon(Icons.forum_outlined),
            label: appLocalizations.translate('navigation.community'),
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            selectedIcon: Icon(Icons.account_circle_outlined),
            label: appLocalizations.translate('navigation.profile'),
          ),
        ]
      ),

      body: _screens[_selectedIndex],
    );
  }
}
