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

## 🚀 Live Demo

**Backend API:** [https://fitnessapp-production-ad23.up.railway.app](https://fitnessapp-production-ad23.up.railway.app)

**Health Check:** [https://fitnessapp-production-ad23.up.railway.app/health](https://fitnessapp-production-ad23.up.railway.app/health)

## 🛠️ Tech Stack

**Frontend**
- Flutter 3.x / Dart
- BLoC pattern for state management
- Hive for local caching
- Clean Architecture (entities/models/repositories)

**Backend**
- Go 1.24+ with Gin framework
- PostgreSQL with GORM
- RESTful API architecture
- JWT authentication
- Docker

**Infrastructure:**
- Railway (hosting + DB)
- GitHub Actions (CI/CD)

**External APIs**
- [WGER API](https://wger.de/en/software/api) - Exercise database
- [Open Food Facts API](https://world.openfoodfacts.org/data) - Nutritional data

## 📱 Screenshots

<img width="240" height="600" alt="main screen" src="https://github.com/user-attachments/assets/9c3c3528-90ed-44ae-87f2-7ff01c45f994" />
<img width="240" height="600" alt="add screen" src="https://github.com/user-attachments/assets/ffe8d884-6ba0-4278-a293-9d4dbf3757b3" />
<img width="240" height="600" alt="calendar screen" src="https://github.com/user-attachments/assets/7dd1eab8-942f-48a1-8cf3-3981810c15c0" />
<img width="240" height="600" alt="nutrition day" src="https://github.com/user-attachments/assets/16cff14d-25c6-4301-96e6-5794acf5ab58" />


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

# Configure environment variables
cp .env.example .env
# Edit .env:
# DATABASE_URL: Your Railway or local PostgreSQL URL
# JWT_SECRET: Generate a random key (32+ chars)
# PORT: 3000 (or any available port)

# Migrations run automatically on startup
go run main.go

# Server runs on http://localhost:3000
# Test: curl http://localhost:3000/health
```

### 2. Mobile App Setup
```bash
cd ../workout_app

# Install dependencies
flutter pub get

# Run on emulator/device
flutter run

# Note: Update API URL in repositories to point to:
# - Local: http://10.0.2.2:3000 (Android emulator)
# - Prod: https://fitnessapp-production-ad23.up.railway.app
```

## 🐳 Docker

### Build & Run
```bash
cd backend
docker build -t fitness-backend .
docker run -p 3000:3000 \
  -e DATABASE_URL="your-db-url" \
  -e JWT_SECRET="your-secret" \
  -e PORT=3000 \
  fitness-backend
```

## 🌐 Production

**The production backend is already deployed on Railway:**
- API: https://fitnessapp-production-ad23.up.railway.app
- Database: Hosted on Railway PostgreSQL
- Auto-deploys on push to `main` branch

**No manual deployment needed** - just push your code!

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

## 🔒 Security
- ✅ Hashed passwords (bcrypt)
- ✅ JWT with expiration (72 hours)
- ✅ Data isolation by user_id
- ✅ Sensitive variables in environment
- ✅ HTTPS in production (Railway)

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
- [ ] Authentification screens
- [ ] Barcode feature
- [ ] Dark mode
- [ ] Multi-language support (French/English)

## 🐛 Known Issues

- Android emulator: Use `10.0.2.2` for localhost backend
- iOS simulator: Use `127.0.0.1` for localhost backend

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👤 Author

**Romain Maes**
- GitHub: [@Namirop](https://github.com/Namirop)
- LinkedIn: [https://www.linkedin.com/in/romainmaes/](https://www.linkedin.com/in/romainmaes/)
- Portfolio: [https://romaindev.carrd.co/](https://romaindev.carrd.co/)

---

Built with Flutter 💙 and Go 🐹
