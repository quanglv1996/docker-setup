# Qdrant

Triển khai [Qdrant](https://qdrant.tech/) vector database bằng Docker.

## Yêu cầu

- Docker & Docker Compose v2

## Cài đặt

### 1. Cấu hình `.env`

| Biến | Mô tả | Mặc định |
|------|--------|----------|
| `QDRANT_API_KEY` | API key xác thực (bắt buộc đổi) | *(bắt buộc)* |
| `QDRANT_READ_ONLY_API_KEY` | API key chỉ đọc (tùy chọn) | — |
| `QDRANT_HTTP_PORT` | Cổng REST API | `6333` |
| `QDRANT_GRPC_PORT` | Cổng gRPC | `6334` |
| `QDRANT_DATA_PATH` | Đường dẫn lưu data | `./data/qdrant` |

> Không commit `.env` lên Git. Thêm `.env` vào `.gitignore`.

### 2. Khởi động

```bash
docker compose up -d
```

### 3. Kiểm tra

```bash
# Health check
curl http://localhost:6333/healthz

# Xem danh sách collections (kèm API key)
curl http://localhost:6333/collections \
  -H "api-key: your_api_key"
```

## Sử dụng

### REST API

| Endpoint | Mô tả |
|----------|-------|
| `GET /collections` | Danh sách collections |
| `PUT /collections/{name}` | Tạo collection |
| `POST /collections/{name}/points` | Thêm vectors |
| `POST /collections/{name}/points/search` | Tìm kiếm vector |

Tài liệu đầy đủ: [qdrant.tech/documentation](https://qdrant.tech/documentation/)

### Dashboard

Qdrant có Web UI tại: `http://localhost:6333/dashboard`

### Kết nối từ ứng dụng

```python
from qdrant_client import QdrantClient

client = QdrantClient(
    url="http://localhost:6333",
    api_key="your_api_key",
)
```

```javascript
import { QdrantClient } from "@qdrant/js-client-rest";

const client = new QdrantClient({
  url: "http://localhost:6333",
  apiKey: "your_api_key",
});
```

## Cloudflare Tunnel

Cloudflare Tunnel trỏ vào port `6333` (REST API). Port `6334` (gRPC) thường chỉ dùng nội bộ, không cần expose qua Cloudflare.

## Lệnh thường dùng

| Lệnh | Mục đích |
|------|---------|
| `docker compose up -d` | Khởi động Qdrant |
| `docker compose down` | Dừng và xóa container |
| `docker compose logs -f qdrant` | Xem logs realtime |
| `docker compose pull && docker compose up -d` | Cập nhật lên phiên bản mới nhất |
