import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:doantotnghiep/presentation/pages/auth/login.dart';
import 'package:doantotnghiep/presentation/pages/chat_ai.dart';
import 'package:doantotnghiep/presentation/pages/community.dart';
import 'package:doantotnghiep/presentation/pages/library.dart';
import 'package:doantotnghiep/presentation/pages/profile/profile.dart';
import 'package:flutter/material.dart';

import '../../core/constants/resource.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const LibraryPage(),
    const CommunityPage(),
    const ChatAi(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        indicatorColor: Kolors.kTransparent,
        selectedIndex: _selectedIndex,
        animationDuration: Duration(milliseconds: 300),
        overlayColor: WidgetStateProperty.all(Kolors.kTransparent),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
        height: 60,
        destinations: [
          NavigationDestination(
            icon: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                R.ASSETS_ICON_LIB
              ),
            ),
            selectedIcon: SizedBox(
              child: Image.asset(
                width: 60,
                height: 60,
                R.ASSETS_ICON_LIB_OUTLINE
              ),
            ),
            label: appLocalizations.translate('navigation.lib'),
          ),
          NavigationDestination(
            icon: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                R.ASSETS_ICON_COMMUNITY
              ),
            ),
            selectedIcon: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                  R.ASSETS_ICON_COMMUNITY_OUTLINE
              ),
            ),
            label: appLocalizations.translate('navigation.community'),
          ),
          NavigationDestination(
            icon: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                  R.ASSETS_ICON_CHAT_BOT
              ),
            ),
            selectedIcon: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                  R.ASSETS_ICON_CHAT_BOT_OUTLINE
              ),
            ),
            label: appLocalizations.translate('navigation.chatbot'),
          ),
          NavigationDestination(
            icon: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                  R.ASSETS_ICON_PROFILE
              ),
            ),
            selectedIcon: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                  R.ASSETS_ICON_PROFILE_OUTLINE
              ),
            ),
            label: appLocalizations.translate('navigation.profile'),
          ),
        ]
      ),

      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
