# User Documentation

This document explains how to use and manage the Inception infrastructure as an end user or system administrator.

## Table of Contents

1. [Overview](#overview)
2. [Starting and Stopping the Project](#starting-and-stopping-the-project)
3. [Accessing Services](#accessing-services)
4. [Managing Credentials](#managing-credentials)
5. [Verifying Services](#verifying-services)
6. [Common Tasks](#common-tasks)
7. [Quick Reference](#quick-reference)

## Overview

### What Services Are Provided?

The Inception infrastructure provides a complete WordPress hosting environment with:

**Mandatory Services:**

- **Web Server (NGINX)**
  - Serves your WordPress website over HTTPS
  - Handles SSL/TLS encryption
  - Acts as a reverse proxy to WordPress

- **WordPress + PHP-FPM**
  - Content Management System for creating and managing website content
  - PHP processing engine
  - Administrative dashboard for site management

- **Database Server (MariaDB)**
  - Stores all WordPress content, settings, and user data
  - Provides reliable data persistence

**Bonus Services:**

- **Redis Cache**
  - In-memory caching system
  - Speeds up WordPress by caching frequently accessed data
  - Reduces database load

- **FTP Server**
  - File Transfer Protocol server
  - Allows easy upload/download of WordPress files
  - Useful for bulk file management

- **Static Website (Hugo)**
  - Built with **Hugo** static site generator
  - Personal resume website
  - Runs as a separate container from WordPress

- **Adminer**
  - Web-based database management interface
  - Browse, edit, and query database directly

- **Portainer**
  - Docker management web interface
  - Visual container monitoring and control
  - View logs, stats, and manage containers easily

### Architecture

```
                          Client
                            │
                            │ HTTPS (443)
                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NGINX Container                                          │
│  - Reverse Proxy                                                            │
│  - SSL Termination                                                          │
│  - Exposed: 443                                                             │
│                                                                             │
│  Routes:                                                                    │
│   /              → WordPress                                                │
│   /hugo/         → Hugo (Static Site)                                       │
│   /adminer/      → Adminer                                                  │
│   /portainer/    → Portainer                                                │
└───────────────┬───────────────────────┬─────────────────────────────┬───────┘
                │                       │                             │
        FastCGI │                       │ HTTP                        │ HTTPS (internal)
                ▼                       ▼                             ▼
┌────────────────────────────┐   ┌──────────────────────┐  ┌──────────────────────┐
│ WordPress / PHP-FPM        │   │     Hugo Container   │  │  Adminer Container   │
│ - WordPress Core           │   │ - Static Website     │  │ - DB Management UI   │
│ - PHP Runtime              │   │ - Port: 1313         │  │ - Internal Only      │
│ - Port: 9000               │   │                      │  │                      │
└───────────────┬────────────┘   └──────────────────────┘  └──────────────────────┘
                │
                │ TCP (3306)
                ▼
┌────────────────────────────────────────────────────┐
│                MariaDB Container                   │
│  - Relational Database                             │
│  - Persistent Data (Volume)                        │
│  - Internal Only                                   │
└────────────────────────────────────────────────────┘
                ▲
                │ Cache (6379)
┌────────────────────────────────────────────────────┐
│                 Redis Container                    │
│  - Object Cache for WordPress                      │
│  - Improves performance                            │
│  - Internal Only                                   │
└────────────────────────────────────────────────────┘


======================= BONUS SERVICES =======================


┌────────────────────────────────────────────────────┐
│                  FTP Container                     │
│  - File transfer to WordPress volume               │
│  - Chrooted users                                  │
│  - Passive mode                                    │
│  - Exposed: 21 (+ passive ports)                   │
└────────────────────────────────────────────────────┘


┌────────────────────────────────────────────────────┐
│                 Portainer Container                │
│  - Docker Management UI                            │
│  - Internal HTTPS (9443)                           │
│  - Not directly exposed to host                    │
│  - Accessed via NGINX:                             │
│    https://your-login.42.fr/portainer/             │
└────────────────────────────────────────────────────┘

```

## Starting and Stopping the Project

### Starting the Infrastructure

To start all services:

```bash
make
```

This command will:
1. Build all Docker images (first time only)
2. Create necessary networks and volumes
3. Start all containers
4. Wait for services to be ready

**Expected output:**
```
Creating network "inception-network"...
Creating volume "db-data"...
Creating volume "wp-data"...
Building mariadb...
Building wordpress...
Building nginx...
Starting services...
✓ All services are running!
```

### Stopping the Infrastructure

To stop all services without removing data:

```bash
make down
```

This preserves your website data and database.

### Restarting Services

To restart the infrastructure:

```bash
make re
```

This stops, rebuilds, and starts all services.

### Complete Cleanup

⚠️ **WARNING**: This will delete all data including your website and database!

```bash
make fclean
```

Use this only when you want to start completely fresh.

## Accessing Services

### WordPress Website

**URL:** `https://usogukpi.42.fr`

**First Visit:**
- Your browser may show a security warning (self-signed certificate)
- Click "Advanced" → "Proceed to site" (exact wording varies by browser)
- This is expected in development environments

### WordPress Admin Panel

**URL:** `https://usogukpi.42.fr/wp-admin`

**Login Credentials:**
- Username: Located in `/secrets/credentials.txt`
- Password: Located in `/secrets/credentials.txt`

**Admin Panel Features:**
- Create and edit posts and pages
- Install themes and plugins
- Manage users
- Configure site settings
- View site statistics

### Bonus Services Access

#### Redis Cache
Redis runs internally and does not have a web interface. It's automatically used by WordPress for caching.

**Connection Details:**
- Password: Located in `secrets/redis_password.txt`

**Verify Redis is working:**
```bash
docker exec -it redis redis-cli -a <redis-password> ping
# Should return: PONG
```

#### FTP Server

The FTP service allows secure file transfer between your local machine and the WordPress container volume.

**Connection Details:**
- Host: `usogukpi.42.fr`
- Port: `21`
- Username: Located in `srcs/.env` as `FTP_USER=blabla`
- Password: Located in `secrets/ftp_password.txt`

**Using Terminal (FTP Client):**

1. Open your terminal
2. Connect to the FTP server:

``` bash
ftp usogukpi.42.fr
```

**Enter Login Credentials**

When prompted, you will see:

```text
Name (usogukpi.42.fr):
```

Type your FTP username and press Enter.

Then you will see:

```text
Password:
```

Type your FTP password and press Enter.

⚠️ The password will not be visible while typing. This is normal.

If your credentials are correct, you will see:

```text
230 Login successful.
ftp>
```

#### Adminer

Adminer is a lightweight database management interface used to manage the MariaDB database through a web browser.


**URL:** `https://usogukpi.42.fr/adminer`

**Connection Details:**
- Username: Located in **srcs/.env** as `DB_USER_NAME=blabla`
- Password: Located in **secrets/db_password.txt**
- Root Password: Located in **secrets/db_root_password.txt**


**Login Details:**
- System: *MySQL*
- Server: *mariadb*
- Username: `root` or `wp_user` from **.env** file
- Password: From **/secrets/db_root_password.txt** or **/secrets/db_password.txt**
- Database: *wordpress*

**Features:**
- Browse database tables
- Execute SQL queries
- Import/export database
- Edit table structure

#### Hugo

This is a simple static site showcasing your skills or serving as a portfolio/resume.

**URL:** `https://usogukpi.42.fr/hugo`

#### Portainer

Portainer is a web-based Docker management interface.

**URL:** `https://usogukpi.42.fr:9443`

**First Time Setup:**
1. Visit the URL above
2. Create an admin password (minimum 12 characters)
3. Select "Docker" environment
4. Click "Connect"

**Features:**
- View all running containers
- Monitor resource usage (CPU, memory, network)
- View container logs in real-time
- Restart/stop containers
- Execute commands in containers
- Manage volumes and networks
- View images and build history

## Managing Credentials

### Location

All credentials are stored in the **secrets/** directory and **srcs/.env** file:

```
secrets/
├── credentials.txt                     # WordPress admin password
├── db_password.txt                     # MariaDB database user password
├── db_root_password.txt                # MariaDB root password
├── ftp_password_bonus.txt              # FTP server password (bonus)
├── grafana_admin_password_bonus.txt    # Grafana admin password (bonus)
└── redis_password_bonus.txt            # Redis password (bonus)

```

### Viewing Credentials

```bash
# WordPress admin credentials
cat secrets/credentials.txt

# Database credentials
cat secrets/db_password.txt

# View environment variables
cat srcs/.env
```

### Security Best Practices

1. **Never commit secrets to Git**
   - The `secrets/` directory is in `.gitignore`
   - Always keep credentials local

2. **Use strong passwords**
   - Minimum 12 characters
   - Mix of letters, numbers, and symbols

3. **Change default passwords**
   - Modify credentials after first setup
   - Update both files and database

### Changing Passwords

⚠️ **Important**: Changing passwords requires rebuilding containers

1. Stop the infrastructure:
   ```bash
   make down
   ```

2. Update password files:
   ```bash
   # Edit the password files
   nano secrets/db_password.txt
   nano secrets/credentials.txt
   ```

3. Remove old volumes (data will be lost):
   ```bash
   make fclean
   ```

4. Restart with new passwords:
   ```bash
   make
   ```

## Verifying Services

### Check All Services Are Running

```bash
docker ps
```

**Expected output:**

```
CONTAINER ID   IMAGE       STATUS         PORTS                   NAMES
abc123def456   nginx       Up 2 minutes   0.0.0.0:443->443/tcp   nginx
def456ghi789   wordpress   Up 2 minutes   9000/tcp               wordpress
ghi789jkl012   mariadb     Up 2 minutes   3306/tcp               mariadb
```

All containers should show `STATUS: Up`.

### Check Individual Services

**NGINX:**

```bash
docker logs nginx
```
Look for: `nginx: ready for start up`

**WordPress:**
```bash
docker logs wordpress
```
Look for: `NOTICE: ready to handle connections`

**MariaDB:**
```bash
docker logs mariadb
```
Look for: `mysqld: ready for connections`

### Test Website Accessibility

```bash
curl -k https://usogukpi.42.fr
```

You should see HTML content from WordPress.

### Check SSL Certificate

```bash
openssl s_client -connect usogukpi.42.fr:443 -servername usogukpi.42.fr
```

Look for:
- `Protocol: TLSv1.2` or `Protocol: TLSv1.3`
- `Verify return code: 0 (ok)` or certificate details

### Verify Bonus Services

**Redis:**
```bash
docker logs redis
# Look for: "Ready to accept connections"

docker exec -it redis redis-cli -a <redis-password> ping
# Should return: PONG
```

**FTP Server:**
```bash
docker logs ftp
# Look for: "vsftpd: started"

# Test FTP connection
ftp usogukpi.42.fr
```

**Adminer:**
```bash
curl -k https://usogukpi.42.fr/adminer
# Should return HTML content
```

**Static Website:**
```bash
curl -k https://usogukpi.42.fr/portfolio
# Should return your portfolio HTML
```

**Portainer:**
```bash
docker logs portainer
# Look for: "Starting Portainer"

curl -k https://usogukpi.42.fr:9443
# Should return Portainer login page
```

## Common Tasks

### Viewing Logs

**All services:**
```bash
docker-compose -f srcs/docker-compose.yml logs
```

**Specific service:**
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

**Follow logs in real-time:**
```bash
docker logs -f wordpress
```

### Checking Disk Usage

**Volume sizes:**
```bash
docker volume ls
du -sh /home/usogukpi/data/*
```

**Container sizes:**
```bash
docker ps -s
```

## Quick Reference

### Main Services

| Task | Command/URL |
|------|-------------|
| Start services | `make` |
| Stop services | `make down` |
| Restart services | `make re` |
| View logs | `docker-compose -f srcs/docker-compose.yml logs` |
| Check status | `docker ps` |
| Access website | `https://usogukpi.42.fr` |
| Admin panel | `https://usogukpi.42.fr/wp-admin` |
| Clean everything | `make fclean` ⚠️ |

### Bonus Services

| Service | URL/Access | Purpose |
|---------|------------|---------|
| Redis Cache | `redis:6379` (internal) | WordPress caching |
| FTP Server | `ftp://your-login.42.fr:21` | File management |
| Adminer | `https://usogukpi.42.fr/adminer` | Database management |
| Static Site | `https://usogukpi.42.fr/hugo` | Portfolio/resume |
| Portainer | `https://usogukpi.42.fr:9443` | Docker GUI management |

### Quick Checks

| Check | Command |
|-------|---------|
| Redis status | `docker exec redis redis-cli ping` |
| FTP status | `docker logs ftp` |
| Adminer access | `curl -k https://usogukpi.42.fr/adminer` |
| Portainer status | `docker logs portainer` |
| All containers | `docker ps` |