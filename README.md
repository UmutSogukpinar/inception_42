<div align="center">
  <a href="https://github.com/umutsogukpinar/inception">
    <img src="https://github.com/ayogun/42-project-badges/blob/main/badges/inceptionm.png" alt="Inception Logo" width="200">
  </a>

  <h1>Inception</h1>

 <p>
    <b>"Building a containerized infrastructure 
        using Docker and Docker Compose."
    </b>
</p>

  <p>
    <a href="https://github.com/umutsogukpinar/inception">
      <img src="https://img.shields.io/badge/Language-Docker%20%2F%20Shell-blue?style=for-the-badge&logo=docker" alt="Docker / Shell">
    </a>
    <a href="#">
      <img src="https://img.shields.io/badge/Score-125%2F100-success?style=for-the-badge" alt="Score">
    </a>
  </p>
</div>



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
- Adminer: `https://usogukpi.42.fr/adminer`
- Portainer: `https://usogukpi.42.fr/portainer`
- Hugo Static Website: `https://usogukpi.42.fr/hugo`

### 🛑 Stopping the Services
```bash
make down
```

### 🧹 Cleaning Up
```bash
make fclean
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

## 🤖 AI Usage

AI tools were used in this project for the following purposes:

- **Research and Documentation**  
  Understanding Docker Compose syntax, NGINX configuration options, SSL/TLS setup, and overall container architecture design.

- **Debugging**  
  Troubleshooting container startup issues, volume permission errors, network connectivity problems, and service communication between containers.

- **README & Markdown Syntax Assistance**  
  Structuring the project documentation, improving clarity and formatting,  
  and receiving assistance with proper **Markdown syntax** (headings, tables, code blocks, formatting best practices).


All AI-generated content was reviewed, tested, and modified to meet project requirements. The core logic and architecture decisions were made independently.
