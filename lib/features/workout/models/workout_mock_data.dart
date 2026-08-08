import 'workout_models.dart';

// Some common dummy exercises to reuse
final _dummyEx1 = Exercise(name: "Isınma (Atlama İpi)", type: ExerciseType.time, targetValue: 120, videoUrl: "");
final _dummyEx2 = Exercise(name: "Gölge Boksu", type: ExerciseType.time, targetValue: 180, videoUrl: "");
final _dummyEx3 = Exercise(name: "Mekik", type: ExerciseType.reps, targetValue: 20, videoUrl: "");
final _dummyEx4 = Exercise(name: "Şınav", type: ExerciseType.reps, targetValue: 15, videoUrl: "");
final _dummyEx5 = Exercise(name: "Squat", type: ExerciseType.reps, targetValue: 30, videoUrl: "");
final _dummyEx6 = Exercise(name: "Kum Torbası", type: ExerciseType.time, targetValue: 180, videoUrl: "");
final _dummyEx7 = Exercise(name: "Esneme", type: ExerciseType.time, targetValue: 60, videoUrl: "");

final Map<String, List<WorkoutRoutine>> mockCategoryWorkouts = {
  "Boks": [
    WorkoutRoutine(
      title: "Temel Gard Çalışması",
      durationMinutes: 15,
      difficulty: "Başlangıç",
      imageUrl: "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 5,
      exercises: [_dummyEx1, _dummyEx2, _dummyEx3, _dummyEx4, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "Kum Torbası Kondisyon",
      durationMinutes: 20,
      difficulty: "Orta",
      imageUrl: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 6,
      exercises: [_dummyEx1, _dummyEx6, _dummyEx6, _dummyEx3, _dummyEx4, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "Gölge Boksu",
      durationMinutes: 10,
      difficulty: "Kolay",
      imageUrl: "https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 3,
      exercises: [_dummyEx1, _dummyEx2, _dummyEx7],
    ),
  ],
  "Wushu Sanda": [
    WorkoutRoutine(
      title: "Temel Tekme Kombinasyonları",
      durationMinutes: 25,
      difficulty: "Orta",
      imageUrl: "https://images.unsplash.com/photo-1555597673-b21d5c935865?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 8,
      exercises: [_dummyEx1, _dummyEx5, _dummyEx2, _dummyEx5, _dummyEx2, _dummyEx3, _dummyEx4, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "Sanda Dayanıklılık",
      durationMinutes: 30,
      difficulty: "Zor",
      imageUrl: "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 10,
      exercises: [_dummyEx1, _dummyEx5, _dummyEx6, _dummyEx4, _dummyEx6, _dummyEx3, _dummyEx2, _dummyEx5, _dummyEx4, _dummyEx7],
    ),
  ],
  "Kardiyo": [
    WorkoutRoutine(
      title: "HIIT Kardiyo",
      durationMinutes: 20,
      difficulty: "Zor",
      imageUrl: "https://images.unsplash.com/photo-1538805060514-97d9cc17730c?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 6,
      exercises: [_dummyEx1, _dummyEx5, _dummyEx4, _dummyEx3, _dummyEx5, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "Hafif Koşu Simülasyonu",
      durationMinutes: 15,
      difficulty: "Başlangıç",
      imageUrl: "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 3,
      exercises: [_dummyEx1, _dummyEx1, _dummyEx7],
    ),
  ],
  "Kas Geliştirme": [
    WorkoutRoutine(
      title: "Üst Vücut Güç",
      durationMinutes: 40,
      difficulty: "Zor",
      imageUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 7,
      exercises: [_dummyEx1, _dummyEx4, _dummyEx4, _dummyEx3, _dummyEx3, _dummyEx4, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "Alt Vücut Patlayıcılık",
      durationMinutes: 35,
      difficulty: "Orta",
      imageUrl: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 6,
      exercises: [_dummyEx1, _dummyEx5, _dummyEx5, _dummyEx5, _dummyEx5, _dummyEx7],
    ),
  ],
  "Benim Oluşturduklarım": [
    WorkoutRoutine(
      title: "Özel Sabah Rutinim",
      durationMinutes: 15,
      difficulty: "Orta",
      imageUrl: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 4,
      exercises: [_dummyEx1, _dummyEx4, _dummyEx3, _dummyEx7],
    ),
  ],
  "Eğitmenden Gelenler": [
    WorkoutRoutine(
      title: "Hoca'nın Dayanıklılık Testi",
      durationMinutes: 45,
      difficulty: "Çok Zor",
      imageUrl: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 8,
      exercises: [_dummyEx1, _dummyEx6, _dummyEx6, _dummyEx4, _dummyEx5, _dummyEx3, _dummyEx2, _dummyEx7],
    ),
  ],
  "Favorilerim": [
    WorkoutRoutine(
      title: "Core Crusher 3000",
      durationMinutes: 15,
      difficulty: "Zor",
      imageUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 5,
      exercises: [_dummyEx1, _dummyEx3, _dummyEx3, _dummyEx3, _dummyEx7],
    ),
  ],
  "En Son Yaptıklarım": [
    WorkoutRoutine(
      title: "Morning Mobility",
      durationMinutes: 10,
      difficulty: "Başlangıç",
      imageUrl: "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 3,
      exercises: [_dummyEx1, _dummyEx7, _dummyEx7],
    ),
  ],
  "Evde": [
    WorkoutRoutine(
      title: "Ekipmansız Vücut Ağırlığı",
      durationMinutes: 20,
      difficulty: "Orta",
      imageUrl: "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 5,
      exercises: [_dummyEx1, _dummyEx4, _dummyEx3, _dummyEx5, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "Ev Tipi Kardiyo",
      durationMinutes: 15,
      difficulty: "Başlangıç",
      imageUrl: "https://images.unsplash.com/photo-1538805060514-97d9cc17730c?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 3,
      exercises: [_dummyEx1, _dummyEx1, _dummyEx7],
    ),
  ],
  "Kulüpte": [
    WorkoutRoutine(
      title: "Ağır Sağlam",
      durationMinutes: 45,
      difficulty: "Çok Zor",
      imageUrl: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 8,
      exercises: [_dummyEx1, _dummyEx6, _dummyEx4, _dummyEx5, _dummyEx4, _dummyEx3, _dummyEx6, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "İstasyon Çalışması",
      durationMinutes: 30,
      difficulty: "Zor",
      imageUrl: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 6,
      exercises: [_dummyEx1, _dummyEx5, _dummyEx6, _dummyEx3, _dummyEx4, _dummyEx7],
    ),
  ],
  "Dışarıda": [
    WorkoutRoutine(
      title: "Parkur Koşusu",
      durationMinutes: 30,
      difficulty: "Orta",
      imageUrl: "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 4,
      exercises: [_dummyEx1, _dummyEx7, _dummyEx1, _dummyEx7],
    ),
    WorkoutRoutine(
      title: "Açık Hava Gölge Boksu",
      durationMinutes: 20,
      difficulty: "Kolay",
      imageUrl: "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=500&auto=format&fit=crop",
      exerciseCount: 3,
      exercises: [_dummyEx1, _dummyEx2, _dummyEx7],
    ),
  ],
};
