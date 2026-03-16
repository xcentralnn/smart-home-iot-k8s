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

# Overview

This project demonstrates a **cloud-native IoT telemetry pipeline** deployed on Kubernetes.

The system processes sensor data through an event-driven architecture consisting of multiple microservices.

Typical workflow:

```text
Simulator → MQTT → Ingestion → InfluxDB → AI Detection → Grafana
```

The project is designed to illustrate how modern IoT monitoring platforms can be built using Kubernetes and containerized services.

---

# Architecture

<div align="center">

<img src="docs/architecture.png" width="850"/>

</div>

The architecture follows a standard telemetry processing pipeline used in many IoT platforms.

Data flows through the following stages:

1. IoT devices generate telemetry
2. Messages are published through MQTT
3. Ingestion services process incoming data
4. Metrics are stored in a time-series database
5. AI models detect anomalies
6. Dashboards visualize system activity

---

# Components

| Component                | Description                                               |
| ------------------------ | --------------------------------------------------------- |
| **IoT Simulator**        | Python application generating simulated sensor telemetry  |
| **MQTT Broker**          | Message broker for device communication                   |
| **Ingestion Service**    | Consumes MQTT messages and writes metrics to InfluxDB     |
| **InfluxDB**             | Time-series database storing sensor metrics               |
| **AI Anomaly Detection** | Machine-learning service detecting abnormal sensor values |
| **Grafana**              | Visualization dashboard for real-time telemetry           |

---

# Dashboard

<div align="center">

<img src="docs/dashboard.png" width="900"/>

</div>

Grafana dashboards provide real-time insight into:

* temperature metrics
* humidity metrics
* sensor activity

---

# Quick Start

## 1. Clone the repository

```bash
git clone https://github.com/xcentralnn/smart-home-iot-k8s.git
cd smart-home-iot-k8s
```

---

## 2. Deploy the platform

All Kubernetes manifests are managed with **Kustomize**.

```bash
kubectl apply -k k8s/
```

Verify workloads:

```bash
kubectl get pods -n smart-home
```

Expected services:

```
mqtt
influxdb
ingestion
anomaly
grafana
```

---

## 3. Run the IoT simulator

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
python simulator/device_simulator.py
```

Sensor telemetry will begin streaming through the system.

---

## 4. Open Grafana

Forward Grafana port:

```bash
kubectl port-forward svc/grafana 3000:3000 -n smart-home
```

Open in browser:

```
http://localhost:3000
```

Login:

```
admin
admin
```

Configure **InfluxDB** as a data source to visualize metrics.

---

# Demo

<div align="center">

<img src="docs/demo.gif" width="900"/>

</div>

The demo illustrates the complete telemetry pipeline:

* simulator generates sensor readings
* ingestion processes MQTT events
* metrics are stored in InfluxDB
* Grafana dashboards update in real time
* anomaly detection identifies abnormal readings

---

# Data Pipeline

```
Simulator
   ↓
MQTT Broker
   ↓
Ingestion Service
   ↓
InfluxDB
   ↓
AI Anomaly Detection
   ↓
Grafana Dashboard
```

---

# Future Improvements

Potential enhancements for this platform:

* multi-device IoT simulation
* autoscaling ingestion services using KEDA
* Prometheus monitoring integration
* GitOps deployment using ArgoCD
* CI/CD pipelines for container builds

---

# License

MIT License
