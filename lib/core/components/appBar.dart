import 'package:flutter/material.dart';
import 'package:loop/core/const/palette.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Palette.themeColor,
      title: Text('User Name',
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(color: Palette.lightBackgroundColor)),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () async {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
