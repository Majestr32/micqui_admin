import 'package:flutter/material.dart';
import 'package:micqui_admin/presentation/widgets/layout/app_drawer.dart';

import '../../../app/router.dart';

class TabletLayout extends StatefulWidget {
  const TabletLayout({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<TabletLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      drawer: AppDrawer(
        goToMyBuckets: () {
          router.go('/buckets');
        },
        goToUsers: () {
          router.go('/users');
        },
      ),
      body: widget.child,
      // const QuestionaireScreen(),
    );
  }
}
