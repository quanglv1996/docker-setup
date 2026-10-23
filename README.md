# docker-setup

Tập hợp các cấu hình Docker Compose sẵn sàng triển khai cho self-hosted infrastructure.

## Dịch vụ

| Thư mục | Dịch vụ | Mô tả |
|---------|---------|-------|
| [`cloudflare-tunnel/`](cloudflare-tunnel/) | Cloudflare Tunnel | Expose dịch vụ nội bộ ra internet, không cần mở port |
| [`portainer/`](portainer/) | Portainer CE | Giao diện web quản lý Docker |
| [`minio/`](minio/) | MinIO | Object storage tương thích S3 |
| [`label-studio/`](label-studio/) | Label Studio | Công cụ gán nhãn dữ liệu AI/ML |
| [`nextcloud/`](nextcloud/) | Nextcloud + MariaDB + Redis | Self-hosted cloud storage |
| [`open-project/`](open-project/) | OpenProject | Quản lý dự án mã nguồn mở |
| [`vaultwarden/`](vaultwarden/) | Vaultwarden | Trình quản lý mật khẩu tương thích Bitwarden |
| [`cloudflare-ddns-wireguard/`](cloudflare-ddns-wireguard/) | DDNS + WireGuard | Tự cập nhật DNS động và VPN server (tùy chọn) |

## Cấu trúc chung

```
docker-setup/
├── docker-compose.yml   ← gom tất cả stack (include), chạy một lệnh
└── <service>/
    ├── docker-compose.yml   ← định nghĩa services (chạy riêng vẫn được)
    ├── .env.example         ← mẫu cấu hình
    ├── .env                 ← cấu hình thật (không commit lên Git)
    └── README.md
```

## Chạy toàn bộ

```bash
# 1. Tạo .env cho từng stack (lần đầu)
for d in */; do [ -f "$d.env.example" ] && [ ! -f "$d.env" ] && cp "$d.env.example" "$d.env"; done

# 2. Chạy tất cả từ thư mục gốc
docker compose up -d
docker compose ps
docker compose logs -f <service>     # vd: nextcloud, openproject
docker compose down                  # dừng tất cả, dữ liệu bind mount vẫn giữ
```

- Mỗi stack đọc `.env` trong thư mục của nó. **Không tạo `.env` ở thư mục gốc** — biến trong đó sẽ ghi đè `.env` của mọi stack.
- Stack `cloudflare-ddns-wireguard` đang tắt trong [`docker-compose.yml`](docker-compose.yml); bỏ comment khi đã điền token thật.
- Vẫn có thể chạy riêng từng stack: `cd <service> && docker compose up -d`. Không chạy cùng lúc cả hai cách (trùng `container_name`).
- Nếu trước đây đã chạy riêng từng thư mục, dừng chúng trước: `cd <service> && docker compose down`.

## Truy cập

Mỗi ứng dụng truy cập được theo 3 cách: `localhost`, IP LAN của máy (`HOST_IP` trong `.env`), và domain qua Cloudflare.

| Ứng dụng | Local / IP | Domain (Cloudflare) | Service trong Cloudflare Tunnel |
|----------|------------|---------------------|---------------------------------|
| Label Studio | `http://<host>:8080` | `label.<domain>` | `http://labelstudio:8080` |
| Nextcloud | `http://<host>:9090` | `nextcloud.<domain>` | `http://nextcloud:80` |
| OpenProject | `http://<host>:8888` | `pm.<domain>` | `http://openproject:80` |
| MinIO Console | `http://<host>:9001` | `minio.<domain>` | `http://minio:9001` |
| MinIO S3 API | `http://<host>:9000` | `s3.<domain>` | `http://minio:9000` |
| Portainer | `http://<host>:9002` | `portainer.<domain>` | `http://portainer:9000` |
| Vaultwarden | `http://localhost:8383` | `vault.<domain>` | `http://vaultwarden:80` |

`<host>` = `localhost` hoặc IP LAN.

### Cấu hình Cloudflare Tunnel

1. Lấy token tại Cloudflare Zero Trust → **Networks → Tunnels**, điền vào `cloudflare-tunnel/.env`.
2. Trong tunnel → **Public Hostname**, thêm từng hostname với **Service** theo cột cuối bảng trên (type `HTTP`).
   `cloudflared` nằm chung mạng `proxy_net` với các ứng dụng nên gọi thẳng bằng tên container.
   Muốn trỏ vào cổng của máy host thì dùng `http://host.docker.internal:<port>`.

### Khi đổi IP LAN

Sửa `HOST_IP` trong `label-studio/.env`, `open-project/.env` và IP trong `NEXTCLOUD_TRUSTED_DOMAINS` (`nextcloud/.env`), rồi `docker compose up -d`.

### Lưu ý

- **Vaultwarden**: web vault cần HTTPS (hoặc `localhost`) để mã hoá trên trình duyệt, nên `http://<IP>:8383` không đăng nhập được web vault — dùng domain hoặc `localhost`.
- **OpenProject** chạy với `OPENPROJECT_HTTPS=false` để vào được bằng HTTP; domain vẫn có HTTPS nhờ Cloudflare. Nên bật **SSL/TLS → Edge Certificates → Always Use HTTPS** trên Cloudflare.
- Windows: nếu máy khác trong LAN không vào được, kiểm tra Windows Firewall cho phép các cổng trên.

## Yêu cầu chung

- Docker Engine & Docker Compose v2.20+ (hỗ trợ `include`)

## Bảo mật

- Không commit `.env` lên Git — đã có trong `.gitignore`
- Đổi tất cả mật khẩu và secret key mặc định trước khi chạy
- Nên đặt Portainer sau Cloudflare Access Policy
