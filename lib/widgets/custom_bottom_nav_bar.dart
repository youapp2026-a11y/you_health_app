
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:feather_icons/feather_icons.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/chat');
            break;
          case 2:
            context.go('/camera');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FeatherIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(FeatherIcons.messageSquare),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(FeatherIcons.camera),
          label: 'Camera',
        ),
      ],
    );
  }
}
