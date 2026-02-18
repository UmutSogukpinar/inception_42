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
  Make sure your user has **sudo privileges** before running the commands below.  
  If not, switch to root and grant sudo permission:
  ```bash
    su -
    usermod -aG sudo <your_username>
   ```
  Log out and log back in after this step.

   ```bash
   # Update package manager
   sudo apt update

   # Install Docker
   sudo apt install -y docker.io

   # Install Docker Compose
   sudo apt install -y docker-compose

   # Add user to docker group (run Docker without sudo)
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

	USER_NAME=${USER}
	DATA_DIR=${HOME}/data
	DOMAIN_NAME=usogukpi.42.fr

	# ========= MariaDB =========

	DB_NAME=wordpress
	DB_USER_NAME=wp_user

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

	FTP_PORT=21
	FTP_PASV_PORT_RANGE=30000-30009

	# ========= Redis =========

	REDIS_HOST=redis
	REDIS_PORT=6379

	# ========== Adminer ==========

	ADMINER_PORT=8080
   EOF
   ```

5. **Set Proper Permissions**
   ```bash
   chmod 600 secrets/*
   chmod 755 /home/$USER/data
   chmod 755 /home/$USER/data/{db,wordpress}
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
docker exec -it mariadb mysql -u root -p
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

### Data Persistence

**Where data is stored:**

```bash
# On host machine
/home/$USER/data/
├── mariadb/         
│   ├── mysql/
│   ├── wordpress/
│   └── ...
├── redis /
├── wordpress/  
│   ├── wp-content/
│   ├── wp-config.php
│   └── ...
├── hugo/
└── portainer/
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

**Network name:** `inception`
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
