# 403 Forbidden Error Fix

## Problem
Getting `403 Forbidden` error when accessing:
- `http://www.trackmyexpenses.in:8080/api/auth/login`

## Root Causes

1. **Spring Security Configuration**: Spring Security is blocking the request
2. **CSRF Protection**: CSRF token might be required
3. **Path Mismatch**: The path might not match what Spring Security expects
4. **Authentication Required**: The endpoint might require authentication

## Solutions Applied

### 1. Fixed Nginx Proxy Configuration
Updated `proxy_pass` to preserve the `/api` prefix:
- Changed from: `proxy_pass http://budget_tracker_api:8080/;` (removes `/api`)
- Changed to: `proxy_pass http://budget_tracker_api:8080;` (keeps `/api`)

### 2. Application Properties Configuration
The `application.properties` file includes:
```properties
spring.security.csrf.enabled=false
```

However, if the Spring Boot code has its own security configuration, it might override this.

## Additional Solutions to Try

### Option 1: Check if Path Needs to be Modified

If the Spring Boot app expects paths **without** `/api` prefix, update Nginx:

```nginx
location /api/ {
    proxy_pass http://budget_tracker_api:8080/;  # Removes /api prefix
}
```

If the Spring Boot app expects paths **with** `/api` prefix (current config):

```nginx
location /api/ {
    proxy_pass http://budget_tracker_api:8080;  # Keeps /api prefix
}
```

### Option 2: Update Spring Boot Security Configuration

Since the code is cloned from GitHub, you may need to update the security configuration in the repository to allow public access to `/api/auth/**` endpoints.

The security configuration should include:
```java
@Configuration
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }
}
```

### Option 3: Use Port 80 Instead of 8080

Access the API through Nginx on port 80:
```
http://www.trackmyexpenses.in/api/auth/login
```

This ensures all requests go through Nginx with proper CORS headers.

### Option 4: Check API Logs for Detailed Error

```bash
docker-compose logs -f budget_tracker_production_api
```

Look for Spring Security error messages that indicate why the request is being blocked.

## Testing

### Test 1: Check if endpoint exists
```bash
# From inside the API container
docker exec budget_tracker_api wget -O- http://localhost:8080/api/auth/login
```

### Test 2: Test with curl (if available)
```bash
curl -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"test","password":"test"}' \
     -v
```

### Test 3: Check Nginx proxy
```bash
# Check if Nginx is forwarding correctly
docker exec budget_tracker_nginx cat /var/log/nginx/access.log | tail -20
```

## Current Configuration Status

✅ Nginx is listening on port 8080
✅ CORS headers are configured
✅ Proxy pass is configured to keep `/api` prefix
✅ Application properties has CSRF disabled

## Next Steps

1. **Check API Logs**: Look for Spring Security error messages
2. **Verify Endpoint Path**: Confirm if Spring Boot expects `/api/auth/login` or `/auth/login`
3. **Update Security Config**: If needed, update the Spring Boot security configuration in the GitHub repository
4. **Test Alternative Path**: Try accessing without `/api` prefix if the app doesn't use it

## If Issue Persists

The 403 error is likely coming from Spring Security configuration in the Spring Boot code. Since the code is cloned from GitHub, you may need to:

1. Fork/update the repository
2. Modify the security configuration to allow public access to auth endpoints
3. Rebuild the Docker image

Or contact the repository maintainer to fix the security configuration.

