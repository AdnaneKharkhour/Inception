# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites

- A Linux machine or VM (the project is designed to run inside a VM)
- Docker Engine and Docker Compose (v2)
- `make`
- `sudo` access for creating data directories and editing `/etc/hosts`

### Repository Structure

```
Makefile                         # Build/run/clean entry point
srcs/
  docker-compose.yml             # Service orchestration
  .env                           # Environment variables (not committed)
  requirements/
    nginx/                       # NGINX reverse proxy + TLS
    wordpress/                   # WordPress + PHP-FPM
    mariadb/                     # MariaDB database
    bonus/
      redis/                     # Redis cache
      ftp/                       # vsftpd FTP server
      adminer/                   # Adminer DB UI
      website/                   # Static HTML/CSS site
      service/                   # FileBrowser
secrets/                         # Local secret files (not committed)
```

Each service directory contains at minimum a `Dockerfile`, and most also have a `conf/` directory for configuration files and a `tools/` directory for entrypoint/setup scripts.

### Configuration Files

**`srcs/.env`** -- This is the central configuration file. It must be created manually since it's gitignored. It should contain:

- `DOMAIN_NAME` -- your 42 domain (e.g. `akharkho.42.fr`)
- `DATA_PATH` -- host path for persistent storage (e.g. `/home/akharkho/data`)
- MySQL/MariaDB credentials: `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`
- WordPress credentials: `WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL`, `WP_USER`, `WP_USER_PASSWORD`, `WP_USER_EMAIL`
- FTP credentials: `FTP_USER`, `FTP_PASSWORD`
- FileBrowser credentials: `FB_USER`, `FB_PASSWORD`

**Secrets** -- The `secrets/` directory holds local secret files (`credentials.txt`, `db_password.txt`, `db_root_password.txt`). These are also gitignored. If your setup scripts reference them, make sure they exist before building.

### Host Setup

Map the project domain to localhost:

```bash
echo "127.0.0.1 akharkho.42.fr" | sudo tee -a /etc/hosts
```

The Makefile creates data directories automatically, but if you need them beforehand:

```bash
mkdir -p /home/akharkho/data/mariadb
mkdir -p /home/akharkho/data/wordpress
```

## Building and Launching

### Using the Makefile

The Makefile wraps Docker Compose and handles directory creation:

```bash
make up       # Create data dirs + build all images + start containers
make down     # Stop containers (data preserved)
make clean    # Stop containers + prune images and volumes
make fclean   # clean + delete /home/$USER/data entirely
make re       # fclean + up (full reset and rebuild)
```

`make up` runs `docker compose -f srcs/docker-compose.yml up -d --build`, so images are always rebuilt from Dockerfiles when you run it.

### Direct Docker Compose

If you need finer control:

```bash
# Build only one service
docker compose -f srcs/docker-compose.yml build wordpress

# Build without cache (useful when debugging Dockerfile changes)
docker compose -f srcs/docker-compose.yml build --no-cache nginx

# Start without rebuilding
docker compose -f srcs/docker-compose.yml up -d

# Start only specific services
docker compose -f srcs/docker-compose.yml up -d nginx wordpress mariadb
```

## Managing Containers and Volumes

### Container Operations

```bash
# List running containers and their status
docker compose -f srcs/docker-compose.yml ps

# Follow logs for a service
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Tail last 50 lines
docker compose -f srcs/docker-compose.yml logs --tail=50 mariadb

# Restart a single service
docker compose -f srcs/docker-compose.yml restart nginx

# Open a shell inside a running container
docker compose -f srcs/docker-compose.yml exec wordpress bash
docker compose -f srcs/docker-compose.yml exec mariadb bash
```

### Volume and Network Inspection

```bash
# List Docker volumes
docker volume ls

# Inspect a volume (shows mount point and options)
docker volume inspect mariadb_data
docker volume inspect wordpress_data

# Inspect the project network
docker network inspect inception
```

### Typical Development Workflow

When iterating on a service:

1. Edit the Dockerfile or config files under `srcs/requirements/<service>/`
2. Rebuild and restart just that service:
   ```bash
   docker compose -f srcs/docker-compose.yml up -d --build <service>
   ```
3. Check logs to verify:
   ```bash
   docker compose -f srcs/docker-compose.yml logs -f <service>
   ```
4. If the container state is broken or you changed something fundamental, do a full reset:
   ```bash
   make re
   ```

## Data Storage and Persistence

### Named Volumes

Two named volumes are defined in `docker-compose.yml`:

| Volume | Container mount | Host path |
|---|---|---|
| `mariadb_data` | `/var/lib/mysql` | `/home/akharkho/data/mariadb` |
| `wordpress_data` | `/var/www/html` | `/home/akharkho/data/wordpress` |

Both are configured with `driver_opts` that bind them to specific host directories. This means you can inspect and back up the data directly on the host filesystem.

The `wordpress_data` volume is shared between multiple containers: WordPress (read/write), NGINX (read, to serve static files), FTP (read/write), and FileBrowser (read/write).

### What Gets Preserved and What Gets Deleted

| Command | Containers | Images | Volumes / Host data |
|---|---|---|---|
| `make down` | Stopped | Kept | Kept |
| `make clean` | Removed | Pruned | Docker volumes pruned, host dirs kept |
| `make fclean` | Removed | Pruned | Host data dirs deleted (`/home/$USER/data`) |

After `make fclean`, the next `make up` will start fresh -- new database, new WordPress installation, everything from zero.
