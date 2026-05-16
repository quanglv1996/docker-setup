# Portainer

Triển khai [Portainer CE](https://www.portainer.io/) — giao diện web quản lý Docker — bằng Docker.

## Yêu cầu

- Docker & Docker Compose v2

## Cài đặt

### 1. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `PORTAINER_PORT` | Cổng host expose ra ngoài | `9000` |
| `PORTAINER_DATA_PATH` | Đường dẫn lưu data Portainer | `./data` |

### 2. Khởi động

```bash
docker compose up -d
```

### 3. Tạo tài khoản admin

Truy cập `http://localhost:9000` (hoặc domain Cloudflare Tunnel), tạo tài khoản admin **trong vòng 5 phút** sau khi khởi động — nếu quá hạn, restart container:

```bash
docker compose restart portainer
```

## Lưu ý bảo mật

- Docker socket được mount **read-only** (`ro`) — Portainer vẫn hoạt động đầy đủ nhưng giảm rủi ro.
- Nên đặt sau Cloudflare Tunnel với Access Policy để giới hạn truy cập.

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động Portainer |
| `docker compose down` | Dừng và xóa container |
| `docker compose restart portainer` | Khởi động lại |
| `docker compose pull && docker compose up -d` | Cập nhật lên phiên bản mới nhất |
