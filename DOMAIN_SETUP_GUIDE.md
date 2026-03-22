# 🌐 How to Buy a Domain and Connect It to Your Droplet

Complete guide to purchase a domain from Namecheap and configure it to point to your DigitalOcean droplet.

---

## 📋 Prerequisites

- DigitalOcean droplet IP: **143.110.254.96**
- Credit/debit card for payment
- Email address for domain account

---

## Part 1: Purchase Domain from Namecheap ⭐

### Step 1: Visit Namecheap Website

1. Go to: **https://www.namecheap.com**
2. You'll see the homepage with a search bar at the top

### Step 2: Search for Your Domain

1. In the search bar, type your desired domain name
   - Example: `harshit-portfolio.com`
   - Or: `harshit-dev.com`
   - Or: `myportfolio.io`

2. Click **"Search"** button

### Step 3: Check Availability & Price

- ✅ **Green checkmark** = Available to buy
- ❌ **Red X** = Not available (try different name)
- Price shown on right side (typically **$8.88/year** for `.com`)

**Example search results:**
```
harshit-portfolio.com     ✅ $10.88/year
harshit-dev.com          ✅ $9.88/year
harshitportfolio.io      ✅ $34.88/year
```

### Step 4: Add to Cart

1. Find your preferred domain
2. Click the domain name or **"Add to Cart"** button
3. Domain moves to your shopping cart (top right)

### Step 5: Review & Proceed Checkout

1. Click **Shopping Cart** (top right)
2. Verify domain and price
3. Click **"Checkout"**

### Step 6: Create/Login to Namecheap Account

**If you don't have an account:**
- Fill in: Email, password, first name, last name
- Click **"Create Account & Continue"**

**If you have an account:**
- Enter email and password
- Click **"Sign In"**

### Step 7: Review Billing Information

Fill in or verify:
- **Name**: Your full name
- **Email**: Your email address
- **Address**: Your home address
- **City, State, ZIP**: Your location
- **Country**: Your country
- **Phone**: Your phone number *(important for domain contact)*

### Step 8: Select Domain Protection

You'll see options:
```
☐ WHOIS Guard™ (Hide your personal info) — Free 1 year → $2.88/year
☐ Domain Privacy (Alternative) — $2.88/year
☐ AUTO RENEW (Recommended) ✅ Check this box
```

**Recommendations:**
- ✅ **Check "AUTO RENEW"** — Domain won't expire accidentally
- ✅ **Check "WHOIS Guard" or "Privacy"** — Hides your info (optional)

### Step 9: Select Payment Method

Choose your payment option:
- **Credit Card** (Visa, Mastercard, American Express)
- **PayPal**
- **Bitcoin** (if you prefer)

Click **"Proceed to Payment"**

### Step 10: Enter Payment Details

1. Enter credit card number, expiry, CVV
2. Review **Order Summary**:
   ```
   Domain Registration (1 year)    $8.88
   WHOIS Guard (optional)           $0.00  (free 1st year)
   AUTO RENEW (enabled)             ✅
   ─────────────────────────
   Total                            $8.88
   ```
3. Click **"Complete Order"**

### Step 11: Confirm Purchase

- ✅ You'll see **"Order Complete"** message
- 📧 Email confirmation sent to your email address
- Domain is now **yours for 1 year!**

---

## Part 2: Connect Domain to DigitalOcean Droplet

### Step 12: Log in to Namecheap Dashboard

1. Go to: **https://www.namecheap.com/myaccount/login/**
2. Enter email and password
3. Click **"Sign In"**

### Step 13: Access Domain Management

1. Click **"Dashboard"** (top left)
2. Under **"My Products"**, click **"Domain List"**
3. You'll see your domain in the list

### Step 14: Click on Your Domain

1. Find your domain in the list
2. Click the domain name to open settings

### Step 15: Go to Advanced DNS

1. Look for tabs at the top of the page
2. Click **"Advanced DNS"** tab
3. You should see current DNS records

### Step 16: Add A Records (Point Domain to Droplet IP)

