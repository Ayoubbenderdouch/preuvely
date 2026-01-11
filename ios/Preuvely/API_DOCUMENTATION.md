# Preuvely API Documentation

**Version:** 1.0
**Base URL:** `https://api.preuvely.com/api`
**Content-Type:** `application/json`

---

## Table of Contents

1. [Authentication](#authentication)
2. [User](#user)
3. [Stores](#stores)
4. [Reviews](#reviews)
5. [Claims](#claims)
6. [Reports](#reports)
7. [Notifications](#notifications)
8. [Data Models](#data-models)
9. [Error Handling](#error-handling)

---

## Authentication

All authenticated endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

### POST /api/auth/register

Register a new user account.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Ahmed Benali",
  "email": "ahmed@example.com",
  "password": "securePassword123",
  "password_confirmation": "securePassword123"
}
```

**Success Response (201 Created):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "Ahmed Benali",
      "email": "ahmed@example.com",
      "phone": null,
      "email_verified": false,
      "created_at": "2025-01-15T10:30:00Z"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 86400
  },
  "message": "Registration successful. Please verify your email."
}
```

**Error Responses:**

*400 Bad Request - Validation Error:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": ["The email has already been taken."],
      "password": ["The password must be at least 8 characters."]
    }
  }
}
```

*422 Unprocessable Entity:*
```json
{
  "error": {
    "code": "UNPROCESSABLE_ENTITY",
    "message": "The given data was invalid."
  }
}
```

---

### POST /api/auth/login

Authenticate user with email and password.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "ahmed@example.com",
  "password": "securePassword123"
}
```

**Success Response (200 OK):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "Ahmed Benali",
      "email": "ahmed@example.com",
      "phone": "+213555123456",
      "email_verified": true,
      "created_at": "2025-01-15T10:30:00Z"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 86400
  },
  "message": "Login successful"
}
```

**Error Responses:**

*401 Unauthorized - Invalid Credentials:*
```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  }
}
```

*403 Forbidden - Email Not Verified:*
```json
{
  "error": {
    "code": "EMAIL_NOT_VERIFIED",
    "message": "Please verify your email before logging in"
  }
}
```

---

### POST /api/auth/logout

Logout the current user and invalidate the access token.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:** None

**Success Response (200 OK):**
```json
{
  "message": "Successfully logged out"
}
```

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

### POST /api/auth/social

Authenticate user via social provider (Google or Apple).

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "provider": "google",
  "token": "social_provider_oauth_token_here",
  "name": "Ahmed Benali"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| provider | string | Yes | Social provider: `google` or `apple` |
| token | string | Yes | OAuth token from the social provider |
| name | string | No | User's name (optional, used for new registrations) |

**Success Response (200 OK):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "Ahmed Benali",
      "email": "ahmed@gmail.com",
      "phone": null,
      "email_verified": true,
      "created_at": "2025-01-15T10:30:00Z"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 86400,
    "is_new_user": false
  },
  "message": "Social login successful"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "INVALID_PROVIDER",
    "message": "Invalid social provider"
  }
}
```

*401 Unauthorized:*
```json
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Social authentication failed"
  }
}
```

---

### POST /api/auth/verify-email

Verify user's email address using the verification token.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "token": "email_verification_token_here"
}
```

**Success Response (200 OK):**
```json
{
  "message": "Email verified successfully"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Invalid or expired verification token"
  }
}
```

*404 Not Found:*
```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User not found"
  }
}
```

---

### POST /api/auth/resend-verification

Resend the email verification link.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:** None (uses authenticated user's email)

**Success Response (200 OK):**
```json
{
  "message": "Verification email sent successfully"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "ALREADY_VERIFIED",
    "message": "Email is already verified"
  }
}
```

*429 Too Many Requests:*
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Please wait before requesting another verification email",
    "retry_after": 60
  }
}
```

---

## User

### GET /api/user/profile

