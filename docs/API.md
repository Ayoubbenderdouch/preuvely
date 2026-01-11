# Preuvely API Documentation

**Base URL:** `https://api.preuvely.com/api/v1`

**Version:** 1.0

**Last Updated:** December 2024

**Total Endpoints:** 27

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Authentication](#authentication)
3. [User Profile](#user-profile)
4. [Banners](#banners)
5. [Categories](#categories)
6. [Stores](#stores)
7. [Reviews](#reviews)
8. [Claims](#claims)
9. [Reports](#reports)
10. [Error Handling](#error-handling)
11. [Rate Limiting](#rate-limiting)
12. [iOS Integration](#iosswift-integration-examples)

---

## Quick Start

### 1. Register a User

```bash
curl -X POST https://api.preuvely.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ahmed Benali",
    "email": "ahmed@example.com",
    "password": "securepass123",
    "password_confirmation": "securepass123"
  }'
```

### 2. Login and Get Token

```bash
curl -X POST https://api.preuvely.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "password": "securepass123"
  }'
```

### 3. Use Token for Authenticated Requests

```bash
curl https://api.preuvely.com/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Headers

All requests should include:

```
Content-Type: application/json
Accept: application/json
Accept-Language: en|fr|ar  (optional, for localized responses)
```

Authenticated requests require:

```
Authorization: Bearer <token>
```

---

## Authentication

### 1. Register

```http
POST /auth/register
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | User's full name |
| `email` | string | Yes | Email address |
| `password` | string | Yes | Password (min 8 characters) |
| `password_confirmation` | string | Yes | Password confirmation |

**Response (201):**

```json
{
  "message": "User registered successfully. Please check your email to verify your account.",
  "user": {
    "id": 1,
    "name": "Ahmed Benali",
    "email": "ahmed@example.com",
    "avatar": null,
    "email_verified": false
  },
  "token": "1|abcdef123456..."
}
```

---

### 2. Login

```http
POST /auth/login
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Email address |
| `password` | string | Yes | Password |

**Response (200):**

```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "name": "Ahmed Benali",
    "email": "ahmed@example.com",
    "avatar": "https://storage.preuvely.com/avatars/user-1.jpg"
  },
  "token": "1|abcdef123456...",
  "email_verified": true
}
```

---

### 3. Social Login - Get Redirect URL

```http
GET /auth/social/{provider}/redirect
```

**URL Parameters:**
- `provider`: `google` or `apple`

**Response (200):**

```json
{
  "redirect_url": "https://accounts.google.com/o/oauth2/..."
}
```

---

### 4. Social Login - Callback (Web)

```http
GET /auth/social/{provider}/callback
```

---

### 5. Social Login - Callback (Mobile)

```http
POST /auth/social/{provider}/callback
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id_token` | string | Yes | OAuth ID token from provider |

**Response (200):**

```json
{
  "message": "Login successful",
  "user": {...},
  "token": "1|abcdef123456...",
  "is_new_user": false
}
```

---

### 6. Email Verification

```http
GET /auth/email/verify/{id}/{hash}
```

Signed URL sent via email. Verifies user's email address.

---

### 7. Resend Verification Email

```http
POST /auth/email/resend
```

**Headers:** `Authorization: Bearer <token>`

**Rate Limit:** 3 per hour

**Response (200):**

```json
{
  "message": "Verification email resent successfully"
}
```

---

### 8. Get Current User

```http
GET /auth/me
```

**Headers:** `Authorization: Bearer <token>`

**Response (200):**

```json
{
  "user": {
    "id": 1,
    "name": "Ahmed Benali",
    "email": "ahmed@example.com",
    "phone": "+213555123456",
    "avatar": "https://storage.preuvely.com/avatars/user-1.jpg",
    "email_verified_at": "2024-01-15T10:00:00Z"
  }
}
```

---

### 9. Logout

```http
POST /auth/logout
```

**Headers:** `Authorization: Bearer <token>`

**Response (200):**

```json
{
  "message": "Logged out successfully"
}
```

---

## User Profile

### 10. Update Profile

```http
PUT /auth/profile
```
or
```http
PATCH /auth/profile
```

**Headers:** `Authorization: Bearer <token>`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | User's full name |
| `phone` | string | No | Phone number (unique) |

**Response (200):**

```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": 1,
    "name": "Ahmed Benali",
    "email": "ahmed@example.com",
    "phone": "+213555123456",
    "avatar": "https://storage.preuvely.com/avatars/user-1.jpg"
  }
}
```

---

### 11. Upload Avatar

```http
POST /auth/avatar
```

**Headers:**
- `Authorization: Bearer <token>`
- `Content-Type: multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `avatar` | file | Yes | Image file (jpeg, png, jpg, gif; max 2MB) |

**Response (200):**

```json
{
  "message": "Avatar uploaded successfully",
  "avatar": "https://storage.preuvely.com/avatars/user-1-abc123.jpg"
}
```

---

## Banners

### 12. List Banners

```http
GET /banners
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `locale` | string | Language code (en, ar, fr) |

**Response (200):**

```json
{
  "data": [
    {
      "id": 1,
      "title": "Summer Sale!",
      "subtitle": "Up to 50% off on all items",
      "image_url": "https://storage.preuvely.com/banners/summer-sale.jpg",
      "background_color": "#FF6B35",
      "link_type": "category",
      "link_value": "fashion"
    }
  ]
}
```

**Link Types:**
- `none` - No action on tap
- `store` - Navigate to store (link_value = store slug)
- `category` - Navigate to category (link_value = category slug)
- `url` - Open external URL (link_value = full URL)

---

## Categories

### 13. List Categories

```http
GET /categories
```

**Response (200):**

```json
{
  "data": [
    {
      "id": 1,
      "name": "Electronics",
      "name_ar": "إلكترونيات",
      "name_fr": "Électronique",
      "slug": "electronics",
      "icon": "laptopcomputer",
      "is_high_risk": false
    }
  ]
}
```

---

### 14. Get Category

```http
GET /categories/{slug}
```

**Response (200):**

```json
{
  "data": {
    "id": 1,
    "name": "Electronics",
    "slug": "electronics",
    "icon": "laptopcomputer",
    "is_high_risk": false,
    "stores_count": 150
  }
}
```

---

## Stores

### 15. Search Stores

```http
GET /stores/search
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query |
| `category` | string | Filter by category slug |
| `city` | string | Filter by city |
| `verified` | boolean | Only verified stores |
| `sort_by` | string | `best_rated`, `most_reviewed`, `newest` |
| `per_page` | integer | Results per page (max 50) |
| `page` | integer | Page number |

**Response (200):**

```json
{
  "data": [
    {
      "id": 1,
      "name": "TechZone DZ",
      "slug": "techzone-dz",
      "city": "Algiers",
      "is_verified": true,
      "avg_rating": 4.5,
      "reviews_count": 128,
      "categories": [...],
      "thumbnail_url": "https://..."
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 72
  }
}
```

---

### 16. Get Store Details

```http
GET /stores/{slug}
```

**Response (200):**

```json
{
  "data": {
    "id": 1,
    "name": "TechZone DZ",
    "slug": "techzone-dz",
    "description": "Your trusted electronics store",
    "city": "Algiers",
    "is_verified": true,
    "avg_rating": 4.5,
    "reviews_count": 128,
    "is_high_risk": false,
    "categories": [
      {"id": 1, "name": "Electronics", "slug": "electronics"}
    ],
    "links": [
      {"platform": "instagram", "url": "https://instagram.com/techzone_dz", "handle": "techzone_dz"}
    ],
    "contacts": {
      "whatsapp": "+213555123456",
      "phone": "+213555123456"
    }
  }
}
```

---

### 17. Get Store Summary (Rating Breakdown)

```http
GET /stores/{slug}/summary
```

**Response (200):**

```json
{
  "data": {
    "avg_rating": 4.5,
    "reviews_count": 128,
    "is_verified": true,
    "proof_badge": true,
    "rating_breakdown": {
      "1": 5,
      "2": 8,
      "3": 15,
      "4": 35,
      "5": 65
    }
  }
}
```

---

### 18. Create Store

```http
POST /stores
```

**Headers:** `Authorization: Bearer <token>`

**Requires:** Verified email

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Store name (max 255) |
| `description` | string | No | Description (max 2000) |
| `city` | string | No | City (max 100) |
| `category_ids` | array | Yes | Array of category IDs (min 1) |
| `links` | array | No | Social media links |
| `links[].platform` | string | Yes | `instagram`, `facebook`, `tiktok`, `website` |
| `links[].url` | string | Yes | Valid URL |
| `links[].handle` | string | No | Platform handle |
| `contacts` | object | No | Contact info |
| `contacts.whatsapp` | string | No | WhatsApp number |
| `contacts.phone` | string | No | Phone number |

**Example Request:**

```json
{
  "name": "My Fashion Store",
  "description": "Best fashion items in Oran",
  "city": "Oran",
  "category_ids": [3, 5],
  "links": [
    {"platform": "instagram", "url": "https://instagram.com/myfashion", "handle": "myfashion"}
  ],
  "contacts": {
    "whatsapp": "+213555987654"
  }
}
```

**Response (201):**

```json
{
  "message": "Store created successfully",
  "data": {
    "id": 42,
    "name": "My Fashion Store",
    "slug": "my-fashion-store-abc123",
    "status": "active"
  }
}
```

---

### 19. Get Store Reviews

```http
GET /stores/{store}/reviews
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `per_page` | integer | Results per page |
| `page` | integer | Page number |

**Response (200):**

```json
{
  "data": [
    {
      "id": 1,
      "stars": 5,
      "comment": "Excellent service!",
      "has_proof": true,
      "proof_status": "approved",
      "created_at": "2024-01-15T14:30:00Z",
      "user": {
        "id": 5,
        "name": "Sarah M.",
        "avatar_url": null
      },
      "reply": {
        "id": 1,
        "reply_text": "Thank you!",
        "created_at": "2024-01-16T09:00:00Z"
      }
    }
  ],
  "meta": {...}
}
```

---

## Reviews

### 20. Create Review

```http
POST /stores/{store}/reviews
```

**Headers:** `Authorization: Bearer <token>`

**Requires:** Verified email

**Rate Limit:** 5 reviews per day

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `stars` | integer | Yes | Rating 1-5 |
| `comment` | string | Yes | Review text (8-500 chars) |

**Response (201):**

```json
{
  "message": "Review submitted successfully.",
  "requires_proof": false,
  "data": {
    "id": 156,
    "stars": 5,
    "comment": "Great experience!",
    "status": "approved",
    "has_proof": false
  }
}
```

**For High-Risk Categories:**

```json
{
  "message": "Review submitted. Please upload proof for approval.",
  "requires_proof": true,
  "data": {
    "id": 157,
    "status": "pending",
    "has_proof": false
  }
}
```

**Error - Already Reviewed (409):**

```json
{
  "message": "You have already reviewed this store"
}
```

---

### 21. Get My Review for Store

```http
GET /stores/{store}/my-review
```

**Headers:** `Authorization: Bearer <token>`

**Response (200):**

```json
{
  "has_reviewed": true,
  "data": {
    "id": 156,
    "stars": 5,
    "comment": "Great experience!",
    "status": "approved",
    "has_proof": true,
    "proof_status": "approved"
  }
}
```

---

### 22. Upload Proof

```http
POST /reviews/{review}/proof
```

**Headers:**
- `Authorization: Bearer <token>`
- `Content-Type: multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `proof` | file | Yes | Image file (jpg, png, webp; max 5MB) |

**Response (201):**

```json
{
  "message": "Proof uploaded successfully. Once approved, your review will show a verified badge.",
  "data": {
    "id": 89,
    "url": "https://storage.preuvely.com/proofs/...",
    "status": "pending"
  }
}
```

---

### 23. Reply to Review (Store Owner)

```http
POST /reviews/{review}/reply
```

**Headers:** `Authorization: Bearer <token>`

**Requirements:** User must own a verified store

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reply_text` | string | Yes | Reply text (max 300 chars) |

**Response (201):**

```json
{
  "message": "Reply submitted successfully.",
  "data": {
    "id": 45,
    "reply_text": "Thank you for your feedback!",
    "created_at": "2024-01-16T10:30:00Z"
  }
}
```

---

## Claims

### 24. Submit Claim

```http
POST /stores/{store}/claim
```

**Headers:** `Authorization: Bearer <token>`

**Requires:** Verified email

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `requester_name` | string | Yes | Your full name |
| `requester_phone` | string | Yes | WhatsApp number |
| `note` | string | No | Additional info |

**Response (201):**

```json
{
  "message": "Claim request submitted successfully.",
  "data": {
    "id": 12,
    "store_id": 5,
    "status": "pending"
  }
}
```

---

### 25. Get My Claims

```http
GET /claims
```

**Headers:** `Authorization: Bearer <token>`

**Response (200):**

```json
{
  "data": [
    {
      "id": 12,
      "store": {
        "id": 5,
        "name": "TechZone DZ",
        "slug": "techzone-dz"
      },
      "status": "pending",
      "created_at": "2024-01-20T08:00:00Z"
    }
  ]
}
```

---

## Reports

### 26. Submit Report

```http
POST /reports
```

**Headers:** `Authorization: Bearer <token>`

**Requires:** Verified email

**Rate Limit:** 10 per day

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reportable_type` | string | Yes | `store`, `review`, `reply` |
| `reportable_id` | integer | Yes | ID of content |
| `reason` | string | Yes | `spam`, `inappropriate`, `fake`, `scam`, `other` |
| `note` | string | No | Additional details |

**Response (201):**

```json
{
  "message": "Report submitted successfully.",
  "data": {
    "id": 34,
    "reportable_type": "Review",
    "reason": "fake",
    "status": "open"
  }
}
```

---

### 27. Get My Reports

```http
GET /reports
```

**Headers:** `Authorization: Bearer <token>`

**Response (200):**

```json
{
  "data": [
    {
      "id": 34,
      "reportable_type": "Review",
      "reportable_id": 156,
      "reason": "fake",
      "status": "open",
      "created_at": "2024-01-21T15:00:00Z"
    }
  ]
}
```

---

## Error Handling

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden (email not verified) |
| 404 | Not Found |
| 409 | Conflict (duplicate) |
| 422 | Validation Error |
| 429 | Too Many Requests |
| 500 | Server Error |

### Error Response Format

```json
{
  "message": "Human readable error message",
  "errors": {
    "field_name": ["Validation error message"]
  }
}
```

---

## Rate Limiting

| Action | Limit | Window |
|--------|-------|--------|
| Reviews | 5 | Per day |
| Reports | 10 | Per day |
| Resend Email | 3 | Per hour |
| General | 60 | Per minute |

**Rate Limit Headers:**

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 58
X-RateLimit-Reset: 1705842300
```

---

## All Endpoints Summary

| # | Method | Endpoint | Auth | Description |
|---|--------|----------|------|-------------|
| 1 | POST | /auth/register | No | Register user |
| 2 | POST | /auth/login | No | Login user |
| 3 | GET | /auth/social/{provider}/redirect | No | OAuth redirect |
| 4 | GET | /auth/social/{provider}/callback | No | OAuth callback (web) |
| 5 | POST | /auth/social/{provider}/callback | No | OAuth callback (mobile) |
| 6 | GET | /auth/email/verify/{id}/{hash} | No | Verify email |
| 7 | POST | /auth/email/resend | Yes | Resend verification |
| 8 | GET | /auth/me | Yes | Get current user |
| 9 | POST | /auth/logout | Yes | Logout |
| 10 | PUT/PATCH | /auth/profile | Yes | Update profile |
| 11 | POST | /auth/avatar | Yes | Upload avatar |
| 12 | GET | /banners | No | List banners |
| 13 | GET | /categories | No | List categories |
| 14 | GET | /categories/{slug} | No | Get category |
| 15 | GET | /stores/search | No | Search stores |
| 16 | GET | /stores/{slug} | No | Get store |
| 17 | GET | /stores/{slug}/summary | No | Rating breakdown |
| 18 | POST | /stores | Yes* | Create store |
| 19 | GET | /stores/{store}/reviews | No | List reviews |
| 20 | POST | /stores/{store}/reviews | Yes* | Create review |
| 21 | GET | /stores/{store}/my-review | Yes | Check my review |
| 22 | POST | /reviews/{review}/proof | Yes* | Upload proof |
| 23 | POST | /reviews/{review}/reply | Yes* | Reply to review |
| 24 | POST | /stores/{store}/claim | Yes* | Claim store |
| 25 | GET | /claims | Yes | My claims |
| 26 | POST | /reports | Yes* | Submit report |
| 27 | GET | /reports | Yes | My reports |

**Yes*** = Requires verified email

---

## iOS/Swift Integration Examples

### APIClient

```swift
import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://api.preuvely.com/api/v1"

    var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }

    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: URL(string: "\(baseURL)\(endpoint)")!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200...201:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        case 401: throw APIError.unauthorized
        case 404: throw APIError.notFound
        case 409: throw APIError.conflict
        case 429: throw APIError.rateLimited
        default: throw APIError.serverError
        }
    }
}
```

### Upload Avatar Example

```swift
func uploadAvatar(image: UIImage) async throws -> String {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        throw APIError.unknown
    }

    let boundary = UUID().uuidString
    var request = URLRequest(url: URL(string: "\(baseURL)/auth/avatar")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken!)", forHTTPHeaderField: "Authorization")

    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    body.append(imageData)
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    request.httpBody = body

    let (data, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(AvatarResponse.self, from: data)
    return response.avatar
}
```

---

## Support

- **API Issues:** api@preuvely.com
- **Documentation:** docs@preuvely.com

---

## Changelog

### Version 1.0 (December 2024)
- Initial API release
- 27 endpoints
- Authentication (email, Google, Apple)
- Profile management with avatar upload
- Dynamic banners system
- Store management (search, create, claim)
- Review system with proof upload
- Report system
- Multi-language support (EN, FR, AR)