Look for the section with existing records. You need to **add two A records**:

#### Add Record #1: For root domain (@)

```
Type: A (Address)
Name/Host: @
Value: 143.110.254.96
TTL: 30 min
```

**Steps:**
1. Click **"+ Add Record"** button
2. **Type**: Select **"A Record"** from dropdown
3. **Name**: Type `@` (represents root domain)
4. **IPv4 Address**: Paste `143.110.254.96`
5. **TTL**: Select **"30 min"** or **"Automatic"**
6. Click **"Save"** (checkmark icon)

#### Add Record #2: For www subdomain

```
Type: A (Address)
Name/Host: www
Value: 143.110.254.96
TTL: 30 min
```

**Steps:**
1. Click **"+ Add Record"** button again
2. **Type**: Select **"A Record"**
3. **Name**: Type `www`
4. **IPv4 Address**: Paste `143.110.254.96`
5. **TTL**: Select **"30 min"**
6. Click **"Save"**

### Step 17: Verify Records Were Added

Your records should now show:

```
Type  | Name | Value            | TTL
──────┼──────┼──────────────────┼─────────
A     | @    | 143.110.254.96   | 30 min
A     | www  | 143.110.254.96   | 30 min
```

### Step 18: Click "Save All Changes"

- Look for **"Save All Changes"** button at bottom right
- Click it to confirm all DNS changes
- You'll see a **green checkmark** ✅

### Step 19: DNS Propagation (Wait 5-30 minutes)

DNS changes take time to propagate globally:

```
⏱️  5 minutes     → Propagating
⏱️  15 minutes    → Mostly propagated
⏱️  30+ minutes   → Fully propagated
```

During this time:
- ✅ Domain works sometimes, then doesn't (normal)
- ✅ Some regions see your site, others don't (normal)
- ✅ Keep refreshing your browser

### Step 20: Verify Domain Points to Your Droplet

**On your local machine, run these commands:**

```bash
# Check DNS resolution
nslookup your-domain.com
# Should show: 143.110.254.96

# Or use dig
dig your-domain.com
# Should show: 143.110.254.96 in "ANSWER SECTION"
```

**Online DNS checker:**
- Visit: https://dns.google/
- Enter your domain name
- Should show **143.110.254.96** for both @ and www records

---

## Part 3: Configure Your Droplet

### Step 21: Update Nginx Configuration

Now that your domain is pointing to the droplet, update Nginx to accept requests from your domain.

**On your DigitalOcean droplet:**

```bash
ssh root@143.110.254.96
```

Edit your Nginx config:

```bash
sudo nano /etc/nginx/sites-available/portfolio
```

Find this section:
```nginx
server_name DOMAIN.COM www.DOMAIN.COM 143.110.254.96;
```

Replace with your actual domain:
```nginx
server_name your-domain.com www.your-domain.com 143.110.254.96;
```

Also update the SSL certificate lines:
```nginx
ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
```

**Example: If your domain is `harshit-portfolio.com`:**
```nginx
server_name harshit-portfolio.com www.harshit-portfolio.com 143.110.254.96;
```

### Step 22: Update Django Settings

Update your `.env` file:

```bash
sudo nano /home/portfolio/app/.env
```

Update ALLOWED_HOSTS:
```env
ALLOWED_HOSTS=your-domain.com,www.your-domain.com,143.110.254.96
```

**Example:**
```env
ALLOWED_HOSTS=harshit-portfolio.com,www.harshit-portfolio.com,143.110.254.96
```

### Step 23: Test Nginx Configuration

```bash
sudo nginx -t
```

Should show:
```
nginx: configuration file test is successful
```

### Step 24: Reload Nginx

```bash
sudo systemctl reload nginx
```

### Step 25: Install SSL Certificate (HTTPS)

Run Certbot to get a free SSL certificate:

```bash
sudo certbot certonly --nginx -d your-domain.com -d www.your-domain.com
```

Replace with your actual domain:
```bash
sudo certbot certonly --nginx -d harshit-portfolio.com -d www.harshit-portfolio.com
```

