# 🚀 Production Deployment Guide — Django Portfolio

**Droplet IP**: 143.110.254.96  
**Domain**: your-domain.com (from Namecheap)  
**Setup**: Shared DigitalOcean droplet (multiple sites on same server)

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Server Preparation](#server-preparation)
3. [Git Setup](#git-setup)
4. [Django Configuration](#django-configuration)
5. [Gunicorn Setup](#gunicorn-setup)
6. [Nginx Configuration](#nginx-configuration)
7. [SSL/HTTPS Setup](#sslhttps-setup)
8. [Deployment](#deployment)
9. [Monitoring & Maintenance](#monitoring--maintenance)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### On Your Local Machine
- [ ] Git repository initialized (with remote origin)
- [ ] All changes committed
- [ ] `.env.example` file reviewed and ready

### On DigitalOcean Droplet
- [ ] SSH key access configured
- [ ] Nginx installed
- [ ] Python 3.9+ installed
- [ ] Existing portfolio site already running (to learn from)
- [ ] 1GB RAM available (portfolio uses ~100-150MB)

---

## Server Preparation

### 1. SSH into Droplet

```bash
ssh root@143.110.254.96
```

### 2. Create Portfolio User & Directory

```bash
# Create dedicated user
sudo useradd -m -s /bin/bash portfolio
sudo usermod -aG sudo portfolio

# Create app directory
sudo mkdir -p /home/portfolio/app
sudo mkdir -p /home/portfolio/logs
sudo chown -R portfolio:portfolio /home/portfolio

# Switch to portfolio user
sudo su - portfolio
```

### 3. Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv python3-dev
sudo apt install -y build-essential libpq-dev  # For PostgreSQL (optional)
sudo apt install -y git curl wget
```

### 4. Create Python Virtual Environment

```bash
cd /home/portfolio
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
```

---

## Git Setup

### 1. Clone Repository (As Portfolio User)

```bash
cd /home/portfolio/app
git clone https://github.com/your-username/portfolio.git .
# Or if using HTTPS:
# git clone https://github.com/your-username/portfolio.git .
```

### 2. Set Git Remote (if needed)

```bash
git remote set-url origin https://github.com/your-username/portfolio.git
# Or for SSH (requires SSH keys):
# git remote set-url origin git@github.com:your-username/portfolio.git
```

### 3. Configure Git (one-time)

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@gmail.com"
```

---

## Django Configuration

### 1. Activate Virtual Environment

```bash
cd /home/portfolio/app
source /home/portfolio/venv/bin/activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Create & Configure .env File

```bash
cp .env.example .env
nano .env  # Edit with your values
```

**Required values in .env**:
```env
DEBUG=False
SECRET_KEY=your-very-long-secure-random-string-here
ALLOWED_HOSTS=your-domain.com,www.your-domain.com,143.110.254.96

# For production, use strong secret key:
# python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

**To generate a strong SECRET_KEY**:
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copy the output to your .env file.

### 4. Create Logs Directory

```bash
mkdir -p /home/portfolio/logs
touch /home/portfolio/logs/django.log
touch /home/portfolio/logs/gunicorn_access.log
touch /home/portfolio/logs/gunicorn_error.log
```

### 5. Run Migrations

```bash
cd /home/portfolio/app
export DJANGO_SETTINGS_MODULE=portfolio.settings_production
python manage.py migrate
```

### 6. Create Superuser

```bash
python manage.py createsuperuser
# Follow prompts to create admin account
```

### 7. Collect Static Files

```bash
python manage.py collectstatic --noinput
```

### 8. Test Django Settings

```bash
python manage.py check --deploy
```

---

## Gunicorn Setup

### 1. Create Gunicorn Socket Directory

```bash
sudo mkdir -p /run/gunicorn
sudo chown portfolio:www-data /run/gunicorn
sudo chmod 775 /run/gunicorn
```

### 2. Create Systemd Socket File

Create `/etc/systemd/system/gunicorn-portfolio.socket`:

```ini
[Unit]
Description=gunicorn socket for portfolio

[Socket]
ListenStream=/run/gunicorn/portfolio.sock
User=portfolio
Group=www-data
SocketMode=0660

[Install]
WantedBy=sockets.target
```

### 3. Create Systemd Service File

Create `/etc/systemd/system/portfolio.service`:

```ini
[Unit]
Description=Gunicorn Application Server for Django Portfolio
After=network.target gunicorn-portfolio.socket

[Service]
Type=notify
User=portfolio
Group=www-data
WorkingDirectory=/home/portfolio/app
Environment="PATH=/home/portfolio/venv/bin"
Environment="DJANGO_SETTINGS_MODULE=portfolio.settings_production"
EnvironmentFile=/home/portfolio/app/.env

ExecStart=/home/portfolio/venv/bin/gunicorn \
    --config /home/portfolio/app/gunicorn_config.py \
    --workers 4 \
    --bind unix:/run/gunicorn/portfolio.sock \
    portfolio.wsgi:application

Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

### 4. Enable and Start Gunicorn

```bash
sudo systemctl daemon-reload
sudo systemctl enable gunicorn-portfolio.socket portfolio.service
sudo systemctl start gunicorn-portfolio.socket portfolio.service
sudo systemctl status portfolio
```

---

## Nginx Configuration

### 1. Create Nginx Configuration

Create `/etc/nginx/sites-available/portfolio`:

Use the provided `nginx_config_template.conf` and replace:
- `DOMAIN.COM` → your actual domain (e.g., `harshit-portfolio.com`)

```bash
sudo nano /etc/nginx/sites-available/portfolio
# Paste the template content, edit DOMAIN.COM
```

### 2. Enable Site

```bash
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/portfolio
```

### 3. Test Nginx Configuration

```bash
sudo nginx -t
```

Should output: `nginx: configuration file test is successful`

### 4. Reload Nginx

```bash
sudo systemctl reload nginx
```

---

## SSL/HTTPS Setup

### 1. Install Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 2. Generate SSL Certificate

```bash
sudo certbot certonly --nginx -d your-domain.com -d www.your-domain.com
```

Follow the prompts:
- Enter your email
- Agree to terms
- Choose webroot or standalone

Certbot will save certificates at:
- Certificate: `/etc/letsencrypt/live/your-domain.com/fullchain.pem`
- Key: `/etc/letsencrypt/live/your-domain.com/privkey.pem`

### 3. Verify Nginx Configuration Uses SSL

The `nginx_config_template.conf` already includes SSL paths. Verify in `/etc/nginx/sites-available/portfolio`:

```nginx
ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
```

### 4. Reload Nginx

```bash
sudo systemctl reload nginx
```

### 5. Set Up Auto-Renewal of SSL

```bash
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
sudo systemctl status certbot.timer
```

Test renewal dry-run:
```bash
sudo certbot renew --dry-run
```

---

## DNS Configuration (Namecheap)

### 1. Log into Namecheap

Visit: https://www.namecheap.com/myaccount/login/

### 2. Go to Dashboard → Manage Domains

### 3. Click on Your Domain → Advanced DNS

### 4. Add A Records

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 143.110.254.96 | 30 min |
| A | www | 143.110.254.96 | 30 min |

### 5. Click "Save All Changes"

⏳ **DNS propagation takes 5-30 minutes**

### 6. Verify DNS Resolution

```bash
dig your-domain.com
nslookup your-domain.com
```

---

## Final Deployment

### 1. Test Everything Locally First

```bash
# On your droplet, test that Django, Gunicorn, and Nginx all work
sudo systemctl status portfolio
sudo systemctl status nginx
curl http://localhost  # Should return HTML
```

### 2. Make Deploy Script Executable

```bash
chmod +x /home/portfolio/app/deploy.sh
```

### 3. Run Initial Setup

```bash
cd /home/portfolio/app
source /home/portfolio/venv/bin/activate
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput
```

### 4. Restart Services

```bash
sudo systemctl restart portfolio
sudo systemctl reload nginx
```

### 5. Test Your Site

```bash
# Before DNS propagates, test with IP
curl -H "Host: your-domain.com" http://143.110.254.96

# After DNS propagates, visit in browser
https://your-domain.com
https://your-domain.com/admin/  # Admin panel
```

---

## Monitoring & Maintenance

### View Logs

```bash
# Django logs
tail -f /home/portfolio/logs/django.log

# Gunicorn logs
sudo journalctl -u portfolio -f

# Nginx logs
sudo tail -f /var/log/nginx/portfolio_error.log
sudo tail -f /var/log/nginx/portfolio_access.log

# Systemd service logs
sudo systemctl status portfolio -l
```

### Restart Services

```bash
# Restart Gunicorn
sudo systemctl restart portfolio

# Reload Nginx (no downtime)
sudo systemctl reload nginx

# Restart both
sudo systemctl restart portfolio && sudo systemctl reload nginx
```

### Database Backups

```bash
# Backup SQLite database
cp /home/portfolio/app/db.sqlite3 /home/portfolio/app/db.sqlite3.backup

# Schedule daily backups (optional - add to crontab)
# 0 2 * * * cp /home/portfolio/app/db.sqlite3 /home/portfolio/backups/db.sqlite3.$(date +\%Y\%m\%d)
```

### Update Code from Git

```bash
cd /home/portfolio/app
git pull origin main
source /home/portfolio/venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart portfolio
```

---

## Troubleshooting

### Issue: "502 Bad Gateway"

**Check Gunicorn**:
```bash
sudo systemctl status portfolio
sudo journalctl -u portfolio -n 20
```

**Check socket file exists**:
```bash
ls -la /run/gunicorn/portfolio.sock
```

**Check permissions**:
```bash
sudo chown portfolio:www-data /run/gunicorn/portfolio.sock
sudo chmod 660 /run/gunicorn/portfolio.sock
```

### Issue: "403 Forbidden"

**Check Nginx error log**:
```bash
sudo tail -f /var/log/nginx/portfolio_error.log
```

**Verify permissions on static files**:
```bash
sudo chown -R portfolio:www-data /home/portfolio/app
sudo chmod -R 755 /home/portfolio/app
```

### Issue: SSL Certificate Not Working

**Verify certificate exists**:
```bash
ls -la /etc/letsencrypt/live/your-domain.com/
```

**Check Nginx syntax**:
```bash
sudo nginx -t
```

**Renew certificate manually**:
```bash
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

### Issue: Static Files Not Loading

**Collect static files**:
```bash
cd /home/portfolio/app
source /home/portfolio/venv/bin/activate
python manage.py collectstatic --noinput --clear
sudo systemctl restart portfolio
```

**Check permissions**:
```bash
ls -la /home/portfolio/app/staticfiles/
```

### Issue: Database Locked (SQLite)

**Restart Django**:
```bash
sudo systemctl restart portfolio
```

**Consider upgrading to PostgreSQL for production** (see Install PostgreSQL section below).

---

## Advanced: Install PostgreSQL (Optional)

SQLite works fine for small portfolios, but PostgreSQL is more robust for production:

```bash
# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Create database and user
sudo -u postgres psql << EOF
CREATE DATABASE portfolio_db;
CREATE USER portfolio_user WITH PASSWORD 'secure_password';
ALTER ROLE portfolio_user SET client_encoding TO 'utf8';
ALTER ROLE portfolio_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE portfolio_user SET default_transaction_deferrable TO on;
ALTER ROLE portfolio_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE portfolio_db TO portfolio_user;
\q
EOF

# Update .env
nano /home/portfolio/app/.env
# Change:
# DB_ENGINE=django.db.backends.postgresql
# DB_NAME=portfolio_db
# DB_USER=portfolio_user
# DB_PASSWORD=secure_password
# DB_HOST=localhost
# DB_PORT=5432

# Migrate
cd /home/portfolio/app
python manage.py migrate
```

---

## Summary Checklist

- [ ] SSH key access to 143.110.254.96 working
- [ ] Portfolio user created on droplet
- [ ] Python virtual environment set up
- [ ] Repository cloned to `/home/portfolio/app`
- [ ] `.env` file configured with SECRET_KEY, ALLOWED_HOSTS
- [ ] Database migrations run
- [ ] Static files collected
- [ ] Gunicorn service configured and running
- [ ] Nginx site configuration created
- [ ] SSL certificate issued by Certbot
- [ ] DNS records updated at Namecheap
- [ ] Domain resolves to 143.110.254.96
- [ ] Site loads at https://your-domain.com
- [ ] Admin panel at https://your-domain.com/admin/

---

## Quick Deploy Command (After Initial Setup)

```bash
cd /home/portfolio/app
git pull origin main
source /home/portfolio/venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart portfolio
```

---

## Need Help?

- Check logs: `sudo journalctl -u portfolio -f`
- Test Nginx: `sudo nginx -t`
- SSH into droplet: `ssh root@143.110.254.96`
- Django check: `python manage.py check --deploy`

---

**Last Updated**: 2024-03-22
