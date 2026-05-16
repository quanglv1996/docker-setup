# docker-setup

Tập hợp các cấu hình Docker Compose sẵn sàng triển khai cho self-hosted infrastructure.

## Dịch vụ

| Thư mục | Dịch vụ | Mô tả |
|---------|---------|-------|
| [`cloudflare-tunnel/`](cloudflare-tunnel/) | Cloudflare Tunnel | Expose dịch vụ nội bộ ra internet, không cần mở port |
| [`cloudflare-ddns-wireguard/`](cloudflare-ddns-wireguard/) | DDNS + WireGuard | Tự cập nhật DNS động và VPN server |
| [`n8n/`](n8n/) | n8n + PostgreSQL | Workflow automation |
| [`minio/`](minio/) | MinIO | Object storage tương thích S3 |
| [`label-studio/`](label-studio/) | Label Studio | Công cụ gán nhãn dữ liệu AI/ML |
| [`open-project/`](open-project/) | OpenProject | Quản lý dự án mã nguồn mở |
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

```bash
cd <service>/
cp .env.example .env    # nếu có, hoặc chỉnh .env trực tiếp
docker compose up -d
```

Chi tiết cấu hình từng dịch vụ xem trong `README.md` tương ứng.

## Bảo mật

- Không commit `.env` lên Git — đã có trong `.gitignore`
- Đổi tất cả mật khẩu và secret key mặc định trước khi chạy
