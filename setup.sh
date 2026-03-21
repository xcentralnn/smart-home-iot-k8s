#!/bin/bash

set -e

echo "=========================================="
echo "  Smart Home IoT - Cài đặt môi trường"
echo "=========================================="

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Kiểm tra các công cụ cần thiết
check_requirements() {
    echo ""
    echo "Kiểm tra yêu cầu hệ thống..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 chưa được cài đặt"
        exit 1
    fi
    print_status "Python3: $(python3 --version)"
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl chưa được cài đặt"
        exit 1
    fi
    print_status "kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    
    if ! command -v docker &> /dev/null; then
        print_warning "Docker chưa được cài đặt (cần thiết để build images)"
    else
        print_status "Docker: $(docker --version)"
    fi
}

# Tạo môi trường Python
setup_python_env() {
    echo ""
    echo "Tạo môi trường Python..."
    
    if [ -d ".venv" ]; then
        print_warning "Môi trường .venv đã tồn tại, bỏ qua..."
    else
        python3 -m venv .venv
        print_status "Đã tạo môi trường ảo .venv"
    fi
    
    source .venv/bin/activate
    print_status "Đã kích hoạt môi trường ảo"
    
    pip install --upgrade pip -q
    pip install -r simulator/requirements.txt -q
    print_status "Đã cài đặt dependencies cho simulator"
}

# Triển khai lên Kubernetes
deploy_k8s() {
    echo ""
    echo "Triển khai lên Kubernetes..."
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Không thể kết nối tới Kubernetes cluster"
        print_warning "Hãy đảm bảo cluster đang chạy (minikube start, kind create cluster, ...)"
        exit 1
    fi
    
    kubectl apply -k k8s/
    print_status "Đã apply manifests"
    
    echo ""
    echo "Đợi pods khởi động..."
    kubectl wait --for=condition=ready pod -l project=smart-home-iot -n smart-home --timeout=120s 2>/dev/null || true
    
    echo ""
    kubectl get pods -n smart-home
}

# Hiển thị hướng dẫn tiếp theo
show_next_steps() {
    echo ""
    echo "=========================================="
    echo "  Cài đặt hoàn tất!"
    echo "=========================================="
    echo ""
    echo "Các bước tiếp theo:"
    echo ""
    echo "1. Chạy simulator:"
    echo "   source .venv/bin/activate"
    echo "   python simulator/device_simulator_room1.py"
    echo ""
    echo "2. Truy cập Grafana:"
    echo "   kubectl port-forward svc/grafana 3000:3000 -n smart-home"
    echo "   Mở: http://localhost:3000 (admin/admin)"
    echo ""
    echo "3. Xem dashboard: Dashboards → IoT"
    echo ""
}

# Main
check_requirements
setup_python_env
deploy_k8s
show_next_steps
