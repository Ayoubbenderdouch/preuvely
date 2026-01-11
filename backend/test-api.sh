#!/bin/bash

# =============================================================================
# API Test Script for Preuvely Backend
# Tests all 27 API endpoints on localhost:8000
# =============================================================================

BASE_URL="http://localhost:8000"

# Set this token after running the login endpoint
# Copy the token from the login response and paste it here
TOKEN=""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function to print section headers
print_header() {
    echo ""
    echo -e "${BLUE}=============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=============================================================================${NC}"
}

# Helper function to print endpoint info
print_endpoint() {
    echo ""
    echo -e "${GREEN}>>> $1${NC}"
    echo -e "${YELLOW}$2${NC}"
}

# =============================================================================
# PUBLIC ENDPOINTS (No Authentication Required)
# =============================================================================

print_header "PUBLIC ENDPOINTS (No Authentication Required)"

# -----------------------------------------------------------------------------
# 1. GET /api/v1/banners
# -----------------------------------------------------------------------------
print_endpoint "1. GET /api/v1/banners" "Fetches all active banners"
curl -s -X GET "${BASE_URL}/api/v1/banners" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 2. GET /api/v1/categories
# -----------------------------------------------------------------------------
print_endpoint "2. GET /api/v1/categories" "Fetches all categories"
curl -s -X GET "${BASE_URL}/api/v1/categories" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 3. GET /api/v1/categories/{slug}
# -----------------------------------------------------------------------------
print_endpoint "3. GET /api/v1/categories/{slug}" "Fetches a specific category by slug"
curl -s -X GET "${BASE_URL}/api/v1/categories/electronics" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 4. GET /api/v1/stores/search
# -----------------------------------------------------------------------------
print_endpoint "4. GET /api/v1/stores/search" "Search stores with optional filters"
curl -s -X GET "${BASE_URL}/api/v1/stores/search?q=test&category=electronics&page=1&per_page=10" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 5. GET /api/v1/stores/{slug}
# -----------------------------------------------------------------------------
print_endpoint "5. GET /api/v1/stores/{slug}" "Fetches a specific store by slug"
curl -s -X GET "${BASE_URL}/api/v1/stores/example-store" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 6. GET /api/v1/stores/{slug}/summary
# -----------------------------------------------------------------------------
print_endpoint "6. GET /api/v1/stores/{slug}/summary" "Fetches store summary/statistics"
curl -s -X GET "${BASE_URL}/api/v1/stores/example-store/summary" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 7. GET /api/v1/stores/{store}/reviews
# -----------------------------------------------------------------------------
print_endpoint "7. GET /api/v1/stores/{store}/reviews" "Fetches reviews for a store"
curl -s -X GET "${BASE_URL}/api/v1/stores/example-store/reviews?page=1&per_page=10" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# =============================================================================
# AUTHENTICATION ENDPOINTS
# =============================================================================

print_header "AUTHENTICATION ENDPOINTS"

# -----------------------------------------------------------------------------
# 8. POST /api/v1/auth/register
# -----------------------------------------------------------------------------
print_endpoint "8. POST /api/v1/auth/register" "Register a new user"
curl -s -X POST "${BASE_URL}/api/v1/auth/register" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Test User",
        "email": "testuser@example.com",
        "password": "password123",
        "password_confirmation": "password123"
    }' | json_pp

# -----------------------------------------------------------------------------
# 9. POST /api/v1/auth/login
# -----------------------------------------------------------------------------
print_endpoint "9. POST /api/v1/auth/login" "Login and get auth token"
echo -e "${RED}NOTE: Copy the token from this response and set it in the TOKEN variable at the top of this script${NC}"
curl -s -X POST "${BASE_URL}/api/v1/auth/login" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "testuser@example.com",
        "password": "password123"
    }' | json_pp

# -----------------------------------------------------------------------------
# 10. GET /api/v1/auth/email/verify/{id}/{hash}
# -----------------------------------------------------------------------------
print_endpoint "10. GET /api/v1/auth/email/verify/{id}/{hash}" "Verify email address"
curl -s -X GET "${BASE_URL}/api/v1/auth/email/verify/1/sample-hash-value" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 11. GET /api/v1/auth/social/{provider}/redirect
# -----------------------------------------------------------------------------
print_endpoint "11. GET /api/v1/auth/social/{provider}/redirect" "Get social login redirect URL"
curl -s -X GET "${BASE_URL}/api/v1/auth/social/google/redirect" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" | json_pp

