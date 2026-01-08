# Fitness Tracker App

A complete Flutter mobile application for workout and nutrition tracking with automatic macro calculation.

## ✨ Features

- **Workout Tracking**: Log exercises with sets, reps, and weights
- **Nutrition Tracking**: Daily calorie and macro tracking
- **Automatic Macro Calculation**: Based on user profile (weight, height, activity level, goals)
- **Workout Calendar**: Visual overview of training schedule
- **Local Cache**: Resume incomplete workouts seamlessly
- **Exercise Library**: 800+ exercises from WGER API
- **Food Database**: Nutritional data from Open Food Facts API

## 🛠️ Tech Stack

**Frontend**
- Flutter 3.x / Dart
- BLoC pattern for state management
- Hive for local caching
- Clean Architecture (entities/models/repositories)

**Backend**
- Go 1.21+ with Gin framework
- PostgreSQL with GORM
- RESTful API architecture

**External APIs**
- [WGER API](https://wger.de/en/software/api) - Exercise database
- [Open Food Facts API](https://world.openfoodfacts.org/data) - Nutritional data

## 📱 Screenshots

[TODO: Add 3-4 key screenshots]

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Go 1.21+ ([install guide](https://go.dev/doc/install))
- PostgreSQL 14+ ([install guide](https://www.postgresql.org/download/))

### 1. Backend Setup
```bash
# Clone the repository
git clone https://github.com/Namirop/fitness_app.git
cd backend

# Install dependencies
go mod download

# Create database
createdb fitness_app_db

# Configure environment variables
cp .env.example .env
# Edit .env with your database credentials

# Run migrations
go run main.go migrate

# Start server (default port: 3000)
go run main.go
```

### 2. Mobile App Setup
```bash
cd ../workout_app

# Install dependencies
flutter pub get

# Update backend URL in lib/data/repositories/*_repository.dart
# Change baseUrl from "http://10.0.2.2:3000" to your backend URL

# Run app
flutter run
```

## 📁 Project Structure
```
lib/
├── blocs/              # BLoC state management (events, states, business logic)
├── data/
│   ├── entities/       # Domain entities (business models)
│   ├── models/         # Data models (JSON serialization)
│   ├── repositories/   # Data access layer (API calls)
│   └── services/       # Business services (cache, calculations)
├── screens/            # UI screens and widgets
├── core/
│   ├── constants/      # App-wide constants
│   ├── enums/          # Enumerations
│   └── utils/          # Helper functions
└── main.dart           # App entry point
```

## 🎨 Technical Decisions

**Why BLoC Pattern?**
- Clear separation between UI and business logic
- Easier testing and debugging
- Better code organization for complex state management

**Why Go for Backend?**
- Excellent performance for REST APIs
- Simple deployment (single binary)
- Strong typing and built-in concurrency

**Why Not Firebase?**
- Full control over data and infrastructure
- No vendor lock-in
- Learning opportunity for backend development

**Why Clean Architecture?**
- Clear separation of concerns
- Easy to test individual layers
- Flexible to swap data sources (API, local DB, cache)

## 🗺️ Roadmap

- [x] Core MVP (workout + nutrition tracking)
- [ ] Barcode feature
- [ ] Dark mode
- [ ] Multi-language support (French/English)
- [ ] Progress statistics and charts

## 🐛 Known Issues

- Android emulator: Use `10.0.2.2` for localhost backend
- iOS simulator: Use `127.0.0.1` for localhost backend

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👤 Author

**Romain Maes**
- GitHub: [@Namirop](https://github.com/Namirop)
- LinkedIn: [TODO]
- Portfolio: [TODO]

---

Built with Flutter 💙 and Go 🐹