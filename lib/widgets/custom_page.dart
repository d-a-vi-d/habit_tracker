import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_appbar.dart';

class CustomPage extends StatelessWidget {
  final String? title;
  final Widget child;
  final VoidCallback? onFabPressed;
  final bool scrollable;
  final bool isChild;
  final Widget? appBarItem;
  final VoidCallback? onBack;
  final RefreshCallback? onRefresh;

  const CustomPage({
    this.title,
    required this.child,

    this.onFabPressed,
    this.onRefresh,
    this.scrollable = true,
    super.key,
    this.isChild = false,
    this.appBarItem,
    this.onBack,
  });

  Widget _maybeWithRefresh(Widget child) {
    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: child);
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: onFabPressed != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 8),
              child: FloatingActionButton(
                onPressed: onFabPressed,
                backgroundColor: AppColors.primary400,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: AppColors.neutralLight),
              ),
            )
          : null,
      appBar: title != null
          ? CustomAppBar(title: title!, isChild: isChild, appBarItem: appBarItem, onBack: onBack)
          : null,
      body: _maybeWithRefresh(
        SafeArea(
          child: scrollable
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [const SizedBox(height: 20), child, const SizedBox(height: 50)],
                    ),
                  ),
                )
              : Padding(padding: const EdgeInsets.all(15), child: child),
        ),
      ),
    );
  }
}
