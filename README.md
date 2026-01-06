# Kubernetest Cluster with KinD and Simple Service, Deploy

This repository contains configuration files and manifests to set up a local Kubernetes cluster using KinD (Kubernetes in Docker). It includes a simple deployment and service for demonstration purposes.

## Prerequisites

- Docker installed and running on your machine.
- KinD installed. You can install it by following the instructions at <https://kind.sigs.k8s.io/docs/user/quick-start/>
- kubectl installed. You can install it by following the instructions at <https://kubernetes.io/docs/tasks/tools/install-kubectl/>

## Setting Up the Cluster

1. Create a KinD cluster using the provided configuration file:

   ```bash
   kind create cluster --config config.yaml
   ```

2. Verify that the cluster is running:

   ```bash
   kubectl cluster-info --context kind-multinode
    ```

3. Apply the deployment and service manifests:

    ```bash
    kubectl apply -f deployment.yaml
    kubectl apply -f service.yaml
    ```

4. Check the status of the deployment and service:

    ```bash
    kubectl get deployments
    kubectl get services
    ```

## Accessing the Service

- The service is exposed on port 30080 of your local machine. You can access it by navigating to `http://localhost:30080` in your web browser.

## Cleanup

- To delete the KinD cluster, run:

   ```bash
   kind delete cluster
   kind delete clusters --all
   ```

## Notes

- This setup is intended for local development and testing purposes only. Do not use it for production environments.
- You can modify the deployment and service manifests to suit your application needs.

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.
