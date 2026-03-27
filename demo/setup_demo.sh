#!/bin/bash

# ===========================================
# Script chuẩn bị môi trường demo
# ===========================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   SMART HOME IoT - SETUP DEMO${NC}"
echo -e "${BLUE}========================================${NC}"

# Bước 1: Kiểm tra kubectl
echo -e "\n${YELLOW}[1/5] Kiểm tra kubectl...${NC}"
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}✓ kubectl đã cài đặt${NC}"
else
    echo -e "${RED}✗ kubectl chưa cài đặt${NC}"
    exit 1
fi

# Bước 2: Kiểm tra pods
echo -e "\n${YELLOW}[2/5] Kiểm tra pods trong namespace smart-home...${NC}"
kubectl get pods -n smart-home
PODS_READY=$(kubectl get pods -n smart-home --no-headers | grep -c "Running")
PODS_TOTAL=$(kubectl get pods -n smart-home --no-headers | wc -l)
echo -e "${GREEN}✓ $PODS_READY/$PODS_TOTAL pods đang Running${NC}"

# Bước 3: Cài đặt Python dependencies
echo -e "\n${YELLOW}[3/5] Cài đặt Python dependencies...${NC}"
if [ -d "../.venv" ]; then
    source ../.venv/bin/activate
else
    python3 -m venv ../.venv
    source ../.venv/bin/activate
fi
pip install -q paho-mqtt
echo -e "${GREEN}✓ Dependencies đã cài đặt${NC}"

# Bước 4: Hướng dẫn port-forward
echo -e "\n${YELLOW}[4/5] Cần mở các terminal riêng để port-forward:${NC}"
echo -e "${BLUE}Terminal 1 - Grafana:${NC}"
echo "  kubectl port-forward svc/grafana 3000:3000 -n smart-home"
echo -e "${BLUE}Terminal 2 - MQTT:${NC}"
echo "  kubectl port-forward svc/mqtt 31883:1883 -n smart-home"

# Bước 5: Hướng dẫn chạy demo
echo -e "\n${YELLOW}[5/5] Chạy demo simulator:${NC}"
echo -e "${BLUE}Dữ liệu bình thường:${NC}"
echo "  python demo_simulator.py --mode normal"
echo -e "${BLUE}Dữ liệu bất thường (để demo ML):${NC}"
echo "  python demo_simulator.py --mode anomaly"
echo -e "${BLUE}Xen kẽ (realistic):${NC}"
echo "  python demo_simulator.py --mode mixed"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}   SETUP HOÀN TẤT - SẴN SÀNG DEMO!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Mở Grafana: http://localhost:3000 (admin/admin)${NC}"
echo -e "${YELLOW}Vào: Dashboards → IoT${NC}\n"
