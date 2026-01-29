# Fitness Tracker App

A complete Flutter mobile application for workout and nutrition tracking with automatic macro calculation.

## 🚀 Live Demo

**Backend API:** https://fitnessapp-production-ad23.up.railway.app
**Health Check:** https://fitnessapp-production-ad23.up.railway.app/health

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

- Go 1.24+ with Gin framework
- PostgreSQL with GORM
- RESTful API architecture
- JWT Authentification
- Docker

**Infrastructure:**

- Railway (hosting + DB)
- GitHub Actions (CI/CD)

**External APIs**

- [WGER API](https://wger.de/en/software/api) - Exercise database
- [Open Food Facts API](https://world.openfoodfacts.org/data) - Nutritional data

## 📱 Screenshots

[TODO: Add 3-4 key screenshots]

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Go 1.24+ ([install guide](https://go.dev/doc/install))
- PostgreSQL 14+ ([install guide](https://www.postgresql.org/download/))

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/Namirop/fitness_app.git
cd backend

# Install dependencies
go mod download

# Configure environment variables
cp .env.example .env
# Edit .env with your credentials:
# - DATABASE_URL: Your Railway or local PostgreSQL URL
# - JWT_SECRET: Generate a random key (32+ chars)
# - PORT: 3000 (or any available port)

# Migrations run automatically on startup
go run main.go

# Server runs on http://localhost:3000
# Test: curl http://localhost:3000/health
```

### Mobile App Setup

```bash
cd ../workout_app

# Install dependencies
flutter pub get

# Run app
flutter run

# Note: Update API URL in repositories to point to:
# - Local: http://10.0.2.2:3000 (Android emulator)
# - Prod: https://ton-app.up.railway.app
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

## 🌐 Production Deployment

**The production backend is already deployed on Railway:**

- API: https://ton-app.up.railway.app
- Database: Hosted on Railway PostgreSQL
- Auto-deploys on push to `main` branch

**No manual deployment needed** - just push your code!

## 📁 Project Structure

```

lib/
├── blocs/ # BLoC state management (events, states, business logic)
├── data/
│ ├── entities/ # Domain entities (business models)
│ ├── models/ # Data models (JSON serialization)
│ ├── repositories/ # Data access layer (API calls)
│ └── services/ # Business services (cache, calculations)
├── screens/ # UI screens and widgets
├── core/
│ ├── constants/ # App-wide constants
│ ├── enums/ # Enumerations
│ └── utils/ # Helper functions
└── main.dart # App entry point

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
- [ ] Barcode feature
- [ ] Dark mode
- [ ] Multi-language support (French/English)
- [ ] Progress statistics and charts

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👤 Author

**Romain Maes**

- GitHub: [@Namirop](https://github.com/Namirop)
- LinkedIn: www.linkedin.com/in/romainmaes
- Portfolio: https://romaindev.carrd.co/