Get the authenticated user's profile.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "name": "Ahmed Benali",
    "email": "ahmed@example.com",
    "phone": "+213555123456",
    "email_verified": true,
    "created_at": "2025-01-15T10:30:00Z",
    "profile_photo_url": "https://api.preuvely.com/storage/avatars/user_1.jpg",
    "reviews_count": 12,
    "claims_count": 2
  }
}
```

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

### PUT /api/user/profile

Update the authenticated user's profile.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Ahmed B. Benali",
  "phone": "+213555654321"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | No | User's display name (min: 2, max: 100 characters) |
| phone | string | No | Phone number (E.164 format recommended) |

**Success Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "name": "Ahmed B. Benali",
    "email": "ahmed@example.com",
    "phone": "+213555654321",
    "email_verified": true,
    "created_at": "2025-01-15T10:30:00Z",
    "profile_photo_url": "https://api.preuvely.com/storage/avatars/user_1.jpg"
  },
  "message": "Profile updated successfully"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "name": ["The name must be at least 2 characters."]
    }
  }
}
```

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

### POST /api/user/profile/photo

Upload or update the user's profile photo.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Request Body (multipart/form-data):**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| photo | file | Yes | Image file (JPEG, PNG, max 5MB) |

**Success Response (200 OK):**
```json
{
  "data": {
    "profile_photo_url": "https://api.preuvely.com/storage/avatars/user_1_1705312200.jpg"
  },
  "message": "Profile photo updated successfully"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "photo": ["The photo must be an image.", "The photo may not be greater than 5120 kilobytes."]
    }
  }
}
```

*413 Payload Too Large:*
```json
{
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "The uploaded file exceeds the maximum allowed size"
  }
}
```

---

## Stores

### GET /api/stores

Get a paginated list of stores with optional search and filters.

**Request Headers:**
```
Authorization: Bearer <access_token> (optional)
```

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| query | string | No | - | Search query for store name |
| category | string | No | - | Category slug filter (e.g., `fashion`, `electronics`) |
| verified_only | boolean | No | false | Filter to only verified stores |
| sort_by | string | No | `best_rated` | Sort option: `best_rated`, `most_reviewed`, `newest` |
| page | integer | No | 1 | Page number for pagination |
| per_page | integer | No | 20 | Items per page (max: 50) |

**Example Request:**
```
GET /api/stores?query=tech&category=phones-electronics&verified_only=true&sort_by=best_rated&page=1&per_page=20
```

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "TechZone DZ",
      "slug": "techzone-dz",
      "description": "Your trusted electronics store in Algeria. We offer the latest smartphones, laptops, and accessories with warranty.",
      "city": "Algiers",
      "is_verified": true,
      "avg_rating": 4.7,
      "reviews_count": 234,
      "categories": [
        {
          "id": 1,
          "name": "Phones & Electronics",
          "name_ar": "هواتف وإلكترونيات",
          "name_fr": "Téléphones & Électronique",
          "slug": "phones-electronics",
          "icon": "phones",
          "is_high_risk": false,
          "stores_count": 234
        }
      ],
      "links": [
        {
          "id": 1,
          "platform": "instagram",
          "url": "https://instagram.com/techzone.dz",
          "handle": "@techzone.dz"
        },
        {
          "id": 2,
          "platform": "facebook",
          "url": "https://facebook.com/techzonedz",
          "handle": null
        }
      ],
      "contacts": {
        "whatsapp": "+213555123456",
        "phone": "+213555123456"
      },
      "created_at": "2025-01-10T08:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 12,
    "per_page": 20,
    "total": 234
  }
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "sort_by": ["The selected sort_by is invalid."]
    }
  }
}
```

---

### GET /api/stores/{id}

Get detailed information about a specific store.

**Request Headers:**
```
Authorization: Bearer <access_token> (optional)
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer or string | Store ID or slug |