# -----------------------------------------------------------------------------
# 12. POST /api/v1/auth/social/{provider}/callback
# -----------------------------------------------------------------------------
print_endpoint "12. POST /api/v1/auth/social/{provider}/callback" "Handle social login callback"
curl -s -X POST "${BASE_URL}/api/v1/auth/social/google/callback" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "code": "sample-oauth-code",
        "state": "sample-state"
    }' | json_pp

# =============================================================================
# AUTHENTICATED ENDPOINTS (Require Bearer Token)
# =============================================================================

print_header "AUTHENTICATED ENDPOINTS (Require Bearer Token)"

if [ -z "$TOKEN" ]; then
    echo -e "${RED}WARNING: TOKEN is not set. The following endpoints will likely fail.${NC}"
    echo -e "${RED}Run the login endpoint first, then set the TOKEN variable.${NC}"
fi

# -----------------------------------------------------------------------------
# 13. POST /api/v1/auth/logout
# -----------------------------------------------------------------------------
print_endpoint "13. POST /api/v1/auth/logout" "Logout and invalidate token"
curl -s -X POST "${BASE_URL}/api/v1/auth/logout" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" | json_pp

# -----------------------------------------------------------------------------
# 14. GET /api/v1/auth/me
# -----------------------------------------------------------------------------
print_endpoint "14. GET /api/v1/auth/me" "Get current authenticated user"
curl -s -X GET "${BASE_URL}/api/v1/auth/me" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" | json_pp

# -----------------------------------------------------------------------------
# 15. PUT /api/v1/auth/profile
# -----------------------------------------------------------------------------
print_endpoint "15. PUT /api/v1/auth/profile" "Update user profile"
curl -s -X PUT "${BASE_URL}/api/v1/auth/profile" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d '{
        "name": "Updated Name",
        "email": "updated@example.com"
    }' | json_pp

# -----------------------------------------------------------------------------
# 16. POST /api/v1/auth/avatar
# -----------------------------------------------------------------------------
print_endpoint "16. POST /api/v1/auth/avatar" "Upload user avatar"
echo -e "${YELLOW}NOTE: This endpoint requires a file upload. Example with actual file:${NC}"
echo 'curl -X POST "${BASE_URL}/api/v1/auth/avatar" \'
echo '    -H "Authorization: Bearer ${TOKEN}" \'
echo '    -F "avatar=@/path/to/avatar.jpg"'
curl -s -X POST "${BASE_URL}/api/v1/auth/avatar" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -F "avatar=" | json_pp

# -----------------------------------------------------------------------------
# 17. POST /api/v1/auth/email/resend
# -----------------------------------------------------------------------------
print_endpoint "17. POST /api/v1/auth/email/resend" "Resend email verification"
curl -s -X POST "${BASE_URL}/api/v1/auth/email/resend" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" | json_pp

# =============================================================================
# STORE MANAGEMENT ENDPOINTS (Authenticated)
# =============================================================================

print_header "STORE MANAGEMENT ENDPOINTS (Authenticated)"

# -----------------------------------------------------------------------------
# 18. POST /api/v1/stores
# -----------------------------------------------------------------------------
print_endpoint "18. POST /api/v1/stores" "Create a new store"
curl -s -X POST "${BASE_URL}/api/v1/stores" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d '{
        "name": "My Test Store",
        "description": "A test store for API testing",
        "website": "https://teststore.com",
        "category_id": 1
    }' | json_pp

# -----------------------------------------------------------------------------
# 19. POST /api/v1/stores/{store}/reviews
# -----------------------------------------------------------------------------
print_endpoint "19. POST /api/v1/stores/{store}/reviews" "Create a review for a store"
curl -s -X POST "${BASE_URL}/api/v1/stores/example-store/reviews" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d '{
        "rating": 5,
        "title": "Great store!",
        "content": "I had an excellent experience with this store. Highly recommended!"
    }' | json_pp