**Follow the prompts:**
- Enter your email address
- Agree to terms (A)
- Choose domain validation method (usually automatic)

**Output should show:**
```
Congratulations! Your certificate has been issued.
Certificate is saved at: /etc/letsencrypt/live/harshit-portfolio.com/
```

### Step 26: Reload Nginx Again

```bash
sudo systemctl reload nginx
```

### Step 27: Restart Django Application

```bash
sudo systemctl restart portfolio
```

---

## ✅ Final Verification

### Step 28: Test Your Site

**In your browser, visit:**

```
https://your-domain.com
https://www.your-domain.com
```

**You should see:**
- ✅ Your portfolio homepage loads
- 🔒 Green lock icon (HTTPS secure)
- ✅ Admin panel at `/admin/`
- ✅ All media/images loading

**Check that:**
1. HTTP redirects to HTTPS automatically
2. Certificate is valid (click lock icon to verify)
3. Site loads from both domain and www.domain

### Step 29: Check Certificate Auto-Renewal

```bash
sudo systemctl status certbot.timer
```

Should show:
```
Active: active (running)
```

This ensures your SSL certificate renews automatically.

---

## 📊 Summary of What You Did

| Step | Action | Result |
|------|--------|--------|
| 1-11 | Purchased domain from Namecheap | Domain registered for 1 year |
| 12-19 | Added DNS A records pointing to droplet IP | Domain now points to 143.110.254.96 |
| 20 | Verified DNS propagation | nslookup shows correct IP |
| 21-22 | Updated Nginx + Django configs | Droplet accepts requests from domain |
| 23-26 | Generated SSL certificate with Certbot | HTTPS enabled with free cert |
| 27 | Restarted services | All changes applied |
| 28-29 | Tested site and certificate renewal | Site live at your domain! 🎉 |

---

## 🔍 Troubleshooting

### Error: "Address already in use" when reloading Nginx

**Solution:**
```bash
sudo systemctl restart nginx
```

### Error: "Certificate not issued" from Certbot

**Solution:**
```bash
# Can still use HTTP while debugging
sudo nginx -t
sudo systemctl reload nginx

# Try again later or check Namecheap DNS:
nslookup your-domain.com
```

### Domain not resolving from your computer

**Solution:**
```bash
# Flush local DNS cache
# macOS:
sudo dscacheutil -flushcache

# Linux:
sudo systemctl restart systemd-resolved

# Windows (in PowerShell as admin):
ipconfig /flushdns
```

### Browser shows "ERR_NAME_NOT_RESOLVED"

**Reason:** DNS hasn't propagated yet  
**Solution:** Wait another 5-15 minutes and refresh, or check online:
- https://dns.google/
- https://dnschecker.org/

### Certificate shows as invalid/untrusted

**Solution:**
```bash
# Restart services and clear browser cache
sudo systemctl reload nginx
# In browser: Ctrl+Shift+Delete (or Cmd+Shift+Delete on Mac)
# Clear all browsing data and reload
```

---

## 💰 Cost Summary

| Item | Cost | Renewal |
|------|------|---------|
| Domain (.com) | $8.88/year | Auto (if you enabled it) |
| SSL Certificate | FREE | Auto-renews (Certbot) |
| Droplet | $6/month | Ongoing |
| **Total/Year** | ~$79 | Minimal maintenance |

---

## 📌 Important Reminders

✅ **Domain expires in 1 year** — Enable AUTO RENEW to avoid losing it  
✅ **SSL cert renews automatically** — Certbot handles this  
✅ **DNS changes take time** — Be patient with propagation  
✅ **Keep credentials safe** — Don't share Namecheap or DNS passwords  
✅ **Update Django ALLOWED_HOSTS** — Always add new domains to settings  

---

## 🎉 You're Done!

Your portfolio is now live at:
- **https://your-domain.com** ✅
- **https://www.your-domain.com** ✅

Congratulations! Your personal portfolio is on the internet! 🚀