**Success Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "name": "TechZone DZ",
    "slug": "techzone-dz",
    "description": "Your trusted electronics store in Algeria. We offer the latest smartphones, laptops, and accessories with warranty.",
    "city": "Algiers",
    "is_verified": true,
    "avg_rating": 4.7,
    "reviews_count": 234,
    "categories": [
      {
        "id": 1,
        "name": "Phones & Electronics",
        "name_ar": "هواتف وإلكترونيات",
        "name_fr": "Téléphones & Électronique",
        "slug": "phones-electronics",
        "icon": "phones",
        "is_high_risk": false,
        "stores_count": 234
      }
    ],
    "links": [
      {
        "id": 1,
        "platform": "instagram",
        "url": "https://instagram.com/techzone.dz",
        "handle": "@techzone.dz"
      },
      {
        "id": 2,
        "platform": "facebook",
        "url": "https://facebook.com/techzonedz",
        "handle": null
      }
    ],
    "contacts": {
      "whatsapp": "+213555123456",
      "phone": "+213555123456"
    },
    "summary": {
      "avg_rating": 4.7,
      "reviews_count": 234,
      "is_verified": true,
      "rating_breakdown": {
        "1": 5,
        "2": 8,
        "3": 21,
        "4": 78,
        "5": 122
      },
      "proof_badge": true
    },
    "created_at": "2025-01-10T08:00:00Z"
  }
}
```

**Error Responses:**

*404 Not Found:*
```json
{
  "error": {
    "code": "STORE_NOT_FOUND",
    "message": "Store not found"
  }
}
```

---

### POST /api/stores

Create a new store listing.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "My Tech Store",
  "description": "Premium electronics and gadgets",
  "city": "Oran",
  "category_ids": [1, 4],
  "links": [
    {
      "platform": "instagram",
      "url": "https://instagram.com/mytechstore",
      "handle": "@mytechstore"
    },
    {
      "platform": "website",
      "url": "https://mytechstore.dz",
      "handle": null
    }
  ],
  "contacts": {
    "whatsapp": "+213555999888",
    "phone": "+213555999888"
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Store name (min: 2, max: 100 characters) |
| description | string | No | Store description (max: 1000 characters) |
| city | string | No | City location |
| category_ids | array | Yes | Array of category IDs (at least 1) |
| links | array | Yes | Array of store links (at least 1) |
| links[].platform | string | Yes | Platform: `instagram`, `facebook`, `tiktok`, `website`, `whatsapp` |
| links[].url | string | Yes | Full URL to the store's page |
| links[].handle | string | No | Social media handle |
| contacts | object | No | Contact information |
| contacts.whatsapp | string | No | WhatsApp number |
| contacts.phone | string | No | Phone number |

**Success Response (201 Created):**
```json
{
  "data": {
    "id": 100,
    "name": "My Tech Store",
    "slug": "my-tech-store",
    "description": "Premium electronics and gadgets",
    "city": "Oran",
    "is_verified": false,
    "avg_rating": 0,
    "reviews_count": 0,
    "categories": [...],
    "links": [...],
    "contacts": {
      "whatsapp": "+213555999888",
      "phone": "+213555999888"
    },
    "created_at": "2025-01-15T14:30:00Z"
  },
  "message": "Store created successfully"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "name": ["The name field is required."],
      "links": ["At least one link is required."],
      "links.0.platform": ["The selected platform is invalid."]
    }
  }
}
```

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

*409 Conflict:*
```json
{
  "error": {
    "code": "STORE_EXISTS",
    "message": "A store with this name or URL already exists"
  }
}
```

---

### GET /api/stores/categories

Get all available store categories.

**Request Headers:** None required

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Phones & Electronics",
      "name_ar": "هواتف وإلكترونيات",
      "name_fr": "Téléphones & Électronique",
      "slug": "phones-electronics",
      "icon": "phones",
      "is_high_risk": false,
      "stores_count": 234
    },
    {
      "id": 2,
      "name": "Fashion",
      "name_ar": "أزياء",
      "name_fr": "Mode",
      "slug": "fashion",
      "icon": "fashion",
      "is_high_risk": false,
      "stores_count": 456
    },
    {
      "id": 3,
      "name": "Beauty & Perfume",
      "name_ar": "جمال وعطور",
      "name_fr": "Beauté & Parfum",
      "slug": "beauty-perfume",
      "icon": "beauty",
      "is_high_risk": false,
      "stores_count": 312
    },
    {
      "id": 4,
      "name": "Digital Services",
      "name_ar": "خدمات رقمية",
      "name_fr": "Services Numériques",
      "slug": "digital-services",
      "icon": "digital",
      "is_high_risk": true,
      "stores_count": 156
    },
    {
      "id": 5,
      "name": "Credits & E-Payments",
      "name_ar": "رصيد ودفع إلكتروني",
      "name_fr": "Crédits & Paiements",
      "slug": "credits-payments",
      "icon": "credits",
      "is_high_risk": true,
      "stores_count": 134
    },
    {
      "id": 6,
      "name": "Food & Restaurants",
      "name_ar": "طعام ومطاعم",
      "name_fr": "Nourriture & Restaurants",
      "slug": "food-restaurants",
      "icon": "food",
      "is_high_risk": false,
      "stores_count": 189
    },
    {
      "id": 7,
      "name": "Kids & Toys",
      "name_ar": "أطفال وألعاب",
      "name_fr": "Enfants & Jouets",
      "slug": "kids-toys",
      "icon": "kids",
      "is_high_risk": false,
      "stores_count": 145
    },
    {
      "id": 8,
      "name": "Supplements & Health",
      "name_ar": "مكملات وصحة",
      "name_fr": "Suppléments & Santé",
      "slug": "supplements-health",
      "icon": "supplements",
      "is_high_risk": true,
      "stores_count": 87
    }
  ]
}
```

