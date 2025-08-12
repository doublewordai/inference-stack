# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0](https://github.com/doublewordai/inference-stack/compare/v0.3.0...v0.4.0) (2025-08-12)


### Features

* convert from deployments to statefulsets for model groups ([05fb5fd](https://github.com/doublewordai/inference-stack/commit/05fb5fd46f2eec2635b27c7eef7495ba6a3ae452))


### Bug Fixes

* revert back to deployments with more transparent configuration ([1f1bc5e](https://github.com/doublewordai/inference-stack/commit/1f1bc5e6c54450f36f600ff22baa76e6d748a460))

## [0.3.0](https://github.com/doublewordai/inference-stack/compare/v0.2.4...v0.3.0) (2025-08-11)


### Features

* add startup probe to inference-stack chart ([94a1543](https://github.com/doublewordai/inference-stack/commit/94a1543a8be491afabcd6dba22e3a56ee1fd83ed))

## [0.2.4](https://github.com/doublewordai/inference-stack/compare/v0.2.3...v0.2.4) (2025-08-11)


### Bug Fixes

* add startup probe to inference-stack chart to reduce cold start time ([fc7b205](https://github.com/doublewordai/inference-stack/commit/fc7b20512859f34b46b4cb062362630fbc2c414e))

## [0.2.3](https://github.com/doublewordai/inference-stack/compare/v0.2.2...v0.2.3) (2025-08-11)


### Bug Fixes

* add release token and helm package from correct directory ([da00a4b](https://github.com/doublewordai/inference-stack/commit/da00a4b12ba056b4104dc960b022e817cfe258c1))

## [0.2.2](https://github.com/doublewordai/inference-stack/compare/v0.2.1...v0.2.2) (2025-08-11)


### Bug Fixes

* release main ([a2cbc9d](https://github.com/doublewordai/inference-stack/commit/a2cbc9dc8a94407ea14d4fec65e94ce6805eb74c))

## [0.2.1](https://github.com/doublewordai/inference-stack/compare/v0.2.0...v0.2.1) (2025-08-08)


### Bug Fixes

* trigger release-please for workflow testing ([14de0e5](https://github.com/doublewordai/inference-stack/commit/14de0e566b80576b6daf7cb840ee07a95e252b72))

## [0.2.0](https://github.com/doublewordai/inference-stack/compare/v0.1.0...v0.2.0) (2025-08-08)


### Features

* add network policies for onwards and modelgroup ([e50835e](https://github.com/doublewordai/inference-stack/commit/e50835e7663bbb9cd942fb78a3f254774ecc8a6d))

## [0.1.0](https://github.com/doublewordai/inference-stack/compare/v0.1.0...v0.1.0) (2025-08-08)


### Features

* v0.1.0 release of inference-stack chart ([aecded8](https://github.com/doublewordai/inference-stack/commit/aecded852160b6626e6927bb6fca5ee2d2cd26ef))


### Bug Fixes

* fixing CI to run tests and linting ([cf7c67c](https://github.com/doublewordai/inference-stack/commit/cf7c67c7292aee3a65a88f19aaea8614554f0d3f))


### Miscellaneous

* increase default initialDelaySeconds for health checks ([2c6a042](https://github.com/doublewordai/inference-stack/commit/2c6a042d4186b73b4b3072584839eab5a3068444))
* separate helm release from release please ([1b4e4b6](https://github.com/doublewordai/inference-stack/commit/1b4e4b6172acfbe1575419ba0ee28a06b9f75edd))
* trigger release please ([0514e29](https://github.com/doublewordai/inference-stack/commit/0514e29e4f274816544dc49151ca3203e37269fc))
