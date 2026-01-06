# SSL/HTTPS Setup Guide

## Current Status

The Nginx configuration is set up for HTTPS with Let's Encrypt certificates, but the certificates don't exist yet. This is preventing Nginx from starting.

## Option 1: Generate SSL Certificates First (Recommended)

### Using Certbot (Let's Encrypt)

1. **Install Certbot** (if not already installed):
   ```bash
   sudo apt-get update
   sudo apt-get install certbot
   ```

2. **Stop Nginx temporarily** (if running):
   ```bash
   docker-compose stop nginx
   ```

3. **Generate certificates**:
   ```bash
   sudo certbot certonly --standalone -d trackmyexpenses.in -d www.trackmyexpenses.in
   ```

4. **Certificates will be stored in**:
   - `/etc/letsencrypt/live/trackmyexpenses.in/fullchain.pem`
   - `/etc/letsencrypt/live/trackmyexpenses.in/privkey.pem`

5. **Start Nginx**:
   ```bash
   docker-compose start nginx
   ```

### Using Docker with Certbot

```bash
docker run -it --rm \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  -p 80:80 \
  certbot/certbot certonly --standalone \
  -d trackmyexpenses.in -d www.trackmyexpenses.in
```

## Option 2: Temporary HTTP-Only Configuration

If you need to start Nginx before certificates are ready, you can temporarily comment out the SSL server block and use HTTP only.

## Option 3: Use Self-Signed Certificates (Development Only)

For testing purposes, you can generate self-signed certificates:

```bash
sudo mkdir -p /etc/letsencrypt/live/trackmyexpenses.in
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/letsencrypt/live/trackmyexpenses.in/privkey.pem \
  -out /etc/letsencrypt/live/trackmyexpenses.in/fullchain.pem
```

## Verification

After certificates are in place:

1. **Check certificate files exist**:
   ```bash
   ls -la /etc/letsencrypt/live/trackmyexpenses.in/
   ```

2. **Restart Nginx**:
   ```bash
   docker-compose restart nginx
   ```

3. **Check Nginx status**:
   ```bash
   docker-compose logs nginx
   ```

4. **Test HTTPS**:
   ```bash
   curl -I https://www.trackmyexpenses.in
   ```

## Important Notes

- **Port 80 must be open** for Let's Encrypt validation
- **Domain must point to your server** (DNS configured)
- **Certificates expire every 90 days** - set up auto-renewal
- **The `/etc/letsencrypt` directory must be accessible** to the Docker container

## Auto-Renewal Setup

Set up a cron job to renew certificates:

```bash
# Add to crontab (crontab -e)
0 0 * * * certbot renew --quiet && docker-compose restart nginx
```

