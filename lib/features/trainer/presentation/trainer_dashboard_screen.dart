import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path_helper;
import '../../../core/services/storage_service.dart';

class LocalExercise {
  final String name;
  final String durationOrReps;
  final String videoUrl;

  LocalExercise({
    required this.name,
    required this.durationOrReps,
    required this.videoUrl,
  });
}

class TrainerDashboardScreen extends StatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  State<TrainerDashboardScreen> createState() => _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends State<TrainerDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  String _selectedCategory = "Boks";
  String _selectedDifficulty = "Orta";
  final List<LocalExercise> _exercises = [];

  final List<String> _categories = [
    "Boks",
    "Wushu Sanda",
    "Kardiyo",
    "Kas Geliştirme",
    "Benim Oluşturduklarım",
  ];

  final List<String> _difficulties = ["Kolay", "Orta", "Zor"];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addExercise(LocalExercise exercise) {
    setState(() {
      _exercises.add(exercise);
    });
  }

  void _showAddExerciseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExerciseBottomSheet(onSave: _addExercise),
    );
  }

  void _saveProgram() {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen en az bir egzersiz ekleyin!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Mock save routine outputting logic
    print("----- YENİ PROGRAM DETAYLARI -----");
    print("Başlık: ${_titleController.text}");
    print("Kategori: $_selectedCategory");
    print("Zorluk: $_selectedDifficulty");
    print("Egzersiz Sayısı: ${_exercises.length}");
    for (var i = 0; i < _exercises.length; i++) {
      final ex = _exercises[i];
      print(
        "  Egzersiz ${i + 1}: ${ex.name} - ${ex.durationOrReps} (Video: ${ex.videoUrl})",
      );
    }
    print("----------------------------------");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${_titleController.text} antrenmanı başarıyla kaydedildi! 🥊",
        ),
        backgroundColor: Colors.teal,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Eğitmen Paneli",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program Info Card
              Card(
                color: cardBgColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Antrenman Bilgileri",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: "Antrenman Başlığı",
                          hintText: "Örn: Hızlı Kombinasyon Çalışması",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Lütfen antrenman başlığını girin";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: "Kategori",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              dropdownColor: cardBgColor,
                              items: _categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedCategory = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedDifficulty,
                              decoration: InputDecoration(
                                labelText: "Zorluk Derecesi",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              dropdownColor: cardBgColor,
                              items: _difficulties.map((diff) {
                                return DropdownMenuItem(
                                  value: diff,
                                  child: Text(
                                    diff,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedDifficulty = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Exercises List Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Egzersizler Listesi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _showAddExerciseBottomSheet,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      "Egzersiz Ekle",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Exercises List View
              if (_exercises.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      style: BorderStyle.values[1],
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.sports_mma_outlined,
                        size: 48,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Henüz egzersiz eklenmedi.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final ex = _exercises[index];
                    return Card(
                      color: cardBgColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent.withOpacity(0.2),
                          foregroundColor: Colors.redAccent,
                          child: Text("${index + 1}"),
                        ),
                        title: Text(
                          ex.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Süre/Tekrar: ${ex.durationOrReps}"),
                        trailing: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 40),

              // Save Program Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _saveProgram,
                  child: const Text(
                    "Programı Kaydet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Aktif Sporcularım Section
              const Text(
                "Aktif Sporcularım",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAthleteTile(context, "Ali Demir", "inst_hamza", "Hamza Akburak", "Kahverengi Kuşak", cardBgColor),
                  _buildAthleteTile(context, "Ayşe Kaya", "inst_hamza", "Hamza Akburak", "Mavi Kuşak", cardBgColor),
                  _buildAthleteTile(context, "Can Yılmaz", "inst_hamza", "Hamza Akburak", "Mavi Kuşak", cardBgColor),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAthleteTile(
    BuildContext context,
    String athleteName,
    String trainerId,
    String trainerName,
    String subtitle,
    Color cardBgColor,
  ) {
    return Card(
      color: cardBgColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.tealAccent.withOpacity(0.2),
          child: Text(
            athleteName.substring(0, 1),
            style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(athleteName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chat_bubble_outline, color: Colors.tealAccent),
        onTap: () {
          context.push('/chat', extra: {
            'trainerId': trainerId,
            'trainerName': trainerName,
          });
        },
      ),
    );
  }
}

class _AddExerciseBottomSheet extends StatefulWidget {
  final Function(LocalExercise) onSave;
  const _AddExerciseBottomSheet({required this.onSave});

  @override
  State<_AddExerciseBottomSheet> createState() =>
      _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<_AddExerciseBottomSheet> {
  final _exerciseFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  File? _selectedVideo;
  String? _uploadedVideoUrl;
  bool _isProcessing = false;
  String _processingStage = "";

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadVideo() async {
    setState(() {
      _isProcessing = true;
      _processingStage = "Video seçiliyor...";
    });

    final videoFile = await StorageService().pickVideoFromGallery();
    if (videoFile == null) {
      setState(() => _isProcessing = false);
      return;
    }

    setState(() {
      _selectedVideo = videoFile;
      _processingStage = "Sıkıştırılıyor (2-3 MB)...";
    });

    // Compress video
    final compressedFile = await StorageService().compressVideo(videoFile);

    setState(() {
      _processingStage = "Yükleniyor (Firebase Storage)...";
    });

    // Upload video
    final uploadUrl = await StorageService().uploadWorkoutVideo(
      compressedFile ?? videoFile,
    );

    setState(() {
      _uploadedVideoUrl = uploadUrl;
      _isProcessing = false;
    });
  }

  void _save() {
    if (!_exerciseFormKey.currentState!.validate()) return;
    if (_uploadedVideoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen egzersiz için bir video seçin ve yükleyin!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newExercise = LocalExercise(
      name: _nameController.text.trim(),
      durationOrReps: _durationController.text.trim(),
      videoUrl: _uploadedVideoUrl!,
    );

    widget.onSave(newExercise);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _exerciseFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Yeni Egzersiz Ekle",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Egzersiz Adı",
                  hintText: "Örn: Sol-Sağ Direk ve Eskiv",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Lütfen egzersiz adını girin";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Süre veya Tekrar",
                  hintText: "Örn: 30 Dk, 20x, 3 Seri",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Lütfen süre veya tekrar bilgisini girin";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Video Pick Area
              Center(
                child: Column(
                  children: [
                    if (_isProcessing) ...[
                      const CircularProgressIndicator(color: Colors.tealAccent),
                      const SizedBox(height: 12),
                      Text(
                        _processingStage,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                    ] else if (_uploadedVideoUrl != null) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Video Başarıyla Sıkıştırıldı ve Yüklendi!",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kullanılan Video: ${_selectedVideo != null ? path_helper.basename(_selectedVideo!.path) : 'Bilinmeyen'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.tealAccent,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _pickAndUploadVideo,
                        icon: const Icon(
                          Icons.video_library,
                          color: Colors.teal,
                        ),
                        label: const Text(
                          "Video Seç & Yükle",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _save,
                  child: const Text(
                    "Egzersizi Kaydet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
