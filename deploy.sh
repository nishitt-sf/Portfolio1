#!/bin/bash

##############################################################################
# Production Deployment Script for Django Portfolio
# Usage: sudo bash deploy.sh
# 
# This script will:
# 1. Pull latest code from git
# 2. Install dependencies
# 3. Run migrations
# 4. Collect static files
# 5. Restart Gunicorn + Nginx
#
# Prerequisites:
# - User 'portfolio' exists
# - Virtual environment at /home/portfolio/venv
# - .env file configured at /home/portfolio/app/.env
# - Nginx configured
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PORTFOLIO_USER="portfolio"
PORTFOLIO_HOME="/home/portfolio"
PORTFOLIO_APP="$PORTFOLIO_HOME/app"
VENV="$PORTFOLIO_HOME/venv"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Django Portfolio Deployment Script${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Check if portfolio user exists
if ! id "$PORTFOLIO_USER" &>/dev/null; then
    echo -e "${RED}Error: User '$PORTFOLIO_USER' does not exist${NC}"
    echo "Create it with: sudo useradd -m -s /bin/bash portfolio"
    exit 1
fi

cd "$PORTFOLIO_APP"

echo -e "${GREEN}→ Activating virtual environment...${NC}"
source "$VENV/bin/activate"

echo -e "${GREEN}→ Pulling latest code from git...${NC}"
git pull origin main

echo -e "${GREEN}→ Installing dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${GREEN}→ Setting Django settings to production...${NC}"
export DJANGO_SETTINGS_MODULE=portfolio.settings_production

echo -e "${GREEN}→ Running database migrations...${NC}"
python manage.py migrate --noinput

echo -e "${GREEN}→ Collecting static files...${NC}"
python manage.py collectstatic --noinput --clear

echo -e "${GREEN}→ Checking for errors...${NC}"
python manage.py check --deploy

echo -e "${GREEN}→ Setting permissions...${NC}"
chown -R "$PORTFOLIO_USER:www-data" "$PORTFOLIO_APP"
chmod -R 755 "$PORTFOLIO_APP"
chmod -R 755 "$PORTFOLIO_APP/media"
chmod -R 755 "$PORTFOLIO_APP/staticfiles"

echo -e "${GREEN}→ Restarting Gunicorn...${NC}"
systemctl restart portfolio

echo -e "${GREEN}→ Reloading Nginx...${NC}"
nginx -s reload

echo -e "${GREEN}→ Waiting for services to start...${NC}"
sleep 2

echo -e "${GREEN}→ Checking Gunicorn status...${NC}"
systemctl status portfolio --no-pager

echo -e "${GREEN}→ Checking Nginx status...${NC}"
systemctl status nginx --no-pager

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Verify your site loads: https://your-domain.com"
echo "2. Check logs: tail -f $PORTFOLIO_APP/logs/django.log"
echo "3. Check Nginx logs: tail -f /var/log/nginx/portfolio_error.log"
echo ""
