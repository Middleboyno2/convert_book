import 'package:flutter/material.dart';

import '../../../core/constants/resource.dart';

class ProfileItem extends StatelessWidget {
  final String name;
  final String title;
  final VoidCallback onTap;
  const ProfileItem({
    super.key,
    required this.name,
    required this.title,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Image.asset(
            name
          ),
          title: Text(
            title,
            // style: const TextStyle(color: Colors.white), // Màu chữ
          ),
          trailing: const Icon(Icons.chevron_right), // Mũi tên bên phải
          onTap: onTap, // Hành động khi nhấn
        ),
        const Divider(
          color: Colors.grey, // Đường kẻ dưới
          height: 1,
          thickness: 0.5,
        ),
      ],
    );
  }
}
