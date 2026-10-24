# docker-setup

Tập hợp các cấu hình Docker Compose sẵn sàng triển khai cho self-hosted infrastructure.

## Dịch vụ

| Thư mục | Dịch vụ | Mô tả |
|---------|---------|-------|
| [`qdrant/`](qdrant/) | Qdrant | Vector database |
| [`portainer/`](portainer/) | Portainer CE | Giao diện web quản lý Docker |
| [`cloudflare-tunnel/`](cloudflare-tunnel/) | Cloudflare Tunnel | Expose dịch vụ nội bộ ra internet, không cần mở port |
| [`cloudflare-ddns-wireguard/`](cloudflare-ddns-wireguard/) | DDNS + WireGuard | Tự cập nhật DNS động và VPN server |
| [`n8n/`](n8n/) | n8n + PostgreSQL | Workflow automation |
| [`minio/`](minio/) | MinIO | Object storage tương thích S3 |
| [`label-studio/`](label-studio/) | Label Studio | Công cụ gán nhãn dữ liệu AI/ML |
| [`open-project/`](open-project/) | OpenProject | Quản lý dự án mã nguồn mở |
| [`dify/`](dify/) | Dify + PostgreSQL + Redis + Weaviate | Nền tảng phát triển ứng dụng LLM |
| [`nextcloud/`](nextcloud/) | Nextcloud + MariaDB + Redis | Self-hosted cloud storage |
| [`9router/`](9router/) | 9router | Reverse proxy / router |

## Cấu trúc chung

Mỗi thư mục là một stack độc lập gồm:

```
<service>/
├── docker-compose.yml   ← định nghĩa services
├── .env                 ← biến cấu hình (không commit lên Git)
└── README.md            ← hướng dẫn chi tiết
```

## Yêu cầu chung

- Docker Engine & Docker Compose v2

## Sử dụng

Tạo `.env` cho từng app từ file mẫu rồi chỉnh lại giá trị:

```bash
for d in */; do [ -f "$d.env.example" ] && [ ! -f "$d.env" ] && cp "$d.env.example" "$d.env"; done
```

**Chạy toàn bộ app cùng lúc** (từ thư mục gốc, cần Docker Compose >= v2.20):

```bash
docker compose up -d
```

Danh sách app được chạy nằm trong [`docker-compose.yml`](docker-compose.yml) ở thư mục gốc — app nào không muốn chạy thì comment dòng `include` tương ứng. Mặc định không chạy `cloudflare-tunnel`, `cloudflare-ddns-wireguard`, `vaultwarden`.

**Chạy riêng một app:**

```bash
cd <service>/
docker compose up -d
```

Chi tiết cấu hình từng dịch vụ xem trong `README.md` tương ứng.

## Bảo mật

- Không commit `.env` lên Git — đã có trong `.gitignore`
- Đổi tất cả mật khẩu và secret key mặc định trước khi chạy
