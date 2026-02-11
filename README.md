*This project has been created as part of the 42 curriculum by usogukpi*

# 🐳 Inception

## 📖 Description

Inception is a system administration project that focuses on containerization and infrastructure deployment using Docker. The goal is to set up a small infrastructure composed of different services running in dedicated containers, orchestrated with Docker Compose.

This project creates a complete WordPress hosting environment with the following services:
- **NGINX**: Web server with TLS encryption (TLSv1.2/1.3)
- **WordPress + PHP-FPM**: Content management system
- **MariaDB**: Database server

All services run in isolated Docker containers, connected through a custom Docker network, with persistent data storage using Docker volumes.

## ⚙️ Instructions

### 🧰 Prerequisites

- A virtual machine running **Debian** or **Alpine Linux**
- **Docker Engine** installed
- **Docker Compose (v2)** installed
- **GNU Make** installed (required to build and manage the project using `make`)

### 🔍 Requirements Verification

You can verify that all required tools are properly installed by running:

```bash
docker --version
docker compose version
make --version
```


### 🛠️ Setup
1. Clone this repository to your virtual machine
2. Configure your domain name to point to your local IP:
   ```bash
   # Add to /etc/hosts
   127.0.0.1 usogukpi.42.fr
   ```
3. Create necessary secrets and environment files (see DEV_DOC.md)
4. Build and start the infrastructure:
   ```bash
   make
   ```

### 🌐 Accessing the Services
- WordPress website: `https://usogukpi.42.fr`
- WordPress admin panel: `https://usogukpi.42.fr/wp-admin`

### 🛑 Stopping the Services
```bash
make down
```

### 🧹 Cleaning Up
```bash
make fclean
```

## Project Structure

```
.
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── ftp_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── bonus/
        │   ├── adminer/
        │   │   └── Dockerfile
        │   ├── ftp/
        │   │   ├── Dockerfile
        │   │   ├── conf/
        │   │   └── tools/
        │   ├── portainer/
        │   │   └── Dockerfile
        │   ├── redis/
        │   │   ├── Dockerfile
        │   │   ├── tools/
        │   │   └── conf/
        │   └── hugo/
        │       ├── Dockerfile
        │       └── content/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

## 🔬 Project Description

### ⚙️ Docker and Containerization

This project implements a microservices architecture using Docker containers. Each service (NGINX, WordPress, MariaDB) runs in isolation with its own filesystem, process space, and network interface.

#### ⚖️ Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|-----------------|---------|
| **Resource Usage** | Heavy - includes full OS | Lightweight - shares host kernel |
| **Startup Time** | Minutes | Seconds |
| **Isolation** | Complete hardware virtualization | Process-level isolation |
| **Portability** | Limited - large image sizes | High - small, portable images |
| **Use Case** | Running different OS, strong isolation | Microservices, rapid deployment |

**Why Docker for this project?** Docker provides faster deployment, better resource efficiency, and easier management of microservices compared to full virtualization.

#### ⚖️ Secrets vs Environment Variables

| Feature | Docker Secrets | Environment Variables |
|---------|---------------|----------------------|
| **Security** | Encrypted at rest and in transit | Stored in plain text |
| **Scope** | Swarm mode, mounted as files | Available to all processes |
| **Visibility** | Not visible in `docker inspect` | Visible in `docker inspect` |
| **Best For** | Passwords, API keys, certificates | Non-sensitive configuration |

**Implementation:** This project uses Docker secrets for sensitive data (database passwords, credentials) and environment variables for non-sensitive configuration (domain names, usernames).

#### ⚖️ Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|---------------|--------------|
| **Isolation** | Isolated network namespace | Shares host's network |
| **Port Mapping** | Required for external access | Direct access to all ports |
| **Security** | Better - controlled exposure | Lower - all ports exposed |
| **Service Discovery** | Built-in DNS | Manual configuration |

**Implementation:** This project uses a custom bridge network (`inception-network`) allowing containers to communicate using service names while maintaining isolation from the host.

#### ⚖️ Docker Volumes vs Bind Mounts

| Feature | Docker Volumes | Bind Mounts |
|---------|---------------|-------------|
| **Management** | Managed by Docker | User manages paths |
| **Portability** | Platform-independent | Platform-specific paths |
| **Permissions** | Docker handles permissions | Host permissions apply |
| **Backup** | Easier to backup/migrate | Manual backup required |
| **Performance** | Optimized by Docker | Direct filesystem access |

**Implementation:** This project uses Docker named volumes for:
- WordPress database (`db-data`)
- WordPress files (`wp-data`)

Both volumes are stored in `/home/login/data` on the host for easy access and backup.

### 🎯 Design Choices

1. **Base Images**: Using Alpine Linux (penultimate stable version) for minimal attack surface and smaller image sizes
2. **TLS Security**: NGINX configured with TLSv1.2/1.3 only, ensuring modern encryption standards
3. **Process Management**: Each container runs a single process (no `tail -f` hacks), following Docker best practices
4. **Restart Policy**: Containers configured to restart on failure, ensuring high availability
5. **No Latest Tags**: All images use specific version tags for reproducibility

### ✨ Bonus Services

In addition to the mandatory services, the following bonus features have been implemented:

* **Redis Cache**
   - In-memory caching for WordPress
   - Significantly improves page load times
   - Reduces database queries
   - Accessible at: `redis:6379`

* **FTP Server (vsftpd)**
   - Provides FTP access to WordPress files
   - Enables easy file management
   - Port: 21 (control), 21000-21010 (passive mode)
   - Access: `ftp://usogukpi.42.fr`

* **Static Website (Hugo)**
  - **Purpose:** Personal portfolio / resume website  
  - **Technology:** Built with **Hugo** (static site generator) using HTML/CSS/JavaScript  
  - **Architecture:** Generates static files served directly by NGINX  
  - **Objective:** Demonstrates modern static site generation, content structuring, and clean design principles  
  - **Access URL:** `https://usogukpi.42.fr/hugo`

* **Adminer**
   - Web-based database management tool
   - Lightweight alternative to phpMyAdmin
   - Direct database access and query execution
   - Accessible at: `https://usogukpi.42.fr/adminer`

* **Portainer**
   - Docker container management UI
   - Visual monitoring and management of all containers
   - Resource usage statistics and logs
   - Accessible at: `https://usogukpi.42.fr:9443`
   - Provides GUI for Docker administration

## 📚 Resources

### Docker Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Service-Specific Resources
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Codex](https://wordpress.org/support/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)

### Additional Learning
- [Understanding PID 1 in Docker](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [Docker Networks Deep Dive](https://docs.docker.com/network/)
- [Docker Volumes Guide](https://docs.docker.com/storage/volumes/)

### AI Usage

AI tools were used in this project for:
- **Research and Documentation**: Understanding Docker Compose syntax, NGINX configuration options, and SSL/TLS setup

- **Debugging**: Troubleshooting container startup issues and network connectivity problems


All AI-generated content was reviewed, tested, and modified to meet project requirements. The core logic and architecture decisions were made independently.
