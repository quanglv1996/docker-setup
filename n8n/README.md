# n8n + PostgreSQL - Docker Setup

Triển khai [n8n](https://n8n.io/) (workflow automation) với PostgreSQL làm database, có thể chạy sau Cloudflare Tunnel hoặc reverse proxy.

## Kiến trúc

```
Internet
   │
   ▼
Cloudflare Tunnel (tùy chọn)
   │
   ▼
n8n :5678  ──►  PostgreSQL :5432
```

## Yêu cầu

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose v2
- (Tùy chọn) Domain và Cloudflare Tunnel để truy cập từ internet

## Cấu trúc thư mục

```
n8n/
├── data/
│   ├── postgres/   ← database PostgreSQL (tự tạo khi chạy)
│   └── n8n/        ← workflows, credentials, config (tự tạo khi chạy)
├── docker-compose.yml
├── .env
└── README.md
```

## Cài đặt

### 1. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `POSTGRES_DB` | Tên database | `n8n` |
| `POSTGRES_USER` | User database | `n8n` |
| `POSTGRES_PASSWORD` | Password database | *(đổi bắt buộc)* |
| `N8N_HOST` | Domain hoặc IP (không kèm scheme) | `localhost` |
| `N8N_PROTOCOL` | `http` hoặc `https` | `http` |
| `WEBHOOK_URL` | URL đầy đủ cho webhook | `http://localhost:5678/` |
| `N8N_EDITOR_BASE_URL` | URL đầy đủ cho editor UI | `http://localhost:5678/` |
| `N8N_BASIC_AUTH_USER` | Username đăng nhập n8n | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | Password đăng nhập n8n | *(đổi bắt buộc)* |
| `N8N_ENCRYPTION_KEY` | Khóa mã hóa credentials | *(đổi bắt buộc)* |
| `N8N_PORT_HOST` | Cổng host ánh xạ vào container | `5678` |
| `POSTGRES_DATA_PATH` | Đường dẫn lưu database | `./data/postgres` |
| `N8N_DATA_PATH` | Đường dẫn lưu dữ liệu n8n | `./data/n8n` |

**Sinh `N8N_ENCRYPTION_KEY`:**
```bash
openssl rand -hex 32
```

> **Quan trọng:** `N8N_ENCRYPTION_KEY` dùng để mã hóa credentials đã lưu. Sau khi đặt và tạo workflow, **không được thay đổi** — nếu đổi sẽ không thể giải mã credentials cũ.

> **Lưu ý bảo mật:** Không commit `.env` lên Git. Thêm vào `.gitignore`.

### 2. Khởi động

```bash
docker compose up -d
```

### 3. Kiểm tra

```bash
docker compose ps
docker compose logs -f n8n
```

Truy cập tại `http://localhost:5678` (hoặc domain đã cấu hình).

## Chạy sau Cloudflare Tunnel / Reverse Proxy

Chỉnh `.env`:

```env
N8N_HOST=n8n.example.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.example.com/
N8N_EDITOR_BASE_URL=https://n8n.example.com/
```

Khởi động lại:

```bash
docker compose down
docker compose up -d
```

## Thay đổi vị trí lưu dữ liệu

Chỉnh trong `.env`:

```env
POSTGRES_DATA_PATH=/mnt/storage/n8n/postgres
N8N_DATA_PATH=/mnt/storage/n8n/data
```

> Nếu đã có dữ liệu cũ, hãy copy toàn bộ thư mục sang đường dẫn mới trước khi khởi động lại.

## ⚠️ Fix lỗi Permission (bind mount)

Container n8n chạy với user `node` (UID `1000`). Nếu thư mục data thuộc quyền user khác sẽ bị lỗi **Permission denied**.

**Fix:**
```bash
sudo chown -R 1000:1000 ./data/n8n
```

PostgreSQL tự xử lý permission thư mục của nó khi khởi động lần đầu, thường không cần fix thủ công.

> Chỉ cần chạy một lần sau khi tạo thư mục hoặc thay đổi `N8N_DATA_PATH`.

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động tất cả services |
| `docker compose down` | Dừng và xóa containers |
| `docker compose logs -f n8n` | Xem logs n8n realtime |
| `docker compose logs -f postgres` | Xem logs database |
| `docker compose pull` | Cập nhật image mới |
| `docker compose restart n8n` | Khởi động lại chỉ n8n |
