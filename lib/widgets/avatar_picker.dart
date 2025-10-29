import 'package:flutter/material.dart';

class AvatarPicker extends StatelessWidget {
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  const AvatarPicker({super.key, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[
      Icons.pets, Icons.rocket_launch, Icons.local_florist, Icons.whatshot, Icons.auto_awesome
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(icons.length, (i) {
        final selected = selectedIndex == i;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? const Color.fromARGB(255, 10, 140, 180) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? const Color.fromARGB(255, 10, 140, 180) : Colors.grey.shade300, width: 2),
              boxShadow: [
                if (selected)
                  const BoxShadow(blurRadius: 8, spreadRadius: 1, color: Colors.black12),
              ],
            ),
            child: Icon(icons[i], size: 28, color: selected ? Colors.white : const Color.fromARGB(255, 10, 140, 180)),
          ),
        );
      }),
    );
  }
}
