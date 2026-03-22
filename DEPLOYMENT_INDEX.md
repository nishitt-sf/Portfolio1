# 🌍 Deployment & Hosting Guide Index

**This Django Portfolio is ready to deploy on DigitalOcean with a custom domain.**

---

## 📚 Documentation Files (Read in This Order)

### 0. **Domain & DNS Setup** 🌐 START HERE IF NO DOMAIN YET
- **[DOMAIN_SETUP_GUIDE.md](DOMAIN_SETUP_GUIDE.md)** — Step-by-step: Buy domain from Namecheap + Connect to droplet (29 steps)
- **[DOMAIN_QUICK_REFERENCE.md](DOMAIN_QUICK_REFERENCE.md)** — 2-minute TL;DR version

### 1. **Start Here** 📍
- **[DEPLOYMENT_FILES_SUMMARY.md](DEPLOYMENT_FILES_SUMMARY.md)** — Overview of all deployment files and what each does

### 2. **Main Deployment Guide**
- **[PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)** — Comprehensive step-by-step guide (3000+ words)
  - Prerequisites and system setup
  - Django configuration for production
  - Gunicorn and Nginx setup
  - SSL/HTTPS with Certbot
  - Domain DNS configuration (Namecheap)
  - Monitoring and maintenance
  - PostgreSQL optional upgrade

### 3. **Quick Reference**
- **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** — Fast checklist for experienced DevOps
  - Copy-paste ready commands
  - Organized by phase
  - All commands in one place

### 4. **Troubleshooting**
- **[DEBUGGING_GUIDE.md](DEBUGGING_GUIDE.md)** — 25+ common issues and fixes
  - 502 Bad Gateway
  - SSL certificate issues
  - Static files not loading
  - Database problems
  - Memory/performance issues
  - Complete solutions with commands

---

## 🗂️ Configuration Files (Created for Production)

### Settings & Environment
- **`portfolio/settings_production.py`** — Production Django settings (never hardcode values!)
- **`.env.example`** — Environment template (copy to `.env` on server, never commit `.env`)

### Application Server
- **`gunicorn_config.py`** — Gunicorn WSGI server configuration
- **`portfolio.service.template`** — Systemd service file (place in `/etc/systemd/system/`)

### Web Server
- **`nginx_config_template.conf`** — Nginx reverse proxy + SSL config (edit domain name first!)

### Containers (Optional)
- **`Dockerfile`** — Containerize your Django app
- **`docker-compose.yml`** — Multi-container setup (PostgreSQL + Django + Nginx)
- **`.dockerignore`** — Exclude files from Docker image

### Dependencies
- **`requirements.txt`** — Updated with production packages (Gunicorn, WhiteNoise, etc.)

---

## 🚀 Setup Scripts

### For Server Initialization
- **`initial_setup.sh`** — One-time setup (system packages, users, directories)
  - Run as: `sudo bash initial_setup.sh`

### For Deployment & Updates
- **`deploy.sh`** — Automate deployment (git pull, migrations, static files, restart)
  - Run as: `sudo bash deploy.sh`

### For Monitoring
- **`monitoring.sh`** — Health check script (all services, disk, SSL cert, connectivity)
  - Run manually or add to crontab: `*/5 * * * * bash /home/portfolio/monitoring.sh`

---

## 🎯 Deployment Scenarios

### Scenario A: Fresh DigitalOcean Droplet (No existing sites)

1. Read: [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md) — Full guide
2. Run: `bash initial_setup.sh` on droplet
3. Follow: Django Configuration section
4. Setup: Gunicorn + Nginx
5. Verify: Site loads at your domain

**Time: ~45-60 minutes**

---

### Scenario B: Shared Droplet (With existing portfolio)

