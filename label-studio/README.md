# Label Studio + MinIO - Docker Setup

Triển khai [Label Studio](https://labelstud.io/) kèm [MinIO](https://min.io/) làm S3-compatible storage, chạy sau Cloudflare Tunnel (hoặc reverse proxy bất kỳ).

## Kiến trúc

```
Internet
   │
   ▼
Cloudflare Tunnel
   │
   ▼
Label Studio :8080  ──►  MinIO :9000 (S3 API)
                          MinIO :9001 (Console UI)
```

## Yêu cầu

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose v2
- Domain đã trỏ về server (ví dụ qua Cloudflare Tunnel)

## Cấu trúc thư mục

```
label-studio/
├── data/
│   ├── minio/          ← dữ liệu MinIO (tự tạo khi chạy)
│   └── labelstudio/    ← dữ liệu Label Studio (tự tạo khi chạy)
├── docker-compose.yml
├── .env
└── README.md
```

## Cài đặt

### 1. Cấu hình `.env`

Sao chép và chỉnh sửa file `.env`:

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `MINIO_ROOT_USER` | Username đăng nhập MinIO | `minioadmin` |
| `MINIO_ROOT_PASSWORD` | Password MinIO (≥ 8 ký tự) | `minioadmin123` |
| `LABEL_STUDIO_DOMAIN` | Domain public của Label Studio | `labelstudio.example.com` |
| `AWS_ACCESS_KEY_ID` | Access key dùng để Label Studio kết nối MinIO | `minioadmin` |
| `AWS_SECRET_ACCESS_KEY` | Secret key tương ứng | `minioadmin123` |
| `AWS_S3_BUCKET_NAME` | Tên bucket lưu trữ dữ liệu | `labelstudio` |
| `MINIO_DATA_PATH` | Đường dẫn lưu dữ liệu MinIO | `./data/minio` |
| `LABELSTUDIO_DATA_PATH` | Đường dẫn lưu dữ liệu Label Studio | `./data/labelstudio` |

> **Lưu ý bảo mật:** Đổi `MINIO_ROOT_PASSWORD` và `AWS_SECRET_ACCESS_KEY` trước khi chạy production. Không commit `.env` lên Git.

### 2. Tạo bucket trên MinIO

Bucket phải tồn tại trước khi Label Studio khởi động. Có hai cách:

**Cách A — MinIO Console (sau khi stack đã chạy):**
1. Truy cập `http://localhost:9001`
2. Đăng nhập bằng `MINIO_ROOT_USER` / `MINIO_ROOT_PASSWORD`
3. Tạo bucket với tên khớp `AWS_S3_BUCKET_NAME`

**Cách B — MinIO CLI:**
```bash
docker compose exec minio mc alias set local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
docker compose exec minio mc mb local/$AWS_S3_BUCKET_NAME
```

### 3. Khởi động

```bash
docker compose up -d
```

### 4. Kiểm tra

```bash
docker compose ps
docker compose logs -f labelstudio
```

Label Studio sẽ khả dụng tại `https://<LABEL_STUDIO_DOMAIN>` (qua tunnel) hoặc `http://localhost:8080` (local).

## Thay đổi vị trí lưu dữ liệu

Chỉnh hai biến trong `.env`:

```env
MINIO_DATA_PATH=/mnt/storage/minio
LABELSTUDIO_DATA_PATH=/mnt/storage/labelstudio
```

Sau đó khởi động lại:

```bash
docker compose down
docker compose up -d
```

> Nếu di chuyển dữ liệu từ đường dẫn cũ, hãy copy toàn bộ nội dung thư mục trước khi khởi động lại.

## ⚠️ Fix lỗi Permission (bind mount)

Khi dùng bind mount, container Label Studio chạy với user `1001` (group `0`). Nếu thư mục data được tạo bởi root hoặc user khác, container sẽ bị lỗi **Permission denied** khi ghi dữ liệu.

**Triệu chứng:**
```
PermissionError: [Errno 13] Permission denied: '/label-studio/data/...'
```

**Cách fix — chạy lệnh sau trên host (Linux/macOS/WSL):**
```bash
sudo chown -R 1001:0 /path/to/data
```

Ví dụ nếu data nằm tại `E:/_DOCKER/label-studio/data` (WSL):
```bash
sudo chown -R 1001:0 /mnt/e/_DOCKER/label-studio/data
```

Hoặc nếu đang dùng Linux native:
```bash
sudo chown -R 1001:0 /path/to/labelstudio/data
```

> Lệnh này chỉ cần chạy **một lần** sau khi tạo thư mục data hoặc khi thay đổi `LABELSTUDIO_DATA_PATH`. MinIO không yêu cầu fix permission vì image minio chạy với user có quyền phù hợp.

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động tất cả services |
| `docker compose down` | Dừng và xóa containers |
| `docker compose logs -f` | Xem logs realtime |
| `docker compose pull` | Cập nhật images mới nhất |
| `docker compose restart labelstudio` | Khởi động lại chỉ Label Studio |

## Cổng dịch vụ

| Service | Cổng |
|---------|------|
| Label Studio | `8080` |
| MinIO S3 API | `9000` |
| MinIO Console | `9001` |
