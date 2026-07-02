Go-Core Template CI/CD 
================================================================

> [Aeon Digital](http://www.aeondigital.com.br)  
> rianna@aeondigital.com.br

&nbsp;

> Centralizes and standardizes the Continuous Integration (CI) and Continuous Delivery (CD) automation pipelines for our Go-Core ecosystem libs and applications.

The primary objective is to ensure that security enhancements, code quality validations (linters), and build automation optimizations are instantly propagated to all consuming downstream projects without duplicating workflow files.


&nbsp;
&nbsp;


________________________________________________________________________________

## 2. REPOSITORY GOVERNANCE & SCOPE MATRIX

To maintain a scalable and organized ecosystem as new technologies and engineering groups emerge, we enforce a strict repository naming convention across the organization.


&nbsp;


| Category | Naming Pattern | Example | Description |
| :--- | :--- | :--- | :--- |
| **Governance** | `[tech]-[group]-template-[type]` | `[tech]-[group]-template-ci-cd` <br> `[tech]-[group]-template-docs` | Base infrastructure, reusable workflows, and architectural guidelines. |
| **Applications** | `[tech]-[group]-app-[name]` | `[tech]-[group]-app-order-api` | End-user applications, APIs, workers, or microservices that generate executables. |
| **Libraries** | `[tech]-[group]-lib-[name]` | `[tech]-[group]-lib-logger` | Shared internal code packages imported as dependencies by application projects. |


&nbsp;
&nbsp;


________________________________________________________________________________

## 3. HOW TO CONSUME THIS CI/CD TEMPLATE

Application repositories (`*-app-*`) must not contain complex execution logic inside their local workflow directories. Instead, they must reference the centralized Reusable Workflows hosted in this repository.


&nbsp;


### 3.1 Initial Integration Setup

To link a downstream project to this centralized pipeline engine, create a standard configuration file within the target repository.

&nbsp;

#### Configuration File Path:

```text
.github/workflows/main.yml
```

&nbsp;

#### File Content Blueprint:
```yaml
name: Executable Pipeline

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  central-pipeline:
    # Syntax: org-or-user/repository-name/.github/workflows/filename.yml@branch-or-tag
    uses: <YOUR_ORGANIZATION_OR_USER>/Go-Core-Template-CI-CD/.github/workflows/ci-cd.yaml@main
```


&nbsp;
&nbsp;


________________________________________________________________________________

## 4. AVAILABLE WORKFLOW ENGINES

This central hub manages multiple technical pipelines designed to dynamically match specific downstream project requirements.


&nbsp;


### 4.1 Base Tech Validation Pipeline (`.github/workflows/ci-cd-<TECH>.yml`)

This reusable engine automatically triggers on every Push or Pull Request from consuming repositories.

&nbsp;

#### Execution Steps:

* Executes automated workspace isolation and repository checkout.
* Configures the exact target language runtime ecosystem environment version.
* Inject dynamic global configuration blueprints (e.g., linter rule sheets).
* Triggers automated test suites and validation modules natively.
* Verifies compilation validity by executing a standard package build test.


&nbsp;
&nbsp;


________________________________________________________________________________

## 5. PROPAGATING GLOBAL UPDATES

Modifications made to this centralized blueprint repository automatically apply to the entire downstream ecosystem.


&nbsp;


### 5.1 The Update Lifecycle Workflow

When a security rule, linter standard, or build optimization is merged into this repository:
* Stage the modification inside a dedicated feature branch.
* Submit a formal Pull Request targeting the `main` branch.
* Once merged into `main`, **all downstream ecosystem applications using this engine inherit the updates instantly** on their next execution trigger.
