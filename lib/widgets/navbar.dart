import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  final List<IconData> icons = const [
    LucideIcons.home,
    LucideIcons.utensils,
    LucideIcons.pieChart,
    LucideIcons.user,
    LucideIcons.diamond,
  ];

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / icons.length;

    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          // GREEN BAR
          Container(
            margin: const EdgeInsets.all(12),
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF29B35A),
              borderRadius: BorderRadius.circular(28),
            ),
          ),

          // WHITE CURVE BEHIND ACTIVE ICON
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: currentIndex * itemWidth + itemWidth / 2 - 35,
            bottom: 32,
            child: Container(
              height: 70,
              width: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ICON ROW
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (index) {
                bool selected = index == currentIndex;

                return GestureDetector(
                  onTap: () => onTap?.call(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    transform: selected
                        ? (Matrix4.identity()..translate(0, -18))
                        : Matrix4.identity(),
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF5ED47A)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icons[index],
                        size: 26,
                        color: selected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
