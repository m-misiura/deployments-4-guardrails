#!/bin/bash

# Deploy all resources first to create the routes
echo "Deploying all resources..."
oc apply -k llama-stack-testing

# Wait for routes to be created (with timeout)
echo "Waiting for routes to be available..."
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  ATTEMPT=$((ATTEMPT+1))
  
  # Check if routes exist and get their hostnames
  GRANITE_ROUTE=$(oc get routes granite-detector-route -o jsonpath='{.spec.host}' 2>/dev/null)
  HAP_ROUTE=$(oc get routes hap-route -o jsonpath='{.spec.host}' 2>/dev/null)
  REGEX_ROUTE=$(oc get routes regex-route -o jsonpath='{.spec.host}' 2>/dev/null)
  
  # Check if all routes are available
  if [ -n "$GRANITE_ROUTE" ] && [ -n "$HAP_ROUTE" ] && [ -n "$REGEX_ROUTE" ]; then
    echo "All routes are available!"
    break
  else
    echo "Waiting for routes to be available... attempt $ATTEMPT/$MAX_ATTEMPTS"
    sleep 5
  fi
done

# Update ConfigMap with actual route hostnames
echo "Updating ConfigMap with route hostnames..."
cat <<EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: fmstack-nlp
    component: fms-orchestr8-nlp
    deploy-name: fms-orchestr8-nlp
  name: fms-orchestr8-config-nlp
data:
  config.yaml: |
    detectors:
      granite:
        type: text_chat
        service:
          hostname: ${GRANITE_ROUTE}
          port: 80
        chunker_id: whole_doc_chunker
        default_threshold: 0.5
      hap:
        type: text_contents
        service:
          hostname: ${HAP_ROUTE}
          port: 80
        chunker_id: whole_doc_chunker
        default_threshold: 0.5
      regex: 
        type: text_contents
        service:
          hostname: ${REGEX_ROUTE}
          port: 80
        chunker_id: whole_doc_chunker
        default_threshold: 0.5
EOF

# Restart the orchestrator to pick up the new config
echo "Restarting orchestrator..."
oc rollout restart deployment/fms-orchestr8-nlp

# Wait for the restart to complete
echo "Waiting for orchestrator to be ready..."
oc rollout status deployment/fms-orchestr8-nlp

echo "Setup complete!"