---

## Reviews

### GET /api/stores/{id}/reviews

Get paginated reviews for a specific store.

**Request Headers:**
```
Authorization: Bearer <access_token> (optional)
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | Store ID |

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | integer | No | 1 | Page number |
| per_page | integer | No | 20 | Items per page (max: 50) |

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "store_id": 1,
      "user_id": 1,
      "user_name": "Ahmed B.",
      "stars": 5,
      "comment": "Excellent service! I bought an iPhone and the delivery was fast. The product was original and sealed. Highly recommended!",
      "status": "approved",
      "is_high_risk": false,
      "has_proof": false,
      "proof": null,
      "reply": {
        "id": 1,
        "reply_text": "Thank you Ahmed! We're glad you're happy with your purchase. Welcome back anytime!",
        "user_name": "TechZone Team",
        "created_at": "2025-01-14T10:30:00Z"
      },
      "created_at": "2025-01-13T08:00:00Z"
    },
    {
      "id": 3,
      "store_id": 1,
      "user_id": 3,
      "user_name": "Karim L.",
      "stars": 5,
      "comment": "Best crypto exchange in Algeria! Fast transactions and great rates.",
      "status": "approved",
      "is_high_risk": true,
      "has_proof": true,
      "proof": {
        "id": 1,
        "url": "https://api.preuvely.com/storage/proofs/proof_1.jpg",
        "status": "approved",
        "created_at": "2025-01-12T14:00:00Z"
      },
      "reply": null,
      "created_at": "2025-01-11T15:30:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 12,
    "per_page": 20,
    "total": 234
  }
}
```

**Error Responses:**

*404 Not Found:*
```json
{
  "error": {
    "code": "STORE_NOT_FOUND",
    "message": "Store not found"
  }
}
```

---

### POST /api/stores/{id}/reviews

Create a review for a store.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | Store ID |

