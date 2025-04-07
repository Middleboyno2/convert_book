
import 'package:doantotnghiep/presentation/widgets/CustomSearch.dart';
import 'package:doantotnghiep/presentation/widgets/empty/empty_book.dart';
import 'package:doantotnghiep/presentation/widgets/tab_bar.dart';
import 'package:doantotnghiep/presentation/widgets/tabbar/completed.dart';
import 'package:doantotnghiep/presentation/widgets/tabbar/unread.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../widgets/setting/language_dropdown.dart';

class LibraryPage extends StatefulWidget{
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearch = false;
  void changeSearch(){
    setState(() {
      isSearch = !isSearch;
    });
  }

  TextEditingController search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // // Lấy translation không có tham số
    // String title = AppLocalizations.of(context).translate('library.title');
    //
    // // vi du: Lấy translation có tham số
    // String welcome = AppLocalizations.of(context).translateWithArgs(
    //     'library.welcome',
    //     args: {'name': 'John Doe'}
    // );
    return DefaultTabController(
      length: 2,

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // centerTitle: true,
          // title: Text(AppLocalizations.of(context).translate('library.title')),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(75), // search 45 + tabbar 30
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSearch(controller: _searchController,),
                CustomTabBar(),
              ],
            )
          ),
          actions: [
            IconButton(
              onPressed: (){
                context.push('/storage');
              },
              icon: Icon(Icons.add)
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.more_vert)
            ),
          ],
        ),
      
        body: TabBarView(
          children: [
            UnreadBook(),
            CompletedBook()
          ]
        )
      ),
    );
  }
}