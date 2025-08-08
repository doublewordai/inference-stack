# Doubleword Inference Stack

A comprehensive Helm chart for deploying production grade LLMs. This stack is a lightweight, transparent framework to allow you to deploy any model on any inference engine with minimal configuration. It is designed to be flexible, allowing you to easily switch between different models and inference engines without changing your client code.

The spirit of this project is to produce a framework that solves distributed serving of LLMs in a non-specific way to the inference engine running the weights.

We achieve this by deploying the [Onwards AI Gateway](https://github.com/doublewordai/onwards) with configurable LLM model groups. This chart provides a transparent, unified interface for routing requests to multiple inference engines like vLLM, SGLang, TensorRT-LLM, and others. It also allows you to set human readable model names that map to backend services, making it easy to switch between models without changing client code.

If you want to go beyond what's available here for high-throughput deployments, [contact us](https://www.doubleword.ai/contact) at <hello@doubleword.ai>.

## Architecture Overview

<div align="center">
<img src="./Inference%20Stack%20Architecture.png" alt="Architecture Diagram" width="600">
</div>

The stack consists of:

- **Onwards Gateway**: The API gateway that routes requests to different inference engines.
- **Model Groups**: A grouping of kubernetes resources that represent a deployment of an inference engine. Each model group can only have one active model at a time, but can have custom numbers of replicas.
- **Inference Engines**: Backend services like vLLM, SGLang, TensorRT-LLM that handle the actual inference requests.

## Roadmap

We are actively developing this stack to support sophisticated LLM deployments. See our [issues](https://github.com/doublewordai/inference-stack/issues) for the latest features and improvements. Some key features we are working on include:

- **Model Group Prefix Aware Routing**: <https://github.com/doublewordai/inference-stack/issues/4>
- **More complicated model group configurations**, such as dynamo: <https://github.com/doublewordai/inference-stack/issues/5>
- **AutoScaling**: dynamic: <https://github.com/doublewordai/inference-stack/issues/6> and scale to zero: <https://github.com/doublewordai/inference-stack/issues/7>
- **Inference Engine Support**: Adding example and support for more inference engines, please [open an issue](https://github.com/doublewordai/inference-stack/issues/new) to request specific engines.

## Getting Started

### Install from OCI Registry

```bash
# Add the Helm repository (OCI format)
helm pull oci://ghcr.io/doublewordai/inference-stack

# Install with default configuration
helm install my-inference-stack oci://ghcr.io/doublewordai/inference-stack
```

### Install from Source

```bash
# Clone the repository
git clone https://github.com/doublewordai/inference-stack.git
cd inference-stack

# Install with default values
helm install my-inference-stack .

# Or install with custom values
helm install my-inference-stack . -f my-values.yaml
```

### Basic Configuration

The most important configuration is defining your model groups. Each model group represents a deployment of an inference engine:

```yaml
modelGroups:
  # vLLM deployment serving Llama models
  vllm-llama:
    enabled: true
    image: vllm/vllm-openai
    tag: latest
    modelAlias:
      - "llama"
      - "llama-3.1-8b-instruct"
    modelName: "meta-llama/Meta-Llama-3.1-8B-Instruct"
    command:
      - "vllm"
      - "serve"
      - "--model"
      - "meta-llama/Meta-Llama-3.1-8B-Instruct"
    
  # SGLang deployment serving Qwen models  
  sglang-qwen:
    enabled: true
    image: lmsysorg/sglang
    tag: latest
    modelAlias:
      - "qwen"
      - "qwen-2.5-7b-instruct"
    modelName: "Qwen/Qwen2.5-7B-Instruct"
    command:
      - "python"
      - "-m"
      - "sglang.launch_server"
      - "--model-path"
      - "Qwen/Qwen2.5-7B-Instruct"
```

### GPU Configuration

For GPU-enabled inference:

```yaml
modelGroups:
  vllm-llama:
    enabled: true
    resources:
      limits:
        nvidia.com/gpu: 2
        memory: 16Gi
      requests:
        nvidia.com/gpu: 1  
        memory: 8Gi
    nodeSelector:
      accelerator: nvidia-tesla-v100
    tolerations:
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule
```

### Persistent Storage for Model Caching

```yaml
modelGroups:
  vllm-llama:
    # Single persistent volume
    persistentVolumes:
      - name: model-cache
        size: 100Gi
        storageClass: fast-ssd
        mountPath: /root/.cache/huggingface
        accessModes:
          - ReadWriteOnce
    
    # Multiple persistent volumes (advanced)
    # persistentVolumes:
    #   - name: model-cache
    #     size: 50Gi
    #     mountPath: /root/.cache/huggingface
    #   - name: model-weights
    #     size: 200Gi
    #     mountPath: /models
    #     storageClass: fast-ssd
```

### Deployment Strategy Configuration

```yaml
modelGroups:
  vllm-llama:
    # Rolling update strategy for zero-downtime deployments
    strategy:
      type: RollingUpdate
      rollingUpdate:
        maxSurge: 1          # Allow 1 extra pod during updates
        maxUnavailable: 0    # Never take pods down (blue-green)
    
    # Scale replicas for high availability
    replicaCount: 3
```

### External Access via Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
  hosts:
    - host: inference.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: inference-tls
      hosts:
        - inference.example.com
```

## Example Configurations

This framework can be used to deploy any set inference engines, we offer these as examples to get you started quickly. The `examples/` directory contains ready-to-use configurations:

- **`single-vllm.yaml`** - Single vLLM model deployment with persistent caching
- **`single-sglang.yaml`** - SGLang deployment optimized for structured generation  
- **`single-tensorrt-llm.yaml`** - TensorRT-LLM with model compilation init container
- **`multi-engine.yaml`** - Complete multi-engine setup (vLLM + SGLang + TensorRT-LLM)

Use any example as a starting point, for example:

```bash
helm install my-stack . -f examples/single-vllm.yaml
```

## Usage Examples

### Deploying Multiple Models

```yaml
# values.yaml
modelGroups:
  # Code generation with vLLM
  vllm-codegen:
    enabled: true
    image: vllm/vllm-openai
    tag: latest
    modelAlias:
      - "codegen"
      - "code-generation"
    modelName: "Salesforce/codegen-2B-multi"
    command:
      - "vllm"
      - "serve"
      - "--model"
      - "Salesforce/codegen-2B-multi"
    
  # Chat models with SGLang
  sglang-chat:
    enabled: true
    image: lmsysorg/sglang
    tag: latest
    modelAlias:
      - "chat"
      - "qwen-chat"
    modelName: "Qwen/Qwen2.5-7B-Instruct"
    command:
      - "python"
      - "-m"
      - "sglang.launch_server"
      - "--model-path"
      - "Qwen/Qwen2.5-7B-Instruct"
    
  # High-performance with TensorRT-LLM
  tensorrt-llm:
    enabled: true
    image: nvcr.io/nvidia/tritonserver
    tag: 24.01-trtllm-python-py3
    modelAlias:
      - "optimized"
      - "fast-inference"
    modelName: "mistralai/Mistral-7B-Instruct-v0.2"
    command:
      - "tritonserver"
      - "--model-repository=/models"
```

### Using the API

Once deployed, you can use the standard OpenAI API format:

```bash
# Get available models
curl -X GET http://inference.example.com/v1/models

# Generate completion
curl -X POST http://inference.example.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.1-8b-chat",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Development

### Prerequisites

- Helm 3.13+
- Kubernetes 1.20+
- (Optional) GPU nodes with NVIDIA device plugin

### Running Tests

```bash
# Install test dependencies
helm plugin install https://github.com/helm-unittest/helm-unittest.git

# Run linting
helm lint .

# Run unit tests  
helm unittest .

# Test template rendering
helm template test-release .
```

### Local Development

```bash
# Test with different configurations
helm template test-release . \
  --set modelGroups.vllm-llama.enabled=true \
  --set ingress.enabled=true \
  --debug

# Install locally
helm install test-release . \
  --set modelGroups.vllm-llama.enabled=true \
  --dry-run
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

Reach out at: <hello@doubleword.ai>!

- 📚 [Documentation](https://github.com/doublewordai/inference-stack/wiki)
- 🐛 [Issue Tracker](https://github.com/doublewordai/inference-stack/issues)
- 💬 [Discussions](https://github.com/doublewordai/inference-stack/discussions)