**Request Body:**
```json
{
  "stars": 5,
  "comment": "Great store! Fast delivery and excellent customer service. The products are original and well packaged."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| stars | integer | Yes | Rating from 1 to 5 |
| comment | string | Yes | Review text (min: 10, max: 1000 characters) |

**Success Response (201 Created):**
```json
{
  "data": {
    "id": 100,
    "store_id": 1,
    "user_id": 5,
    "user_name": "User",
    "stars": 5,
    "comment": "Great store! Fast delivery and excellent customer service. The products are original and well packaged.",
    "status": "pending",
    "is_high_risk": false,
    "has_proof": false,
    "proof": null,
    "reply": null,
    "created_at": "2025-01-15T16:00:00Z"
  },
  "message": "Review submitted successfully"
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "stars": ["The stars must be between 1 and 5."],
      "comment": ["The comment must be at least 10 characters."]
    }
  }
}
```

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

*403 Forbidden:*
```json
{
  "error": {
    "code": "EMAIL_NOT_VERIFIED",
    "message": "Please verify your email before posting reviews"
  }
}
```

*404 Not Found:*
```json
{
  "error": {
    "code": "STORE_NOT_FOUND",
    "message": "Store not found"
  }
}
```

*409 Conflict:*
```json
{
  "error": {
    "code": "REVIEW_EXISTS",
    "message": "You have already reviewed this store"
  }
}
```

---

### POST /api/reviews/{id}/proof

Upload proof image for a review (e.g., purchase receipt, delivery confirmation).

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | Review ID |

**Request Body (multipart/form-data):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| image | file | Yes | Proof image (JPEG, PNG, max 10MB) |

**Success Response (200 OK):**
```json
{
  "data": {
    "id": 50,
    "url": "https://api.preuvely.com/storage/proofs/proof_50.jpg",
    "status": "pending",
    "created_at": "2025-01-15T16:30:00Z"
  },
  "message": "Proof uploaded successfully. It will be reviewed shortly."
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "image": ["The image must be a valid image file.", "The image may not be greater than 10240 kilobytes."]
    }
  }
}
```

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

*403 Forbidden:*
```json
{
  "error": {
    "code": "NOT_REVIEW_OWNER",
    "message": "You can only upload proof for your own reviews"
  }
}
```

*404 Not Found:*
```json
{
  "error": {
    "code": "REVIEW_NOT_FOUND",
    "message": "Review not found"
  }
}
```

*409 Conflict:*
```json
{
  "error": {
    "code": "PROOF_EXISTS",
    "message": "Proof has already been uploaded for this review"
  }
}
```

---

### GET /api/user/reviews

Get all reviews submitted by the authenticated user.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | integer | No | 1 | Page number |
| per_page | integer | No | 20 | Items per page (max: 50) |

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "store_id": 1,
      "store_name": "TechZone DZ",
      "store_slug": "techzone-dz",
      "user_id": 5,
      "user_name": "Ahmed B.",
      "stars": 5,
      "comment": "Excellent service! I bought an iPhone and the delivery was fast.",
      "status": "approved",
      "is_high_risk": false,
      "has_proof": true,
      "proof": {
        "id": 1,
        "url": "https://api.preuvely.com/storage/proofs/proof_1.jpg",
        "status": "approved",
        "created_at": "2025-01-13T09:00:00Z"
      },
      "reply": {
        "id": 1,
        "reply_text": "Thank you Ahmed!",
        "user_name": "TechZone Team",
        "created_at": "2025-01-14T10:30:00Z"
      },
      "created_at": "2025-01-13T08:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 20,
    "total": 5
  }
}
```

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

## Claims

### POST /api/stores/{id}/claim

Submit a claim to become the owner of a store.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | Store ID |

**Request Body:**
```json
{
  "owner_name": "Ahmed Benali",
  "phone": "+213555123456",
  "note": "I am the owner of this store since 2020. I can provide business registration documents."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| owner_name | string | Yes | Full name of the store owner |
| phone | string | Yes | Contact phone number |
| note | string | No | Additional information to support the claim |

**Success Response (201 Created):**
```json
{
  "data": {
    "id": 10,
    "store_id": 1,
    "store_name": "TechZone DZ",
    "user_id": 5,
    "owner_name": "Ahmed Benali",
    "phone": "+213555123456",
    "note": "I am the owner of this store since 2020. I can provide business registration documents.",
    "status": "pending",
    "created_at": "2025-01-15T17:00:00Z"
  },
  "message": "Claim submitted successfully. We will review it shortly."
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "owner_name": ["The owner name field is required."],
      "phone": ["The phone field is required."]
    }
  }
}
```

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

*403 Forbidden:*
```json
{
  "error": {
    "code": "EMAIL_NOT_VERIFIED",
    "message": "Please verify your email before claiming stores"
  }
}
```

*404 Not Found:*
```json
{
  "error": {
    "code": "STORE_NOT_FOUND",
    "message": "Store not found"
  }
}
```

*409 Conflict:*
```json
{
  "error": {
    "code": "CLAIM_EXISTS",
    "message": "You already have a pending claim for this store"
  }
}
```

*409 Conflict:*
```json
{
  "error": {
    "code": "STORE_ALREADY_CLAIMED",
    "message": "This store has already been claimed by another user"
  }
}
```

---

### GET /api/user/claims

Get all claims submitted by the authenticated user.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "store_id": 1,
      "store_name": "TechZone DZ",
      "user_id": 5,
      "owner_name": "Ahmed Benali",
      "phone": "+213555123456",
      "note": "I am the owner of this store since 2020.",
      "status": "approved",
      "created_at": "2025-01-08T10:00:00Z"
    },
    {
      "id": 2,
      "store_id": 3,
      "store_name": "Beauty Queen",
      "user_id": 5,
      "owner_name": "Ahmed Benali",
      "phone": "+213555123456",
      "note": null,
      "status": "pending",
      "created_at": "2025-01-13T14:00:00Z"
    },
    {
      "id": 3,
      "store_id": 5,
      "store_name": "Home Decor Plus",
      "user_id": 5,
      "owner_name": "Ahmed Benali",
      "phone": "+213555123456",
      "note": "Previous claim - incorrect information provided",
      "status": "rejected",
      "created_at": "2025-01-01T09:00:00Z"
    }
  ]
}
```

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

