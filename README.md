# Salesforce Stabilization & Integration Demo

A technical demonstration project by **SENVORA Systems** focused on Salesforce engineering practices for integration reliability, asynchronous processing, testing, maintainability, and automated code quality.

This repository does not contain client code or production data.

---

## Overview

Salesforce environments often become difficult to maintain when integrations, asynchronous processing, UI components, and business logic evolve without clear technical boundaries.

This project demonstrates a small but structured Salesforce implementation designed around:

- Apex service separation
- Asynchronous Queueable processing
- External API integration patterns
- Named Credentials
- Lightning Web Components
- Apex unit testing
- LWC Jest testing
- Static code analysis
- Automated CI quality gates

The objective is not to reproduce a full enterprise implementation, but to demonstrate engineering practices that can be applied when reviewing, stabilizing, and evolving an existing Salesforce codebase.

---

## Architecture

```text
Account Record Page
        |
        v
LWC accountSyncPanel
        |
        v
AccountSyncController
        |
        v
AccountSyncQueueable
        |
        v
ExternalAccountService
        |
        v
Named Credential reference
External_Account_API
        |
        v
Environment-specific external endpoint
(not configured by this repository)
```

## Responsibilities

### `accountSyncPanel`

Lightning Web Component responsible for the user interaction. It:

- Receives the current Account record ID
- Submits the synchronization request
- Displays a loading state
- Reports successful queueing
- Handles Apex errors

### `AccountSyncController`

Thin Apex controller exposed to Lightning. It validates the Account ID and delegates processing to the asynchronous layer.

### `AccountSyncQueueable`

Queueable Apex implementation responsible for starting the outbound processing asynchronously and allowing HTTP callouts.

### `ExternalAccountService`

Integration service responsible for:

- Constructing the outbound request
- Serializing Salesforce data
- Using the expected Named Credential reference
- Processing the external response
- Handling unsuccessful HTTP responses

## Integration Design

The Apex source uses the Salesforce Named Credential pattern:

```text
callout:External_Account_API/accounts
```

`External_Account_API` is the Named Credential reference expected by the implementation. This demonstrates separation of endpoint and authentication configuration from Apex code; the repository does not provision or guarantee the Named Credential or its external endpoint.

The repository does not contain authentication secrets, tokens, production credentials, or external system credentials.

## Runtime Configuration

Deploying the source code alone is not sufficient for a live callout. Each target Salesforce environment must separately configure the expected Named Credential and authentication, and provide a compatible external endpoint.

The current reference/demo environment does not claim a configured live external Account API. Without the required runtime configuration, the controller can enqueue the asynchronous job and the job can start, but the external callout will fail. Successful end-to-end external synchronization is therefore not presented as a verified capability of this repository.

## Asynchronous Processing

The outbound callout workflow is queued using:

```apex
Queueable, Database.AllowsCallouts
```

This separates the user interaction from the external callout. Retry, monitoring, and orchestration mechanisms are not implemented by this reference project.

## Testing

### Apex

Using deterministic `HttpCalloutMock` responses, the Apex test suite currently validates:

- Successful callout-handling behavior for a mocked external response
- External server errors
- Invalid unsaved records
- Queueable execution
- Controller Queueable creation
- Invalid controller input

Current verified result:

```text
Tests Run: 6
Passed:    6
Failed:    0
Pass Rate: 100%
```

HTTP callout behavior is isolated using `HttpCalloutMock`; these tests do not verify a live external integration.

### Lightning Web Components

The LWC Jest suite validates:

- Submission of the current Account record ID
- Asynchronous loading state
- Successful queueing confirmation
- Apex error handling

Current verified result:

```text
Test Suites: 1 passed
Tests:       3 passed
Failures:    0
```

## Code Quality

The project uses multiple automated quality controls.

### ESLint

JavaScript and Lightning Web Component code is statically checked using Salesforce-compatible ESLint rules.

### Prettier

Source formatting is automatically normalized to maintain consistent code style.

### Salesforce Code Analyzer

