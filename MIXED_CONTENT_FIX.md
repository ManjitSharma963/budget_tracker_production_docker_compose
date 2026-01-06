# Mixed Content Fix for Production

## Problem
- Page loads over HTTPS: `https://www.trackmyexpenses.in/`
- API call uses HTTP: `http://www.trackmyexpenses.in:8080/api/auth/login`
- Browser blocks mixed content (HTTPS page cannot load HTTP resources)

## Solution

### Option 1: Use HTTPS on Port 443 (Recommended)
**Update your frontend to use HTTPS on port 443:**

```javascript
// Instead of:
const API_BASE_URL = 'http://www.trackmyexpenses.in:8080/api';

// Use:
const API_BASE_URL = 'https://www.trackmyexpenses.in/api';
// or use relative path (same origin):
const API_BASE_URL = '/api';
```

**Benefits:**
- Same origin (no CORS issues)
- No mixed content warnings
- Standard HTTPS port (443)
- Better security

### Option 2: Keep Port 8080 (Not Recommended)
If you must use port 8080, update to HTTPS:

```javascript
// Change from HTTP to HTTPS:
const API_BASE_URL = 'https://www.trackmyexpenses.in:8080/api';
```

**Note:** Port 8080 HTTP will automatically redirect to HTTPS on port 443.

## Nginx Configuration Changes

### 1. HTTP Server (Port 80)
- **Redirects all HTTP traffic to HTTPS**
- Handles: `trackmyexpenses.in`, `www.trackmyexpenses.in`, and `139.59.85.102`

### 2. HTTPS Server (Port 443)
- **Serves UI and API over HTTPS**
- API accessible at: `https://www.trackmyexpenses.in/api/*`
- Full CORS support enabled

### 3. Port 8080 Server
- **HTTP requests redirect to HTTPS on port 443**
- This ensures all traffic uses HTTPS

## Frontend Configuration Update

### React.js Frontend Example

**File: `src/config/api.js` or similar**

```javascript
// Production API Configuration
const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://www.trackmyexpenses.in/api';

// Or use relative path (recommended):
const API_BASE_URL = '/api';

export default API_BASE_URL;
```

**File: `src/services/api.js` or similar**

```javascript
import API_BASE_URL from '../config/api';

// Example API call
export const login = async (credentials) => {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    credentials: 'include', // Important for CORS with credentials
    body: JSON.stringify(credentials),
  });
  
  return response.json();
};
```

### Environment Variables

**File: `.env.production`**

```env
REACT_APP_API_URL=https://www.trackmyexpenses.in/api
```

**File: `.env` (development)**

```env
REACT_APP_API_URL=http://localhost:8080/api
```

## Testing

### 1. Test HTTPS API on Port 443
```bash
curl -X POST https://www.trackmyexpenses.in/api/auth/login \
     -H "Content-Type: application/json" \
     -H "Origin: https://www.trackmyexpenses.in" \
     -d '{"username":"test","password":"test"}' \
     -v
```

### 2. Test HTTP Redirect (Port 8080)
```bash
curl -I http://www.trackmyexpenses.in:8080/api/auth/login
```

Expected: `301 Moved Permanently` with `Location: https://www.trackmyexpenses.in/api/auth/login`

### 3. Test from Browser Console
```javascript
// Test API call
fetch('https://www.trackmyexpenses.in/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  credentials: 'include',
  body: JSON.stringify({username: 'test', password: 'test'})
})
.then(r => r.json())
.then(data => console.log('Success:', data))
.catch(err => console.error('Error:', err));
```

## Deployment Steps

1. **Update Frontend Code:**
   - Change API URL from `http://www.trackmyexpenses.in:8080/api` to `https://www.trackmyexpenses.in/api`
   - Or use relative path: `/api`

2. **Rebuild Frontend:**
   ```bash
   npm run build
   ```

3. **Restart Nginx (on production server):**
   ```bash
   docker-compose restart nginx
   ```

4. **Verify SSL Certificates:**
   ```bash
   # Check if certificates exist
   ls -la /etc/letsencrypt/live/trackmyexpenses.in/
   
   # Should show:
   # - fullchain.pem
   # - privkey.pem
   ```

5. **Test the Application:**
   - Open `https://www.trackmyexpenses.in`
   - Check browser console for any errors
   - Verify API calls work correctly

## Troubleshooting

### Issue: "SSL certificate not found"
**Solution:** Ensure SSL certificates are generated and mounted:
```bash
# Check certificate path
docker exec budget_tracker_nginx ls -la /etc/letsencrypt/live/trackmyexpenses.in/
```

### Issue: "Mixed Content" still appears
**Solution:** 
1. Clear browser cache
2. Check that frontend is using HTTPS URLs
3. Verify Nginx is serving HTTPS correctly

### Issue: "CORS error"
**Solution:**
- Ensure frontend uses `credentials: 'include'` in fetch requests
- Verify CORS headers in Nginx response
- Check that origin matches allowed origins

## Summary

**Best Practice:**
- Use `https://www.trackmyexpenses.in/api` (port 443)
- Or use relative path `/api` (same origin)
- Avoid using port 8080 in production

**Current Configuration:**
- ✅ HTTP (port 80) → Redirects to HTTPS
- ✅ HTTPS (port 443) → Serves UI and API
- ✅ HTTP (port 8080) → Redirects to HTTPS (port 443)