## Reports

### POST /api/reports

Submit a report for a store or review.

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "reportable_type": "store",
  "reportable_id": 5,
  "reason": "scam",
  "note": "This store never delivered my order and stopped responding to messages."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| reportable_type | string | Yes | Type of item to report: `store` or `review` |
| reportable_id | integer | Yes | ID of the store or review |
| reason | string | Yes | Reason for report: `spam`, `inappropriate`, `fake`, `scam`, `other` |
| note | string | No | Additional details about the report |

**Success Response (201 Created):**
```json
{
  "data": {
    "id": 25,
    "user_id": 5,
    "reportable_type": "store",
    "reportable_id": 5,
    "reportable_name": "Home Decor Plus",
    "reason": "scam",
    "note": "This store never delivered my order and stopped responding to messages.",
    "status": "pending",
    "created_at": "2025-01-15T18:00:00Z"
  },
  "message": "Report submitted successfully. We will review it shortly."
}
```

**Error Responses:**

*400 Bad Request:*
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "reportable_type": ["The selected reportable type is invalid."],
      "reason": ["The selected reason is invalid."]
    }
  }
}
```

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

*404 Not Found:*
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "The store or review you are trying to report was not found"
  }
}
```

*409 Conflict:*
```json
{
  "error": {
    "code": "REPORT_EXISTS",
    "message": "You have already reported this item"
  }
}
```

---

### GET /api/user/reports

Get all reports submitted by the authenticated user.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "user_id": 5,
      "reportable_type": "store",
      "reportable_id": 5,
      "reportable_name": "Home Decor Plus",
      "reason": "scam",
      "note": "This store never delivered my order and stopped responding.",
      "status": "pending",
      "created_at": "2025-01-14T12:00:00Z"
    },
    {
      "id": 2,
      "user_id": 5,
      "reportable_type": "review",
      "reportable_id": 4,
      "reportable_name": "Review by Mohamed R.",
      "reason": "fake",
      "note": "This review seems fake - user never purchased from this store.",
      "status": "resolved",
      "created_at": "2025-01-08T09:00:00Z"
    }
  ]
}
```

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

## Notifications

### GET /api/notifications

Get paginated list of notifications for the authenticated user.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | integer | No | 1 | Page number |
| per_page | integer | No | 20 | Items per page (max: 50) |
| unread_only | boolean | No | false | Filter to only unread notifications |

**Success Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "type": "review_approved",
      "title": "Review Approved",
      "message": "Your review for TechZone DZ has been approved.",
      "data": {
        "store_id": 1,
        "store_slug": "techzone-dz",
        "review_id": 100
      },
      "is_read": false,
      "created_at": "2025-01-15T10:00:00Z"
    },
    {
      "id": 2,
      "type": "claim_approved",
      "title": "Claim Approved",
      "message": "Your claim for TechZone DZ has been approved. You are now the verified owner.",
      "data": {
        "store_id": 1,
        "store_slug": "techzone-dz",
        "claim_id": 10
      },
      "is_read": true,
      "created_at": "2025-01-14T15:00:00Z"
    },
    {
      "id": 3,
      "type": "proof_approved",
      "title": "Proof Approved",
      "message": "Your proof for the review has been verified.",
      "data": {
        "store_id": 1,
        "review_id": 100,
        "proof_id": 50
      },
      "is_read": true,
      "created_at": "2025-01-14T12:00:00Z"
    },
    {
      "id": 4,
      "type": "store_reply",
      "title": "Store Replied",
      "message": "TechZone DZ replied to your review.",
      "data": {
        "store_id": 1,
        "store_slug": "techzone-dz",
        "review_id": 100,
        "reply_id": 5
      },
      "is_read": false,
      "created_at": "2025-01-14T11:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 2,
    "per_page": 20,
    "total": 25,
    "unread_count": 5
  }
}
```

