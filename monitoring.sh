#!/bin/bash

##############################################################################
# Monitoring Script for Django Portfolio
# Usage: bash monitoring.sh or crontab: */5 * * * * bash /home/portfolio/monitoring.sh
##############################################################################

PORTFOLIO_APP="/home/portfolio/app"
LOG_FILE="/home/portfolio/logs/monitoring.log"
ALERT_EMAIL="admin@your-domain.com"  # Update this

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Alert function
alert() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  ALERT: $1" >> "$LOG_FILE"
    
    # Optional: Send email notification
    # echo "$1" | mail -s "Portfolio Deployment Alert" "$ALERT_EMAIL"
}

echo -e "${YELLOW}🔍 Monitoring Django Portfolio...${NC}\n"

# ===== Check Gunicorn =====
if ! pgrep -f "gunicorn.*portfolio" > /dev/null; then
    alert "Gunicorn process is not running!"
    echo -e "${RED}✗ Gunicorn: NOT RUNNING${NC}"
    log "Gunicorn process not found - attempting restart..."
    sudo systemctl restart portfolio
else
    echo -e "${GREEN}✓ Gunicorn: Running${NC}"
    log "Gunicorn process confirmed running"
fi

# ===== Check Nginx =====
if ! pgrep -f "nginx" > /dev/null; then
    alert "Nginx is not running!"
    echo -e "${RED}✗ Nginx: NOT RUNNING${NC}"
    log "Nginx not found - attempting restart..."
    sudo systemctl restart nginx
else
    echo -e "${GREEN}✓ Nginx: Running${NC}"
    log "Nginx confirmed running"
fi

# ===== Check Socket File =====
if [ -S "/run/gunicorn/portfolio.sock" ]; then
    echo -e "${GREEN}✓ Socket: Exists${NC}"
    log "Gunicorn socket file exists"
else
    alert "Gunicorn socket file not found!"
    echo -e "${RED}✗ Socket: MISSING${NC}"
    log "Socket file /run/gunicorn/portfolio.sock not found"
fi

# ===== Check Disk Space =====
DISK_USAGE=$(df "$PORTFOLIO_APP" | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    alert "Disk usage is high: ${DISK_USAGE}%"
    echo -e "${RED}✗ Disk Space: HIGH (${DISK_USAGE}%)${NC}"
else
    echo -e "${GREEN}✓ Disk Space: ${DISK_USAGE}%${NC}"
fi

# ===== Check Database =====
if [ -f "$PORTFOLIO_APP/db.sqlite3" ]; then
    DB_SIZE=$(du -h "$PORTFOLIO_APP/db.sqlite3" | cut -f1)
    echo -e "${GREEN}✓ Database: Found ($DB_SIZE)${NC}"
    log "Database size: $DB_SIZE"
else
    alert "Database file not found!"
    echo -e "${RED}✗ Database: NOT FOUND${NC}"
fi

# ===== Check Log Files =====
ERROR_COUNT=$(tail -100 /var/log/nginx/portfolio_error.log 2>/dev/null | wc -l)
if [ "$ERROR_COUNT" -gt 10 ]; then
    alert "High number of Nginx errors detected"
    echo -e "${RED}⚠ Nginx Errors: $ERROR_COUNT recent errors${NC}"
else
    echo -e "${GREEN}✓ Nginx Errors: Low ($ERROR_COUNT)${NC}"
fi

# ===== Check Systemd Service =====
if systemctl is-active --quiet portfolio; then
    echo -e "${GREEN}✓ Systemd Service: Active${NC}"
    log "Portfolio systemd service is active"
else
    alert "Portfolio systemd service is inactive!"
    echo -e "${RED}✗ Systemd Service: INACTIVE${NC}"
    log "Portfolio systemd service not active"
fi

# ===== Check SSL Certificate =====
CERT_PATH="/etc/letsencrypt/live"
if [ -d "$CERT_PATH" ]; then
    CERT_EXPIRY=$(ls "$CERT_PATH" | head -1 | xargs -I {} openssl x509 -enddate -noout -in "$CERT_PATH/{}/cert.pem" 2>/dev/null | cut -d= -f2)
    if [ ! -z "$CERT_EXPIRY" ]; then
        echo -e "${GREEN}✓ SSL Certificate: Valid (Expires: $CERT_EXPIRY)${NC}"
        log "SSL certificate expires: $CERT_EXPIRY"
    else
        echo -e "${YELLOW}⚠ SSL Certificate: Status unknown${NC}"
    fi
else
    echo -e "${YELLOW}⚠ SSL Certificate: Not found (may not use HTTPS yet)${NC}"
fi

# ===== HTTP connectivity test =====
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null)
if [ "$HTTP_STATUS" == "301" ] || [ "$HTTP_STATUS" == "302" ] || [ "$HTTP_STATUS" == "200" ]; then
    echo -e "${GREEN}✓ HTTP Response: $HTTP_STATUS${NC}"
    log "HTTP test successful - status code $HTTP_STATUS"
else
    alert "HTTP test failed - status code $HTTP_STATUS"
    echo -e "${RED}✗ HTTP Response: FAILED ($HTTP_STATUS)${NC}"
fi

echo ""
echo -e "${YELLOW}📊 Summary${NC}"
echo "Monitoring log: $LOG_FILE"
tail -5 "$LOG_FILE"

log "Monitoring check completed"
