#!/bin/bash

##############################################################################
# Initial Server Setup Script
# Run this ONCE on your DigitalOcean droplet after SSH access is configured
# Usage: bash initial_setup.sh
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}  Initial DigitalOcean Server Setup${NC}"
echo -e "${YELLOW}============================================${NC}\n"

# Update system
echo -e "${GREEN}→ Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo -e "${GREEN}→ Installing system dependencies...${NC}"
sudo apt install -y \
    python3 python3-pip python3-venv python3-dev \
    nginx git curl wget \
    build-essential libpq-dev \
    certbot python3-certbot-nginx

# Create portfolio user
echo -e "${GREEN}→ Creating portfolio user...${NC}"
if ! id "portfolio" &>/dev/null; then
    sudo useradd -m -s /bin/bash portfolio
    echo "  ✓ User 'portfolio' created"
else
    echo "  ℹ User 'portfolio' already exists"
fi

# Create app directories
echo -e "${GREEN}→ Creating app directories...${NC}"
sudo mkdir -p /home/portfolio/app
sudo mkdir -p /home/portfolio/logs
sudo mkdir -p /home/portfolio/backups
sudo chown -R portfolio:portfolio /home/portfolio

# Setup virtual environment
echo -e "${GREEN}→ Creating Python virtual environment...${NC}"
sudo -u portfolio python3 -m venv /home/portfolio/venv

# Set permissions
echo -e "${GREEN}→ Setting permissions...${NC}"
sudo chmod -R 755 /home/portfolio
sudo chown -R portfolio:portfolio /home/portfolio

# Enable Nginx
echo -e "${GREEN}→ Enabling Nginx...${NC}"
sudo systemctl enable nginx
sudo systemctl start nginx

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ Initial Setup Complete!${NC}"
echo -e "${GREEN}============================================${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Clone your repository:"
echo "   sudo -u portfolio git clone https://... /home/portfolio/app"
echo ""
echo "2. Then follow PRODUCTION_DEPLOYMENT.md for:"
echo "   - Installing dependencies"
echo "   - Configuring .env"
echo "   - Database migrations"
echo "   - Gunicorn setup"
echo "   - Nginx configuration"
echo "   - SSL setup"
echo ""
