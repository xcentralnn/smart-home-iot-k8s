# 🎯 Hướng Dẫn Demo Cho Giảng Viên

## Chuẩn Bị Trước Demo

### Terminal 1: Kiểm tra pods đang chạy
```bash
kubectl get pods -n smart-home
```
Đảm bảo tất cả pods đều `Running`.

### Terminal 2: Port-forward Grafana
```bash
kubectl port-forward svc/grafana 3000:3000 -n smart-home
```

### Terminal 3: Port-forward MQTT (cho simulator)
```bash
kubectl port-forward svc/mqtt 31883:1883 -n smart-home
```

### Mở Browser
- Grafana: http://localhost:3000
- Login: admin / admin
- Vào: Dashboards → IoT

---

## Kịch Bản Demo (5-7 phút)

### Bước 1: Giới Thiệu Kiến Trúc (1 phút)
Mở slide hoặc hình `docs/architecture.png` và giải thích:
```
IoT Simulator → MQTT → Ingestion → InfluxDB → ML Anomaly → Grafana
```

### Bước 2: Show Kubernetes Pods (30 giây)
```bash
kubectl get pods -n smart-home
```
Giải thích: "Đây là các microservices đang chạy trên K8s"

### Bước 3: Chạy Simulator - Dữ Liệu Bình Thường (1 phút)
```bash
cd demo
source ../.venv/bin/activate
python demo_simulator.py --mode normal
```
- Quay sang Grafana, show biểu đồ đang cập nhật
- Chỉ ra: "Dữ liệu bình thường, anomaly score thấp"

### Bước 4: Inject Anomaly - ĐIỂM NHẤN (2 phút)
Dừng simulator (Ctrl+C), chạy lại với mode anomaly:
```bash
python demo_simulator.py --mode anomaly
```
- Quay sang Grafana
- Chỉ ra: "Nhiệt độ tăng đột biến → ML phát hiện → Anomaly flag = true"
- Đây là điểm WOW của demo!

### Bước 5: Mixed Mode (1 phút)
```bash
python demo_simulator.py --mode mixed
```
- Show cả 2 loại data xen kẽ
- ML tự động phân biệt normal vs anomaly

### Bước 6: Show Code ML (tùy chọn, 1 phút)
Mở file `services/anomaly-detection/model.py`:
- Giải thích Isolation Forest
- Show cách tính anomaly score

---

## Các Lệnh Demo Nhanh

### Chạy simulator với các mode
```bash
# Dữ liệu bình thường
python demo_simulator.py --mode normal

# Dữ liệu bất thường (để demo ML detect)
python demo_simulator.py --mode anomaly

# Xen kẽ (realistic nhất)
python demo_simulator.py --mode mixed

# Tăng tốc độ publish (mỗi 1 giây)
python demo_simulator.py --mode mixed --interval 1
```

### Xem logs của anomaly service
```bash
kubectl logs -f deployment/anomaly-detector -n smart-home
```

### Xem logs của ingestion service
```bash
kubectl logs -f deployment/ingestion -n smart-home
```

---

## Câu Hỏi Thường Gặp Từ Giảng Viên

### Q: Tại sao dùng Isolation Forest?
A: Phù hợp cho unsupervised anomaly detection, không cần labeled data, hiệu quả với high-dimensional data.

### Q: Tại sao dùng MQTT?
A: Lightweight protocol, phù hợp IoT, pub/sub pattern, low bandwidth.

### Q: Tại sao dùng InfluxDB?
A: Time-series database, tối ưu cho sensor data, query nhanh theo thời gian.

### Q: Model được train như thế nào?
A: CronJob trong K8s chạy định kỳ, train trên historical data từ InfluxDB.

---

## Troubleshooting

### Grafana không hiện data
```bash
# Kiểm tra ingestion service
kubectl logs deployment/ingestion -n smart-home

# Kiểm tra InfluxDB
kubectl port-forward svc/influxdb 8086:8086 -n smart-home
# Truy cập http://localhost:8086
```

### Simulator không kết nối được MQTT
```bash
# Đảm bảo port-forward đang chạy
kubectl port-forward svc/mqtt 31883:1883 -n smart-home
```

### Anomaly không được detect
```bash
# Kiểm tra anomaly service
kubectl logs deployment/anomaly-detector -n smart-home
```
