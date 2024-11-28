import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomBottomAppBar extends StatefulWidget {
  final Color? selectedItemColor;
  final List<CustomBottomAppBarItem> children;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomAppBar({
    Key? key,
    this.selectedItemColor,
    required this.children,
    required this.currentIndex,
    required this.onTap,
  })  : assert(children.length == 6, 'children.length must be 4'),
        super(key: key);

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.children.map(
              (item) {
            final currentItem = widget.children.indexOf(item) == widget.currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () {
                  widget.onTap(widget.children.indexOf(item));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Icon(
                    currentItem ? item.primaryIcon : item.secondaryIcon,
                    color: currentItem ? widget.selectedItemColor : AppColors.purplelightMain,
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class CustomBottomAppBarItem {
  final String? label;
  final IconData? primaryIcon;
  final IconData? secondaryIcon;
  final VoidCallback? onPressed;

  CustomBottomAppBarItem({
    this.label,
    this.primaryIcon,
    this.secondaryIcon,
    this.onPressed,
  });

  CustomBottomAppBarItem.empty({
    this.label,
    this.primaryIcon,
    this.secondaryIcon,
    this.onPressed,
  });
}
