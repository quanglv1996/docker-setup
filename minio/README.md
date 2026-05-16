# MinIO

Triển khai [MinIO](https://min.io/) object storage tương thích S3 API bằng Docker.

## Kiến trúc

```
Internet
   │
   ▼
Cloudflare Tunnel / Reverse Proxy
   │
   ├── :9000  ─►  MinIO S3 API
   └── :9001  ─►  MinIO Console (Web UI)
```

## Yêu cầu

- Docker & Docker Compose v2

## Cấu trúc thư mục

```
minio/
├── docker-compose.yml
├── .env
└── README.md
```

Dữ liệu lưu theo `MINIO_DATA_PATH` trong `.env` (mặc định `./data/`), tự tạo khi khởi động.

## Cài đặt

### 1. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `MINIO_ROOT_USER` | Tài khoản admin | `admin` |
| `MINIO_ROOT_PASSWORD` | Mật khẩu admin (tối thiểu 8 ký tự) | *(bắt buộc đổi)* |
| `MINIO_CONSOLE_URL` | URL đầy đủ Console UI (khi dùng reverse proxy) | — |
| `MINIO_API_PORT` | Cổng host cho S3 API | `9000` |
| `MINIO_CONSOLE_PORT` | Cổng host cho Web Console | `9001` |
| `MINIO_DATA_PATH` | Đường dẫn lưu object data | `./data` |

> Không commit `.env` lên Git. Thêm `.env` vào `.gitignore`.

### 2. Khởi động

```bash
docker compose up -d
```

### 3. Kiểm tra

```bash
docker compose ps
docker compose logs -f minio
```

Truy cập Console tại `http://localhost:9001` (hoặc domain đã cấu hình).

## Chạy sau Cloudflare Tunnel / Reverse Proxy

Chỉnh `.env`:

```env
MINIO_CONSOLE_URL=https://minio-console.yourdomain.com
```

Tunnel/proxy cần trỏ:
- `minio-console.yourdomain.com` → port `9001` (Console UI)
- `minio.yourdomain.com` → port `9000` (S3 API)

Khởi động lại:

```bash
docker compose down && docker compose up -d
```

## Sử dụng S3 API

MinIO tương thích hoàn toàn với S3 API. Cấu hình client:

| Tham số | Giá trị |
|---------|---------|
| Endpoint | `http://localhost:9000` hoặc domain S3 |
| Access Key | `MINIO_ROOT_USER` |
| Secret Key | `MINIO_ROOT_PASSWORD` |
| Region | `us-east-1` (mặc định, có thể đổi) |
| Path style | Bật (force path style) |

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động MinIO |
| `docker compose down` | Dừng và xóa container |
| `docker compose restart minio` | Khởi động lại MinIO |
| `docker compose logs -f minio` | Xem logs realtime |
| `docker compose pull && docker compose up -d` | Cập nhật image mới nhất |
