import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await AuthService().login(email, password);
    
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        
        if (email == 'admin@akburak.com' && password == 'admin123') {
          debugPrint("Admin logged in!");
          await prefs.setBool('onboarding_completed', true);
          await prefs.setString('user_name', "Admin Eğitmen");
          await prefs.setStringList('user_interests', ["Boks", "Wushu Sanda", "Fitness"]);
          if (mounted) {
            context.go('/home');
          }
        } else {
          final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
          if (onboardingCompleted) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Giriş başarısız. Lütfen bilgilerinizi kontrol edin."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildVideoBackground() {
    return SizedBox.expand(
      child: Image.asset(
        'assets/images/login_bg.png',
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Borderless Looping Video Background / Fallback
          _buildVideoBackground(),

          // 2. Dark Overlay Layer for Premium Contrast
          Container(
            color: Colors.black.withOpacity(0.68),
          ),

          // 3. Form Interactive Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Branding Header
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/logo.jpg'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "AKBURAK SPOR KULÜBÜ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Adrenalin ve Şampiyonların Adresi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13, 
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Email Input (Glassmorphic Accent)
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "E-Posta Adresi",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lütfen e-posta adresinizi girin";
                          }
                          if (!value.contains("@") || !value.contains(".")) {
                            return "Geçersiz e-posta formatı";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Input (Glassmorphic Accent)
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Şifre",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Lütfen şifrenizi girin";
                          }
                          if (value.length < 6) {
                            return "Şifre en az 6 karakter olmalıdır";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Login Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Giriş Yap",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Şifremi Unuttum",
                            style: TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            context.push('/register');
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Hesabın yok mu? ",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Üye Ol",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Divider "--- VEYA ---"
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "VEYA",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4), 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Google Sign In
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            await Future.delayed(const Duration(milliseconds: 800));
                            setState(() => _isLoading = false);
                            
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('is_logged_in', true);
                            if (mounted) {
                              context.go('/onboarding');
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Mock Google Logo using customized text/color
                              const Text(
                                "G ",
                                style: TextStyle(
                                  color: Colors.blue, 
                                  fontSize: 22, 
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                              const Text(
                                "Google ile Giriş Yap",
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.black87
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
