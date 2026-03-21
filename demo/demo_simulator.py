#!/usr/bin/env python3
"""
Demo Simulator - Dùng để demo cho giảng viên
Có 3 chế độ:
1. normal - Dữ liệu bình thường
2. anomaly - Dữ liệu bất thường (nhiệt độ/độ ẩm cao)
3. mixed - Xen kẽ bình thường và bất thường
"""

import time
import random
import json
import argparse
import paho.mqtt.client as mqtt

BROKER = "localhost"
PORT = 31883
TOPIC = "smarthome/demo"

# Màu cho terminal
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print(f"{Colors.GREEN}✓ Kết nối MQTT broker thành công!{Colors.RESET}")
    else:
        print(f"{Colors.RED}✗ Lỗi kết nối: {rc}{Colors.RESET}")

def generate_normal_data():
    """Dữ liệu bình thường: nhiệt độ 20-30°C, độ ẩm 40-60%"""
    return {
        "temperature": round(random.uniform(22, 28), 1),
        "humidity": round(random.uniform(45, 55), 1),
        "device": "demo",
        "timestamp": time.time(),
        "type": "normal"
    }

def generate_anomaly_data():
    """Dữ liệu bất thường: nhiệt độ >40°C hoặc độ ẩm >85%"""
    anomaly_type = random.choice(["high_temp", "high_humidity", "both"])
    
    if anomaly_type == "high_temp":
        return {
            "temperature": round(random.uniform(45, 55), 1),
            "humidity": round(random.uniform(45, 55), 1),
            "device": "demo",
            "timestamp": time.time(),
            "type": "anomaly_high_temp"
        }
    elif anomaly_type == "high_humidity":
        return {
            "temperature": round(random.uniform(22, 28), 1),
            "humidity": round(random.uniform(90, 98), 1),
            "device": "demo",
            "timestamp": time.time(),
            "type": "anomaly_high_humidity"
        }
    else:
        return {
            "temperature": round(random.uniform(45, 55), 1),
            "humidity": round(random.uniform(90, 98), 1),
            "device": "demo",
            "timestamp": time.time(),
            "type": "anomaly_both"
        }

def print_data(payload, is_anomaly):
    """In dữ liệu với màu sắc"""
    if is_anomaly:
        color = Colors.RED
        icon = "⚠️ "
        label = "ANOMALY"
    else:
        color = Colors.GREEN
        icon = "✓ "
        label = "NORMAL"
    
    print(f"\n{color}{Colors.BOLD}{icon}{label}{Colors.RESET}")
    print(f"  📊 Temperature: {color}{payload['temperature']}°C{Colors.RESET}")
    print(f"  💧 Humidity:    {color}{payload['humidity']}%{Colors.RESET}")
    print(f"  🏠 Device:      {payload['device']}")

def run_demo(mode, interval):
    """Chạy demo với chế độ được chọn"""
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect
    
    print(f"\n{Colors.BLUE}{'='*50}{Colors.RESET}")
    print(f"{Colors.BOLD}🚀 SMART HOME IoT DEMO{Colors.RESET}")
    print(f"{Colors.BLUE}{'='*50}{Colors.RESET}")
    print(f"📡 Broker: {BROKER}:{PORT}")
    print(f"📨 Topic:  {TOPIC}")
    print(f"🎯 Mode:   {mode.upper()}")
    print(f"⏱️  Interval: {interval}s")
    print(f"{Colors.BLUE}{'='*50}{Colors.RESET}\n")
    
    try:
        client.connect(BROKER, PORT)
        client.loop_start()
    except Exception as e:
        print(f"{Colors.RED}✗ Không thể kết nối MQTT: {e}{Colors.RESET}")
        print(f"{Colors.YELLOW}Hãy chắc chắn đã chạy: kubectl port-forward svc/mqtt 31883:1883 -n smart-home{Colors.RESET}")
        return
    
    time.sleep(1)
    count = 0
    anomaly_count = 0
    
    try:
        while True:
            count += 1
            
            if mode == "normal":
                payload = generate_normal_data()
                is_anomaly = False
            elif mode == "anomaly":
                payload = generate_anomaly_data()
                is_anomaly = True
            else:  # mixed
                # Cứ 5 lần thì có 1 lần anomaly
                if count % 5 == 0:
                    payload = generate_anomaly_data()
                    is_anomaly = True
                else:
                    payload = generate_normal_data()
                    is_anomaly = False
            
            if is_anomaly:
                anomaly_count += 1
            
            # Publish to MQTT
            client.publish(TOPIC, json.dumps(payload))
            
            # Print
            print(f"\n{Colors.BLUE}[{count}] Published to {TOPIC}{Colors.RESET}")
            print_data(payload, is_anomaly)
            print(f"\n{Colors.YELLOW}📈 Stats: {count} messages, {anomaly_count} anomalies{Colors.RESET}")
            
            time.sleep(interval)
            
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}Demo stopped. Total: {count} messages, {anomaly_count} anomalies{Colors.RESET}")
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Demo Simulator cho Smart Home IoT")
    parser.add_argument(
        "--mode", "-m",
        choices=["normal", "anomaly", "mixed"],
        default="mixed",
        help="Chế độ: normal (bình thường), anomaly (bất thường), mixed (xen kẽ)"
    )
    parser.add_argument(
        "--interval", "-i",
        type=int,
        default=3,
        help="Khoảng thời gian giữa các message (giây)"
    )
    
    args = parser.parse_args()
    run_demo(args.mode, args.interval)
