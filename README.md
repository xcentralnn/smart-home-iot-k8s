<div align="center">

# Smart Home IoT Monitoring on Kubernetes

<img src="docs/architecture.png" width="900"/>

A cloud-native IoT monitoring platform built with Kubernetes.

Simulates IoT sensors → streams telemetry through MQTT → stores time-series data in InfluxDB → detects anomalies using machine learning → visualizes metrics in Grafana.

<br>

![GitHub stars](https://img.shields.io/github/stars/xcentralnn/smart-home-iot-k8s?style=social)
![GitHub forks](https://img.shields.io/github/forks/xcentralnn/smart-home-iot-k8s?style=social)
![License](https://img.shields.io/badge/license-MIT-green)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestrated-blue?logo=kubernetes)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.10+-yellow?logo=python)

</div>

---

<div align="center">

# Smart Home IoT Monitoring on Kubernetes

<img src="docs/architecture.png" width="900"/>

Cloud-native IoT telemetry pipeline running on Kubernetes.

Simulated sensors → MQTT messaging → time-series storage → visualization in Grafana.

<br>

![GitHub stars](https://img.shields.io/github/stars/xcentralnn/smart-home-iot-k8s?style=social)
![GitHub forks](https://img.shields.io/github/forks/xcentralnn/smart-home-iot-k8s?style=social)
![License](https://img.shields.io/badge/license-MIT-green)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestrated-blue?logo=kubernetes)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)
![Python](https://img.shields.io/badge/Python-3.10+-yellow?logo=python)

</div>

---

# Overview

This project demonstrates a **cloud-native IoT monitoring platform deployed on Kubernetes**.

The system simulates IoT sensors that publish telemetry through MQTT.  
Data is processed by microservices, stored in a time-series database, and visualized in Grafana dashboards.

Telemetry pipeline:

```
Simulator → MQTT → Ingestion → InfluxDB → Grafana
```

---

# Architecture

<div align="center">

<img src="docs/architecture.png" width="850"/>

</div>

Data flows through the following stages:

1. IoT simulator generates sensor telemetry  
2. MQTT broker receives device messages  
3. Ingestion service processes incoming events  
4. Metrics are stored in InfluxDB  
5. Grafana dashboards visualize telemetry  

---

# Components

| Component | Description |
|---|---|
| **IoT Simulator** | Python program generating simulated sensor data |
| **MQTT Broker** | Messaging layer for IoT telemetry |
| **Ingestion Service** | Consumes MQTT messages and writes metrics to InfluxDB |
| **InfluxDB** | Time-series database storing sensor telemetry |
| **Grafana** | Visualization dashboard for metrics |

---

# Dashboard

<div align="center">

<img src="docs/dashboard.png" width="900"/>

</div>

The dashboard displays:

- temperature metrics  
- humidity metrics  
- sensor activity over time  

---

# Quick Start

## 1. Clone repository

```bash
git clone https://github.com/xcentralnn/smart-home-iot-k8s.git
cd smart-home-iot-k8s
```

---

# 2. Deploy the platform

All Kubernetes manifests are managed using **Kustomize**.

```bash
kubectl apply -k k8s/
```

Verify workloads:

```bash
kubectl get all -n smart-home
```

Example healthy output:

```
NAME                             READY   STATUS
pod/grafana-xxxx                 1/1     Running
pod/influxdb-xxxx                1/1     Running
pod/ingestion-xxxx               1/1     Running
pod/mqtt-xxxx                    1/1     Running
```

Services:

```
service/grafana    NodePort   3000:32000
service/influxdb   ClusterIP  8086
service/mqtt       NodePort   1883:31883
```

Once all pods are **Running**, the platform is ready.

---

# 3. Run the IoT simulator

Create Python environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r simulator/requirements.txt
```

Run simulator:

```bash
python simulator/device_simulator_room1.py
```

Example output:

```
Connected to MQTT broker

Published:
{
 temperature: 28.9,
 humidity: 46.2,
 device: room1
}
```

Sensor telemetry is now streaming into the platform.

---

# 4. Access Grafana

### Option 1 — NodePort

Open in browser:

```
http://localhost:32000
```

---

### Option 2 — Port Forward (recommended if NodePort does not work)

```bash
kubectl port-forward svc/grafana 3000:3000 -n smart-home
```

Open:

```
http://localhost:3000
```

---

Login credentials:

```
admin
admin
```

---

# 5. View the dashboard

After login:

```
Dashboards → IoT
```

You will see real-time telemetry including:

- temperature
- humidity
- device activity

The dashboard updates continuously as the simulator publishes new sensor data.

---

# Demo

<div align="center">

<img src="docs/demo.gif" width="900"/>

</div>

---

# Data Pipeline

```
IoT Simulator
      ↓
MQTT Broker
      ↓
Ingestion Service
      ↓
InfluxDB
      ↓
Grafana Dashboard
```

---

# Future Improvements

Potential extensions:

- multi-device IoT simulation  
- autoscaling ingestion with **KEDA**  
- GitOps deployment using **ArgoCD**  
- CI/CD pipelines for container builds  
- Prometheus monitoring integration  

---

# License

MIT License