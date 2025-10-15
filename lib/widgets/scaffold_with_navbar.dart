import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'drawer_widget.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final String? userAvatarUrl;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final titles = ["Home", "Add", "Settings"];
    final currentTitle = titles[navigationShell.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: userAvatarUrl != null
                  ? NetworkImage(userAvatarUrl!)
                  : null,
              child: userAvatarUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
