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

.PHONY: up deploy test status lint down help

CLUSTER := multinode
URL     := http://localhost:30080

help: ## list all targets
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}'

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
