# 9router - Docker Setup

Triển khai [9router](https://hub.docker.com/r/decolua/9router) bằng Docker Compose.

## Yêu cầu

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose v2

## Cấu trúc thư mục

```
9router/
├── data/           ← dữ liệu ứng dụng (tự tạo khi chạy)
├── docker-compose.yml
├── .env
└── README.md
```

## Cài đặt

### 1. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `PORT_HOST` | Cổng host ánh xạ vào container | `20128` |
| `TZ` | Múi giờ | `Asia/Ho_Chi_Minh` |
| `DATA_PATH` | Đường dẫn lưu dữ liệu | `./data` |

### 2. Khởi động

```bash
docker compose up -d
```

### 3. Kiểm tra

```bash
docker compose ps
docker compose logs -f 9router
```

## Thay đổi vị trí lưu dữ liệu

Chỉnh `DATA_PATH` trong `.env`:

```env
DATA_PATH=/mnt/storage/9router
```

Khởi động lại:

```bash
docker compose down
docker compose up -d
```

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động |
| `docker compose down` | Dừng và xóa container |
| `docker compose logs -f` | Xem logs realtime |
| `docker compose pull` | Cập nhật image mới |
| `docker compose restart 9router` | Khởi động lại service |
