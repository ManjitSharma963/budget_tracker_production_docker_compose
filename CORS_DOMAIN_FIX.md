# CORS Fix for Domain Access

## Problem
- `http://139.59.85.102/` works fine
- `http://www.trackmyexpenses.in` doesn't work
- CORS error: "No 'Access-Control-Allow-Origin' header is present on the requested resource"
- Error occurs when accessing: `http://www.trackmyexpenses.in:8080/api/auth/login`

## Root Cause
1. **Nginx wasn't starting**: SSL certificates didn't exist, causing Nginx to crash
2. **Port 8080 requests bypassed Nginx**: When Nginx wasn't running, requests went directly to API container (no CORS headers)
3. **CORS headers not being set**: Even when Nginx was running, CORS headers might not have been properly configured for the domain

## Solutions Applied

### 1. Fixed Nginx Startup Issue
- **Commented out HTTPS server block** temporarily (until SSL certificates are ready)
- **Updated HTTP server block** to serve content instead of redirecting
- **Added IP address to server_name** so both domain and IP work

### 2. Enhanced Port 8080 CORS Configuration
- **Added `default_server`** to port 8080 listener to catch all requests
- **Added IP address and catch-all** to server_name: `trackmyexpenses.in www.trackmyexpenses.in 139.59.85.102 _`
- **Ensured CORS headers are added** with `always` flag to override any backend headers
- **Proper OPTIONS handling** for preflight requests

### 3. Current Configuration

**HTTP Server (Port 80):**
- Serves UI and API through `/api/` route
- Handles: `trackmyexpenses.in`, `www.trackmyexpenses.in`, and `139.59.85.102`
- CORS headers configured

**Port 8080 Server:**
- Handles direct API access
- CORS headers configured for all origins
- Catches all requests (default_server)

## Testing

### Test 1: Check Nginx is Running
```bash
docker-compose ps nginx
```
Should show: `Up` status

### Test 2: Test CORS Preflight (Port 8080)
```bash
curl -X OPTIONS http://www.trackmyexpenses.in:8080/api/auth/login \
     -H "Origin: http://www.trackmyexpenses.in" \
     -H "Access-Control-Request-Method: POST" \
     -v
```

Expected: Should return 204 with CORS headers including `Access-Control-Allow-Origin: http://www.trackmyexpenses.in`

### Test 3: Test Actual Request (Port 8080)
```bash
curl -X POST http://www.trackmyexpenses.in:8080/api/auth/login \
     -H "Origin: http://www.trackmyexpenses.in" \
     -H "Content-Type: application/json" \
     -d '{"username":"test","password":"test"}' \
     -v
```

Expected: Should include `Access-Control-Allow-Origin: http://www.trackmyexpenses.in` header

## Frontend Configuration

### Recommended: Use Port 80 (Through Nginx)
Update your frontend to use:
```javascript
const API_BASE_URL = 'http://www.trackmyexpenses.in/api';
// or
const API_BASE_URL = '/api'; // Relative path (same origin)
```

### Alternative: Use Port 8080 (Direct API Access)
If you must use port 8080:
```javascript
const API_BASE_URL = 'http://www.trackmyexpenses.in:8080/api';
```

## Verification Steps

1. **Check Nginx is running:**
   ```bash
   docker-compose ps nginx
   ```

2. **Check Nginx logs:**
   ```bash
   docker-compose logs nginx | tail -20
   ```

3. **Test from browser console:**
   ```javascript
   fetch('http://www.trackmyexpenses.in:8080/api/auth/login', {
     method: 'OPTIONS',
     headers: {
       'Origin': 'http://www.trackmyexpenses.in',
       'Access-Control-Request-Method': 'POST'
     }
   }).then(r => {
     console.log('CORS Headers:', r.headers.get('Access-Control-Allow-Origin'));
   });
   ```

## If Issue Persists

1. **Check if requests are reaching Nginx:**
   ```bash
   docker-compose logs -f nginx
   ```
   Then make a request and see if it appears in logs

2. **Verify DNS is pointing correctly:**
   ```bash
   nslookup www.trackmyexpenses.in
   ```
   Should resolve to `139.59.85.102`

3. **Test direct IP access:**
   ```bash
   curl -v http://139.59.85.102:8080/api/auth/login
   ```

4. **Check if port 8080 is accessible:**
   ```bash
   netstat -tuln | grep 8080
   # or
   docker port budget_tracker_nginx
   ```

## Next Steps

Once SSL certificates are ready:
1. Uncomment the HTTPS server block in `nginx.conf`
2. Uncomment the redirect line in HTTP server block
3. Restart Nginx

See `SSL_SETUP.md` for SSL certificate generation instructions.

