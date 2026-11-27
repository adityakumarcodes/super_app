import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class FabAction {
  const FabAction({required this.icon, required this.label, this.onPressed});

  final Icon icon;
  final String label;
  final VoidCallback? onPressed;
}

class ActionFab extends StatelessWidget {
  const ActionFab({
    super.key,
    required this.actions,
    this.expandIcon,
    this.collapseIcon,
    this.position = M3EFabMenuPosition.right,
    this.size = M3EFabSize.regular,
    this.color = M3EFabColor.primary,
  });

  final List<FabAction> actions;
  final Icon? expandIcon;
  final Icon? collapseIcon;
  final M3EFabMenuPosition position;
  final M3EFabSize size;
  final M3EFabColor color;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  void _handleAction(BuildContext context, FabAction action) {
    if (action.onPressed != null) {
      action.onPressed!();
    } else {
      _showComingSoon(context, action.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Single action: regular FAB
    if (actions.length == 1) {
      return M3EFab(
        icon: actions.first.icon,
        onPressed: () => _handleAction(context, actions.first),
      );
    }

    // Multiple actions: expandable FAB menu
    return M3EFabMenu(
      position: position,
      size: size,
      color: color,
      expandIcon: expandIcon ?? const Icon(Icons.add),
      collapseIcon: collapseIcon ?? const Icon(Icons.close),
      closeOnItemTap: true,
      items: actions
          .map(
            (action) => M3EFabMenuItem(
              icon: action.icon,
              label: action.label,
              onPressed: () => _handleAction(context, action),
            ),
          )
          .toList(),
    );
  }
}
