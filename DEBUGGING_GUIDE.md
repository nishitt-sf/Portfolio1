# 📚 Debugging Guide for Django Portfolio Deployment

Common issues and solutions for production deployment.

## 502 Bad Gateway

### Symptoms
- Browser shows "502 Bad Gateway"
- Nginx error log shows upstream connection refused

### Solutions

**1. Check Gunicorn Status**
```bash
sudo systemctl status portfolio
sudo journalctl -u portfolio -n 20
```

**2. Check Socket File**
```bash
ls -la /run/gunicorn/portfolio.sock
# Should exist and have 660 permissions
```

**3. Fix Permissions**
```bash
sudo chown portfolio:www-data /run/gunicorn/portfolio.sock
sudo chmod 660 /run/gunicorn/portfolio.sock
```

**4. Restart Services**
```bash
sudo systemctl restart portfolio
sudo systemctl reload nginx
```

---

## 403 Forbidden

### Symptoms
- Files won't load (CSS, JS, images)
- Admin page gives 403

### Solutions

**1. Check File Permissions**
```bash
ls -la /home/portfolio/app/staticfiles/
# Should be readable by www-data
```

**2. Fix Permissions**
```bash
sudo chown -R portfolio:www-data /home/portfolio/app
sudo chmod -R 755 /home/portfolio/app
sudo chmod -R 755 /home/portfolio/app/staticfiles
```

**3. Recollect Static Files**
```bash
cd /home/portfolio/app
source /home/portfolio/venv/bin/activate
python manage.py collectstatic --noinput --clear
```

---

## Static Files Not Loading

### Symptoms
- CSS/JS/images don't load
- Browser console shows 404 errors for `/static/...`

### Solutions

**1. Verify Static Files Were Collected**
```bash
ls -la /home/portfolio/app/staticfiles/
# Should contain css/, js/, admin/, etc.
```

**2. Check Nginx Configuration**
```bash
sudo nano /etc/nginx/sites-available/portfolio
# Verify location /static/ block points to correct path:
# alias /home/portfolio/app/staticfiles/;
```

**3. Test Nginx Configuration**
```bash
sudo nginx -t
# Should show: nginx: configuration file test is successful
```

**4. Clear Browser Cache**
```
Ctrl+Shift+Delete or Cmd+Shift+Delete
```

---

## SSL/HTTPS Not Working

### Symptoms
- Browser shows security warning
- Can't access https://your-domain.com

### Solutions

**1. Check Certificate Exists**
```bash
sudo ls -la /etc/letsencrypt/live/your-domain.com/
# Should exist with fullchain.pem and privkey.pem
```

**2. Check Nginx SSL Configuration**
```bash
sudo nano /etc/nginx/sites-available/portfolio
# Verify:
# ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
```

**3. Test Nginx Configuration**
```bash
sudo nginx -t
```

**4. Renew Certificate**
```bash
sudo certbot renew --force-renewal
```

**5. Reload Nginx**
```bash
sudo systemctl reload nginx
```

---

## Database "database is locked" Error

### Symptoms
- 500 errors in Django
- Logs show "database is locked"
- This happens only with SQLite

### Solutions

**1. Restart Django**
```bash
sudo systemctl restart portfolio
```

**2. Check for Long-Running Queries**
```bash
# If using PostgreSQL:
sudo -u postgres psql -d portfolio_db -c "SELECT * FROM pg_stat_activity WHERE state != 'idle';"
```

**3. Upgrade to PostgreSQL (Recommended for Production)**

See PRODUCTION_DEPLOYMENT.md → "Advanced: Install PostgreSQL"

---

## "Connection refused" when accessing site

### Symptoms
- `curl: (7) Failed to connect`
- Site not reachable on port 80 or 443

### Solutions

**1. Check Nginx is Running**
```bash
sudo systemctl status nginx
sudo systemctl start nginx
```

**2. Check Port Binding**
```bash
sudo netstat -tlnp | grep nginx
# Should show listening on ports 80 and 443
```

**3. Check Firewall Rules**
```bash
sudo ufw status
# Should show:
# 22/tcp       ALLOW
# 80/tcp       ALLOW
# 443/tcp      ALLOW

# If needed:
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## Admin Panel Won't Load

### Symptoms
- `/admin/` gives 500 error
- Logs show database errors

### Solutions

**1. Check Database Migrations**
```bash
cd /home/portfolio/app
source /home/portfolio/venv/bin/activate
export DJANGO_SETTINGS_MODULE=portfolio.settings_production
python manage.py migrate --check
# Should show all migrations applied

