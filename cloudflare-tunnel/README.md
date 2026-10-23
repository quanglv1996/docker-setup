# Cloudflare Tunnel - Docker Setup

Triển khai Cloudflare Tunnel bằng Docker Compose để expose các dịch vụ nội bộ ra internet một cách an toàn, không cần mở cổng trên router/firewall.

## Yêu cầu

- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/)
- Tài khoản [Cloudflare](https://cloudflare.com) với một domain đã được quản lý
- Tunnel Token từ Cloudflare Zero Trust Dashboard

## Cấu trúc thư mục

```
cloudflare-tunnel/
├── docker-compose.yml
├── .env
└── README.md
```

## Cài đặt

### 1. Lấy Tunnel Token

1. Truy cập [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Vào **Networks** → **Tunnels** → **Create a tunnel**
3. Chọn **Cloudflared** → đặt tên tunnel → **Save tunnel**
4. Sao chép token được cung cấp

### 2. Cấu hình biến môi trường

Tạo file `.env` (hoặc chỉnh sửa file hiện có):

```env
TUNNEL_TOKEN=your_tunnel_token_here
```

> **Lưu ý bảo mật:** Không commit file `.env` lên Git. Thêm `.env` vào `.gitignore`.

### 3. Khởi động

```bash
docker compose up -d
```

### 4. Kiểm tra trạng thái

```bash
docker compose ps
docker compose logs -f cloudflared
```

## Dừng dịch vụ

```bash
docker compose down
```

## Cấu hình Public Hostname

Sau khi tunnel đang chạy, vào Cloudflare Zero Trust Dashboard → **Networks** → **Tunnels** → chọn tunnel → **Configure** → **Public Hostname** để thêm các route:

`cloudflared` nằm trong mạng `proxy_net` cùng các ứng dụng, nên Service dùng tên container
(không dùng `localhost` — đó là chính container cloudflared):

| Subdomain       | Service                     |
|-----------------|-----------------------------|
| `label.example.com` | `http://labelstudio:8080` |
| `nextcloud.example.com` | `http://nextcloud:80` |
| `host.example.com` | `http://host.docker.internal:3000` (cổng trên máy host) |

Danh sách đầy đủ xem [README gốc](../README.md#truy-cập).

## Ghi chú

- Container sẽ tự khởi động lại khi bị crash hoặc khi Docker khởi động lại (`restart: unless-stopped`).
- Tunnel hoạt động theo chiều ra (outbound), không yêu cầu mở port nào trên firewall.
- Để debug, chạy: `docker compose logs cloudflared`