Salesforce Code Analyzer is executed against the project as part of the engineering workflow.

Current quality gate:

```text
Critical / Sev1 findings: 0
High / Sev2 findings:     0
```

Moderate and low-severity findings can be reviewed separately without weakening the critical/high-severity gate.

### Pre-Commit Validation

Husky and lint-staged execute automated checks before commits are accepted.

The pre-commit workflow includes:

```text
Formatting
    |
    v
ESLint
    |
    v
Related LWC Jest Tests
    |
    v
Git Commit
```

This helps prevent known formatting, JavaScript quality, or LWC test failures from entering the repository.

## Continuous Integration

GitHub Actions runs the project's automated quality pipeline on changes to `main` and on pull requests.

The CI pipeline currently performs:

1. Repository checkout
2. Node.js setup
3. Java setup
4. Dependency installation
5. LWC Jest tests
6. Salesforce CLI installation
7. Salesforce Code Analyzer
8. Critical/high-severity quality gate

The pipeline fails when Code Analyzer reports:

```text
Sev1 > 0
or
Sev2 > 0
```

The current `main` branch passes the CI pipeline.

The current CI pipeline performs local/static quality validation. It does not authenticate to a Salesforce org or automatically deploy metadata.

## Project Structure

```text
force-app/
└── main/
    └── default/
        ├── classes/
        │   ├── AccountSyncController.cls
        │   ├── AccountSyncControllerTest.cls
        │   ├── AccountSyncQueueable.cls
        │   ├── AccountSyncQueueableTest.cls
        │   ├── ExternalAccountService.cls
        │   ├── ExternalAccountServiceMock.cls
        │   └── ExternalAccountServiceTest.cls
        └── lwc/
            └── accountSyncPanel/
                ├── accountSyncPanel.html
                ├── accountSyncPanel.js
                ├── accountSyncPanel.js-meta.xml
                └── __tests__/
                    └── accountSyncPanel.test.js
.github/
└── workflows/
    └── ci.yml
code-analyzer.yml
eslint.config.js
sfdx-project.json
```

## Running the Tests

### LWC Jest

```shell
sf force lightning lwc test run
```

### Apex Tests

After authenticating a Salesforce development org:

```shell
sf apex run test --test-level RunLocalTests --wait 10
```

### Code Analyzer

```shell
sf code-analyzer run --workspace force-app --view detail
```

### Pre-Commit Quality Checks

```shell
npm run precommit
```

## Engineering Decisions

### Thin controller

The Lightning controller contains minimal business logic and delegates processing to dedicated classes.

### Service separation

External communication is isolated from the UI and asynchronous orchestration layers.

### Named Credentials

The source code references `External_Account_API`; each target environment must provide the corresponding endpoint and authentication configuration separately.

### Queueable Apex

Callouts are removed from the synchronous UI interaction.

### Mocked callouts

Tests do not depend on live external services.

### Automated quality gates

Formatting, linting, testing, and static analysis are part of the development workflow rather than manual final checks.

## Scope

This repository is intentionally small. It is a reference implementation demonstrating maintainable Salesforce integration architecture and engineering practices, not a production integration platform.

A production implementation could additionally require areas such as:

- Integration observability
- Structured logging
- Retry policies
- Idempotency controls
- Dead-letter handling
- Deployment environments
- Permission architecture
- Production authentication configuration
- Operational monitoring

Those concerns should be introduced when justified by the requirements rather than added prematurely.

## About SENVORA Systems

SENVORA Systems is a B2B technology consultancy focused on enterprise technology consulting, Salesforce, enterprise architecture, systems integration, cloud infrastructure, data, and applied AI.

The company focuses on clear architecture, maintainable systems, and reducing operational and technical risk.

## Disclaimer

This is an independent demonstration project created for technical portfolio purposes. It:

- Contains no client proprietary code
- Contains no production customer data
- Contains no production credentials
- Does not represent a completed client engagement
- Is not affiliated with or endorsed by Salesforce

Salesforce and related marks are trademarks of Salesforce, Inc.
