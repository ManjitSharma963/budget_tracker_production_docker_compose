# CORS Fix for Port 8080 Direct Access

## Problem
When accessing the API directly on port 8080 (`http://www.trackmyexpenses.in:8080/api/auth/login`), CORS errors occurred because:
1. Requests bypassed Nginx (which had CORS headers)
2. Spring Boot API wasn't properly handling CORS for direct access
3. No CORS headers were present in the response

## Solution Applied

### 1. Added Nginx Server Block for Port 8080
Created a new server block in `nginx/nginx.conf` that:
- Listens on port 8080
- Handles requests to `www.trackmyexpenses.in:8080`
- Adds CORS headers to all API responses
- Proxies requests to the API container internally

### 2. Updated Docker Compose Configuration
- **Removed** direct port 8080 exposure from API container
- **Added** port 8080 exposure to Nginx container
- Now all port 8080 traffic goes through Nginx (with CORS support)

### 3. How It Works Now

**Before:**
```
Client → Port 8080 → API Container (No CORS headers) ❌
```

**After:**
```
Client → Port 8080 → Nginx (Adds CORS headers) → API Container ✅
```

## Current Configuration

### Port Mappings
- **Port 80**: Nginx → UI and `/api/` routes (with CORS)
- **Port 8080**: Nginx → Direct API access (with CORS)
- **Port 3000**: Direct UI access (bypasses Nginx)
- **Port 3306**: MySQL database

### API Access Methods

1. **Through Nginx (Port 80) - Recommended**
   ```
   http://www.trackmyexpenses.in/api/auth/login
   ```
   ✅ CORS headers included
   ✅ Single port for all traffic

2. **Direct API Access (Port 8080) - Now Fixed**
   ```
   http://www.trackmyexpenses.in:8080/api/auth/login
   ```
   ✅ CORS headers included (via Nginx)
   ✅ Works for direct API access

## Testing

### Test CORS Preflight (Port 8080)
```bash
curl -X OPTIONS http://www.trackmyexpenses.in:8080/api/auth/login \
     -H "Origin: http://www.trackmyexpenses.in" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -v
```

Expected: Should return 204 with CORS headers

### Test Actual Request (Port 8080)
```bash
curl -X POST http://www.trackmyexpenses.in:8080/api/auth/login \
     -H "Origin: http://www.trackmyexpenses.in" \
     -H "Content-Type: application/json" \
     -d '{"username":"test","password":"test"}' \
     -v
```

Expected: Should include `Access-Control-Allow-Origin` header

## Important Notes

1. **API Container Port 8080**: The API container still runs on port 8080 internally, but it's no longer directly exposed to the host. All external access goes through Nginx.

2. **Internal Communication**: Services can still communicate internally using the container name:
   - `budget_tracker_production_api:8080` (internal network)

3. **CORS Headers**: All CORS headers are now handled by Nginx, ensuring consistent behavior whether accessing through port 80 or port 8080.

4. **Frontend Recommendation**: For best practices, update your frontend to use:
   ```javascript
   // Recommended: Use port 80 through Nginx
   const API_BASE_URL = 'http://www.trackmyexpenses.in/api';
   
   // Or if you must use port 8080, it now works with CORS
   const API_BASE_URL = 'http://www.trackmyexpenses.in:8080/api';
   ```

## Verification

Check that Nginx is listening on port 8080:
```bash
docker-compose ps nginx
```

You should see: `0.0.0.0:8080->8080/tcp`

Check API container (should NOT expose port 8080):
```bash
docker-compose ps budget_tracker_production_api
```

You should see: `8080/tcp` (internal only, no host mapping)

## Troubleshooting

### If CORS errors persist:

1. **Check Nginx logs:**
   ```bash
   docker-compose logs nginx
   ```

2. **Verify Nginx configuration:**
   ```bash
   docker exec budget_tracker_nginx nginx -t
   ```

3. **Test direct API access:**
   ```bash
   curl -v http://www.trackmyexpenses.in:8080/api/auth/login
   ```

4. **Check if Nginx is handling port 8080:**
   ```bash
   netstat -tuln | grep 8080
   # or
   docker port budget_tracker_nginx
   ```

