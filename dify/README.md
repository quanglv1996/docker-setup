# Dify

Triển khai [Dify](https://dify.ai/) — nền tảng phát triển ứng dụng LLM — bằng Docker.

## Kiến trúc

```
Internet
   │
   ▼
Cloudflare Tunnel
   │
   ▼
nginx :80
   ├── /api, /console/api, /v1, /files  ──►  api :5001
   └── /                                ──►  web :3000
                                              │
                          api / worker ──►  PostgreSQL :5432
                                       ──►  Redis      :6379
                                       ──►  Weaviate   :8080
                                       ──►  sandbox    :8194
```

## Yêu cầu

- Docker & Docker Compose v2

## Cấu trúc thư mục

```
dify/
├── docker-compose.yml
├── .env
├── nginx/
│   └── nginx.conf
└── README.md
```

## Cài đặt

### 1. Sinh các secret key

```bash
openssl rand -hex 32   # dùng cho SECRET_KEY
openssl rand -hex 16   # dùng cho REDIS_PASSWORD, DB_PASSWORD, v.v.
```

### 2. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `DB_USERNAME` | User PostgreSQL | `dify` |
| `DB_PASSWORD` | Mật khẩu PostgreSQL | *(bắt buộc đổi)* |
| `DB_DATABASE` | Tên database | `dify` |
| `REDIS_PASSWORD` | Mật khẩu Redis | *(bắt buộc đổi)* |
| `WEAVIATE_API_KEY` | API key Weaviate | *(bắt buộc đổi)* |
| `SANDBOX_API_KEY` | API key Sandbox | *(bắt buộc đổi)* |
| `SECRET_KEY` | Secret key Flask (32 hex) | *(bắt buộc đổi)* |
| `CONSOLE_WEB_URL` | URL public của Dify | *(bắt buộc)* |
| `CONSOLE_API_URL` | URL public của Dify API | *(bắt buộc)* |
| `SERVICE_API_URL` | URL public Service API | *(bắt buộc)* |
| `APP_WEB_URL` | URL public App frontend | *(bắt buộc)* |
| `DIFY_PORT` | Cổng host expose nginx | `80` |
| `STORAGE_TYPE` | Loại storage (`local` hoặc `s3`) | `local` |
| `LOG_LEVEL` | Mức log | `INFO` |
| `DB_DATA_PATH` | Đường dẫn lưu PostgreSQL | `./data/db` |
| `REDIS_DATA_PATH` | Đường dẫn lưu Redis | `./data/redis` |
| `WEAVIATE_DATA_PATH` | Đường dẫn lưu Weaviate | `./data/weaviate` |
| `API_STORAGE_PATH` | Đường dẫn lưu file uploads | `./data/storage` |

> Không commit `.env` lên Git. Thêm `.env` vào `.gitignore`.

### 3. Cấu hình Cloudflare Tunnel

Trỏ tunnel về `http://localhost:80` (hoặc `DIFY_PORT` đã đặt). Tất cả route (API + Web) đều đi qua nginx trên port này.

### 4. Khởi động

```bash
docker compose up -d
```

Lần đầu khởi động, API sẽ tự chạy database migration — chờ khoảng 1-2 phút trước khi truy cập.

### 5. Kiểm tra

```bash
docker compose ps
docker compose logs -f api
```

Truy cập tại domain đã cấu hình, tạo tài khoản admin lần đầu qua giao diện web.

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động tất cả services |
| `docker compose down` | Dừng và xóa containers |
| `docker compose restart api worker` | Khởi động lại API và Worker |
| `docker compose logs -f api` | Xem logs API realtime |
| `docker compose logs -f worker` | Xem logs Worker (celery tasks) |
| `docker compose pull && docker compose up -d` | Cập nhật lên image mới nhất |
