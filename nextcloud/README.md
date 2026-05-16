# Nextcloud

Triển khai [Nextcloud](https://nextcloud.com/) self-hosted cloud storage với MariaDB và Redis bằng Docker.

## Kiến trúc

```
Internet
   │
   ▼
Cloudflare Tunnel / Reverse Proxy
   │
   ▼
Nextcloud :8080 ──► MariaDB :3306
                └── Redis   :6379
```

## Yêu cầu

- Docker & Docker Compose v2

## Cấu trúc thư mục

```
nextcloud/
├── docker-compose.yml
├── .env
└── README.md
```

Dữ liệu lưu theo đường dẫn trong `.env` (mặc định `./data/`), tự tạo khi khởi động.

## Cài đặt

### 1. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `MYSQL_ROOT_PASSWORD` | Mật khẩu root MariaDB | *(bắt buộc đổi)* |
| `MYSQL_DATABASE` | Tên database | `nextcloud` |
| `MYSQL_USER` | User database | `nextcloud` |
| `MYSQL_PASSWORD` | Mật khẩu database | *(bắt buộc đổi)* |
| `NEXTCLOUD_ADMIN_USER` | Tài khoản admin Nextcloud | `admin` |
| `NEXTCLOUD_ADMIN_PASSWORD` | Mật khẩu admin | *(bắt buộc đổi)* |
| `NEXTCLOUD_TRUSTED_DOMAINS` | Danh sách domain tin cậy, cách nhau bằng dấu cách | `localhost` |
| `OVERWRITE_PROTOCOL` | Protocol khi sau reverse proxy (`https`) | `https` |
| `OVERWRITE_HOST` | Domain khi sau reverse proxy | — |
| `OVERWRITE_CLI_URL` | URL đầy đủ cho CLI và cronjob | — |
| `TRUSTED_PROXIES` | Dải IP của proxy (CIDR) | `172.16.0.0/12` |
| `NEXTCLOUD_PORT` | Cổng host expose ra ngoài | `8080` |
| `DB_DATA_PATH` | Đường dẫn lưu data MariaDB | `./data/db` |
| `NEXTCLOUD_DATA_PATH` | Đường dẫn lưu data Nextcloud | `./data/nextcloud` |

> `NEXTCLOUD_ADMIN_USER` và `NEXTCLOUD_ADMIN_PASSWORD` chỉ có tác dụng lần **đầu tiên** khởi tạo — sau đó thay đổi qua giao diện web.

> Không commit `.env` lên Git. Thêm `.env` vào `.gitignore`.

### 2. Khởi động

```bash
docker compose up -d
```

### 3. Kiểm tra

```bash
docker compose ps
docker compose logs -f nextcloud
```

Truy cập tại `http://localhost:8080` (hoặc domain đã cấu hình).

## Chạy sau Cloudflare Tunnel / Reverse Proxy

Chỉnh `.env`:

```env
NEXTCLOUD_TRUSTED_DOMAINS=localhost nextcloud.yourdomain.com
OVERWRITE_PROTOCOL=https
OVERWRITE_HOST=nextcloud.yourdomain.com
OVERWRITE_CLI_URL=https://nextcloud.yourdomain.com
TRUSTED_PROXIES=172.16.0.0/12
```

Khởi động lại:

```bash
docker compose down && docker compose up -d
```

## Thêm trusted domain sau khi đã chạy

```bash
docker exec -u www-data nextcloud php occ config:system:set trusted_domains 2 --value="newdomain.com"
```

## Fix cảnh báo bảo mật / hiệu năng

Sau khi cài xong, truy cập **Settings → Administration → Overview** để xem danh sách cảnh báo. Các lệnh occ thường dùng:

```bash
# Chạy maintenance / scan file
docker exec -u www-data nextcloud php occ files:scan --all

# Thêm missing indices
docker exec -u www-data nextcloud php occ db:add-missing-indices

# Bật memory caching
docker exec -u www-data nextcloud php occ config:system:set memcache.local --value='\OC\Memcache\APCu'
```

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động tất cả services |
| `docker compose down` | Dừng và xóa containers |
| `docker compose restart nextcloud` | Khởi động lại Nextcloud |
| `docker compose logs -f nextcloud` | Xem logs realtime |
| `docker compose pull && docker compose up -d` | Cập nhật lên image mới nhất |