1. Read: [Nginx section](PRODUCTION_DEPLOYMENT.md#nginx-configuration) of main guide
2. Copy: `nginx_config_template.conf` → `/etc/nginx/sites-available/portfolio2`
3. Edit: Replace domain names (different from first site)
4. Create: New Gunicorn socket (`portfolio2.sock`)
5. Setup: New systemd service for second Django app
6. DNS: Point new domain to same IP

**Time: ~20-30 minutes**

---

### Scenario C: Docker/Container Deployment

1. Ensure: Docker installed on machine
2. Use: `Dockerfile` + `docker-compose.yml`
3. Run: `docker-compose up -d`
4. No VM management needed

**Time: ~10 minutes**

---

### Scenario D: Issues After Deployment

1. Check: [DEBUGGING_GUIDE.md](DEBUGGING_GUIDE.md) for your error
2. Run: Commands given in the guide
3. View: Service logs with `systemctl` commands
4. Fix: Follow solution provided
5. Restart: Services

**Time: Varies by issue**

---

## 🔐 Security Checklist

Before going to production:

- [ ] `DEBUG=False` in production settings
- [ ] `SECRET_KEY` is strong and from `.env`
- [ ] `ALLOWED_HOSTS` configured correctly
- [ ] `.env` file exists and is in `.gitignore`
- [ ] SSL certificate installed (Certbot)
- [ ] HTTPS redirects from HTTP
- [ ] Admin panel behind HTTPS
- [ ] Media/uploads directory not executable
- [ ] Email notifications configured (for alerts)
- [ ] Regular backups scheduled

---

## 📊 Performance Baseline

**Your Droplet: DigitalOcean 1GB RAM**

- SQLite database: ~50MB
- Python environment: ~300MB
- Django app code: ~20MB
- Media/uploads: Grows with use
- **Available for Gunicorn**: ~500MB (supports 3-4 workers safely)

### Monitoring
- Watch RAM with: `free -h`
- View processes: `ps aux | grep python`
- Check service: `sudo systemctl status portfolio`
- View logs: `tail -f /home/portfolio/logs/django.log`

### When to Upgrade
- RAM > 80% usage consistently
- Multiple apps on same droplet
- Large file uploads
- High traffic (100+ visitors/day)

---

## 🔄 Workflow for Updates

### Small Changes (CSS, templates, images)

```bash
# On local machine
git add .
git commit -m "Update portfolio styles"
git push origin main

# On droplet
cd /home/portfolio/app
git pull origin main
sudo systemctl reload nginx  # For static file changes
```

### Code Changes (Django views, models)

```bash
# On droplet
cd /home/portfolio/app
git pull origin main
source /home/portfolio/venv/bin/activate
pip install -r requirements.txt
python manage.py migrate  # If models changed
python manage.py collectstatic --noinput
sudo systemctl restart portfolio
```

### Database Changes

```bash
# On droplet
python manage.py makemigrations
python manage.py migrate
sudo systemctl restart portfolio
```

---

## 📞 Getting Help

### Immediate Help
1. Check [DEBUGGING_GUIDE.md](DEBUGGING_GUIDE.md) for your error
2. View logs: `sudo journalctl -u portfolio -f`
3. Test Nginx: `sudo nginx -t`

### Common Commands

```bash
# Check if services running
sudo systemctl status portfolio
sudo systemctl status nginx

# View all logs
tail -f /home/portfolio/logs/django.log
sudo tail -f /var/log/nginx/portfolio_error.log

# Restart services
sudo systemctl restart portfolio
sudo systemctl reload nginx

# SSH to droplet
ssh root@143.110.254.96

# Monitor everything
bash /home/portfolio/app/monitoring.sh
```

### Online Resources
- Django docs: https://docs.djangoproject.com/
- Gunicorn docs: https://docs.gunicorn.org/
- Nginx docs: https://nginx.org/en/docs/
- DigitalOcean community: https://www.digitalocean.com/community/

---

## 📅 Maintenance Schedule

### Daily
- Monitor logs for errors
- Check website loads correctly

### Weekly
- Review `/home/portfolio/logs/django.log`
- Monitor disk usage: `df -h`
- Check memory: `free -h`

### Monthly
- Test backups restore
- Review and update dependencies
- Check SSL certificate expiry: `sudo certbot certificates`

### Quarterly
- Review logs for patterns
- Update system packages: `sudo apt update && sudo apt upgrade`
- Performance optimization

---

## ✅ File Checklist

| File | Type | Purpose |
|------|------|---------|
| `DOMAIN_SETUP_GUIDE.md` | 📖 Guide | How to buy & connect domain |
| `DOMAIN_QUICK_REFERENCE.md` | ⚡ Quick Ref | 2-min domain setup summary |
| `PRODUCTION_DEPLOYMENT.md` | 📖 Guide | Main deployment guide |
| `DEPLOYMENT_CHECKLIST.md` | ✓ Checklist | Quick reference |
| `DEBUGGING_GUIDE.md` | 🔧 Troubleshooting | Common issues & fixes |
| `DEPLOYMENT_FILES_SUMMARY.md` | 📝 Reference | File descriptions |
| `portfolio/settings_production.py` | ⚙️ Config | Production settings |
| `.env.example` | 📋 Template | Environment variables |
| `gunicorn_config.py` | ⚙️ Config | Gunicorn server |
| `nginx_config_template.conf` | ⚙️ Config | Nginx web server |
| `portfolio.service.template` | ⚙️ Config | Systemd service |
| `requirements.txt` | 📦 Dependencies | Python packages |
| `initial_setup.sh` | 🚀 Script | First-time server setup |
| `deploy.sh` | 🚀 Script | Deployment automation |
| `monitoring.sh` | 📊 Script | Health checks |
| `Dockerfile` | 🐳 Container | Docker image |
| `docker-compose.yml` | 🐳 Container | Multi-container setup |
| `.gitignore` | 🔒 Security | Hide sensitive files |
| `.dockerignore` | 🔒 Security | Hide files from Docker |

---

## 🚀 TL;DR — Quick Start

```bash
# On your DigitalOcean droplet
ssh root@143.110.254.96

# First time only
bash initial_setup.sh

# For each Django app
sudo -u portfolio git clone https://github.com/YOU/portfolio.git /home/portfolio/app
cd /home/portfolio/app
cp .env.example .env
nano .env  # Add your values

# Activate venv
source /home/portfolio/venv/bin/activate

# Setup Django
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput

# Setup Gunicorn & Nginx
# (Follow steps in PRODUCTION_DEPLOYMENT.md)

# Setup SSL
sudo certbot certonly --nginx -d your-domain.com

# Add DNS records at Namecheap
# (A record @ → 143.110.254.96)
# (A record www → 143.110.254.96)

# Wait 5-30 minutes for DNS propagation
# Visit: https://your-domain.com 🎉
```

---

**You're ready to deploy! Start with [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)**
