# Contributing

The spirit of this project is to produce a framework that solves distributed serving of LLMs in a non-specific way to the inference engine running the weights. All features should be implemented with this in mind.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/inference-stack.git`
3. Install [Helm](https://helm.sh/docs/intro/install/) and [helm-unittest](https://github.com/helm-unittest/helm-unittest)

## Making Changes

1. Create a feature branch: `git checkout -b feature-name`
2. Make your changes to templates, values, or examples
3. Test your changes:

   ```bash
   helm lint .
   helm unittest .
   helm template test-release . --values examples/single-vllm.yaml
   ```

4. Update tests if needed
5. Commit with conventional commits: `feat:`, `fix:`, `docs:`, etc.

## Submitting

1. Push your branch: `git push origin feature-name`
2. Create a Pull Request with:
   - Clear description of changes
   - Test results showing lint and unittest pass
   - Example usage if adding new features

## Project Structure

- `templates/` - Helm templates
- `examples/` - Example values files
- `tests/` - Unit tests
- `values.yaml` - Default configuration

## Need Help?

Open an issue for questions or feature requests. Reach out at: <hello@doubleword.ai>!
