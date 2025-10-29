import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/password_strength_meter.dart';
import '../widgets/avatar_picker.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _dob = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;
  int? _avatarIndex;

  // Bounce animation on valid input
  late AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 180), lowerBound: 0.98, upperBound: 1.02)..value = 1;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _dob.dispose();
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      HapticFeedback.selectionClick();
    }
  }

  // Units for progress: name, email, dob, password, avatar
  int get _completed {
    int c = 0;
    if (_name.text.trim().isNotEmpty) c++;
    if (_email.text.contains('@') && _email.text.contains('.')) c++;
    if (_dob.text.isNotEmpty) c++;
    if (_password.text.length >= 6) c++;
    if (_avatarIndex != null) c++;
    return c;
  }

  void _onFieldValidated(bool ok) {
    if (ok) {
      _bounce.forward(from: 0.98);
    }
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields.')),
      );
      return;
    }
    if (_avatarIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick an avatar to continue!')),
      );
      return;
    }
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _loading = false);

      // Achievement logic
      final strongPwd = _password.text.length >= 10 &&
                        RegExp(r'[A-Z]').hasMatch(_password.text) &&
                        RegExp(r'[0-9]').hasMatch(_password.text) &&
                        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_password.text);

      final noon = DateTime.now().hour < 12; // Signed up before noon
      final allFilled = _completed == 5;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            userName: _name.text.trim(),
            avatarIndex: _avatarIndex!,
            badges: [
              if (strongPwd) 'Strong Password Master',
              if (noon) 'The Early Bird Special',
              if (allFilled) 'Profile Completer',
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account '),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: Column(
              children: [
                // Progress
                ProgressTracker(totalUnits: 5, completedUnits: _completed),
                const SizedBox(height: 20),

                // Name
                ScaleTransition(
                  scale: _bounce,
                  child: TextFormField(
                    controller: _name,
                    decoration: _dec('Player Name', Icons.person),
                    validator: (v) {
                      final ok = v != null && v.trim().isNotEmpty;
                      _onFieldValidated(ok);
                      return ok ? null : 'What should we call you on this adventure?';
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                ScaleTransition(
                  scale: _bounce,
                  child: TextFormField(
                    controller: _email,
                    decoration: _dec('Email Address', Icons.email),
                    validator: (v) {
                      final ok = v != null && v.contains('@') && v.contains('.');
                      _onFieldValidated(ok);
                      return ok ? null : 'Not a valid email, plese try again';
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // DOB
                TextFormField(
                  controller: _dob,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _dec('Date of Birth', Icons.calendar_today).copyWith(
                    suffixIcon: IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDate),
                  ),
                  validator: (v) {
                    final ok = v != null && v.isNotEmpty;
                    _onFieldValidated(ok);
                    return ok ? null : 'When did your adventure begin?';
                  },
                ),
                const SizedBox(height: 16),

                // Password + meter
                TextFormField(
                  controller: _password,
                  obscureText: !_showPassword,
                  onChanged: (_) => setState(() {}),
                  decoration: _dec('Secret Password', Icons.lock).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: Colors.deepPurple),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (v) {
                    final ok = (v ?? '').length >= 6;
                    _onFieldValidated(ok);
                    return ok ? null : 'Make it stronger! At least 6 characters';
                  },
                ),
                const SizedBox(height: 8),
                PasswordStrengthMeter(password: _password.text),
                const SizedBox(height: 20),

                // Avatar selection
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Choose your Avatar', style: TextStyle(color: Colors.deepPurple[800], fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                AvatarPicker(
                  selectedIndex: _avatarIndex,
                  onSelected: (i) => setState(() => _avatarIndex = i),
                ),
                const SizedBox(height: 30),

                // Submit
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _loading ? 60 : double.infinity,
                  height: 56,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple)))
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Start My Adventure', style: TextStyle(fontSize: 18, color: Colors.white)),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
