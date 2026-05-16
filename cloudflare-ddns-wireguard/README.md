# Cloudflare DDNS + WireGuard

Tự động cập nhật DNS động qua Cloudflare và dựng VPN WireGuard bằng Docker.

## Kiến trúc

```
Client
   │  WireGuard UDP :51820
   ▼
Server (IP động)
   ├── cloudflare-ddns  ──►  Cloudflare DNS (cập nhật IP tự động)
   └── wireguard        ──►  VPN endpoint
```

## Yêu cầu

- Docker & Docker Compose v2
- Domain quản lý trên Cloudflare
- Mở port UDP 51820 trên firewall / router (nếu sau NAT)

## Cài đặt

### 1. Tạo Cloudflare API Token

Truy cập [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens):

- **Create Token** → template `Edit zone DNS`
- Permissions: `Zone → DNS → Edit`, `Zone → Zone → Read`
- Zone Resources: `Include → Specific zone → yourdomain.com`
- **Proxy phải tắt** (DNS only) cho record VPN

### 2. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `CF_API_TOKEN` | Cloudflare API Token | *(bắt buộc)* |
| `CF_ZONE` | Domain gốc trên Cloudflare | *(bắt buộc)* |
| `CF_SUBDOMAIN` | Subdomain trỏ vào server | `vpn` |
| `WG_SERVERURL` | Domain đầy đủ của VPN server | *(bắt buộc)* |
| `WG_SERVERPORT` | Cổng UDP WireGuard | `51820` |
| `WG_PEERS` | Số lượng client tạo sẵn | `3` |
| `WG_PEERDNS` | DNS cho client VPN | `8.8.8.8` |
| `WG_INTERNAL_SUBNET` | Subnet nội bộ VPN | `10.13.13.0` |
| `WG_CONFIG_PATH` | Đường dẫn lưu config WireGuard | `./wg-config` |
| `PUID` / `PGID` | UID/GID chạy container | `1000` |

### 3. Mở firewall

```bash
sudo ufw allow 51820/udp
```

Nếu server sau NAT/router: forward UDP port `51820` về IP server.

### 4. Khởi động

```bash
docker compose up -d
```

### 5. Kiểm tra

```bash
docker compose ps
docker logs cloudflare-ddns   # Xem IP đã cập nhật chưa
docker logs wireguard          # Xem WireGuard khởi động
```

## Lấy config client

```bash
# Xem config dạng text
cat wg-config/peer1/peer1.conf

# Xem QR code (quét bằng app WireGuard)
docker exec -it wireguard /app/show-peer 1
```

Config client có dạng:

```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.13.13.2/32
DNS = 8.8.8.8

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = vpn.yourdomain.com:51820
AllowedIPs = 0.0.0.0/0
```

## Thêm / xóa peer

```bash
# Thêm peer mới
docker exec -it wireguard /app/add-peer newuser

# Hiển thị QR code peer
docker exec -it wireguard /app/show-peer newuser

# Xóa peer
docker exec -it wireguard /app/remove-peer newuser
```

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động tất cả services |
| `docker compose down` | Dừng và xóa containers |
| `docker compose restart wireguard` | Khởi động lại WireGuard |
| `docker logs cloudflare-ddns` | Kiểm tra cập nhật DNS |
| `docker compose pull && docker compose up -d` | Cập nhật image mới nhất |
