# Deployment Guide

## Table of Contents
1. [Deployment Overview](#deployment-overview)
2. [Environment Requirements](#environment-requirements)
3. [Development Deployment](#development-deployment)
4. [Production Deployment](#production-deployment)
5. [Database Migration](#database-migration)
6. [Configuration Management](#configuration-management)
7. [Monitoring & Maintenance](#monitoring--maintenance)
8. [Backup & Recovery](#backup--recovery)
9. [Security Hardening](#security-hardening)
10. [Troubleshooting](#troubleshooting)

---

## Deployment Overview

### Deployment Environments

| Environment | Purpose | URL | Database |
|-------------|---------|-----|----------|
| **Development** | Local development | localhost:8081 | Local MySQL |
| **Staging** | Pre-production testing | staging.taphoammo.com | Staging DB |
| **Production** | Live system | www.taphoammo.com | Production DB |

### Deployment Methods

1. **Manual Deployment** - JAR file deployment (current)
2. **Docker Deployment** - Containerized deployment (planned)
3. **CI/CD Pipeline** - Automated deployment (planned)

---

## Environment Requirements

### Hardware Requirements

#### Minimum (Development/Staging)
- **CPU:** 2 cores
- **RAM:** 2 GB
- **Storage:** 10 GB SSD
- **Network:** 10 Mbps

#### Recommended (Production)
- **CPU:** 4 cores
- **RAM:** 8 GB
- **Storage:** 50 GB SSD
- **Network:** 100 Mbps
- **Load Balancer:** Nginx/Apache

---

### Software Requirements

#### Server
- **Operating System:** Linux (Ubuntu 22.04 LTS recommended) or Windows Server 2019+
- **JRE/JDK:** OpenJDK 17 or Oracle JDK 17
- **Database:** MySQL 8.0+
- **Web Server:** Nginx or Apache (for reverse proxy)

#### Database
- **MySQL Server:** 8.0+
- **InnoDB Storage Engine**
- **Character Set:** utf8mb4
- **Collation:** utf8mb4_unicode_ci

---

## Development Deployment

### Local Development Setup

Already covered in [DEVELOPMENT.md](./DEVELOPMENT.md).

**Quick Start:**
```bash
# Clone repository
git clone <repo-url>
cd SWE391_Group3_Project

# Setup database
mysql -u root -p < marketplace.sql
mysql -u root -p < marketplace-sample-data.sql

# Configure application.properties
# Edit src/main/resources/application.properties

# Run application
./mvnw spring-boot:run
```

**Access:** http://localhost:8081

---

## Production Deployment

### Pre-Deployment Checklist

- [ ] Production database created and configured
- [ ] Database migrations tested
- [ ] Configuration files updated (remove dev settings)
- [ ] Security settings enabled (HTTPS, CSRF, etc.)
- [ ] Application built with production profile
- [ ] Backup strategy in place
- [ ] Monitoring tools configured
- [ ] Domain name and SSL certificate ready
- [ ] Firewall rules configured
- [ ] Load balancer configured (if applicable)

---

### Step 1: Server Setup

#### Install Java 17

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install openjdk-17-jre-headless -y
java -version  # Verify installation
```

**CentOS/RHEL:**
```bash
sudo yum install java-17-openjdk -y
java -version
```

**Windows Server:**
- Download JDK 17 from Oracle or Adoptium
- Install and set JAVA_HOME environment variable

---

#### Install MySQL 8.0

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
sudo mysql_secure_installation  # Follow prompts
```

**Configuration:**
```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Add/modify:
```ini
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
max_connections = 200
innodb_buffer_pool_size = 2G  # Adjust based on RAM
```

Restart MySQL:
```bash
sudo systemctl restart mysql
```

---

### Step 2: Database Setup

#### Create Production Database

```bash
mysql -u root -p
```

```sql
-- Create database
CREATE DATABASE mmo_market_system_prod
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Create application user
CREATE USER 'marketplace_app'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON mmo_market_system_prod.* TO 'marketplace_app'@'localhost';
FLUSH PRIVILEGES;

-- Verify
SHOW GRANTS FOR 'marketplace_app'@'localhost';
EXIT;
```

#### Import Schema

```bash
mysql -u marketplace_app -p mmo_market_system_prod < marketplace.sql
```

**For Production:** Do NOT import sample data (`marketplace-sample-data.sql`)

---

### Step 3: Application Configuration

#### Create Application User

```bash
sudo useradd -m -s /bin/bash marketplace
sudo passwd marketplace  # Set password
```

#### Create Directory Structure

```bash
sudo mkdir -p /opt/marketplace
sudo mkdir -p /opt/marketplace/logs
sudo mkdir -p /opt/marketplace/config
sudo mkdir -p /var/log/marketplace
sudo chown -R marketplace:marketplace /opt/marketplace
sudo chown -R marketplace:marketplace /var/log/marketplace
```

---

#### Production Configuration File

Create `/opt/marketplace/config/application-prod.properties`:

```properties
# Server Configuration
server.port=8080
server.servlet.context-path=/

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/mmo_market_system_prod
spring.datasource.username=marketplace_app
spring.datasource.password=STRONG_PASSWORD_HERE
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# HikariCP Connection Pool
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
spring.jpa.open-in-view=false
spring.jpa.properties.hibernate.default_batch_fetch_size=16
spring.jpa.properties.hibernate.jdbc.batch_size=20
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true

# JSP Configuration
spring.mvc.view.prefix=/WEB-INF/view/
spring.mvc.view.suffix=.jsp

# File Upload Configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
spring.servlet.multipart.location=/opt/marketplace/uploads

# Business Configuration
marketplace.seller.minimum-deposit=5000000
marketplace.escrow.hold-days=3
marketplace.wallet.currency=VND

# Security Configuration
spring.security.user.name=admin
spring.security.user.password=${ADMIN_PASSWORD}

# Logging Configuration
logging.level.root=WARN
logging.level.vn.group3.marketplace=INFO
logging.level.org.springframework.security=WARN
logging.file.name=/var/log/marketplace/application.log
logging.file.max-size=10MB
logging.file.max-history=30
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n

# Actuator Configuration
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=when-authorized
management.metrics.export.prometheus.enabled=true

# Session Configuration
server.servlet.session.timeout=30m
server.servlet.session.cookie.http-only=true
server.servlet.session.cookie.secure=true

# Error Handling
server.error.include-message=always
server.error.include-stacktrace=never
```

**⚠️ Security Notes:**
- Replace `STRONG_PASSWORD_HERE` with actual passwords
- Use environment variables for sensitive data (recommended)
- Never commit this file to version control

---

### Step 4: Build Application

**On Build Server or Local Machine:**

```bash
# Checkout production branch
git checkout main
git pull origin main

# Clean build
./mvnw clean package -DskipTests

# Verify JAR created
ls -lh target/marketplace-*.jar
```

**Expected Output:**
```
marketplace-0.0.1-SNAPSHOT.jar
```

---

### Step 5: Deploy Application

#### Upload JAR to Server

```bash
# From local machine
scp target/marketplace-0.0.1-SNAPSHOT.jar marketplace@server_ip:/opt/marketplace/
```

#### Create Systemd Service

Create `/etc/systemd/system/marketplace.service`:

```ini
[Unit]
Description=TaphoaMMO Marketplace Application
After=syslog.target network.target mysql.service

[Service]
Type=simple
User=marketplace
Group=marketplace
WorkingDirectory=/opt/marketplace
ExecStart=/usr/bin/java -jar \
    -Xms512m \
    -Xmx2g \
    -Dspring.profiles.active=prod \
    -Dspring.config.location=/opt/marketplace/config/application-prod.properties \
    /opt/marketplace/marketplace-0.0.1-SNAPSHOT.jar

SuccessExitStatus=143
StandardOutput=journal
StandardError=journal
SyslogIdentifier=marketplace

Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Reload systemd:**
```bash
sudo systemctl daemon-reload
```

---

#### Start Application

```bash
# Enable on boot
sudo systemctl enable marketplace

# Start service
sudo systemctl start marketplace

# Check status
sudo systemctl status marketplace

# View logs
sudo journalctl -u marketplace -f
```

**Verify Application Running:**
```bash
curl http://localhost:8080/health
# Expected: OK
```

---

### Step 6: Nginx Reverse Proxy

#### Install Nginx

```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### Configure Nginx

Create `/etc/nginx/sites-available/marketplace`:

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name www.taphoammo.com taphoammo.com;

    return 301 https://$server_name$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name www.taphoammo.com taphoammo.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/taphoammo.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/taphoammo.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/marketplace_access.log;
    error_log /var/log/nginx/marketplace_error.log;

    # Client Body Size
    client_max_body_size 10M;

    # Proxy to Spring Boot
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }

    # Static Resources Cache
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf)$ {
        proxy_pass http://localhost:8080;
        proxy_cache_valid 200 7d;
        expires 7d;
        add_header Cache-Control "public, immutable";
    }

    # Health Check
    location /actuator/health {
        proxy_pass http://localhost:8080/actuator/health;
        access_log off;
    }
}
```

**Enable Site:**
```bash
sudo ln -s /etc/nginx/sites-available/marketplace /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

---

### Step 7: SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain certificate
sudo certbot --nginx -d taphoammo.com -d www.taphoammo.com

# Auto-renewal test
sudo certbot renew --dry-run

# Certbot auto-renews via cron
sudo systemctl status certbot.timer
```

---

### Step 8: Firewall Configuration

```bash
# UFW (Ubuntu Firewall)
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS
sudo ufw enable

# Verify
sudo ufw status
```

**Block Direct Access to Spring Boot:**
```bash
# Only allow localhost to access port 8080
sudo ufw deny 8080/tcp
```

---

## Database Migration

### Migration Strategy

**Development:**
- Use `spring.jpa.hibernate.ddl-auto=update`
- Schema auto-updated by Hibernate

**Production:**
- Use `spring.jpa.hibernate.ddl-auto=validate`
- Manual SQL migration scripts

---

### Creating Migration Script

**Example: Add column to users table**

`migrations/V002__add_phone_verified_column.sql`:
```sql
-- Migration: Add phone verification
-- Author: DevOps Team
-- Date: 2025-01-15

USE mmo_market_system_prod;

-- Add column
ALTER TABLE users
ADD COLUMN phone_verified TINYINT(1) DEFAULT 0 AFTER phone;

-- Update existing records
UPDATE users SET phone_verified = 0 WHERE phone IS NOT NULL;

-- Verify
SELECT COUNT(*) FROM users WHERE phone_verified IS NOT NULL;
```

**Apply Migration:**
```bash
mysql -u marketplace_app -p mmo_market_system_prod < migrations/V002__add_phone_verified_column.sql
```

---

### Rollback Strategy

Always create rollback script:

`migrations/V002__add_phone_verified_column_ROLLBACK.sql`:
```sql
USE mmo_market_system_prod;

ALTER TABLE users DROP COLUMN phone_verified;
```

---

## Configuration Management

### Environment Variables

**Recommended:** Use environment variables for sensitive data

**Set Environment Variables:**
```bash
sudo nano /etc/systemd/system/marketplace.service
```

Add under `[Service]`:
```ini
Environment="DB_PASSWORD=strong_password"
Environment="ADMIN_PASSWORD=admin_password"
Environment="JWT_SECRET=your_jwt_secret"
```

**Use in application.properties:**
```properties
spring.datasource.password=${DB_PASSWORD}
spring.security.user.password=${ADMIN_PASSWORD}
```

---

### Profile-Based Configuration

**Files:**
- `application.properties` - Default
- `application-dev.properties` - Development
- `application-prod.properties` - Production

**Activate Profile:**
```bash
java -jar app.jar --spring.profiles.active=prod
```

---

## Monitoring & Maintenance

### Application Monitoring

#### Health Check Endpoint

```bash
curl http://localhost:8080/actuator/health
```

**Response:**
```json
{
  "status": "UP",
  "components": {
    "db": { "status": "UP" },
    "diskSpace": { "status": "UP" }
  }
}
```

---

#### Log Monitoring

**View Real-time Logs:**
```bash
# Application logs
sudo tail -f /var/log/marketplace/application.log

# Systemd logs
sudo journalctl -u marketplace -f

# Nginx logs
sudo tail -f /var/log/nginx/marketplace_access.log
sudo tail -f /var/log/nginx/marketplace_error.log
```

---

#### Metrics (Actuator)

```bash
# JVM metrics
curl http://localhost:8080/actuator/metrics/jvm.memory.used

# HTTP metrics
curl http://localhost:8080/actuator/metrics/http.server.requests
```

---

### Database Monitoring

**Monitor Connections:**
```sql
SHOW PROCESSLIST;
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';
```

**Monitor Performance:**
```sql
-- Slow queries
SELECT * FROM mysql.slow_log ORDER BY query_time DESC LIMIT 10;

-- Table sizes
SELECT
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'mmo_market_system_prod'
ORDER BY (data_length + index_length) DESC;
```

---

### System Resource Monitoring

**CPU & Memory:**
```bash
# CPU usage
top -bn1 | grep "Cpu(s)"

# Memory usage
free -h

# Disk usage
df -h

# Java process
ps aux | grep java
```

**Automated Monitoring (Recommended):**
- **Prometheus + Grafana** - Metrics collection and visualization
- **New Relic / Datadog** - APM (Application Performance Monitoring)
- **Uptime Robot** - External uptime monitoring

---

## Backup & Recovery

### Database Backup

#### Automated Daily Backup

Create backup script `/opt/marketplace/scripts/backup.sh`:

```bash
#!/bin/bash
# Database backup script

BACKUP_DIR="/opt/marketplace/backups"
DB_NAME="mmo_market_system_prod"
DB_USER="marketplace_app"
DB_PASS="password"  # Or use .my.cnf for security
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql.gz"

# Create backup directory
mkdir -p $BACKUP_DIR

# Dump database
mysqldump -u $DB_USER -p$DB_PASS \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    $DB_NAME | gzip > $BACKUP_FILE

# Delete backups older than 30 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

# Log
echo "Backup completed: $BACKUP_FILE" >> /var/log/marketplace/backup.log
```

**Make Executable:**
```bash
chmod +x /opt/marketplace/scripts/backup.sh
```

**Schedule with Cron:**
```bash
sudo crontab -e
```

Add:
```cron
# Daily backup at 2 AM
0 2 * * * /opt/marketplace/scripts/backup.sh
```

---

#### Restore from Backup

```bash
# Extract and restore
gunzip < backup_file.sql.gz | mysql -u marketplace_app -p mmo_market_system_prod

# Or without extraction
zcat backup_file.sql.gz | mysql -u marketplace_app -p mmo_market_system_prod
```

---

### Application Backup

**Backup JAR and Configuration:**
```bash
# Backup script
tar -czf /opt/marketplace/backups/app_$(date +%Y%m%d).tar.gz \
    /opt/marketplace/*.jar \
    /opt/marketplace/config/
```

---

### Disaster Recovery Plan

1. **Database:** Restore from latest backup
2. **Application:** Redeploy JAR from Git tag/release
3. **Configuration:** Restore from backup or recreate
4. **Uploads:** Restore from cloud storage (S3, etc.)

**Recovery Time Objective (RTO):** 4 hours
**Recovery Point Objective (RPO):** 24 hours (daily backups)

---

## Security Hardening

### Production Security Checklist

- [ ] HTTPS enabled with valid SSL certificate
- [ ] Firewall configured (only 80, 443, 22 open)
- [ ] Spring Security fully configured
- [ ] CSRF protection enabled
- [ ] SQL injection prevention (use JPA)
- [ ] XSS prevention (JSTL escaping)
- [ ] Secure headers configured (Nginx)
- [ ] Database user has minimal permissions
- [ ] Passwords encrypted (BCrypt)
- [ ] Session cookies set to `HttpOnly` and `Secure`
- [ ] File upload validation
- [ ] Rate limiting implemented
- [ ] Regular security updates applied

---

### Disable Development Features

**In Production `application-prod.properties`:**
```properties
# Disable Actuator sensitive endpoints
management.endpoints.web.exposure.include=health,info

# Disable H2 console (if accidentally included)
spring.h2.console.enabled=false

# Disable DevTools
spring.devtools.restart.enabled=false

# Disable SQL logging
spring.jpa.show-sql=false

# Hide error details
server.error.include-stacktrace=never
server.error.include-message=always
```

---

### Regular Security Updates

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Java (if needed)
sudo apt install openjdk-17-jre-headless -y

# Restart application
sudo systemctl restart marketplace
```

---

## Troubleshooting

### Application Won't Start

**Check Logs:**
```bash
sudo journalctl -u marketplace -n 100 --no-pager
```

**Common Issues:**
- Database connection refused → Check MySQL running
- Port already in use → Check `netstat -tlnp | grep 8080`
- Configuration error → Validate `application-prod.properties`

---

### High Memory Usage

**Check JVM Heap:**
```bash
jmap -heap $(pgrep -f marketplace)
```

**Adjust Heap Size:**

Edit `/etc/systemd/system/marketplace.service`:
```ini
ExecStart=/usr/bin/java -jar -Xms1g -Xmx4g ...
```

Reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart marketplace
```

---

### Database Connection Pool Exhausted

**Check Active Connections:**
```sql
SHOW PROCESSLIST;
```

**Increase Pool Size:**

In `application-prod.properties`:
```properties
spring.datasource.hikari.maximum-pool-size=30
```

---

### Slow Performance

**Potential Causes:**
1. Database queries (use indexing)
2. Insufficient JVM heap
3. Too many concurrent users (scale horizontally)
4. Unoptimized code (profiling needed)

**Quick Fixes:**
- Enable query caching
- Add database indexes
- Increase heap size
- Use Redis for session storage

---

## Production Readiness Checklist

### Before Go-Live

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Database migrations tested
- [ ] Security audit completed
- [ ] Performance testing done (load testing)
- [ ] Monitoring configured
- [ ] Backup system tested
- [ ] SSL certificate installed
- [ ] Domain configured correctly
- [ ] Error pages customized
- [ ] Documentation updated
- [ ] Team trained on deployment

### Post-Deployment

- [ ] Health check passing
- [ ] All endpoints accessible
- [ ] User registration working
- [ ] Payment processing working (when implemented)
- [ ] Email notifications working (when implemented)
- [ ] Logs being captured
- [ ] Monitoring alerts configured
- [ ] Performance baseline established

---

**Last Updated:** January 2025
**Document Version:** 1.0.0
