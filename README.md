# Inference Stack Helm Chart

A comprehensive Helm chart for deploying production grade LLMs.

We achieve this by deploying the [Onwards AI Gateway](https://github.com/doublewordai/onwards) with configurable LLM model groups. This chart provides a transparent, unified interface for routing requests to multiple inference engines like vLLM, SGLang, TensorRT-LLM, and others. It also allows you to set human readable model names that map to backend services, making it easy to switch between models without changing client code.

## Features

- **🚀 Onwards Gateway**: Routes requests to multiple LLM backends with human-readable model names
- **🔧 Configurable Model Groups**: Support for vLLM, SGLang, TensorRT-LLM, and any OpenAI-compatible API
- **🔄 Rolling Updates**: Zero-downtime deployments with configurable update strategies
- **💾 Persistent Storage**: Flexible persistent volume support for model caching
- **🔐 Security**: Pod security contexts and service account configuration
- **📈 Monitoring**: Prometheus metrics support and health checks
- **🌐 Ingress**: Optional ingress controller support for external access
- **✅ Production Ready**: Comprehensive testing, linting, and CI/CD pipeline

## Quick Start

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

## Configuration

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

## Architecture

This Helm chart creates a scalable inference stack with the following components:

- **Onwards Gateway**: Routes API requests to appropriate model groups based on model aliases
- **Model Group Deployments**: Each enabled model group creates a Kubernetes Deployment
- **Persistent Volume Claims**: Optional storage for model caching (automatic PVC creation)
- **Services**: Each component gets its own ClusterIP service for internal communication
- **ConfigMaps**: Automatic generation of Onwards routing configuration

### Deployment Strategy

All model groups use **Kubernetes Deployments** (not StatefulSets) with configurable rolling update strategies for:

- ✅ **Zero-downtime updates** with blue-green deployment patterns
- ✅ **Faster scaling** and pod replacement
- ✅ **Better resource utilization** with flexible pod scheduling
- ✅ **Persistent storage** via automatically created PVCs

## Supported Inference Engines

### vLLM

```yaml
modelGroups:
  vllm-model:
    enabled: true
    image: vllm/vllm-openai
    tag: latest
    modelAlias:
      - "llama-3.1-8b"
    containerPort: 8000
    command:
      - "vllm"
      - "serve"
      - "--host"
      - "0.0.0.0"
      - "--port"
      - "8000"
      - "--model"
      - "meta-llama/Meta-Llama-3.1-8B-Instruct"
      - "--tensor-parallel-size"
      - "1"
```

### SGLang

```yaml
modelGroups:
  sglang-model:
    enabled: true
    image: lmsysorg/sglang
    tag: latest
    modelAlias:
      - "qwen-2.5-7b"
    containerPort: 30000
    command:
      - "python"
      - "-m"  
      - "sglang.launch_server"
      - "--model-path"
      - "Qwen/Qwen2.5-7B-Instruct"
      - "--host"
      - "0.0.0.0"
      - "--port"
      - "30000"
```

### TensorRT-LLM

```yaml
modelGroups:
  tensorrt-model:
    enabled: true
    image: nvcr.io/nvidia/tritonserver
    tag: 24.01-trtllm-python-py3
    modelAlias:
      - "mistral-7b"
    containerPort: 8001
    command:
      - "tritonserver"
      - "--model-repository=/models"
      - "--allow-http=true"
    # Model preparation init container
    initContainers:
      - name: model-converter
        image: nvcr.io/nvidia/tensorrt_llm/devel:latest
        command:
          - "sh"
          - "-c"
          - "echo 'Convert HuggingFace models to TensorRT-LLM format here'"
```

## Example Configurations

The `examples/` directory contains ready-to-use configurations:

- **`single-vllm.yaml`** - Single vLLM model deployment with persistent caching
- **`single-sglang.yaml`** - SGLang deployment optimized for structured generation  
- **`single-tensorrt-llm.yaml`** - TensorRT-LLM with model compilation init container
- **`multi-engine.yaml`** - Complete multi-engine setup (vLLM + SGLang + TensorRT-LLM)
- **`doubleword-production.yaml`** - Production configuration with embed + generate models

Use any example as a starting point:

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

## Configuration Reference

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full resource names | `""` |

### Onwards Gateway Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `onwards.replicaCount` | Number of Onwards replicas | `1` |
| `onwards.image.repository` | Onwards container image | `ghcr.io/doublewordai/onwards` |
| `onwards.image.tag` | Image tag | `latest` |
| `onwards.service.type` | Service type | `ClusterIP` |
| `onwards.service.port` | Service port | `80` |
| `onwards.containerPort` | Container port | `3000` |

### Model Group Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `modelGroups.<name>.enabled` | Enable this model group | `false` |
| `modelGroups.<name>.image` | Container image | `""` |
| `modelGroups.<name>.tag` | Image tag | `latest` |
| `modelGroups.<name>.modelAlias` | List of client-facing model aliases for API routing | `[]` |
| `modelGroups.<name>.modelName` | Actual model name/path | `""` |
| `modelGroups.<name>.containerPort` | Container port | `8000` |
| `modelGroups.<name>.resources` | Resource requests/limits | `{}` |
| `modelGroups.<name>.persistentVolumes` | List of persistent volumes | `[]` |
| `modelGroups.<name>.strategy` | Deployment update strategy | `{type: RollingUpdate}` |
| `modelGroups.<name>.command` | Container command and arguments | `[]` |

For a complete list of parameters, see [values.yaml](values.yaml).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `helm unittest . && helm lint .`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📚 [Documentation](https://github.com/doublewordai/inference-stack/wiki)
- 🐛 [Issue Tracker](https://github.com/doublewordai/inference-stack/issues)
- 💬 [Discussions](https://github.com/doublewordai/inference-stack/discussions)

## Related Projects

- [Onwards Gateway](https://github.com/doublewordai/onwards) - The upstream AI gateway project
- [vLLM](https://github.com/vllm-project/vllm) - High-throughput LLM serving
- [SGLang](https://github.com/sgl-project/sglang) - Structured generation language for LLMs
