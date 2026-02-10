*This project has been created as part of the 42 curriculum by usogukpi.*

# 🚀 Project Overview

## 📝 Description

This project is part of the **42 curriculum** and focuses on building a containerized application using **Docker**.  
The main goal is to understand **containerization**, **service isolation**, **networking**, **secrets management**, and **deployment architecture** through a real-world setup.

The project demonstrates how multiple services can work together in a controlled, reproducible, and secure environment using Docker and Docker Compose.

Key objectives:
- Learn Docker images and containers
- Understand service communication via Docker networks
- Manage configuration with environment variables and secrets
- Compare Docker-based solutions with traditional approaches

---

## Instructions

### 📦 Dependencies & Prerequisites
| Dependency | Version Requirement | Purpose |
| :--- | :--- | :--- |
| **Docker Engine** | `20.10.x` or higher | Core containerization runtime. |
| **Docker Compose** | `v2.x`  | Orchestration tool for defining services. |
| **GNU Make** | `4.x` or higher | Task automation tool for build commands. |

### 🔍 Verify Installation of Prerequisites
You can check if the required tools are installed by running:

```bash
docker --version
docker compose version
make --version
```

### ⚙️ Installation

Clone the repository:
```bash
git clone <repository_url>
cd <repository_name>
make
```

## ⚖️ Technical Comparisons

### 🖥️ Virtual Machines vs Docker

| Virtual Machines | Docker |
|------------------|--------|
| Full guest OS per instance | Shares host OS kernel |
| High resource consumption | Lightweight and efficient |
| Slow startup times | Near-instant startup |
| Harder to scale | Designed for scalability |

Docker was chosen for its lightweight nature and suitability for microservice architectures.

---

### 🔐 Secrets vs Environment Variables

| Secrets | Environment Variables |
|--------|----------------------|
| Stored securely by Docker | Exposed to process environment |
| Not baked into images | Can leak via logs or dumps |
| Suitable for passwords and keys | Suitable for non-sensitive config |

Docker secrets are used for sensitive data such as passwords and credentials.

---

### 🌐 Docker Network vs Host Network

| Docker Network | Host Network |
|----------------|-------------|
| Isolated container communication | No isolation |
| Built-in DNS resolution | No service discovery |
| Secure by default | Increased security risks |

Docker networks provide controlled and secure inter-service communication.

---

### 💾 Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|----------------|-------------|
| Managed by Docker | Direct host filesystem access |
| Portable and safer | Host-dependent |
| Recommended for production | Mainly for development |

Docker volumes are used for persistent data such as databases to ensure data integrity and portability.

## 📂 Project Structure

```bash
.
├── Makefile
├── README.md
├── secrets/                # Credentials
└── srcs/
    ├── .env                # Environment variables
    ├── docker-compose.yml  # Main orchestration file
    ├── tools/
    │   └── util.sh
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            ├── adminer/
            ├── ftp/
            ├── hugo/
            ├── portainer/
            └── redis/
```

## 🧩 Content and Structure

All services run in isolated Docker containers (built on **Alpine Linux** and **Debian**) and 
communicate through a private Docker network. Only the necessary ports are exposed to the host machine.

~~~
                          Client
                            │
                            │ HTTPS
                            ▼
┌──────────────────────────────────────────────────────────┐
│                    NGINX Container                       │
│  - Reverse Proxy                                         │
│  - SSL Termination                                       │
│  - Exposed: 443                                          │
│                                                          │
│  Routes:                                                 │
│   /        → WordPress                                   │
│   /hugo/   → Hugo                                        │
└───────────────┬───────────────────────────┬──────────────┘
                │                           │
        FastCGI │                           │ HTTP
                ▼                           ▼
