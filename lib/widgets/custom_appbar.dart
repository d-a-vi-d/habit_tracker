import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isChild;
  final Widget? appBarItem;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isChild = false,
    this.appBarItem,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppBar(
        leading: onBack != null
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)
            : Navigator.canPop(context)
            ? const BackButton()
            : Image.asset('assets/images/logo6.png'),
        title: Navigator.canPop(context)
            ? Row(
                children: [
                  Image.asset('assets/images/logo6.png', height: 30),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
                ],
              )
            : Text(title, overflow: TextOverflow.ellipsis),

        actions: appBarItem != null ? [appBarItem!] : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget navigatorTile(String title, Widget screenName, BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => screenName));
      },
      child: Text(title),
    );
  }
}
