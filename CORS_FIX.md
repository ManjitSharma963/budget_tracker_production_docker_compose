# CORS Configuration Fix

## Problem
The frontend at `http://139.59.85.102` was trying to access `http://localhost:8080/api/auth/register`, which caused:
1. CORS policy blocking (different origins)
2. Browser security blocking (public IP trying to access localhost)

## Solution Applied

### 1. Nginx CORS Headers
Updated `nginx/nginx.conf` to add CORS headers for all API routes:
- Allows all origins dynamically via `$http_origin`
- Handles preflight OPTIONS requests
- Allows common HTTP methods and headers
- Supports credentials

### 2. Spring Boot CORS Environment Variables
Added CORS configuration environment variables in `docker-compose.yml`:
- `SPRING_CORS_ALLOWED_ORIGINS`: Allowed origins (defaults to your frontend IP and localhost)
- `SPRING_CORS_ALLOWED_METHODS`: Allowed HTTP methods
- `SPRING_CORS_ALLOWED_HEADERS`: Allowed headers
- `SPRING_CORS_ALLOW_CREDENTIALS`: Allow credentials

## Important: Frontend URL Configuration

**The frontend MUST NOT use `localhost:8080` when accessing the API from a remote location.**

### Correct API URLs:
1. **Via Nginx (Recommended)**: `http://139.59.85.102/api` or `http://139.59.85.102:80/api`
2. **Direct API Access**: `http://139.59.85.102:8080/api`

### Incorrect API URLs:
- ❌ `http://localhost:8080/api` (won't work from remote)
- ❌ `http://127.0.0.1:8080/api` (won't work from remote)

## Frontend Configuration

Update your React app's API base URL configuration:

### Option 1: Environment Variable (Recommended)
Create a `.env` file or set environment variable:
```env
VITE_API_BASE_URL=http://139.59.85.102/api
# or
REACT_APP_API_BASE_URL=http://139.59.85.102/api
```

### Option 2: Dynamic Configuration
```javascript
const API_BASE_URL = window.location.origin === 'http://139.59.85.102' 
  ? 'http://139.59.85.102/api' 
  : 'http://localhost:8080/api';
```

### Option 3: Use Relative Paths
If frontend and API are on the same domain:
```javascript
const API_BASE_URL = '/api'; // Will use the same origin
```

## Testing CORS

After updating the frontend URL, test with:
```bash
curl -H "Origin: http://139.59.85.102" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS \
     http://139.59.85.102:8080/api/auth/register
```

## Customizing Allowed Origins

To restrict CORS to specific origins, update `docker-compose.yml`:
```yaml
environment:
  SPRING_CORS_ALLOWED_ORIGINS: http://139.59.85.102,https://yourdomain.com
```

Or set via environment variable:
```bash
export CORS_ALLOWED_ORIGINS="http://139.59.85.102,https://yourdomain.com"
docker-compose up -d
```

## Notes

- The Nginx CORS configuration uses `$http_origin` to dynamically allow the requesting origin
- If you need to restrict to specific origins, modify the nginx config to check and validate origins
- The Spring Boot CORS env vars will only work if the application code reads them (may require code changes in the GitHub repo)

