# Progress

## Project Overview
"Akburak Spor Kulübü" is a premium, high-energy fitness and martial arts training companion application. The project features a dual-stack architecture:
- **Frontend:** A cross-platform mobile application built using **Flutter**, incorporating Riverpod for state management, GoRouter for navigation, custom animations, and haptic/audio sensory feedback.
- **Backend:** A modular, asynchronous REST API built using **Python, FastAPI, and MongoDB** (via the Motor client), supporting flexible Pydantic data schemas.

---

## Version History

### V1.0: Foundation
- Established initial Flutter project skeleton.
- Configured clean, structured routing architecture using GoRouter.
- Built basic bottom navigation bar layout.

### V1.2: Workout Architecture Flow
- Upgraded the `WorkoutScreen` UI.
- Designed dynamic, interactive category grids for martial arts (Boks, Wushu Sanda) and fitness disciplines.
- Created the nested `CategoryWorkoutListScreen` navigation flow to allow browsing routines under specific categories before starting detail screens.

### V1.3: Visual Branding
- Customized app styling to support our Dark/Turquoise/Red premium club-spirit color palette.
- Refined UI assets, replacing generic dumbbell/gym icons with custom Boxing Glove icons to reflect the club's martial arts heritage.

### V1.4: Workout Controls & Details
- Enhanced the `WorkoutDetailScreen` with specific target muscle group illustration assets and structured instructions.
- Integrated interactive engine controls in `ActiveWorkoutScreen` allowing users to pause, resume, skip exercises, and track active training phases.

### V1.5: Premium UX Animations
- Built a visually striking, animated `SplashScreen` using smooth fade-in and scale animations.
- Created the custom "Boxing Glove Clash" (`main_layout.dart`) transition overlay, animating left and right boxing gloves crashing together upon switching bottom navigation tabs.

### V1.6: Sensory Feedback & Chatbot Skeleton
- Added native haptic feedback (`HapticFeedback.heavyImpact()`) and audio cues (`audioplayers` package playing `gong.mp3`) triggered dynamically when timers reach zero or phases transition.
- Created the persistent `ChatbotScreen` UI chat bubble layout accessible via a floating action button on the layout.

### V1.7: Asynchronous Python Backend API
- Initialized the FastAPI project inside the `backend/` folder.
- Established asynchronous connection configuration using the `motor` MongoDB driver and python-dotenv.
- Built Pydantic (v2) models for `User`, `WorkoutRoutine`, and `ExerciseItem`.
- Implemented CORS support and defined workouts category retrieval endpoints.

### V1.8: Trainer Dashboard & Video Compression
- Built the `TrainerDashboardScreen` where administrators/trainers can construct custom training programs.
- Implemented client-side video picking (`image_picker`) and quality-balanced compression (`video_compress`) reducing files to a lightweight 2-3MB package.
- Wrote Firebase Storage uploading client services with auto-fallback to sample mock links for offline/prototype execution.
- Resolved layout overflows by making form dropdowns horizontally responsive (`isExpanded: true`) and fixed multi-hero widget conflicts.

### V1.82: Advanced Timer & Workout Engine Visuals
- Implemented next exercise animated preview cards with darkened/blurred background images during rest intervals.
- Integrated dynamic "adrenaline" countdown pulses that scale text and turn indicators red when time remaining is 3 seconds or less.
- Created a global workout progress tracker featuring segmented indicators (Completed = Turquoise, Active = Pulsing Red, Future = Grey).

### V1.9: Onboarding & Auth UI
- Created `login_screen.dart` with email/password validation and persistent session storage using `SharedPreferences`.
- Designed `onboarding_flow_screen.dart` featuring a swipeable 3-card questionnaire:
  - Card 1: Personal info with live BMI calculator and dynamic body avatar shape changes.
  - Card 2: Multi-choice training interests (Boks, Wushu Sanda, Fitness).
  - Card 3: Availability day chips and slider for daily minutes.
- Updated `splash_screen.dart` to direct users dynamically based on their login and onboarding state.
- Revamped `home_screen.dart` to display a customized "Size Özel Önerilenler" section matching the user's selected interests.

