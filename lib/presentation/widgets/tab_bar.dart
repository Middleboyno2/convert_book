import 'package:doantotnghiep/config/colors/kcolor.dart';
import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorAnimation: TabIndicatorAnimation.linear,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.normal, color: Kolors.kGray),
      dividerHeight: 0,
      tabs:[
        Tab(
          text: AppLocalizations.of(context).translate('tabbar.unread'),
        ),
        Tab(
          text: AppLocalizations.of(context).translate('tabbar.completed'),
        )
      ]
    );
  }
}
