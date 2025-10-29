import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class SuccessScreen extends StatefulWidget {
  final String userName;
  final int avatarIndex;
  final List<String> badges;

  const SuccessScreen({
    super.key,
    required this.userName,
    required this.avatarIndex,
    required this.badges,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final ConfettiController _confetti;

  IconData _avatarIcon(int i) {
    const icons = [Icons.pets, Icons.rocket_launch, Icons.favorite, Icons.emoji_emotions, Icons.sports_esports];
    return icons[i % icons.length];
  }

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 10))..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.deepPurple, Colors.purple, Colors.blue, Colors.green, Colors.orange],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_avatarIcon(widget.avatarIndex), color: Colors.white, size: 80),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome, ${widget.userName}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 12),
                  const Text('Your adventure begins now!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),

                  // Badges
                  if (widget.badges.isNotEmpty) ...[
                    const Text('Achievements Unlocked', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.badges.map((b) {
                        return Chip(
                          avatar: const Icon(Icons.verified, size: 18),
                          label: Text(b),
                          backgroundColor: Colors.white,
                          shape: StadiumBorder(side: BorderSide(color: Colors.deepPurple.shade200)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  ElevatedButton(
                    onPressed: () => _confetti.play(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('More Celebration!', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
