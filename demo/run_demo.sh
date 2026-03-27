#!/bin/bash

# ===========================================
# Script chạy demo từng bước
# ===========================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

clear

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}${BOLD}        🏠 SMART HOME IoT AI MONITORING DEMO           ${NC}${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"

# Activate venv
if [ -d "../.venv" ]; then
    source ../.venv/bin/activate
fi

show_step() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}BƯỚC $1: $2${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

wait_for_enter() {
    echo -e "\n${GREEN}Nhấn ENTER để tiếp tục...${NC}"
    read
}

# BƯỚC 1
show_step "1" "Kiểm tra Kubernetes Pods"
echo -e "${BLUE}Lệnh: kubectl get pods -n smart-home${NC}\n"
kubectl get pods -n smart-home
echo -e "\n${GREEN}→ Tất cả pods đang Running = Hệ thống sẵn sàng${NC}"
wait_for_enter

# BƯỚC 2
show_step "2" "Giới thiệu Data Pipeline"
echo -e "
${BOLD}Luồng dữ liệu:${NC}

  ┌─────────────┐    ┌──────────┐    ┌───────────┐    ┌──────────┐
  │ IoT Sensor  │───▶│   MQTT   │───▶│ Ingestion │───▶│ InfluxDB │
  └─────────────┘    └──────────┘    └───────────┘    └────┬─────┘
                                                          │
  ┌─────────────┐                    ┌───────────┐        │
  │   Grafana   │◀───────────────────│ ML Anomaly│◀───────┘
  └─────────────┘                    └───────────┘

${YELLOW}Công nghệ:${NC}
  • MQTT Broker: Eclipse Mosquitto
  • Database: InfluxDB (time-series)
  • ML Model: Isolation Forest (scikit-learn)
  • Dashboard: Grafana
"
wait_for_enter

# BƯỚC 3
show_step "3" "Chạy Simulator - Dữ liệu BÌNH THƯỜNG"
echo -e "${BLUE}Lệnh: python demo_simulator.py --mode normal${NC}"
echo -e "${YELLOW}→ Mở Grafana (http://localhost:3000) để xem biểu đồ${NC}"
echo -e "${YELLOW}→ Nhấn Ctrl+C để dừng và chuyển sang bước tiếp${NC}\n"
python demo_simulator.py --mode normal --interval 2

# BƯỚC 4
show_step "4" "Inject ANOMALY - Demo ML Detection"
echo -e "${RED}⚠️  Bây giờ sẽ gửi dữ liệu BẤT THƯỜNG${NC}"
echo -e "${BLUE}Lệnh: python demo_simulator.py --mode anomaly${NC}"
echo -e "${YELLOW}→ Xem Grafana: Anomaly score tăng, Anomaly flag = true${NC}"
echo -e "${YELLOW}→ Nhấn Ctrl+C để dừng${NC}\n"
python demo_simulator.py --mode anomaly --interval 2

# BƯỚC 5
show_step "5" "Mixed Mode - Realistic Scenario"
echo -e "${BLUE}Lệnh: python demo_simulator.py --mode mixed${NC}"
echo -e "${YELLOW}→ Xen kẽ dữ liệu bình thường và bất thường${NC}"
echo -e "${YELLOW}→ ML tự động phân biệt và detect anomaly${NC}"
echo -e "${YELLOW}→ Nhấn Ctrl+C để kết thúc demo${NC}\n"
python demo_simulator.py --mode mixed --interval 2

# KẾT THÚC
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}${BOLD}              ✓ DEMO HOÀN TẤT!                          ${NC}${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo -e "
${BOLD}Tóm tắt những gì đã demo:${NC}
  1. Kubernetes microservices architecture
  2. IoT data streaming qua MQTT
  3. Time-series storage với InfluxDB
  4. ML Anomaly Detection với Isolation Forest
  5. Real-time visualization với Grafana
"