┌────────────────────────────┐   ┌──────────────────────┐
│ WordPress / PHP-FPM        │   │                      │
│                            │   │    Static Website    │
│ - WordPress Core           │   │         Hugo         │ 
│ - PHP Runtime              │   │  - Port: 1313        │
│ - Port: 9000               │   │                      │
└───────────────┬────────────┘   └──────────────────────┘
                │
                │ TCP
                ▼
┌────────────────────────────────────────────────────┐
│                MariaDB Container                   │
│  - Relational Database                             │
│  - Persistent Data                                 │
│  - Port: 3306                                      │
└────────────────────────────────────────────────────┘
                  	  	▲
                  	  	│ Cache
                  	  	│ 
┌────────────────────────────────────────────────────┐
│                 Redis Container                    │
│  - Object Cache (WordPress)                        │
│  - Improves performance                            │
│  - Port: 6379                                      │
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
│                Adminer Container                   │
│  - Database management UI                          │
│  - Accesses MariaDB internally                     │
│  - Exposed: 8080                                   │
└────────────────────────────────────────────────────┘


┌────────────────────────────────────────────────────┐
│                 Portainer Container                │
│  - Docker Management UI                            │
│  - Manages containers, volumes, networks           │
│  - Exposed: 9443 (HTTPS)                           │
│  - Access to Docker socket                         │
└────────────────────────────────────────────────────┘

~~~

##  🧠 Service, Description, Technology


### ✅ Mandatory Part

| Service | Description | Technology |
| :--- | :--- | :--- |
| **NGINX** | Entry point of the cluster. Handles SSL/TLS termination and reverse proxying. | Debian, OpenSSL |
| **MariaDB** | Relational database storing WordPress data. | Debian, MariaDB |
| **WordPress** | The CMS running on PHP-FPM, communicating with MariaDB. | Debian, PHP 8 |

### 🌟 Bonus Part

| Service | Description
| :--- | :---
| **Redis** | In-memory object caching for WordPress to improve performance. |
| **FTP Server** | Secure file transfer (vsftpd) pointing to the WordPress|volume.|
| **Adminer** | Lightweight Web UI for managing the MariaDB database. |
| **Hugo** | A static website generator serving a personal page. |
| **Portainer** | Web UI for managing Docker containers, images, and networks.| 


## 🛠️ Makefile Commands

| Command | Description |
| :--- | :--- |
| `make` | **(Default)** Initializes the environment and starts the containers (`up`). |
| `make init` | Runs the helper script to initialize data directories. |
| `make up` | Builds images and starts containers in detached mode. |
| `make down` | Stops containers and removes networks. |
| `make clean` | Stops containers and **removes project volumes** (`down -v`). |
| `make fclean` | **Deep Clean:** Runs the clear script and prunes all Docker system data. |
| `make re` | **Reinstall:** Performs a full reset (`fclean` + `all`). |

## 📚Resources

### 📖 Technical References

- Docker Official Documentation  
  https://docs.docker.com/  
  Used to understand Docker images, containers, volumes, networks, and best practices.

- Docker Compose Documentation  
  https://docs.docker.com/compose/  
  Referenced for multi-container orchestration and service dependency management.

- NGINX Documentation  
  https://nginx.org/en/docs/  
  Used to configure the reverse proxy, request routing, and HTTP handling.

- Linux Man Pages  
  https://man7.org/linux/man-pages/  
  Referenced for system-level behavior, permissions, networking, and process management.

---

### 🤖 AI Usage Disclosure

AI tools were used **only as an auxiliary learning and productivity aid**, not as a replacement for understanding or implementation.

Specifically, AI was used for:
- Clarifying Docker and containerization concepts
- Reviewing configuration logic (Dockerfiles, docker-compose.yml)
- Improving documentation structure and readability
- Assisting in drafting and refining the README content

AI was **not** used to:
- Generate the core project architecture
- Implement business logic or service behavior
- Debug runtime issues
- Make final design or security decisions

All implementation, configuration, testing, and final decisions were performed manually by the project author in accordance with the 42 curriculum rules.
