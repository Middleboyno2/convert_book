import 'package:doantotnghiep/presentation/widgets/profile/avatar.dart';
import 'package:doantotnghiep/presentation/widgets/profile/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../widgets/setting/language_dropdown.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: ScreenUtil().screenHeight,
        width: ScreenUtil().screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            AvatarProfile(avatarUrl: '', id: 'dfasdfsdfadsfasd',),
            SizedBox(height: 50,),
            ProfileItem(
              icon: Icons.account_circle_outlined,
              title: 'account',
              onTap: (){}
            ),
            ProfileItem(
                icon: Icons.settings,
                title: 'setting',
                onTap: (){
                  context.push('/setting');
                }
            ),
            ProfileItem(
                icon: Icons.support_agent_outlined,
                title: 'support',
                onTap: (){
                  context.push('/support');
                }
            ),
            const LanguageDropdown(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
