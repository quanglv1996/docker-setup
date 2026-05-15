# Label Studio - Docker Setup

Triển khai [Label Studio](https://labelstud.io/) chạy sau Cloudflare Tunnel (hoặc reverse proxy bất kỳ).

## Kiến trúc

```
Internet
   │
   ▼
Cloudflare Tunnel
   │
   ▼
Label Studio :8080
```

## Yêu cầu

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose v2
- Domain đã trỏ về server (ví dụ qua Cloudflare Tunnel)

## Cấu trúc thư mục

```
label-studio/
├── data/
│   └── labelstudio/    ← dữ liệu Label Studio (tự tạo khi chạy)
├── docker-compose.yml
├── .env
└── README.md
```

## Cài đặt

### 1. Cấu hình `.env`

Tạo file `.env` và điền các giá trị:

```env
LABEL_STUDIO_USERNAME=your@email.com
LABEL_STUDIO_PASSWORD=your_password
LABEL_STUDIO_DOMAIN=label.example.com
LABELSTUDIO_DATA_PATH=./data/labelstudio
```

| Biến | Mô tả |
|------|--------|
| `LABEL_STUDIO_USERNAME` | Email đăng nhập Label Studio |
| `LABEL_STUDIO_PASSWORD` | Mật khẩu đăng nhập |
| `LABEL_STUDIO_DOMAIN` | Domain public của Label Studio |
| `LABELSTUDIO_DATA_PATH` | Đường dẫn lưu dữ liệu (mặc định `./data/labelstudio`) |

> **Lưu ý bảo mật:** Không commit file `.env` lên Git.

### 2. Khởi động

```bash
docker compose up -d
```

### 3. Kiểm tra

```bash
docker compose ps
docker compose logs -f labelstudio
```

Label Studio sẽ khả dụng tại `https://<LABEL_STUDIO_DOMAIN>` (qua tunnel) hoặc `http://localhost:8080` (local).

## Thay đổi vị trí lưu dữ liệu

Chỉnh biến trong `.env`:

```env
LABELSTUDIO_DATA_PATH=/mnt/storage/labelstudio
```

Sau đó khởi động lại:

```bash
docker compose down
docker compose up -d
```

> Nếu di chuyển dữ liệu từ đường dẫn cũ, hãy copy toàn bộ nội dung thư mục trước khi khởi động lại.

## ⚠️ Fix lỗi Permission (bind mount)

Container Label Studio chạy với user `1001` (group `0`). Nếu thư mục data được tạo bởi root hoặc user khác, container sẽ bị lỗi **Permission denied** khi ghi dữ liệu.

**Triệu chứng:**
```
PermissionError: [Errno 13] Permission denied: '/label-studio/data/...'
```

**Cách fix:**
```bash
sudo chown -R 1001:0 /path/to/labelstudio/data
```
```bash
sudo chmod -R 775 /path/to/labelstudio/data
```

> Lệnh này chỉ cần chạy **một lần** sau khi tạo thư mục data hoặc khi thay đổi `LABELSTUDIO_DATA_PATH`.

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động service |
| `docker compose down` | Dừng và xóa container |
| `docker compose logs -f` | Xem logs realtime |
| `docker compose pull` | Cập nhật image mới nhất |
| `docker compose restart labelstudio` | Khởi động lại Label Studio |

## Cổng dịch vụ

| Service | Cổng |
|---------|------|
| Label Studio | `8080` |
