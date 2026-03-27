#!/bin/bash

set -e

echo "=========================================="
echo "  Smart Home IoT - Khởi động ứng dụng"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

cleanup() {
    echo ""
    print_warning "Đang dừng các tiến trình..."
    kill $PF_MQTT_PID $PF_GRAFANA_PID $SIMULATOR_PID 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM

# Kiểm tra kubectl
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl chưa được cài đặt"
    exit 1
fi

# Kiểm tra cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Không thể kết nối tới Kubernetes cluster"
    exit 1
fi
print_status "Đã kết nối Kubernetes cluster"

# Deploy ứng dụng
echo ""
echo "Triển khai ứng dụng lên Kubernetes..."
kubectl apply -k k8s/
print_status "Đã apply manifests"

# Đợi pods sẵn sàng
echo ""
echo "Đợi pods khởi động..."
kubectl wait --for=condition=ready pod -l app=mqtt -n smart-home --timeout=120s
kubectl wait --for=condition=ready pod -l app=influxdb -n smart-home --timeout=120s
kubectl wait --for=condition=ready pod -l app=ingestion -n smart-home --timeout=120s
kubectl wait --for=condition=ready pod -l app=grafana -n smart-home --timeout=120s
print_status "Tất cả pods đã sẵn sàng"

# Cài đặt Python dependencies
echo ""
echo "Cài đặt Python dependencies..."
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
.venv/bin/pip install -q -r simulator/requirements.txt
print_status "Đã cài đặt dependencies"

# Port forward MQTT
echo ""
echo "Khởi động port-forward..."
kubectl port-forward svc/mqtt 31883:1883 -n smart-home &
PF_MQTT_PID=$!
sleep 2
print_status "MQTT port-forward: localhost:31883"

# Port forward Grafana
kubectl port-forward svc/grafana 3000:3000 -n smart-home &
PF_GRAFANA_PID=$!
sleep 2
print_status "Grafana port-forward: localhost:3000"

# Chạy simulator
echo ""
echo "Khởi động IoT Simulator..."
.venv/bin/python simulator/device_simulator_room1.py &
SIMULATOR_PID=$!
sleep 2
print_status "Simulator đang chạy"

echo ""
echo "=========================================="
echo "  Ứng dụng đã sẵn sàng!"
echo "=========================================="
echo ""
echo "  Grafana: http://localhost:3000"
echo "  Login:   admin / admin"
echo ""
echo "  Nhấn Ctrl+C để dừng"
echo "=========================================="

wait
