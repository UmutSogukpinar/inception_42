# Developer Documentation

This document provides detailed technical information for developers working on the Inception project.

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Project Architecture](#project-architecture)
3. [Building and Running](#building-and-running)
4. [Container Management](#container-management)
5. [Volume Management](#volume-management)
6. [Network Configuration](#network-configuration)
7. [Configuration Files](#configuration-files)
8. [Development Workflow](#development-workflow)
9. [Debugging](#debugging)

## Environment Setup

### Prerequisites

1. **Virtual Machine**
   - Debian Bookworm or Alpine Linux (penultimate stable)
   - Minimum 2GB RAM, 15GB disk space
   - User with sudo privileges

2. **Required Software**
   ```bash
   # Update package manager
   sudo apt update
   
   # Install Docker
   sudo apt install -y docker.io
   
   # Install Docker Compose
   sudo apt install -y docker-compose
   
   # Add user to docker group
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **Verify Installation**
   ```bash
   docker --version
   docker-compose --version
   ```

### Initial Project Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Create Directory Structure**
   ```bash
   mkdir -p secrets
   touch srcs/.env
   ```

3. **Configure Domain Name**
   ```bash
   # Add to /etc/hosts
   echo "127.0.0.1 $USER.42.fr" | sudo tee -a /etc/hosts
   ```

4. **Create Environment Files**

   **secrets/db_password.txt:**
   ```bash
   echo "your_secure_database_password" > secrets/db_password.txt
   ```

   **secrets/db_root_password.txt:**
   ```bash
   echo "your_secure_root_password" > secrets/db_root_password.txt
   ```

   **secrets/credentials.txt:**
   ```bash
   cat > secrets/credentials.txt << EOF
   wordpress_admin
   your_secure_admin_password
   admin@example.com
   EOF
   ```

   **secrets/ftp_password.txt:**
   ```bash
   echo "your_secure_ftp_password" > secrets/ftp_password.txt
   ```

   **srcs/.env:**
   ```bash
   cat > srcs/.env << EOF

    # ========= General Settings =========

    USER_NAME=usogukpi
    DATA_DIR=/home/usogukpi/data
    DOMAIN_NAME=usogukpi.42.fr

    # ========= MariaDB =========

    DB_NAME=wordpress
    DB_USER_NAME=db_user

    # ========= WordPress =========

    WORDPRESS_TITLE=Inception
    WP_ADMIN=neyabai
    WP_ADMIN_EMAIL=usogukpi@student.42istanbul.com.tr

    WORDPRESS_DB_USER=wp_user
    WORDPRESS_DB_HOST=mariadb

    DB_HOST=mariadb:3306


    # PHP-FPM listen
    PHP_FPM_LISTEN=9000

    # ========= Nginx =========

    NGINX_PORT=443

    # ========= FTP =========

    FTP_USER=ftpuser

    # ========= Redis =========

    REDIS_HOST=redis
    REDIS_PORT=6379

    # ========= Portainer =========

    PORTAINER_PORT=9443
   EOF
   ```

5. **Set Proper Permissions**
   ```bash
   chmod 600 secrets/*
   chmod 755 /home/$USER/data
   chmod 755 /home/$USER/data/{db,wordpress}
   ```

## Project Architecture

### Directory Structure

```
inception/
├── Makefile                      # Build automation
├── README.md                     # Project overview
├── USER_DOC.md                   # User documentation
├── DEV_DOC.md                    # This file
├── secrets/                      # Sensitive data (git-ignored)
└── srcs/
    ├── .env                      # Environment variables
    ├── docker-compose.yml        # Service orchestration
    └── requirements/
        ├── bonus/
        │   ├── adminer/
        │   ├── ftp/
        │   ├── hugo/
        │   ├── portainer/
        │   └── redis/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

### Container Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Host Machine                             │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Docker Network (Bridge)                      │  │
│  │                                                           │  │
│  │  ┌──────────┐  ┌──────────┐  ┌─────────┐  ┌─────────┐     │  │
│  │  │  NGINX   │  │WordPress │  │MariaDB  │  │  Redis  │     │  │
│  │  │  :443    │←→│   :9000  │←→│  :3306  │←→│  :6379  │     │  │
│  │  └────┬─────┘  └────┬─────┘  └────┬────┘  └─────────┘     │  │
│  │       │             │             │                       │  │
│  │       │             └─────────────┼──────────┐            │  │
│  │       │                           │          │            │  │
│  │  ┌────┴─────┐  ┌──────────┐  ┌───┴────┐  ┌─┴─────────┐    │  │
│  │  │ Adminer  │  │   FTP    │  │Website │  │ Portainer │    │  │
│  │  │  :8080   │  │:21,21000+│  │  :80   │  │   :9443   │    │  │
│  │  └──────────┘  └────┬─────┘  └────────┘  └───────────┘    │  │
│  │                     │                                     │  │
│  └─────────────────────┼─────────────────────────────────────┘  │
│                        │                                        │
│               Ports: 443, 21, 9443                              │
│                        │                                        │
│  ┌─────────────────────▼──────────────────────────────────────┐ │
│  │              /home/$USER/data/                             │ │
│  │  ├── wordpress/     (WP files)                             │ │
│  │  ├── db/            (Database files)                       │ │
│  │  ├── ftp/           (FTP data)                             │ │
│  │  └── portainer/     (Portainer data)                       │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Service Dependencies

**Mandatory Services:**
```
MariaDB (starts first)
    ↓
Redis (caching layer)
    ↓
WordPress (depends on MariaDB and Redis)
    ↓
NGINX (depends on WordPress)
```

**Bonus Services:**
```
FTP → WordPress Volume (parallel to WordPress)
Adminer → MariaDB (parallel to WordPress)
Website → NGINX (independent static site)
Portainer → Docker Socket (independent management)
```

## Building and Running

### Using the Makefile

The Makefile automates the entire build and deployment process.

**Available targets:**

```makefile
make        # Build and start all services
make build  # Build Docker images only
make up     # Start services without rebuilding
make down   # Stop services (keeps data)
make re     # Restart everything (rebuild)
make clean  # Remove containers and networks
make fclean # Remove everything including volumes
```

### Manual Build Process

If you prefer manual control:

1. **Build images:**
   ```bash
   docker-compose -f srcs/docker-compose.yml build
   ```

2. **Start services:**
   ```bash
   docker-compose -f srcs/docker-compose.yml up -d
   ```

3. **View logs:**
   ```bash
   docker-compose -f srcs/docker-compose.yml logs -f
   ```

4. **Stop services:**
   ```bash
   docker-compose -f srcs/docker-compose.yml down
   ```

### Build Process Details

**What happens during build:**

1. **Image Building**
   - Dockerfiles are processed
   - Base images (Alpine/Debian) are pulled
   - Dependencies are installed
   - Configuration files are copied
   - Initialization scripts are set up

2. **Network Creation**
   - Custom bridge network `inception-network` is created
   - Allows containers to communicate by name

3. **Volume Creation**
   - Named volumes `db-data` and `wp-data` are created
   - Mapped to `/home/$USER/data/` on host

4. **Container Startup**
   - MariaDB starts first
   - WordPress waits for database
   - NGINX starts last

## Container Management

### Inspecting Containers

**List running containers:**
```bash
docker ps
```

**View all containers (including stopped):**
```bash
docker ps -a
```

**Inspect container details:**
```bash
docker inspect nginx
docker inspect wordpress
docker inspect mariadb
```

**View container resource usage:**
```bash
docker stats
```

### Accessing Containers

**Execute commands in running container:**
```bash
# Interactive shell
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh

# Single command
docker exec nginx ls -la /etc/nginx
```

**Access MariaDB:**
```bash
docker exec -it mariadb mysql -u root -p$(cat secrets/db_root_password.txt)
```

**Access WordPress CLI:**
```bash
docker exec -it wordpress wp --info --allow-root
```

### Container Lifecycle Commands

```bash
# Start a stopped container
docker start nginx

# Stop a running container
docker stop nginx

# Restart a container
docker restart nginx

# Remove a container
docker rm nginx

# Force remove a running container
docker rm -f nginx
```

### Viewing Container Logs

```bash
# View all logs
docker logs nginx

# Follow logs (real-time)
docker logs -f wordpress

# Last 100 lines
docker logs --tail 100 mariadb

# Logs since specific time
docker logs --since 10m nginx
```

## Volume Management

### Understanding Volumes

Volumes provide persistent storage that survives container restarts and removals.

**Volume types used:**
- Named volumes (managed by Docker)
- Driver: local
- Mount points on host: `/home/$USER/data/`

### Volume Operations

**List volumes:**
```bash
docker volume ls
```

**Inspect volume:**
```bash
docker volume inspect db-data
docker volume inspect wp-data
```

**Check volume usage:**
```bash
# From host
du -sh /home/$USER/data/*

# Volume sizes
docker system df -v
```

**Backup volumes:**
```bash
# Backup database volume
docker run --rm -v db-data:/data -v $(pwd)/backups:/backup \
  alpine tar czf /backup/db-backup-$(date +%Y%m%d).tar.gz -C /data .

# Backup WordPress volume
docker run --rm -v wp-data:/data -v $(pwd)/backups:/backup \
  alpine tar czf /backup/wp-backup-$(date +%Y%m%d).tar.gz -C /data .
```

**Restore volumes:**
```bash
# Restore database volume
docker run --rm -v db-data:/data -v $(pwd)/backups:/backup \
  alpine sh -c "cd /data && tar xzf /backup/db-backup-20240211.tar.gz"

# Restore WordPress volume
docker run --rm -v wp-data:/data -v $(pwd)/backups:/backup \
  alpine sh -c "cd /data && tar xzf /backup/wp-backup-20240211.tar.gz"
```

**Remove volumes:**
```bash
# Remove specific volume (⚠️ destroys data)
docker volume rm db-data

# Remove all unused volumes
docker volume prune
```

### Data Persistence

**Where data is stored:**

```bash
# On host machine
/home/$USER/data/
├── db/          → MariaDB data files
│   ├── mysql/
│   ├── wordpress/
│   └── ...
├── wordpress/   → WordPress installation
│   ├── wp-content/
│   ├── wp-config.php
│   └── ...
├── ftp/         → FTP data (if separate volume)
└── portainer/   → Portainer configuration
    └── portainer.db
```

**Direct access to data:**
```bash
# View database files
ls -la /home/$USER/data/db/

# View WordPress files
ls -la /home/$USER/data/wordpress/

# View Portainer data
ls -la /home/$USER/data/portainer/

# Verify ownership
ls -ld /home/$USER/data/*
```

## Network Configuration

### Network Overview

The project uses a custom bridge network for container communication.

**Network name:** `inception-network`
**Driver:** bridge
**Scope:** local

### Network Commands

**List networks:**
```bash
docker network ls
```

**Inspect network:**
```bash
docker network inspect inception-network
```

**View connected containers:**
```bash
docker network inspect inception-network | grep -A 10 Containers
```

### Inter-Container Communication

Containers communicate using service names as hostnames:

```yaml
# WordPress connects to MariaDB
DB_HOST=mariadb:3306

# NGINX proxies to WordPress
fastcgi_pass wordpress:9000;
```

**Test connectivity:**
```bash
# From NGINX to WordPress
docker exec nginx ping -c 3 wordpress

# From WordPress to MariaDB
docker exec wordpress nc -zv mariadb 3306
```

### Port Mapping

Only NGINX exposes ports to the host:

```yaml
nginx:
  ports:
    - "443:443"
```

Other services are only accessible within the Docker network.

**Verify port bindings:**
```bash
docker port nginx
# Output: 443/tcp -> 0.0.0.0:443
```

## Configuration Files

### Docker Compose Configuration

**srcs/docker-compose.yml:**

```yaml
version: '3.8'

services:
  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    image: mariadb
    env_file: .env
    secrets:
      - db_root_password
      - db_password
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - inception-network
    restart: unless-stopped

  redis:
    build: ./requirements/bonus/redis
    container_name: redis
    image: redis
    networks:
      - inception-network
    restart: unless-stopped

  wordpress:
    build: ./requirements/wordpress
    container_name: wordpress
    image: wordpress
    depends_on:
      - mariadb
      - redis
    env_file: .env
    secrets:
      - db_password
      - wp_admin_user
      - wp_admin_password
      - wp_admin_email
    volumes:
      - wp-data:/var/www/html
    networks:
      - inception-network
    restart: unless-stopped

  nginx:
    build: ./requirements/nginx
    container_name: nginx
    image: nginx
    depends_on:
      - wordpress
    ports:
      - "443:443"
    volumes:
      - wp-data:/var/www/html:ro
    networks:
      - inception-network
    restart: unless-stopped

  # Bonus Services
  ftp:
    build: ./requirements/bonus/ftp
    container_name: ftp
    image: ftp
    depends_on:
      - wordpress
    secrets:
      - wp_admin_user
      - ftp_password
    volumes:
      - wp-data:/var/www/html
    ports:
      - "21:21"
      - "21000-21010:21000-21010"
    networks:
      - inception-network
    restart: unless-stopped

  adminer:
    build: ./requirements/bonus/adminer
    container_name: adminer
    image: adminer
    depends_on:
      - mariadb
    networks:
      - inception-network
    restart: unless-stopped

  website:
    build: ./requirements/bonus/website
    container_name: website
    image: website
    networks:
      - inception-network
    restart: unless-stopped

  portainer:
    image: portainer/portainer-ce:2.19-alpine
    container_name: portainer
    security_opt:
      - no-new-privileges:true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer-data:/data
    ports:
      - "9443:9443"
    networks:
      - inception-network
    restart: unless-stopped

volumes:
  db-data:
    driver: local
    driver_opts:
      type: none
      device: ${DB_DATA_PATH}
      o: bind
  wp-data:
    driver: local
    driver_opts:
      type: none
      device: ${WP_DATA_PATH}
      o: bind
  portainer-data:
    driver: local
    driver_opts:
      type: none
      device: ${PORTAINER_DATA_PATH}
      o: bind

networks:
  inception-network:
    driver: bridge

secrets:
  db_root_password:
    file: ../secrets/db_root_password.txt
  db_password:
    file: ../secrets/db_password.txt
  wp_admin_user:
    file: ../secrets/credentials.txt
  wp_admin_password:
    file: ../secrets/credentials.txt
  wp_admin_email:
    file: ../secrets/credentials.txt
  ftp_password:
    file: ../secrets/ftp_password.txt
```

### Dockerfile Examples

**MariaDB Dockerfile:**
```dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    && rm -rf /var/cache/apk/*

COPY conf/50-server.cnf /etc/my.cnf.d/
COPY tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh

EXPOSE 3306

ENTRYPOINT ["init-db.sh"]
CMD ["mysqld", "--user=mysql"]
```

**NGINX Dockerfile:**
```dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    nginx \
    openssl \
    && rm -rf /var/cache/apk/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-ssl.sh

RUN setup-ssl.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
```

**WordPress Dockerfile:**
```dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    php81-redis \
    wget \
    && rm -rf /var/cache/apk/*

COPY conf/www.conf /etc/php81/php-fpm.d/
COPY tools/setup-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-wp.sh

EXPOSE 9000

ENTRYPOINT ["setup-wp.sh"]
CMD ["php-fpm81", "-F"]
```

### Bonus Services Configuration

#### Redis Dockerfile

```dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    redis \
    && rm -rf /var/cache/apk/*

COPY conf/redis.conf /etc/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf", "--protected-mode", "no"]
```

**redis.conf:**
```conf
bind 0.0.0.0
port 6379
maxmemory 256mb
maxmemory-policy allkeys-lru
save ""
appendonly no
```

#### FTP Server Dockerfile

```dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    vsftpd \
    && rm -rf /var/cache/apk/*

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/setup-ftp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-ftp.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["setup-ftp.sh"]
CMD ["vsftpd", "/etc/vsftpd/vsftpd.conf"]
```

**vsftpd.conf:**
```conf
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
pasv_address=0.0.0.0
```

**setup-ftp.sh:**
```bash
#!/bin/sh

# Create FTP user
FTP_USER=$(head -n 1 /run/secrets/wp_admin_user)
FTP_PASS=$(cat /run/secrets/ftp_password)

adduser -D -h /var/www/html $FTP_USER
echo "$FTP_USER:$FTP_PASS" | chpasswd

# Set permissions
chown -R $FTP_USER:$FTP_USER /var/www/html

exec "$@"
```

#### Adminer Dockerfile

```dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    php81 \
    php81-session \
    php81-mysqli \
    php81-pdo_mysql \
    wget \
    && rm -rf /var/cache/apk/*

WORKDIR /var/www/html

RUN wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" \
    -O adminer.php

EXPOSE 8080

CMD ["php81", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
```

#### Static Website Dockerfile

```dockerfile
FROM alpine:3.18

RUN apk update && apk add --no-cache \
    nginx \
    && rm -rf /var/cache/apk/*

COPY content/ /var/www/html/
COPY conf/nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**index.html (example):**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Portfolio</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Welcome to My Portfolio</h1>
    </header>
    <main>
        <section>
            <h2>About Me</h2>
            <p>System Administrator & DevOps Engineer</p>
        </section>
        <section>
            <h2>Skills</h2>
            <ul>
                <li>Docker & Containerization</li>
                <li>NGINX Configuration</li>
                <li>Database Management</li>
                <li>WordPress Administration</li>
            </ul>
        </section>
    </main>
    <script src="script.js"></script>
</body>
</html>
```

#### Portainer Configuration

```dockerfile
FROM portainer/portainer-ce:latest

# Portainer uses the official image
# No custom configuration needed
```

**Docker Compose entry:**
```yaml
portainer:
  image: portainer/portainer-ce:2.19-alpine
  container_name: portainer
  restart: unless-stopped
  security_opt:
    - no-new-privileges:true
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - portainer-data:/data
  ports:
    - "9443:9443"
  networks:
    - inception-network
```

## Development Workflow

### Making Changes

1. **Modify configuration or code**
2. **Rebuild affected service:**
   ```bash
   docker-compose -f srcs/docker-compose.yml build <service>
   ```
3. **Restart service:**
   ```bash
   docker-compose -f srcs/docker-compose.yml up -d <service>
   ```

### Testing Changes

**Test NGINX configuration:**
```bash
docker exec nginx nginx -t
```

**Test PHP-FPM configuration:**
```bash
docker exec wordpress php-fpm81 -t
```

**Test MariaDB connectivity:**
```bash
docker exec mariadb mysqladmin ping -h localhost -u root -p$(cat secrets/db_root_password.txt)
```

### Debugging Techniques

**Check service health:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

**View real-time logs:**
```bash
docker-compose -f srcs/docker-compose.yml logs -f --tail=50
```

**Inspect environment variables:**
```bash
docker exec nginx env
docker exec wordpress env | grep WP_
```

**Check file permissions:**
```bash
docker exec wordpress ls -la /var/www/html
docker exec mariadb ls -la /var/lib/mysql
```

## Debugging

### Common Issues and Solutions

#### Container Exits Immediately

**Diagnosis:**
```bash
docker ps -a  # Check exit code
docker logs <container>  # View error messages
```

**Common causes:**
- Syntax error in configuration
- Missing dependencies
- Permission issues
- Process not running in foreground

#### Cannot Connect to Database

**Diagnosis:**
```bash
# Check if MariaDB is running
docker exec wordpress ping -c 3 mariadb

# Test database connection
docker exec wordpress nc -zv mariadb 3306

# Check credentials
docker exec wordpress cat /run/secrets/db_password
```

#### SSL Certificate Issues

**Regenerate certificates:**
```bash
docker exec nginx rm -rf /etc/nginx/ssl
docker restart nginx
```

#### Permission Denied Errors

**Fix volume permissions:**
```bash
sudo chown -R $USER:$USER /home/$USER/data
chmod 755 /home/$USER/data/{db,wordpress}
```

### Advanced Debugging

**Attach to running container:**
```bash
docker attach nginx  # Ctrl+C to detach
```

**Run shell in new container with same image:**
```bash
docker run -it --rm nginx sh
```

**Inspect process inside container:**
```bash
docker exec nginx ps aux
```

**Check network connectivity:**
```bash
# Install debugging tools
docker exec nginx apk add --no-cache curl

# Test endpoints
docker exec nginx curl -I http://wordpress:9000
```

### Debugging Bonus Services

#### Redis Issues

**Check Redis connection:**
```bash
# Test from WordPress
docker exec wordpress redis-cli -h redis ping

# Check Redis logs
docker logs redis

# Monitor Redis commands
docker exec redis redis-cli monitor

# Check memory usage
docker exec redis redis-cli INFO memory
```

#### FTP Connection Problems

**Debug FTP:**
```bash
# Check FTP logs
docker logs ftp

# Verify user exists
docker exec ftp cat /etc/passwd | grep ftp

# Test passive mode ports
for port in {21000..21010}; do
  nc -zv localhost $port
done

# Check file permissions
docker exec ftp ls -la /var/www/html
```

#### Adminer Access Issues

**Debug Adminer:**
```bash
# Check if Adminer is running
docker exec adminer ps aux

# Test Adminer port
docker exec nginx curl http://adminer:8080

# Check NGINX proxy configuration
docker exec nginx cat /etc/nginx/nginx.conf | grep -A 10 adminer

# Verify database connection
docker exec adminer ping -c 3 mariadb
```

#### Portainer Not Accessible

**Debug Portainer:**
```bash
# Check Portainer logs
docker logs portainer

# Verify Docker socket mount
docker exec portainer ls -la /var/run/docker.sock

# Check port binding
netstat -tlnp | grep 9443

# Test Portainer API
curl -k https://localhost:9443/api/system/status
```

#### Static Website Issues

**Debug Website:**
```bash
# Check website container
docker logs website

# Verify NGINX is serving the site
docker exec nginx curl http://website

# Check file permissions
docker exec website ls -la /var/www/html

# Test NGINX configuration
docker exec nginx nginx -t
```

## Best Practices

### Security
- Never commit secrets to version control
- Use Docker secrets for sensitive data
- Run containers as non-root when possible
- Keep base images updated
- Scan images for vulnerabilities

### Performance
- Use `.dockerignore` to exclude unnecessary files
- Minimize layers in Dockerfiles
- Use multi-stage builds when appropriate
- Clean up package manager caches

### Maintainability
- Comment complex configurations
- Version tag your images
- Document custom scripts
- Keep Dockerfiles simple and readable

### Development
- Use bind mounts for local development
- Leverage Docker Compose override files
- Test changes in isolation
- Monitor resource usage

## Useful Commands Reference

### Docker
```bash
docker images                    # List images
docker rmi <image>              # Remove image
docker system prune -a          # Clean everything
docker system df                # Show disk usage
```

### Docker Compose
```bash
docker-compose config           # Validate configuration
docker-compose ps               # List services
docker-compose top              # View running processes
docker-compose exec <service> sh # Execute command
```

### Makefile
```bash
make help                       # Show available targets
make build                      # Build images
make logs                       # View logs
make clean                      # Remove containers
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Alpine Linux Packages](https://pkgs.alpinelinux.org/packages)
- [Debian Packages](https://packages.debian.org/)