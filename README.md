*This project has been created as part of the 42 curriculum by akharkho.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The objective is to set up a small web infrastructure made of multiple services, each running in its own Docker container, all orchestrated with Docker Compose on a virtual machine.

The mandatory part requires three core services -- NGINX with TLS (the only public entrypoint, on port 443), WordPress with PHP-FPM, and MariaDB -- connected over a dedicated Docker network, with persistent storage handled by named volumes.

On top of that, this project implements all five bonus services: Redis cache for WordPress, an FTP server pointing to the WordPress volume, a static website (HTML/CSS, no PHP), Adminer for database management, and FileBrowser as an additional useful service.

All containers are built from custom Dockerfiles based on Debian Bullseye. No pre-built images from DockerHub are used.

## Project Description

### Docker and How It Fits This Project

The entire infrastructure is defined in `srcs/docker-compose.yml`. Each service gets its own Dockerfile under `srcs/requirements/`, which means every container is built from scratch during `make up`. Docker handles isolation between services (each one runs in its own container with its own filesystem), networking (a single bridge network named `inception`), and storage (named volumes for the database and WordPress files).

The source tree breaks down as follows:

- `srcs/requirements/nginx/` -- NGINX reverse proxy, TLS termination
- `srcs/requirements/wordpress/` -- WordPress + PHP-FPM, WP-CLI setup script
- `srcs/requirements/mariadb/` -- MariaDB server, database initialization script
- `srcs/requirements/bonus/redis/` -- Redis cache backend
- `srcs/requirements/bonus/ftp/` -- vsftpd FTP server
- `srcs/requirements/bonus/adminer/` -- Adminer (PHP built-in server)
- `srcs/requirements/bonus/website/` -- Static website served by NGINX
- `srcs/requirements/bonus/service/` -- FileBrowser web file manager

### Design Choices

The project runs on Debian Bullseye across all containers. I went with Debian over Alpine because the package ecosystem is broader and debugging is easier when something breaks -- `apt-get` just has more available out of the box compared to `apk`, especially for PHP extensions.

NGINX is the single entrypoint: it terminates TLS with a self-signed certificate and proxies PHP requests to the WordPress container over FastCGI on port 9000. WordPress never talks to the outside world directly.

MariaDB has a healthcheck configured so WordPress waits for the database to actually be ready before trying to connect, rather than just checking if the container started.

For the bonus, I picked FileBrowser as the "service of your choice" because it gives a web-based interface to browse and manage WordPress files, which is genuinely useful during development and debugging.

### Comparisons

#### Virtual Machines vs Docker

A virtual machine runs a full guest operating system on top of a hypervisor. It has its own kernel, its own memory allocation, and boots like a real machine. Docker containers, on the other hand, share the host kernel and only isolate the userspace. This makes containers much lighter and faster to start -- spinning up the full Inception stack takes seconds, while booting several VMs with equivalent services would take minutes and eat significantly more RAM.

That said, VMs provide stronger isolation since each one has its own kernel. Containers rely on kernel namespaces and cgroups, which is solid isolation for most use cases but not as airtight as a full hypervisor boundary.

In this project, Docker runs inside a VM (as required by the subject), so we get the best of both: the VM provides the base environment, and Docker handles the service-level isolation efficiently.

#### Secrets vs Environment Variables

Environment variables are the simplest way to pass configuration to containers. They work well for non-sensitive values like domain names or feature flags. The problem is that environment variables can leak -- they show up in `docker inspect`, in process listings, and in logs if you're not careful.

Docker secrets are designed for sensitive data. They're mounted as files inside the container (under `/run/secrets/`), never stored in image layers, and only available to services that explicitly request them. The downside is they add complexity to the setup.

This project stores configuration in a `.env` file (which is gitignored) and uses a local `secrets/` directory for sensitive values. Passwords are never hardcoded in Dockerfiles.

#### Docker Network vs Host Network

With host networking, a container shares the host's network stack directly. There's no isolation -- any port the container opens is immediately accessible on the host. This is simpler but defeats the purpose of containerization from a network perspective.

A bridge network (which is what this project uses) creates an isolated virtual network. Containers can talk to each other by service name (Docker's internal DNS handles resolution), and only explicitly published ports are reachable from outside. The `inception` network in this project means, for example, that MariaDB is only reachable by WordPress and other containers on the same network -- it's never exposed to the host.

#### Docker Volumes vs Bind Mounts

Bind mounts map a specific host directory into a container. They're straightforward but tightly couple the container to the host filesystem layout. Named volumes are managed by Docker and provide a layer of abstraction -- Docker handles where the data actually lives on disk.

This project uses named volumes (`mariadb_data` and `wordpress_data`), but configures them with `driver_opts` to bind the actual storage to `/home/akharkho/data/mariadb` and `/home/akharkho/data/wordpress` on the host. This satisfies the subject requirement of using named volumes while still keeping data in a predictable location on the host for inspection and backups.

## Instructions

### Prerequisites

- A Linux virtual machine
- Docker and Docker Compose installed
- `make`
- Sudo access (for host file editing and data directory permissions)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/AdnaneKharkhour/Inception.git
cd Inception
```

2. Configure `srcs/.env` with your domain name, database credentials, WordPress users, FTP credentials, and FileBrowser credentials. The `.env` file is not committed to the repository for security reasons -- you need to create it yourself.

3. Add a local DNS entry so your browser resolves the domain:

```bash
echo "127.0.0.1 akharkho.42.fr" | sudo tee -a /etc/hosts
```

### Build and Run

```bash
make up
```

This creates the data directories, builds all Docker images, and starts the containers.

Other Makefile targets:

| Command | What it does |
|---|---|
| `make down` | Stop all containers, keep data |
| `make clean` | Stop containers, remove images and unused Docker resources |
| `make fclean` | Everything `clean` does, plus delete persisted data under `/home/$USER/data` |
| `make re` | Full reset and rebuild from scratch |

### Accessing Services

| Service | URL |
|---|---|
| WordPress site | `https://akharkho.42.fr` |
| WordPress admin | `https://akharkho.42.fr/wp-admin` |
| Adminer | `http://localhost:8080` |
| Static website | `http://localhost:8081` |
| FileBrowser | `http://localhost:8082` |

The browser will warn about the self-signed TLS certificate on the HTTPS URLs -- that's expected.

## Resources

### References

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NetworkChuck - Docker networking crash course](https://www.youtube.com/watch?v=bKFMS5C4CG0)
- [TechWorld with Nana - Docker tutorial](https://www.youtube.com/watch?v=pg19Z8LL06w)
- [NetworkChuck - Docker containers](https://www.youtube.com/watch?v=eGz9DS-aIeY)

### AI Usage

AI was used in two areas:

1. **Service configuration files** -- I used AI to help write and debug configuration files for NGINX, PHP-FPM, MariaDB, Redis, and vsftpd. These config files have a lot of directives and getting the syntax right from documentation alone would have taken much longer. I reviewed and tested every generated config to make sure it actually worked in the context of this project.

2. **Learning Docker concepts** -- I used AI as a learning tool to understand Docker networking, volume management, multi-stage builds, healthchecks, and how services interact inside a Compose setup. This supplemented the official Docker documentation and the video resources listed above.

AI was not used to write the Dockerfiles or the shell setup scripts wholesale -- those were written incrementally while building and testing the containers.