<div align="center">
  <a href="https://github.com/umutsogukpinar/inception_42">
    <img src="https://github.com/ayogun/42-project-badges/blob/main/badges/inceptionm.png" alt="Inception Logo" width="200">
  </a>

  <h1>Inception</h1>
  
  <p>
    <b>"Building a containerized infrastructure 
        using Docker and Docker Compose."
    </b>
  </p>

  <p>
    <a href="#">
      <img src="https://img.shields.io/badge/Score-125%2F100-success?style=for-the-badge" alt="Score">
    </a>
  </p>

</div>


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

### Content and Structure

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
                │                       │
        FastCGI │                       │ HTTP
                ▼                       ▼
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
                │
                │ Cache
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

## Service, Description, Technology


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


## 📦 Dependencies & Prerequisites

Before building the project, ensure that your host machine has the following tools installed. The project is designed to run on a **Linux** environment (specifically the 42 VM).

| Dependency | Version Requirement | Purpose |
| :--- | :--- | :--- |
| **Docker Engine** | `20.10.x` or higher | Core containerization runtime. |
| **Docker Compose** | `v2.x`  | Orchestration tool for defining services. |
| **GNU Make** | `4.x` or higher | Task automation tool for build commands. |
| **Sudo** | - | Required to modify `/etc/hosts`. |

### 🔍 Verify Installation
You can check if the required tools are installed by running:

```bash
docker --version
docker compose version
make --version
```

## Makefile Commands

| Command | Description |
| :--- | :--- |
| `make` | **(Default)** Initializes the environment and starts the containers (`up`). |
| `make init` | Runs the helper script to initialize data directories. |
| `make up` | Builds images and starts containers in detached mode. |
| `make down` | Stops containers and removes networks. |
| `make clean` | Stops containers and **removes project volumes** (`down -v`). |
| `make fclean` | **Deep Clean:** Runs the clear script and prunes all Docker system data. |
| `make re` | **Reinstall:** Performs a full reset (`fclean` + `all`). |