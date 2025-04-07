import 'package:flutter/material.dart';

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon), // Biểu tượng ở bên trái
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
