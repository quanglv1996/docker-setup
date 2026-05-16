# n8n + PostgreSQL

Triển khai [n8n](https://n8n.io/) workflow automation với PostgreSQL, chạy sau Cloudflare Tunnel hoặc reverse proxy.

## Kiến trúc

```
Internet
   │
   ▼
Cloudflare Tunnel / Reverse Proxy
   │
   ▼
n8n :5678  ──►  PostgreSQL :5432
```

## Yêu cầu

- Docker & Docker Compose v2

## Cấu trúc thư mục

```
n8n/
├── docker-compose.yml
├── .env
└── README.md
```

Dữ liệu được lưu theo đường dẫn cấu hình trong `.env` (mặc định `./data/`), tự tạo khi khởi động lần đầu.

## Cài đặt

### 1. Cấu hình `.env`

Sao chép và chỉnh sửa file `.env`:

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `POSTGRES_DB` | Tên database | `n8n` |
| `POSTGRES_USER` | User database | `n8n` |
| `POSTGRES_PASSWORD` | Mật khẩu database | *(bắt buộc đổi)* |
| `N8N_HOST` | Domain hoặc IP (không kèm scheme) | — |
| `N8N_PROTOCOL` | `http` hoặc `https` | `https` |
| `WEBHOOK_URL` | URL đầy đủ cho webhook | — |
| `N8N_EDITOR_BASE_URL` | URL đầy đủ cho editor UI | — |
| `N8N_BASIC_AUTH_USER` | Username đăng nhập n8n | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | Mật khẩu đăng nhập n8n | *(bắt buộc đổi)* |
| `N8N_ENCRYPTION_KEY` | Khóa mã hóa credentials | *(bắt buộc đổi)* |
| `N8N_PORT_HOST` | Cổng host expose ra ngoài | `5678` |
| `POSTGRES_DATA_PATH` | Đường dẫn lưu data PostgreSQL | `./data/postgres` |
| `N8N_DATA_PATH` | Đường dẫn lưu data n8n | `./data/n8n` |

**Sinh `N8N_ENCRYPTION_KEY`:**
```bash
openssl rand -hex 32
```

> `N8N_ENCRYPTION_KEY` dùng để mã hóa credentials. Sau khi tạo workflow, **không thay đổi** — nếu đổi sẽ không giải mã được credentials cũ.

> Không commit `.env` lên Git. Thêm `.env` vào `.gitignore`.

### 2. Fix permission (bind mount)

Container n8n chạy với user `node` (UID `1000`). Chạy lệnh sau trước khi khởi động:

```bash
mkdir -p ./data/n8n
sudo chown -R 1000:1000 ./data/n8n
```

Nếu dùng đường dẫn tùy chỉnh qua `N8N_DATA_PATH`, thay `./data/n8n` bằng đường dẫn đó.

### 3. Khởi động

```bash
docker compose up -d
```

### 4. Kiểm tra

```bash
docker compose ps
docker compose logs -f n8n
```

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động tất cả services |
| `docker compose down` | Dừng và xóa containers |
| `docker compose restart n8n` | Khởi động lại n8n |
| `docker compose logs -f n8n` | Xem logs n8n realtime |
| `docker compose logs -f postgres` | Xem logs PostgreSQL |
| `docker compose pull && docker compose up -d` | Cập nhật lên image mới nhất |