### V1.91: Login Screen Polish
- Added full-screen borderless background using the premium static image `assets/images/login_bg.png` (replaces video player logic for optimized performance).
- Overlayed the background with a dark gradient transparency layer (`Opacity: 0.68`) to maintain input field readability.
- Added Sign Up redirect button to route from `/login` to `/onboarding`.
- Added a stylized mock Google Sign In button with custom Google G branding.
- Programmed a hardcoded Admin login logic (`admin@akburak.com` / `admin123`) that sets onboarding as completed and immediately routes to `/home` (bypassing onboarding).

### V1.92: Registration Flow Correction
- Created `register_screen.dart` with E-Posta Adresi, Şifre, and Şifre Tekrar validation forms.
- Replicated the premium static background image logic from `login_screen.dart` to maintain UI consistency.
- Corrected the routing flow where "Üye Ol" on `login_screen.dart` goes to `/register` instead of `/onboarding`.
- Programmed matching password validation on registration success before routing to `/onboarding`.

### V1.93: Dynamic Gender & BMI Avatars
- Integrated Gender Selection UI (Erkek/Kadın) using Material 3 `SegmentedButton` in the first onboarding card.
- Implemented real-time dynamic body avatar matching logic combining both `Gender` and calculated `BMI` values.
- Mapped specific premium Material Icons and tailored color representations for Slim, Fit/Athletic, and Heavy shapes (male/female profiles).
- Configured persistent session preferences to store `user_gender` on onboarding completion.

### V2.0: Full Backend Integration
- Added the `dio` network dependency to `pubspec.yaml` to support robust HTTP services and custom logging interceptors.
- Created `api_client.dart` with a pre-configured `Dio` instance referencing local host (`http://10.0.2.2:8000`) with connect/receive timeouts and logging intercepts.
- Created `auth_service.dart` to dispatch requests to `/api/auth/login` and `/api/auth/register` endpoints.
- Appended mock auth handler endpoints `/api/auth/login` and `/api/auth/register` to the FastAPI backend (`backend/main.py`).
- Integrated dynamic workout routine loading in `CategoryWorkoutListScreen` by creating `workout_service.dart` connected to `/api/workouts/{category}` endpoint, replacing local mock lists with live API calls.
- Configured robust fallback logic within client services to run locally if network connection fails during development.

### V2.1: Gamification & Instructor Prestige System
- Created database models for UserBadge, InstructorBadge, and Instructor in `backend/models.py`.
- Updated User schema to include earned badges array, and added instructor reference fields (`instructor_id`, `instructor_name`, `instructor_badge_level`) to WorkoutRoutine database.
- Enhanced backend mock routines database in `backend/main.py` with specific instructor IDs and levels (Gold, Silver, Bronze).
- Created a reusable, premium-themed `badge_display.dart` widget in the frontend featuring metallic linear gradients, borders, and custom icons for Bronze, Silver, and Gold badges.
- Integrated the Instructor Credibility Overlay directly inside workout cards (`category_workout_list_screen.dart`), showing the instructor name alongside their metallic prestige level badge.
- Revamped the Profile page's scrollable badges section using the styled UserBadgeCard widgets.

### V2.2: Leaderboard & Social Competition
- Created database query logic for GET `/api/leaderboard` in `backend/main.py` with automatic connection failure fallback to populated mock users.
- Created `leaderboard_models.dart` and `social_service.dart` in the frontend client.
- Developed `leaderboard_screen.dart` with a premium neon dark aesthetic, featuring a Gold/Silver/Bronze top-3 podium layout with custom sizing and glowing effects.
- Added visual streak tracking indicators showing a neon fire/flame (`🔥`) tag next to users with 5+ day streaks.
- Designed a sticky "Senin Sıran" (Your Rank) footer highlighting the user's current ranking and point summary at the bottom.
- Registered the route `/leaderboard` in the shell routing branch and added it as a core tab in `MainLayout`.