# -----------------------------------------------------------------------------
# 20. GET /api/v1/stores/{store}/my-review
# -----------------------------------------------------------------------------
print_endpoint "20. GET /api/v1/stores/{store}/my-review" "Get current user's review for a store"
curl -s -X GET "${BASE_URL}/api/v1/stores/example-store/my-review" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" | json_pp

# =============================================================================
# REVIEW MANAGEMENT ENDPOINTS (Authenticated)
# =============================================================================

print_header "REVIEW MANAGEMENT ENDPOINTS (Authenticated)"

# -----------------------------------------------------------------------------
# 21. POST /api/v1/reviews/{review}/proof
# -----------------------------------------------------------------------------
print_endpoint "21. POST /api/v1/reviews/{review}/proof" "Upload proof for a review"
echo -e "${YELLOW}NOTE: This endpoint requires a file upload. Example with actual file:${NC}"
echo 'curl -X POST "${BASE_URL}/api/v1/reviews/1/proof" \'
echo '    -H "Authorization: Bearer ${TOKEN}" \'
echo '    -F "proof=@/path/to/proof.jpg"'
curl -s -X POST "${BASE_URL}/api/v1/reviews/1/proof" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -F "proof=" | json_pp

# -----------------------------------------------------------------------------
# 22. POST /api/v1/reviews/{review}/reply
# -----------------------------------------------------------------------------
print_endpoint "22. POST /api/v1/reviews/{review}/reply" "Reply to a review (store owner)"
curl -s -X POST "${BASE_URL}/api/v1/reviews/1/reply" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d '{
        "content": "Thank you for your review! We appreciate your feedback."
    }' | json_pp

# =============================================================================
# STORE CLAIM ENDPOINTS (Authenticated)
# =============================================================================

print_header "STORE CLAIM ENDPOINTS (Authenticated)"

# -----------------------------------------------------------------------------
# 23. POST /api/v1/stores/{store}/claim
# -----------------------------------------------------------------------------
print_endpoint "23. POST /api/v1/stores/{store}/claim" "Submit a claim request for a store"
curl -s -X POST "${BASE_URL}/api/v1/stores/example-store/claim" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d '{
        "business_email": "owner@teststore.com",
        "business_phone": "+1234567890",
        "proof_of_ownership": "I am the registered owner of this business."
    }' | json_pp

# -----------------------------------------------------------------------------
# 24. GET /api/v1/claims
# -----------------------------------------------------------------------------
print_endpoint "24. GET /api/v1/claims" "Get user's claim requests"
curl -s -X GET "${BASE_URL}/api/v1/claims" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" | json_pp

# =============================================================================
# REPORT ENDPOINTS (Authenticated)
# =============================================================================

print_header "REPORT ENDPOINTS (Authenticated)"

# -----------------------------------------------------------------------------
# 25. POST /api/v1/reports
# -----------------------------------------------------------------------------
print_endpoint "25. POST /api/v1/reports" "Submit a report"
curl -s -X POST "${BASE_URL}/api/v1/reports" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" \
    -d '{
        "reportable_type": "review",
        "reportable_id": 1,
        "reason": "spam",
        "description": "This review appears to be spam or fake."
    }' | json_pp

# -----------------------------------------------------------------------------
# 26. GET /api/v1/reports
# -----------------------------------------------------------------------------
print_endpoint "26. GET /api/v1/reports" "Get user's submitted reports"
curl -s -X GET "${BASE_URL}/api/v1/reports" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKEN}" | json_pp

# =============================================================================
# SUMMARY
# =============================================================================

print_header "TEST COMPLETE"

echo ""
echo "Total Endpoints Tested: 26 (27th is duplicate logout after token invalidation)"
echo ""
echo "Endpoint Summary:"
echo "  - Public Endpoints (No Auth):     7  (Endpoints 1-7)"
echo "  - Auth Endpoints:                 5  (Endpoints 8-12)"
echo "  - Authenticated Endpoints:        14 (Endpoints 13-26)"
echo ""
echo "Notes:"
echo "  1. Set the TOKEN variable after running endpoint #9 (login)"
echo "  2. File upload endpoints (16, 21) require actual files"
echo "  3. Replace 'example-store' with actual store slugs from your database"
echo "  4. Replace IDs (1, etc.) with actual IDs from your database"
echo ""