**Notification Types:**

| Type | Description |
|------|-------------|
| `review_approved` | User's review was approved |
| `review_rejected` | User's review was rejected |
| `proof_approved` | User's proof was approved |
| `proof_rejected` | User's proof was rejected |
| `claim_approved` | User's store claim was approved |
| `claim_rejected` | User's store claim was rejected |
| `store_reply` | Store owner replied to user's review |
| `report_resolved` | User's report was resolved |
| `new_review` | New review on user's claimed store |

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

### PUT /api/notifications/{id}/read

Mark a specific notification as read.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | Notification ID |

**Request Body:** None

**Success Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "type": "review_approved",
    "title": "Review Approved",
    "message": "Your review for TechZone DZ has been approved.",
    "data": {
      "store_id": 1,
      "store_slug": "techzone-dz",
      "review_id": 100
    },
    "is_read": true,
    "created_at": "2025-01-15T10:00:00Z"
  },
  "message": "Notification marked as read"
}
```

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

*403 Forbidden:*
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You can only update your own notifications"
  }
}
```

*404 Not Found:*
```json
{
  "error": {
    "code": "NOTIFICATION_NOT_FOUND",
    "message": "Notification not found"
  }
}
```

---

### PUT /api/notifications/read-all

Mark all notifications as read for the authenticated user.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:** None

**Success Response (200 OK):**
```json
{
  "message": "All notifications marked as read",
  "count": 5
}
```

**Error Responses:**

*401 Unauthorized:*
```json
{
  "error": {
    "code": "UNAUTHENTICATED",
    "message": "Unauthenticated"
  }
}
```

---

## Data Models

### User

```json
{
  "id": 1,
  "name": "Ahmed Benali",
  "email": "ahmed@example.com",
  "phone": "+213555123456",
  "email_verified": true,
  "created_at": "2025-01-15T10:30:00Z"
}
```

### Store

```json
{
  "id": 1,
  "name": "TechZone DZ",
  "slug": "techzone-dz",
  "description": "Your trusted electronics store in Algeria.",
  "city": "Algiers",
  "is_verified": true,
  "avg_rating": 4.7,
  "reviews_count": 234,
  "categories": [Category],
  "links": [StoreLink],
  "contacts": StoreContact,
  "created_at": "2025-01-10T08:00:00Z"
}
```

### StoreLink

```json
{
  "id": 1,
  "platform": "instagram",
  "url": "https://instagram.com/techzone.dz",
  "handle": "@techzone.dz"
}
```

**Platform Values:** `instagram`, `facebook`, `tiktok`, `website`, `whatsapp`

### StoreContact

```json
{
  "whatsapp": "+213555123456",
  "phone": "+213555123456"
}
```

### Category

```json
{
  "id": 1,
  "name": "Phones & Electronics",
  "name_ar": "هواتف وإلكترونيات",
  "name_fr": "Téléphones & Électronique",
  "slug": "phones-electronics",
  "icon": "phones",
  "is_high_risk": false,
  "stores_count": 234
}
```

### StoreSummary

```json
{
  "avg_rating": 4.7,
  "reviews_count": 234,
  "is_verified": true,
  "rating_breakdown": {
    "1": 5,
    "2": 8,
    "3": 21,
    "4": 78,
    "5": 122
  },
  "proof_badge": true
}
```

### Review

```json
{
  "id": 1,
  "store_id": 1,
  "user_id": 1,
  "user_name": "Ahmed B.",
  "stars": 5,
  "comment": "Excellent service!",
  "status": "approved",
  "is_high_risk": false,
  "has_proof": true,
  "proof": Proof,
  "reply": StoreReply,
  "created_at": "2025-01-13T08:00:00Z"
}
```

**Status Values:** `pending`, `approved`, `rejected`

### Proof

```json
{
  "id": 1,
  "url": "https://api.preuvely.com/storage/proofs/proof_1.jpg",
  "status": "approved",
  "created_at": "2025-01-13T09:00:00Z"
}
```

