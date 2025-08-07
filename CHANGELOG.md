# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 07-08-2025

### Added

- Initial release of the Inference Stack Helm Chart
- Support for Onwards AI Gateway deployment
- Configurable model groups for multiple inference engines
- Support for vLLM, SGLang, and TensorRT-LLM
- Auto-scaling with Horizontal Pod Autoscaler
- Persistent storage for model caching
- Ingress support for external access
- Comprehensive unit tests with helm-unittest
- CI/CD pipeline with GitHub Actions
- Automated releases with release-please
- Security scanning with Checkov
- Helm chart linting and validation

### Features

- **Multi-engine Support**: Deploy multiple inference engines simultaneously
- **Transparent Routing**: Human-readable model names mapped to backend services  
- **GPU Support**: Full GPU resource management and node selection
- **Production Ready**: Health checks, resource limits, security contexts
- **Monitoring**: Prometheus metrics and observability support

[Unreleased]: https://github.com/your-org/inference-stack/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/your-org/inference-stack/releases/tag/v0.1.0
