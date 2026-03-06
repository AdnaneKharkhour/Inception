# User Documentation

## Services Overview

This project runs a containerized web stack using Docker Compose. Here's what each service does:

**Core services:**

- **NGINX** -- The only public-facing entrypoint. It handles HTTPS on port 443 using a self-signed TLS certificate and forwards PHP requests to WordPress via FastCGI.
- **WordPress** -- The main application, running PHP-FPM. It serves the website and the admin dashboard.
- **MariaDB** -- The database backend. Stores all WordPress data (posts, users, settings, etc.).

**Bonus services:**

- **Redis** -- In-memory cache that sits in front of the database to speed up WordPress page loads.
- **FTP** (vsftpd) -- Provides FTP access to the WordPress files volume. Useful for uploading themes or plugins.
- **Adminer** -- A lightweight web-based database management tool. Think phpMyAdmin but smaller.
- **Static website** -- A simple HTML/CSS site served on its own, independent of WordPress.
- **FileBrowser** -- A web-based file manager that gives you a visual way to browse and manage files in the WordPress volume.

## Starting and Stopping the Project

Start everything (builds images if needed):

```bash
make up
```

Stop all containers but keep your data intact:

```bash
make down
```

Stop and remove containers, images, and unused Docker resources:

```bash
make clean
```

Full reset -- stops everything and deletes all persisted data from disk:

```bash
make fclean
```

Rebuild from scratch:

```bash
make re
```

## Accessing the Website and Admin Panels

First, make sure your machine resolves the project domain. If you haven't done this yet:

```bash
echo "127.0.0.1 akharkho.42.fr" | sudo tee -a /etc/hosts
```

Then open the following in your browser:

| Service | URL | Notes |
|---|---|---|
| WordPress site | `https://akharkho.42.fr` | Your browser will warn about the self-signed certificate -- accept the risk to continue |
| WordPress admin | `https://akharkho.42.fr/wp-admin` | Log in with admin credentials from `.env` |
| Adminer | `http://localhost:8080` | Use MariaDB credentials to log in |
| Static website | `http://localhost:8081` | No login needed |
| FileBrowser | `http://localhost:8082` | Uses its own credentials from `.env` |

FTP access is available on port 21 using the FTP credentials from `.env`. You can connect with any FTP client (FileZilla, `lftp`, etc.).

## Credentials

All credentials live in `srcs/.env`. This file is not committed to the repository -- you need to have it locally.

The relevant variables are:

- **WordPress admin**: `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD`
- **WordPress regular user**: `WP_USER` / `WP_USER_PASSWORD`
- **MariaDB root**: `MYSQL_ROOT_PASSWORD`
- **MariaDB application user**: `MYSQL_USER` / `MYSQL_PASSWORD`
- **FTP**: `FTP_USER` / `FTP_PASSWORD`
- **FileBrowser**: `FB_USER` / `FB_PASSWORD`

If you also use the `secrets/` directory, check:

- `secrets/credentials.txt`
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`

**To change credentials:** edit `srcs/.env` (and matching files in `secrets/` if applicable), then rebuild the affected services with `make re`. For database password changes specifically, a full `make fclean` followed by `make up` is safer since the database needs to be re-initialized.

## Checking That Services Are Running

List all containers and their status:

```bash
docker compose -f srcs/docker-compose.yml ps
```

All services should show as `Up`. MariaDB should also show `(healthy)` after its healthcheck passes.

View logs for a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs mariadb
```

Add `--tail=50` to limit output, or `-f` to follow logs in real time.

Quick checks from the command line:

```bash
# WordPress is responding
curl -k https://akharkho.42.fr

# Adminer is up
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080

# FileBrowser is up
curl -s -o /dev/null -w "%{http_code}" http://localhost:8082
```

## Where Data Lives

Project data persists on the host machine in two directories:

- `/home/akharkho/data/mariadb` -- database files
- `/home/akharkho/data/wordpress` -- WordPress site files (themes, plugins, uploads, wp-config)

These directories survive `make down` and `make clean`. Only `make fclean` removes them. Back these up if you have data you care about before running `fclean`.
