# OpenProject - Docker Setup

Triển khai [OpenProject](https://www.openproject.org/) (phần mềm quản lý dự án mã nguồn mở) bằng Docker Compose với bind mount có thể cấu hình.

## Yêu cầu

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose v2
- (Tùy chọn) Domain và Cloudflare Tunnel nếu muốn truy cập từ internet

## Cấu trúc thư mục

```
open-project/
├── data/
│   ├── pgdata/     ← database PostgreSQL (tự tạo khi chạy)
│   └── assets/     ← file đính kèm, cấu hình (tự tạo khi chạy)
├── docker-compose.yml
├── .env
└── README.md
```

## Cài đặt

### 1. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `OPENPROJECT_SECRET_KEY_BASE` | Chuỗi bí mật (bắt buộc đổi) | *(trống)* |
| `OPENPROJECT_HOST_NAME` | Domain hoặc `IP:Port` truy cập | `localhost:8888` |
| `OPENPROJECT_HTTPS` | Bật HTTPS (khi chạy sau proxy) | `false` |
| `OPENPROJECT_PORT` | Cổng host ánh xạ vào container | `8888` |
| `PGDATA_PATH` | Đường dẫn lưu database | `./data/pgdata` |
| `ASSETS_PATH` | Đường dẫn lưu file đính kèm | `./data/assets` |

**Sinh `OPENPROJECT_SECRET_KEY_BASE`:**
```bash
openssl rand -hex 64
```

> **Lưu ý bảo mật:** Không commit `.env` lên Git. Thêm vào `.gitignore`.

### 2. Khởi động

```bash
docker compose up -d
```

Lần đầu khởi động sẽ mất 1–2 phút để OpenProject khởi tạo database.

### 3. Kiểm tra

```bash
docker compose ps
docker compose logs -f openproject
```

Truy cập tại `http://localhost:8888` (hoặc theo `OPENPROJECT_HOST_NAME`).  
Tài khoản mặc định: **admin / admin** (đổi ngay sau lần đăng nhập đầu tiên).

## Chạy sau Cloudflare Tunnel / Reverse Proxy

Chỉnh `.env`:

```env
OPENPROJECT_HOST_NAME=openproject.example.com
OPENPROJECT_HTTPS=true
```

Sau đó khởi động lại:

```bash
docker compose down
docker compose up -d
```

## Thay đổi vị trí lưu dữ liệu

Chỉnh hai biến trong `.env`:

```env
PGDATA_PATH=/mnt/storage/openproject/pgdata
ASSETS_PATH=/mnt/storage/openproject/assets
```

Khởi động lại stack sau khi thay đổi.

> Nếu đã có dữ liệu cũ, hãy copy toàn bộ thư mục sang đường dẫn mới trước khi khởi động lại.

## ⚠️ Fix lỗi Permission (bind mount)

Container OpenProject chạy với UID `1000`. Nếu thư mục data thuộc quyền user khác, sẽ gặp lỗi **Permission denied**.

**Fix:**
```bash
sudo chown -R 1000:1000 ./data
```

Hoặc nếu dùng đường dẫn tùy chỉnh:
```bash
sudo chown -R 1000:1000 /path/to/pgdata /path/to/assets
```

> Chỉ cần chạy một lần sau khi tạo thư mục hoặc thay đổi đường dẫn.

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động |
| `docker compose down` | Dừng và xóa containers |
| `docker compose logs -f` | Xem logs realtime |
| `docker compose pull` | Cập nhật image mới |
| `docker compose restart openproject` | Khởi động lại service |
