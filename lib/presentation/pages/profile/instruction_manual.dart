import 'package:doantotnghiep/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class InstructionManual extends StatefulWidget {
  const InstructionManual({super.key});

  @override
  State<InstructionManual> createState() => _InstructionManualState();
}

class _InstructionManualState extends State<InstructionManual> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            ExpansionTile(
              title: Text(appLocalization.translate('manual.title_1')),
              children: [
                Text(appLocalization.translate('manual.how_to_add_book?')),
              ],
            ),
            ExpansionTile(
              title: Text(appLocalization.translate('manual.title_1')),
              children: [
                Text(appLocalization.translate('manual.how_to_add_book?')),
              ],
            ),
            ExpansionTile(
              title: Text(appLocalization.translate('manual.title_1')),
              children: [
                Text(appLocalization.translate('manual.how_to_add_book?')),
              ],
            ),
            ExpansionTile(
              title: Text(appLocalization.translate('manual.title_1')),
              children: [
                Text(appLocalization.translate('manual.how_to_add_book?')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
