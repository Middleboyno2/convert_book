import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class MenuItemBook extends StatelessWidget {
  const MenuItemBook({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          height: 50,
          color: Colors.grey.shade300,
          child: ListTile(
            title: Text(
              AppLocalizations.of(context).translate('menu_item_book.edit_image')
            ),
            leading: Icon(Icons.edit),
          ),
        ),
        Container(
          height: 50,
          color: Colors.grey.shade300,
          child: ListTile(
            title: Text(
                AppLocalizations.of(context).translate('menu_item_book.delete')
            ),
            leading: Icon(Icons.delete),
            onTap: (){

            },
          ),
        ),
      ],
    );
  }
}
