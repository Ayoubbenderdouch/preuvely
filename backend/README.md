# Preuvely Backend

A production-ready Laravel 12 backend for **Preuvely** - a trusted store reviews platform for Algeria.

## Tech Stack

- **Framework**: Laravel 12 (PHP 8.3+)
- **Database**: MySQL / SQLite
- **Admin Panel**: Filament v3
- **API Auth**: Laravel Sanctum (token-based)
- **Roles/Permissions**: spatie/laravel-permission
- **API Docs**: knuckleswtf/scribe
- **File Uploads**: Laravel Storage (public disk)

## Features

### Core Features
- User registration/login with email or phone
- Store directory with categories, links, and contacts
- Star rating (1-5) + comment reviews
- High-risk category handling (requires proof + admin approval)
- Store ownership claims and verification
- Store replies (only by verified store owners)
- Content reporting system

### Admin Panel (Filament)
- Dashboard with moderation stats
- Category management with high-risk toggle
- Store management (verify/suspend)
- Review moderation (approve/reject with reason)
- Proof approval for high-risk reviews
- Report handling
- User management with roles
- Audit logs

### Security Features
- Rate limiting (5 reviews/day per user)
- Privacy-safe IP/UA hashing (never stores raw IP)
- Profanity filter for user content
- Input validation and sanitization

## Installation

### Requirements
- PHP 8.3+
- Composer
- MySQL or SQLite
- Node.js (for asset compilation)

### Setup Steps

1. **Clone and install dependencies**
```bash
cd backend
composer install
```

2. **Environment configuration**
```bash
cp .env.example .env
php artisan key:generate
```

3. **Configure database**

Edit `.env` and set your database credentials:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=preuvely
DB_USERNAME=root
DB_PASSWORD=
```

Or use SQLite (default):
```env
DB_CONNECTION=sqlite
```

4. **Run migrations and seeders**
```bash
php artisan migrate --seed
```

5. **Create storage link**
```bash
php artisan storage:link
```

6. **Generate API documentation**
```bash
php artisan scribe:generate
```

7. **Start the development server**
```bash
php artisan serve
```

## Default Admin Account

After seeding, you can login to the admin panel with:
- **URL**: http://localhost:8000/admin
- **Email**: admin@preuvely.dz
- **Password**: password

## API Documentation

After running `php artisan scribe:generate`, access the docs at:
- **HTML Docs**: http://localhost:8000/docs
- **Postman Collection**: `public/docs/collection.json`
- **OpenAPI Spec**: `public/docs/openapi.yaml`

## API Endpoints

### Public
- `GET /api/v1/categories` - List categories
- `GET /api/v1/stores/search` - Search stores
- `GET /api/v1/stores/{slug}` - Get store details
- `GET /api/v1/stores/{store}/reviews` - Get approved reviews

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/logout` - Logout (authenticated)
- `GET /api/v1/auth/me` - Get current user (authenticated)

### Authenticated
- `POST /api/v1/stores` - Create store
- `POST /api/v1/stores/{store}/reviews` - Submit review
- `POST /api/v1/reviews/{review}/proof` - Upload proof
- `POST /api/v1/reviews/{review}/reply` - Reply to review (owner only)
- `POST /api/v1/stores/{store}/claim` - Claim ownership
- `POST /api/v1/reports` - Submit report

## Running Tests

```bash
php artisan test
```

Or run specific test files:
```bash
php artisan test tests/Feature/ReviewTest.php
php artisan test tests/Feature/StoreReplyTest.php
php artisan test tests/Feature/RateLimitTest.php
php artisan test tests/Feature/ReportTest.php
php artisan test tests/Feature/AuthTest.php
```

## Business Rules

1. **One review per store per user** - Users can only submit one review per store
2. **High-risk categories** - Reviews require proof upload and admin approval
3. **Verified store replies** - Only verified store owners can reply to reviews
4. **Rate limiting** - Max 5 reviews per day per user
5. **Privacy** - IP addresses are hashed, never stored raw

## Directory Structure

```
app/
├── Enums/              # PHP 8.1+ enums for statuses
├── Filament/           # Admin panel resources
├── Http/
│   ├── Controllers/Api/V1/   # API controllers
│   ├── Requests/Api/V1/      # Form request validation
│   └── Resources/Api/V1/     # API resource transformers
├── Models/             # Eloquent models
├── Policies/           # Authorization policies
└── Services/           # Business logic services

config/
├── moderation.php      # Profanity filter & rate limits
└── scribe.php          # API documentation config

database/
├── factories/          # Model factories for testing
├── migrations/         # Database migrations
└── seeders/            # Database seeders
```

## Configuration

### Moderation Settings

Edit `config/moderation.php` to customize:
- Banned words list for profanity filter
- Rate limits for reviews and stores

### Environment Variables

Key environment variables:
```env
APP_URL=http://localhost:8000
DB_CONNECTION=mysql
SCRIBE_AUTH_KEY=your-test-token
```

## License

This project is proprietary software.
