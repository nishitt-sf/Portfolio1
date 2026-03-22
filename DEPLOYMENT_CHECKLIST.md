# Quick Start Deployment Checklist

## Pre-Deployment (Local Machine)

- [ ] All code committed to git: `git status` shows clean
- [ ] No secrets in code (no hardcoded passwords)
- [ ] `.env.example` file created and reviewed
- [ ] `requirements.txt` updated with all dependencies
- [ ] README.md updated with project description
- [ ] Repository pushed to GitHub/GitLab

## DigitalOcean Droplet Setup (143.110.254.96)

### 1. Initial Server Setup (5 minutes)

```bash
# SSH into droplet
ssh root@143.110.254.96

# Run initial setup script
bash initial_setup.sh

# OR manually:
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv nginx git certbot python3-certbot-nginx
sudo useradd -m -s /bin/bash portfolio
sudo mkdir -p /home/portfolio/app /home/portfolio/logs
sudo chown -R portfolio:portfolio /home/portfolio
```

- [ ] System updated
- [ ] Dependencies installed
- [ ] Portfolio user created
- [ ] App directories created

### 2. Clone & Configure Django (10 minutes)

```bash
# As root
sudo -u portfolio git clone https://github.com/YOUR_USERNAME/portfolio.git /home/portfolio/app

# Switch to portfolio user
sudo su - portfolio

# Create virtual environment
python3 -m venv /home/portfolio/venv
source /home/portfolio/venv/bin/activate

# Install dependencies
cd /home/portfolio/app
pip install -r requirements.txt

# Configure .env
cp .env.example .env
nano .env  # Edit with your values
```

- [ ] Repository cloned
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] `.env` file configured with:
  - [ ] `SECRET_KEY` (generate with: `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`)
  - [ ] `ALLOWED_HOSTS` (your domain + www, and IP)
  - [ ] `DEBUG=False`

### 3. Django Setup (10 minutes)

```bash
# While in virtual environment
export DJANGO_SETTINGS_MODULE=portfolio.settings_production

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Collect static files
python manage.py collectstatic --noinput

# Check for errors
python manage.py check --deploy

# Create logs directory
mkdir -p /home/portfolio/logs
```

- [ ] Migrations completed
- [ ] Superuser account created
- [ ] Static files collected
- [ ] No deployment errors

### 4. Gunicorn Setup (5 minutes)

```bash
# Back as root
exit  # Exit portfolio user

# Create socket directory
sudo mkdir -p /run/gunicorn
sudo chown portfolio:www-data /run/gunicorn
sudo chmod 775 /run/gunicorn

# Copy Gunicorn config
sudo cp /home/portfolio/app/gunicorn_config.py /home/portfolio/app/

# Create systemd service
sudo nano /etc/systemd/system/portfolio.service
# Paste content from: portfolio.service.template
```

- [ ] Socket directory created
- [ ] Gunicorn config copied
- [ ] Systemd service file created

### 5. Enable & Start Gunicorn (2 minutes)

```bash
sudo systemctl daemon-reload
sudo systemctl enable portfolio.service
sudo systemctl start portfolio.service
sudo systemctl status portfolio
```

Check output - should show: **Active: Enabled and Running**

- [ ] Gunicorn enabled
- [ ] Gunicorn started successfully

### 6. Nginx Configuration (5 minutes)

```bash
# Copy Nginx config template
sudo cp /home/portfolio/app/nginx_config_template.conf /etc/nginx/sites-available/portfolio

# Edit and replace DOMAIN.COM with your actual domain
sudo nano /etc/nginx/sites-available/portfolio

# Enable site
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/portfolio

# Test Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

- [ ] Nginx config created
- [ ] Domain name replaced
- [ ] Nginx config test passed
- [ ] Nginx reloaded

### 7. Domain Setup (Namecheap) (5 minutes)

1. Go to https://www.namecheap.com/myaccount/login/
2. Dashboard → Manage Domains → Your Domain → Advanced DNS
3. Add these records:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 143.110.254.96 | 30 min |
| A | www | 143.110.254.96 | 30 min |

4. Click "Save All Changes"
5. Wait 5-30 minutes for DNS propagation

- [ ] A record for @ created
- [ ] A record for www created
- [ ] DNS changes saved

### 8. SSL/HTTPS Setup (2 minutes)

```bash
# Generate SSL certificate
sudo certbot certonly --nginx -d your-domain.com -d www.your-domain.com

# Follow prompts, use standalone method if needed
```

- [ ] SSL certificate issued
- [ ] Certificate path in Nginx config verified
- [ ] Nginx reloaded

### 9. Final Verification (5 minutes)

```bash
# Test HTTP
curl -v http://your-domain.com

# After DNS propagates, visit in browser:
https://your-domain.com
https://your-domain.com/admin/

# Check logs
sudo tail -f /var/log/nginx/portfolio_error.log
sudo tail -f /var/log/nginx/portfolio_access.log
sudo journalctl -u portfolio -f
```

- [ ] HTTP works (should redirect to HTTPS)
- [ ] HTTPS works (secure connection)
- [ ] Admin panel loads
- [ ] No errors in logs

## Post-Deployment

### Scheduled Tasks

```bash
# Edit crontab as portfolio user
sudo -u portfolio crontab -e

# Add monitoring check every 5 minutes:
*/5 * * * * /home/portfolio/app/monitoring.sh

# Add database backup daily at 2 AM:
0 2 * * * cp /home/portfolio/app/db.sqlite3 /home/portfolio/backups/db.sqlite3.$(date +\%Y\%m\%d)
```

- [ ] Monitoring scheduled
- [ ] Backups scheduled

### Content Management

1. Log in to admin: https://your-domain.com/admin/
2. Add your portfolio content:
   - [ ] Profile information
   - [ ] Skills
   - [ ] Projects
   - [ ] Experience
   - [ ] Education
   - [ ] Services
   - [ ] Testimonials

### Maintenance

```bash
# Update code from git
cd /home/portfolio/app
git pull origin main
source /home/portfolio/venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
sudo systemctl restart portfolio

# View logs
tail -f /home/portfolio/logs/django.log
sudo journalctl -u portfolio -n 50
```

## Troubleshooting Quick Links

- **502 Bad Gateway**: Check Gunicorn: `sudo systemctl status portfolio`
- **SSL Problems**: Run `sudo certbot renew --dry-run`
- **Static Files Not Loading**: Run `python manage.py collectstatic --noinput --clear`
- **Database Locked**: Restart Django: `sudo systemctl restart portfolio`

---

**Total Setup Time: ~45-60 minutes**
**Ongoing Maintenance: ~5 minutes/week**

For detailed instructions, see: [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)
