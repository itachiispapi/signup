import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgressTracker extends StatefulWidget {
  final int totalUnits; // # of things to complete
  final int completedUnits; // # of things completed

  const ProgressTracker({super.key, required this.totalUnits, required this.completedUnits});

  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> with SingleTickerProviderStateMixin {
  double lastPercent = 0;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 300), lowerBound: 0.95, upperBound: 1.05)..value = 1;
  }

  @override
  void didUpdateWidget(covariant ProgressTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = _percent();
    if (current >= 0.25 && lastPercent < 0.25) _markMilestone('Great start!');
    if (current >= 0.50 && lastPercent < 0.50) _markMilestone('Halfway there!');
    if (current >= 0.75 && lastPercent < 0.75) _markMilestone('Almost done!');
    if (current >= 1.00 && lastPercent < 1.00) _markMilestone('Ready for adventure!');

    lastPercent = current;
  }

  double _percent() {
    if (widget.totalUnits <= 0) return 0;
    return (widget.completedUnits / widget.totalUnits).clamp(0, 1).toDouble();
  }

  void _markMilestone(String _) {
    HapticFeedback.lightImpact();
    _pulse.forward(from: 0.95);
  }

  String _label() {
    final p = (_percent() * 100).round();
    if (p >= 100) return 'Ready for adventure!';
    if (p >= 75) return 'Almost done!';
    if (p >= 50) return 'Halfway there!';
    if (p >= 25) return 'Great start!';
    return 'Let’s begin!';
    }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _percent();
    return ScaleTransition(
      scale: _pulse,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: Colors.deepPurple[100],
            valueColor: AlwaysStoppedAnimation<Color>(
              pct < 0.25 ? Colors.red :
              pct < 0.50 ? Colors.orange :
              pct < 0.75 ? Colors.blue :
                            Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(pct * 100).round()}% • ${_label()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
