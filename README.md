# GKE Multi Cluster Load Balancing (Global Load Balancer)

1. Create two clusters in two different regions where we want to distribute the load across.

    ```bash
   gcloud container clusters create montreal-cluster \
   --project gke-global-load-balancer \
   --region northamerica-northeast1 \
   --num-nodes 1
    ```

    ```bash
    gcloud container clusters create toronto-cluster \
      --project gke-global-load-balancer \
      --region northamerica-northeast2 \
      --num-nodes 1
    ```

2. Get the credentials for both clusters and run in separate tabs of terminal

   ```bash
   gcloud container clusters get-credentials montreal-cluster \
     --region northamerica-northeast1 \
     --project gke-global-load-balancer
   ```

   ```bash
   gcloud container clusters get-credentials toronto-cluster \
     --region northamerica-northeast2 \
     --project gke-global-load-balancer
   ```

3. For each terminal (cluster), run the following command starting from this step:

   ```bash
   kubectl create deployment hello-world --image=quay.io/stepanstipl/k8s-demo-app:latest
   ```

4. Create a file called service.yaml and add the following content

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: hello-world
     annotations:
       cloud.google.com/neg: '{"ingress": true, "exposed_ports": {"8080":{}}}'
   spec:
     ports:
       - protocol: TCP
         port: 8080
         targetPort: 8080
     selector:
       app: hello-world
     type: ClusterIP
   ```

   ```bash
   kubectl apply -f service.yaml
   ```

5. Do the following steps just once (not like we have done previously starting at step 2).

   ```bash
   gcloud compute health-checks create http health-check-foobar \
     --use-serving-port \
     --request-path="/healthz"
   ```

   ```bash
   gcloud compute backend-services create backend-service-foo \
     --global \
     --health-checks health-check-foobar
   ```

   ```bash
   gcloud compute backend-services create backend-service-bar \
     --global \
     --health-checks health-check-foobar
   ```

   ```bash
   gcloud compute backend-services create backend-service-default \
     --global
   ```

   ```bash
   gcloud compute url-maps create foobar-url-map \
     --global \
     --default-service backend-service-default
   ```

   ```bash
   gcloud compute url-maps add-path-matcher foobar-url-map \
     --global \
     --path-matcher-name=foo-bar-matcher \
     --default-service=backend-service-default \
     --backend-service-path-rules='/foo/*=backend-service-foo,/bar/*=backend-service-bar'
   ```

   ```bash
   gcloud compute target-http-proxies create foobar-http-proxy \
     --global \
     --url-map foobar-url-map \
     --global-url-map
   ```

   ```bash
   gcloud compute forwarding-rules create foobar-forwarding-rule \
     --global \
     --target-http-proxy foobar-http-proxy \
     --ports 8080
   ```

6. Check the NEGs

   ```bash
   gcloud compute network-endpoint-groups list
   ```

   Note down the NEG name and its associated region under each cluster terminal tabs.

7. Configure the load balancer. (Use the names of the NEGs from the previous step)

   ```bash
   gcloud compute backend-services add-backend backend-service-foo \
    --global \
    --network-endpoint-group k8s1-a0fca03c-default-hello-world-8080-3472eb16 \
    --network-endpoint-group-zone=northamerica-northeast1-c \
    --balancing-mode=RATE \
    --max-rate-per-endpoint=100
   ```

   ```bash
   gcloud compute backend-services add-backend backend-service-bar \
    --global \
    --network-endpoint-group k8s1-a0fca03c-default-hello-world-8080-3472eb16 \
    --network-endpoint-group-zone=northamerica-northeast1-c \
    --balancing-mode=RATE \
    --max-rate-per-endpoint=100
   ```

   ```bash
   gcloud compute backend-services add-backend backend-service-foo \
    --global \
    --network-endpoint-group k8s1-758dbcf4-default-hello-world-8080-d606ee96 \
    --network-endpoint-group-zone=northamerica-northeast2-c \
    --balancing-mode=RATE \
    --max-rate-per-endpoint=100
   ```

   ```bash
   gcloud compute backend-services add-backend backend-service-bar \
    --global \
    --network-endpoint-group k8s1-758dbcf4-default-hello-world-8080-d606ee96 \
    --network-endpoint-group-zone=northamerica-northeast2-c \
    --balancing-mode=RATE \
    --max-rate-per-endpoint=100
   ```

   ```bash
   gcloud compute firewall-rules create fw-allow-gclb \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:8080
   ```
