# ⚡ Domain & DNS Quick Reference

**Fastest guide to buy domain and connect to droplet 143.110.254.96**

---

## 🚀 TL;DR (2 Minutes)

### Buy Domain
1. Go to **https://www.namecheap.com**
2. Search domain → Add to cart → Checkout
3. Pay (~$8.88) → Done ✅

### Connect to Droplet
1. Namecheap → Dashboard → Domain List → Your Domain
2. Click **"Advanced DNS"**
3. Add these 2 A records:
   ```
   Type: A  |  Name: @   |  Value: 143.110.254.96  |  TTL: 30 min
   Type: A  |  Name: www |  Value: 143.110.254.96  |  TTL: 30 min
   ```
4. Click **"Save All Changes"** ✅
5. Wait 5-30 minutes for DNS to propagate
6. Visit `https://your-domain.com` — Done! 🎉

---

## 📋 Namecheap Checkout (Quick)

```
1. Search domain
2. Click "Add to Cart"
3. Proceed → Checkout
4. Login/Create account
5. Enter payment info
6. ✅ Mark AUTO RENEW
7. Pay $8.88
8. Confirmation email
```

---

## 🔧 Droplet Configuration (After DNS Propagates)

### SSH to Droplet
```bash
ssh root@143.110.254.96
```

### Update Nginx Config
```bash
sudo nano /etc/nginx/sites-available/portfolio
```

Find:
```
server_name DOMAIN.COM www.DOMAIN.COM;
```

Replace with (example: `harshit.com`):
```
server_name harshit.com www.harshit.com 143.110.254.96;
```

Also update SSL lines:
```nginx
ssl_certificate /etc/letsencrypt/live/harshit.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/harshit.com/privkey.pem;
```

### Update Django .env
```bash
sudo nano /home/portfolio/app/.env
```

Update:
```env
ALLOWED_HOSTS=harshit.com,www.harshit.com,143.110.254.96
```

### Test & Apply
```bash
sudo nginx -t                    # Should say "successful"
sudo systemctl reload nginx      # Apply changes

sudo certbot certonly --nginx \
  -d harshit.com \
  -d www.harshit.com             # Get SSL cert

sudo systemctl reload nginx      # Enable HTTPS
sudo systemctl restart portfolio # Restart Django
```

### Verify
```bash
# Check DNS
nslookup harshit.com
# Should show: 143.110.254.96

# Visit browser
https://harshit.com              # Should load ✅
https://www.harshit.com          # Should load ✅
```

---

## 🔑 Key Info

| Item | Value |
|------|-------|
| Droplet IP | 143.110.254.96 |
| Domain A Record (root) | @ → 143.110.254.96 |
| Domain A Record (www) | www → 143.110.254.96 |
| DNS Propagation Time | 5-30 minutes |
| Domain Price | ~$8.88/year |
| SSL Certificate | FREE (Certbot) |
| Domain Auto-Renewal | ✅ Enable in Namecheap |

---

## ⚠️ Common Mistakes

❌ **Don't:**
- Forget to add both @ and www A records
- Use wrong IP address
- Update Django settings BEFORE DNS propagates
- Skip enabling AUTO RENEW
- Use HTTP (must be HTTPS after SSL setup)

✅ **Do:**
- Double-check IP: 143.110.254.96
- Wait for DNS propagation (~15 min average)
- Update Nginx ALLOWED_HOSTS correctly
- Enable SSL certificate renewal
- Test http://your-domain.com redirects to https://your-domain.com

---

## 🧪 Testing Commands

```bash
# From your local machine:

# Check DNS (run this from Mac/Linux/Windows terminal)
nslookup your-domain.com
dig your-domain.com

# Check if it redirects HTTP → HTTPS
curl -v http://your-domain.com

# Check SSL certificate
openssl s_client -connect your-domain.com:443

# Online verification
# Visit: https://dns.google/ and enter your domain
```

---

## 🆘 Emails to Receive

**After purchasing domain:**
- 📧 Namecheap: Order confirmation
- 📧 Namecheap: Domain active notification

**After generating SSL certificate:**
- 📧 Certbot/Let's Encrypt: Certificate issued
- 📧 Certbot: Renewal reminders (auto-renews)

---

## 📱 Next Steps

1. ✅ Buy domain from Namecheap
2. ✅ Add A records in Advanced DNS
3. ✅ Wait 5-30 minutes
4. ✅ SSH to droplet and update configs
5. ✅ Generate SSL with Certbot
6. ✅ Test site loads: https://your-domain.com
7. ✅ Add content to /admin/ panel

---

**Detailed guide**: [DOMAIN_SETUP_GUIDE.md](DOMAIN_SETUP_GUIDE.md)  
**Full deployment guide**: [PRODUCTION_DEPLOYMENT.md](PRODUCTION_DEPLOYMENT.md)
