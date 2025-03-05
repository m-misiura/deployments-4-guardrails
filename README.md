# Deploying orchestrator and detectors on Openshift

Run the following command in a newly created namespace to deploy the orchestrator and detectors used to test the llama-stack

```bash
oc apply -k llama-stack-testing
```

To remove the orchestrator and detectors, run the following command

```bash
oc delete -k llama-stack-testing
```

## Assumptions

The following operators are available on the cluster:

- Authorino (0.16.0)
- NVIDIA GPU (24.9.2)
- Node Feature Discovery Operator (4.16.0)
- Open Data Hub (2.21.0)
- Red Hat Opneshift Serverless (1.35.0)
- Red Hat Service Mesh (2.6.5-0)

The Open Data Hub, can be initialised with the default DSC Initialization and Data Science Cluster
