import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form State Values
  final _personalFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = "Erkek";
  double _bmi = 0.0;
  String _bmiLabel = "Hesaplanıyor...";
  IconData _bmiIcon = Icons.male;
  Color _bmiColor = Colors.grey;

  // Card 2: Interests
  final List<String> _interests = ["Boks", "Wushu Sanda", "Fitness"];
  final List<String> _selectedInterests = [];

  // Card 3: Availability
  final List<String> _days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
  final List<String> _selectedDays = [];
  double _timeCommitment = 45.0; // minutes default

  @override
  void initState() {
    super.initState();
    // Add real-time BMI listeners
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0 && weight > 0) {
      final heightInMeters = height / 100.0;
      final calculatedBmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        _bmi = calculatedBmi;
        if (_selectedGender == "Erkek") {
          if (_bmi < 18.5) {
            _bmiLabel = "Zayıf (Slim)";
            _bmiIcon = Icons.person_outline;
            _bmiColor = Colors.blueAccent;
          } else if (_bmi >= 18.5 && _bmi < 25.0) {
            _bmiLabel = "Atletik / Fit";
            _bmiIcon = Icons.directions_run;
            _bmiColor = Colors.tealAccent;
          } else {
            _bmiLabel = "Kalıplı / Fazla Kilolu";
            _bmiIcon = Icons.accessibility_new;
            _bmiColor = Colors.redAccent;
          }
        } else {
          // Kadın
          if (_bmi < 18.5) {
            _bmiLabel = "Zayıf (Slim)";
            _bmiIcon = Icons.person_pin_circle_outlined;
            _bmiColor = Colors.pinkAccent;
          } else if (_bmi >= 18.5 && _bmi < 25.0) {
            _bmiLabel = "Atletik / Fit";
            _bmiIcon = Icons.directions_walk;
            _bmiColor = Colors.tealAccent;
          } else {
            _bmiLabel = "Kalıplı / Fazla Kilolu";
            _bmiIcon = Icons.accessibility;
            _bmiColor = Colors.orangeAccent;
          }
        }
      });
    } else {
      setState(() {
        _bmi = 0.0;
        _bmiLabel = "Veri bekleniyor...";
        _bmiIcon = _selectedGender == "Erkek" ? Icons.male : Icons.female;
        _bmiColor = Colors.grey;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen en az bir ilgi alanı seçin!"), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen antrenman yapabileceğiniz en az bir gün seçin!"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_gender', _selectedGender);
    await prefs.setStringList('user_interests', _selectedInterests);
    await prefs.setStringList('user_days', _selectedDays);
    await prefs.setDouble('user_time', _timeCommitment);

    if (mounted) {
      context.go('/home');
    }
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (!_personalFormKey.currentState!.validate()) return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Kayıt ve Analiz Formu", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Page Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => _buildIndicator(index)),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Force control via buttons for validation
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildPersonalInfoCard(isDark),
                  _buildInterestsCard(isDark),
                  _buildAvailabilityCard(isDark),
                ],
              ),
            ),

            // Controls Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _previousPage,
                      child: const Text("Geri"),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _currentPage == 2 ? _completeOnboarding : _nextPage,
                    child: Text(
                      _currentPage == 2 ? "Tamamla & Başla 🥊" : "İleri",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.tealAccent : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // CARD 1: Personal Info & BMI Shape
  Widget _buildPersonalInfoCard(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _personalFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kişisel Bilgiler",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: const InputDecoration(labelText: "İsim Soyisim", prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v == null || v.trim().isEmpty ? "Lütfen isminizi girin" : null,
                ),
                 const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: const InputDecoration(labelText: "Yaş", prefixIcon: Icon(Icons.cake_outlined)),
                  validator: (v) => v == null || int.tryParse(v) == null ? "Geçersiz yaş" : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Cinsiyet",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: Colors.tealAccent,
                      selectedForegroundColor: Colors.black87,
                      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.withOpacity(0.1),
                    ),
                    segments: const [
                      ButtonSegment<String>(
                        value: "Erkek",
                        label: Text("Erkek"),
                        icon: Icon(Icons.male),
                      ),
                      ButtonSegment<String>(
                        value: "Kadın",
                        label: Text("Kadın"),
                        icon: Icon(Icons.female),
                      ),
                    ],
                    selected: {_selectedGender},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _selectedGender = selection.first;
                        _calculateBmi();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(labelText: "Boy (cm)", prefixIcon: Icon(Icons.height)),
                        validator: (v) => v == null || double.tryParse(v) == null ? "Geçersiz boy" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(labelText: "Kilo (kg)", prefixIcon: Icon(Icons.monitor_weight_outlined)),
                        validator: (v) => v == null || double.tryParse(v) == null ? "Geçersiz kilo" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // BMI Calculation visual output
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _bmiColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _bmiColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(_bmiIcon, size: 64, color: _bmiColor, key: ValueKey(_bmiIcon)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _bmi > 0 ? "Vücut Kitle İndeksi: ${_bmi.toStringAsFixed(1)}" : "Vücut İndeksi Analizi",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          _bmiLabel,
                          style: TextStyle(color: _bmiColor, fontWeight: FontWeight.bold, fontSize: 18),
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
    );
  }

  // CARD 2: Interests
  Widget _buildInterestsCard(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "İlgi Alanlarınız Neler?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Size özel antrenman önerileri oluşturmamız için en az bir dal seçin.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _interests.length,
                  itemBuilder: (context, index) {
                    final interest = _interests[index];
                    final isSelected = _selectedInterests.contains(interest);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.tealAccent.withOpacity(0.1) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.tealAccent : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  interest == "Boks" 
                                      ? Icons.sports_mma 
                                      : interest == "Wushu Sanda"
                                          ? Icons.sports_kabaddi
                                          : Icons.fitness_center,
                                  color: isSelected ? Colors.tealAccent : Colors.grey,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  interest,
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.tealAccent : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.tealAccent)
                            else
                              const Icon(Icons.circle_outlined, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CARD 3: Availability
  Widget _buildAvailabilityCard(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Antrenman Takvimi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Hangi günler spor yapabilirsiniz?",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              
              // Days Selector
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _days.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    selectedColor: Colors.tealAccent.withOpacity(0.3),
                    checkmarkColor: Colors.tealAccent,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),
              
              // Daily Commitment Slider
              const Text(
                "Günlük kaç dakika ayırabilirsiniz?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("15 Dk", style: TextStyle(color: Colors.grey)),
                  Text(
                    "${_timeCommitment.toInt()} Dakika",
                    style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text("120 Dk", style: TextStyle(color: Colors.grey)),
                ],
              ),
              Slider(
                value: _timeCommitment,
                min: 15.0,
                max: 120.0,
                divisions: 7, // 15, 30, 45, 60, 75, 90, 105, 120
                activeColor: Colors.tealAccent,
                inactiveColor: Colors.grey.withOpacity(0.3),
                onChanged: (val) {
                  setState(() => _timeCommitment = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