### V2.3: Hoca-Sporcu İletişim Hattı
- Created the Pydantic `Message` model schema in `backend/models.py`.
- Developed message dispatch (`POST /api/messages/send`) and chat history query (`GET /api/messages/{trainer_id}`) routes in `backend/main.py`.
- Added mock push notification overlays when message exchanges occur and stored chats in local memory to ensure persistence during testing.
- Created `chat_models.dart` and `chat_service.dart` to handle message serialization and HTTP GET/POST calls.
- Developed `chat_screen.dart` featuring left/right bubble alignments (Turquoise/Dark bubbles), text submission controls, and automated trainer response triggers.
- Updated `TrainerDashboardScreen` to add the "Aktif Sporcularım" section, linking athlete list items directly to trainer-athlete direct chat rooms.
- Registered `/chat` route in `app_router.dart`.

### V2.4: Cloud Migration & Environment Setup
- Set up secure environmental variables in backend using `pydantic-settings` to load configuration from `.env`.
- Configured MongoDB connection logic in `backend/database.py` utilizing dynamic `MONGO_URI` connection strings.
- Implemented robust database connectivity status ping check on application startup using a FastAPI `lifespan` handler.
- Created `lib/core/config/env_config.dart` in Flutter to support a compile-mode environment switcher.
- Configured dynamic `baseUrl` mapping to route calls to local development emulator (`http://10.0.2.2:8000`) or production cloud backend (`https://akburak-spor-kulubu-backend.onrender.com`).
- Integrated dynamic environment settings into `lib/core/network/api_client.dart`.
- Added `Procfile` configurations for Render/Railway cloud web process execution (`uvicorn main:app --host 0.0.0.0 --port $PORT`).
- Explicitly pinned `bcrypt` in `backend/requirements.txt` for clean cloud container builds.

### V2.5: Security & Auth Hardening
- Integrated native `bcrypt` hashing for securing passwords on database write.
- Integrated `python-jose` for signed JWT token creation and validation using environment variables (`SECRET_KEY`).
- Developed database initialization module checking and populating the default admin user with a hashed password on startup.
- Refactored backend `/api/auth/register` and `/api/auth/login` to query MongoDB and handle JWT payload authentication.
- Added `flutter_secure_storage` to project dependencies and created a wrapper utility `SecureStorage`.
- Built a Dio request interceptor in `ApiClient` to dynamically attach token headers to all authenticated API calls.
- Integrated session management logic inside `AuthService` and updated profile screen logout flows to perform secure token revocation.

---

## Current Stage & Upcoming

We have completed the V2.5 milestone and are transitioning to:
- **Phase 4: Advanced Real-time Performance & Wearable Sync**

---

## Version Summary Table

| Version | Main Focus | Status |
| :--- | :--- | :--- |
| **V1.0** | Project Base, Routing, Navigation | ✅ Completed |
| **V1.2** | Workout Grids & Nested Lists Flow | ✅ Completed |
| **V1.3** | Custom Icons (Boxing Gloves) & Colors | ✅ Completed |
| **V1.4** | Workout Engine Controls | ✅ Completed |
| **V1.5** | Splash & Glove Clash Animations | ✅ Completed |
| **V1.6** | Sensory Feedback & AI Chatbot UI | ✅ Completed |
| **V1.7** | Python FastAPI & Async MongoDB API | ✅ Completed |
| **V1.8** | Trainer Dashboard & Video Sıkıştırma | ✅ Completed |
| **V1.82**| Advanced Timer & Workout Engine Visuals | ✅ Completed |
| **V1.9** | Onboarding & Auth UI | ✅ Completed |
| **V1.91**| Login Screen Polish | ✅ Completed |
| **V1.92**| Registration Flow Correction | ✅ Completed |
| **V1.93**| Dynamic Gender & BMI Avatars | ✅ Completed |
| **V2.0** | Full API Integration & Gamification | ✅ Completed |
| **V2.1** | Gamification & Instructor Prestige | ✅ Completed |
| **V2.2** | Leaderboard & Social Competition | ✅ Completed |
| **V2.3** | Hoca-Sporcu İletişim Hattı | ✅ Completed |
| **V2.4** | Cloud Migration & Environment Setup | ✅ Completed |
| **V2.5** | Security & Auth Hardening | ✅ Completed |
