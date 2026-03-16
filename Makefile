REGISTRY=centraln
VERSION=$(shell git rev-parse --short HEAD) #VERSION=04a16e7

build-ingestion:
	docker build -t $(REGISTRY)/iot-ingestion:$(VERSION) services/ingestion-service

push-ingestion:
	docker push $(REGISTRY)/iot-ingestion:$(VERSION)

build-anomaly:
	docker build -t $(REGISTRY)/iot-anomaly:$(VERSION) services/anomaly-detection

push-anomaly:
	docker push $(REGISTRY)/iot-anomaly:$(VERSION)

build: build-ingestion build-anomaly

push: push-ingestion push-anomaly

deploy:
	kubectl apply -k k8s/

all: build push deploy