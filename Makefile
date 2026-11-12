# =============================================================================
# 🎯 KinD demo — convenience targets
# =============================================================================
#   make up       create the 4-node cluster (skipped if it already exists)
#   make deploy   apply the nginx deployment + NodePort service
#   make test     curl the demo service on localhost:30080
#   make status   show nodes, deployments, services and pods
#   make lint     lint the README with markdownlint-cli2
#   make down     tear everything down (cluster + demo app)
#
# Run `make` (or `make help`) to list all targets.
# =============================================================================

.PHONY: help install up deploy test status lint down nuke

CLUSTER   := multinode
URL       := http://localhost:30080

# --- make install settings ---------------------------------------------------
BIN_DIR     := $(HOME)/.local/bin
OS          := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH        := $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/' -e 's/armv7l/arm/')
KIND_VER    := v0.33.0
KUBECTL_VER := v1.37.0

help: ## list all targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

install: ## install kind + kubectl into ~/.local/bin
	@mkdir -p $(BIN_DIR)
	@command -v podman >/dev/null 2>&1 || command -v docker >/dev/null 2>&1 \
		|| echo "⚠️  no container runtime found — install podman or docker first (see README)"
	@if command -v kind >/dev/null 2>&1; then \
		echo "✅ kind already installed: $$(kind version | head -1)"; \
	else \
		echo "⬇️  kind $(KIND_VER) → $(BIN_DIR)/kind"; \
		curl -fsSL -o $(BIN_DIR)/kind "https://kind.sigs.k8s.io/dl/$(KIND_VER)/kind-$(OS)-$(ARCH)"; \
		chmod +x $(BIN_DIR)/kind; \
	fi
	@if command -v kubectl >/dev/null 2>&1; then \
		echo "✅ kubectl already installed: $$(kubectl version --client 2>/dev/null | head -1)"; \
	else \
		echo "⬇️  kubectl $(KUBECTL_VER) → $(BIN_DIR)/kubectl"; \
		curl -fsSL -o $(BIN_DIR)/kubectl "https://dl.k8s.io/release/$(KUBECTL_VER)/bin/$(OS)/$(ARCH)/kubectl"; \
		chmod +x $(BIN_DIR)/kubectl; \
	fi
	@case ":$$PATH:" in *":$(BIN_DIR):"*) echo "✅ $(BIN_DIR) is on your PATH";; \
		*) echo "ℹ️  add it to your PATH:  export PATH=\"$$PATH:$(BIN_DIR)\"";; esac

up: ## create the cluster (skips if it exists)
	@kind get clusters | grep -qx $(CLUSTER) \
		&& echo "cluster '$(CLUSTER)' already exists — skipping ✅" \
		|| kind create cluster --config config.yaml

deploy: ## apply deployment.yaml + service.yaml
	kubectl apply -f deployment.yaml -f service.yaml

test: ## curl the demo service
	@echo "GET $(URL)"
	@curl -sS --max-time 10 $(URL) | head -5
	@echo "… ✅"

status: ## show cluster status
	kubectl get nodes -o wide
	kubectl get deploy,svc,pods -l app=nginx

lint: ## lint the README with markdownlint-cli2
	npx --yes markdownlint-cli2 "**/*.md"

down: ## tear down the cluster and demo app
	-kubectl delete -f deployment.yaml -f service.yaml --ignore-not-found
	-kind delete cluster --name $(CLUSTER)

nuke: ## delete all KinD clusters
	-kind delete clusters --all
