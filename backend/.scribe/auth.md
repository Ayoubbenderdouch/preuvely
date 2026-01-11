# Authenticating requests

To authenticate requests, include an **`Authorization`** header with the value **`"Bearer {YOUR_AUTH_TOKEN}"`**.

All authenticated endpoints are marked with a `requires authentication` badge in the documentation below.

Obtain your token by calling POST `/api/v1/auth/login` or POST `/api/v1/auth/register`. Include the token in the Authorization header as `Bearer {token}`.
