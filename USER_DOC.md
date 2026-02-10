# 📘 User Documentation

This document explains how to manage, access, and verify the **Inception** infrastructure.

---

## 🛠 Services
The stack provides a complete web infrastructure composed of the following isolated services:

### Mandatory Services
* **NGINX:** The entry point for the website, handling secure connections (TLSv1.2/TLSv1.3) via port 443.
* **WordPress + PHP-FPM:** The content management system where the website content is built and displayed.
* **MariaDB:** The database server that stores all WordPress data.

### Bonus Services
* **Redis:** An in-memory object cache configured for WordPress to improve performance.
* **Adminer:** A lightweight web interface for managing the MariaDB database.
* **FTP Server:** Allows secure file transfer to the WordPress volume.
* **Hugo:** A static website generator serving a personal page, accessible via the main domain.
* **Portainer:** A visual management tool for Docker containers and networks.

---

## 🚀 2. How to Start and Stop the Project
The project is managed via a `Makefile` at the root of the repository.

### Starting the Project
To build the Docker images and start all services (including bonuses), open your terminal at the project root and run:
```bash
make
# OR
make up
```

### Stopping the Project

To stop the containers and remove the created networks:

```bash
make down
```

## 🌐 Accessing the Services
Once the services are running, you can access them via your web browser or FTP client.



| Service        | URL / Access Method                  | Description                     |
|----------------|--------------------------------------|---------------------------------|
| Main Website   | https://usogukpi.42.fr               | WordPress Home                  |
| Static Site    | https://usogukpi.42.fr/hugo/         | Hugo Personal Page (Proxied)    |
| Admin Panel    | https://usogukpi.42.fr/wp-admin      | WordPress Dashboard             |
| Adminer        | http://usogukpi.42.fr:8080           | Database Management UI          |
| Portainer      | https://usogukpi.42.fr:9443          | Docker Infrastructure UI        |
| FTP            | ftp://usogukpi.42.fr (Port 21)       | File Access                     |

Note: Ensure your /etc/hosts file maps 127.0.0.1 to usogukpi.42.fr.


## 🔐 Managing Credentials

Security credentials are stored in the `secrets/` directory and the `.env` file.

- **WordPress Admin**
  - Configured in `.env`
  - User: `neyabai`

- **Database Passwords**
  - User password: `secrets/db_password.txt`
  - Root password: `secrets/db_root_password.txt`

- **FTP Credentials**
  - **User**
    - Defined in `.env`
    - Default: `ftpuser`
  - **Password**
    - Stored in `secrets/ftp_password_bonus.txt`

- **Redis Password**
  - Stored in `secrets/redis_password_bonus.txt`


## ✅ Verifying Service Status

To check if the services are running correctly, follow the steps below.

### List Running Containers

Run the following command:

```bash
docker ps
```

### Test Connections

- **Redis**
  - Check the logs to confirm it is accepting connections:
    ```bash
    docker logs redis
    ```

- **FTP**
  - Try connecting using a terminal client:
    ```bash
    ftp usogukpi.42.fr
    ```
  - Port: `21`