# If not:
python manage.py migrate
```

**2. Create Admin User**
```bash
python manage.py createsuperuser
```

**3. Restart Django**
```bash
sudo systemctl restart portfolio
```

---

## Media Files (Uploads) Not Working

### Symptoms
- Uploaded images don't show
- 404 errors for `/media/...`

### Solutions

**1. Check Media Directory Exists**
```bash
ls -la /home/portfolio/app/media/
# Should have subdirectories: avatars/, resume/, etc.
```

**2. Fix Permissions**
```bash
sudo chown -R portfolio:www-data /home/portfolio/app/media
sudo chmod -R 755 /home/portfolio/app/media
```

**3. Check Nginx Configuration**
```bash
sudo nano /etc/nginx/sites-available/portfolio
# Verify location /media/ block:
# location /media/ {
#     alias /home/portfolio/app/media/;
# }
```

**4. Reload Nginx**
```bash
sudo systemctl reload nginx
```

---

## High Memory Usage / Site Crashes

### Symptoms
- Server becomes unresponsive
- SSH connection times out
- Gunicorn process killed

### Solutions

**1. Check Memory Usage**
```bash
free -h
ps aux | grep python
# Look for memory % column

# Check swap
swapon -s
```

**2. Reduce Gunicorn Workers**
```bash
sudo nano /etc/systemd/system/portfolio.service
# Change workers: --workers 2  (reduce from 4)

sudo systemctl daemon-reload
sudo systemctl restart portfolio
```

**3. Upgrade Droplet (if needed)**
- DigitalOcean Dashboard → Droplet → Resize
- Upgrade from 1GB to 2GB RAM

**4. Enable Process Monitoring**
```bash
# Install htop for monitoring
sudo apt install htop
htop  # Press 'q' to exit
```

---

## Nginx Error Logs Show "Permission denied"

### Symptoms
- Error log: "Permission denied while connecting to upstream"
- 502 Bad Gateway errors

### Solutions

**1. Fix Socket Permissions**
```bash
sudo chown portfolio:www-data /run/gunicorn/portfolio.sock
sudo chmod 660 /run/gunicorn/portfolio.sock
```

**2. Check Nginx User**
```bash
sudo nano /etc/nginx/nginx.conf
# First line should be:
# user www-data;

sudo systemctl reload nginx
```

---

## Django Not Picking Up .env Variables

### Symptoms
- `DEBUG=True` even with `DEBUG=False` in .env
- Settings show default values

### Solutions

**1. Verify DJANGO_SETTINGS_MODULE**
```bash
echo $DJANGO_SETTINGS_MODULE
# Should show: portfolio.settings_production

# If not set in systemd service:
sudo nano /etc/systemd/system/portfolio.service
# Should have:
# Environment="DJANGO_SETTINGS_MODULE=portfolio.settings_production"
```

**2. Verify .env File Location**
```bash
ls -la /home/portfolio/app/.env
# Should exist and be readable
```

**3. Restart Gunicorn**
```bash
sudo systemctl restart portfolio
```

---

## DNS Not Resolving

### Symptoms
- Website won't load when using domain name
- Works with IP: 143.110.254.96
- nslookup shows wrong IP

### Solutions

**1. Check DNS Records**
```bash
nslookup your-domain.com
dig your-domain.com
# Should return: 143.110.254.96
```

**2. Go to Namecheap**
- Dashboard → Manage Domains → Your Domain → Advanced DNS
- Verify A records point to 143.110.254.96
- Click "Save All Changes"

**3. Wait for Propagation**
- DNS can take 5-30 minutes to propagate
- Use online tool: https://dns.google/

**4. Flush Local DNS Cache**
```bash
# On Local Machine:
# macOS: sudo dscacheutil -flushcache
# Linux: sudo systemctl restart systemd-resolved
# Windows: ipconfig /flushdns
```

---

## SSL Certificate Expiration

### Symptoms
- Browser warns "Certificate Expired"
- HTTPS stops working

### Solutions

**1. Check Certificate Status**
```bash
sudo openssl x509 -enddate -noout -in /etc/letsencrypt/live/your-domain.com/cert.pem
```

**2. Renew Certificate**
```bash
sudo certbot renew
sudo systemctl reload nginx
```

**3. Auto-Renewal Check**
```bash
sudo systemctl status certbot.timer
# Should show "active"
```

---

## Getting Help

### View All Logs

```bash
# Django errors
tail -f /home/portfolio/logs/django.log

# Gunicorn errors
sudo journalctl -u portfolio -f

# Nginx access
sudo tail -f /var/log/nginx/portfolio_access.log

# Nginx errors
sudo tail -f /var/log/nginx/portfolio_error.log
```

### Test Configuration

```bash
# Django
cd /home/portfolio/app
python manage.py check --deploy

# Nginx
sudo nginx -t

# Systemd
sudo systemctl status portfolio
sudo systemctl status nginx
```

### Common Commands

```bash
# Restart a service
sudo systemctl restart portfolio
sudo systemctl restart nginx

# View service logs
sudo systemctl status portfolio -l
journalctl -u portfolio -n 50

# Check if ports are open
sudo netstat -tlnp
```

---

**Need more help?** Check the detailed deployment guide:
[PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)