**Status Values:** `pending`, `approved`, `rejected`

### StoreReply

```json
{
  "id": 1,
  "reply_text": "Thank you for your review!",
  "user_name": "TechZone Team",
  "created_at": "2025-01-14T10:30:00Z"
}
```

### Claim

```json
{
  "id": 1,
  "store_id": 1,
  "store_name": "TechZone DZ",
  "user_id": 5,
  "owner_name": "Ahmed Benali",
  "phone": "+213555123456",
  "note": "I am the owner of this store.",
  "status": "approved",
  "created_at": "2025-01-08T10:00:00Z"
}
```

**Status Values:** `pending`, `approved`, `rejected`

### Report

```json
{
  "id": 1,
  "user_id": 5,
  "reportable_type": "store",
  "reportable_id": 5,
  "reportable_name": "Home Decor Plus",
  "reason": "scam",
  "note": "This store never delivered my order.",
  "status": "pending",
  "created_at": "2025-01-14T12:00:00Z"
}
```

**Reportable Type Values:** `store`, `review`

**Reason Values:** `spam`, `inappropriate`, `fake`, `scam`, `other`

**Status Values:** `pending`, `resolved`, `dismissed`

### Notification

```json
{
  "id": 1,
  "type": "review_approved",
  "title": "Review Approved",
  "message": "Your review for TechZone DZ has been approved.",
  "data": {
    "store_id": 1,
    "store_slug": "techzone-dz",
    "review_id": 100
  },
  "is_read": false,
  "created_at": "2025-01-15T10:00:00Z"
}
```

### PaginationMeta

```json
{
  "current_page": 1,
  "last_page": 12,
  "per_page": 20,
  "total": 234
}
```

---

## Error Handling

### Error Response Format

All errors follow a consistent format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field_name": ["Validation error message"]
    }
  }
}
```

### Common HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | OK - Request succeeded |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid request parameters |
| 401 | Unauthorized - Authentication required or failed |
| 403 | Forbidden - Access denied |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource already exists |
| 413 | Payload Too Large - File size exceeds limit |
| 422 | Unprocessable Entity - Validation failed |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |

### Common Error Codes

| Code | Description |
|------|-------------|
| `UNAUTHENTICATED` | No valid authentication token provided |
| `INVALID_CREDENTIALS` | Email or password is incorrect |
| `EMAIL_NOT_VERIFIED` | User's email is not verified |
| `VALIDATION_ERROR` | Request validation failed |
| `NOT_FOUND` | Requested resource not found |
| `STORE_NOT_FOUND` | Store not found |
| `REVIEW_NOT_FOUND` | Review not found |
| `NOTIFICATION_NOT_FOUND` | Notification not found |
| `FORBIDDEN` | User does not have permission |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `ALREADY_VERIFIED` | Email already verified |
| `STORE_EXISTS` | Store already exists |
| `REVIEW_EXISTS` | User already reviewed this store |
| `CLAIM_EXISTS` | User already has a pending claim |
| `STORE_ALREADY_CLAIMED` | Store already claimed by another user |
| `REPORT_EXISTS` | User already reported this item |
| `PROOF_EXISTS` | Proof already uploaded for review |
| `NOT_REVIEW_OWNER` | User is not the owner of the review |
| `FILE_TOO_LARGE` | Uploaded file exceeds size limit |
| `INVALID_PROVIDER` | Invalid social auth provider |
| `INVALID_TOKEN` | Invalid or expired token |

### Rate Limiting

API requests are rate limited to prevent abuse:

- **Authenticated users:** 100 requests per minute
- **Unauthenticated users:** 30 requests per minute

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705312200
```

---

## Localization

The API supports multiple languages. Set the `Accept-Language` header to receive localized content:

```
Accept-Language: ar
Accept-Language: fr
Accept-Language: en
```

Supported languages:
- `en` - English (default)
- `ar` - Arabic
- `fr` - French

Category names include all translations in the response (`name`, `name_ar`, `name_fr`).

---

## Versioning

The API uses URL versioning. The current version is v1, accessible at:

```
https://api.preuvely.com/api/v1/...
```

The base URL without version (`/api/...`) defaults to the latest stable version.

---

*Last updated: January 2025*
