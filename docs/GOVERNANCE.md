# Cloud Retail – Governance

This document codifies region choice, environments, naming rules, tags, and baseline guardrails for the **Cloud Retail** project.

---

## 1) Region

**Primary:** `uaenorth`  
**Fallback:** `centralindia`

**Why `uaenorth`:**
- Low latency to your VPS and target users.
- All required services available (Storage/ADLS Gen2, Azure SQL, Data Factory, Databricks, Azure ML, App Service).
- Good capacity and quota profile.

Use the fallback only if capacity or service constraints arise.

---

## 2) Environments

- **dev** (current): iterative work, relaxed networking, cost-optimized SKUs
- **prod** (later): locked-down networking, approved SKUs, stricter RBAC

Environment separation:
- Separate resource groups per environment.
- Optionally separate subscriptions if needed later.

---

## 3) Naming Rules

**Style:** lowercase, short tokens, hyphens where allowed.

**Tokens**
- `{proj}` = `retail`
- `{env}` = `dev` or `prod`
- `{nn}` = 2-char uniqueness suffix when needed (e.g., `01`, `a1`)

### Standard Patterns

| Resource Type          | Pattern (example)                 | Constraints / Notes |
|---|---|---|
| Resource Group         | `rg-{proj}-{env}` → `rg-retail-dev` | Letters, numbers, hyphens. |
| Storage Account (ADLS) | `st{proj}{env}{nn}` → `stretaildev01` | **No hyphens**, 3–24 chars, lowercase, globally unique. Enable hierarchical namespace. |
| Data Lake Containers   | `raw`, `processed`, `curated`, `models` | Lowercase simple names. |
| Key Vault              | `kv-{proj}-{env}` → `kv-retail-dev` | 3–24 chars, alnum + hyphens, start with letter. |
| Azure SQL Server       | `sqlsrv-{proj}-{env}` → `sqlsrv-retail-dev` | 3–63 chars, unique in region. |
| Azure SQL Database     | `sqldb-{proj}-{env}` → `sqldb-retail-dev` | 1–128 chars. |
| Data Factory           | `df-{proj}-{env}` → `df-retail-dev` | 3–63 chars, letters, numbers, hyphens. |
| Databricks Workspace   | `dbw-{proj}-{env}` → `dbw-retail-dev` | 3–30 chars. |
| Azure ML Workspace     | `aml-{proj}-{env}` → `aml-retail-dev` | 3–33 chars, lowercase, hyphens. |
| App Service Plan       | `asp-{proj}-{env}` → `asp-retail-dev` | 1–40 chars. |
| Web App (Streamlit)    | `app-{proj}-{env}{nn}` → `app-retail-dev01` | Globally unique DNS; add `{nn}` if needed. |
| Log Analytics          | `law-{proj}-{env}` → `law-retail-dev` | 4–63 chars. |

**General rules**
- Prefer the same `{proj}` and `{env}` across all resources.
- Append `{nn}` only when a global-name collision occurs.
- Keep names stable; avoid renames after creation.

---

## 4) Tags (Apply at Resource Group and inherit)

**Standard set**
- `env`: `dev` or `prod`
- `owner`: `haseeb`
- `project`: `retail`
- `cost-center`: `personal`

**Example**
env=dev
owner=haseeb
project=retail
cost-center=personal

yaml
Copy
Edit

Tagging policy
- Required at RG creation; verify inheritance on child resources.
- Do not remove standard tags. You may add module-specific tags if needed (e.g., `component=etl`).

---

## 5) Identity & Access (RBAC)

- Prefer **Managed Identities (MI)** for services.
- **Principles**
  - Least privilege; grant only required data roles.
  - Use AAD groups where possible.
- **Baseline grants**
  - ADF MI → Storage: **Storage Blob Data Contributor** on needed containers.
  - ADF MI → SQL: scoped database role/user (reader/writer as needed).
  - Databricks MI → Storage: **Storage Blob Data Contributor** on lake containers.
  - App Service MI (later) → SQL/Storage per app needs.
  - Human admins: Contributor on RG (setup only), then reduce.

---

## 6) Secrets & Key Vault

Vault: `kv-retail-{env}`

- **Enable** soft delete + purge protection.
- Store:
  - SQL admin (if used), connection strings
  - Service principal creds (if any)
  - External API keys
- Access:
  - Grant **Key Vault Secrets User/Reader** to MIs that must read secrets.
- Use **Key Vault references** for App Service settings.

---

## 7) Networking (baseline for dev)

- Start with public endpoints + firewall allowlists.
- Azure SQL:
  - Set AAD admin.
  - Allow Azure services; IP-allow your dev IP.
- Storage:
  - Public endpoint OK for dev; consider private endpoints for prod.
- Plan for Private Endpoints + VNets in prod.

---

## 8) Monitoring & Logs

- Create **Log Analytics Workspace**: `law-{proj}-{env}`.
- Enable **Diagnostic Settings** to LAW for:
  - Storage, SQL, Data Factory, Databricks, Key Vault, App Service
- Minimum retention: 30 days in dev, 90 days in prod.
- Define alert rules for:
  - ADF pipeline failures
  - Databricks job failures
  - SQL DTU/CPU high
  - Storage throttling

---

## 9) Cost Management

- Create a **Budget** on the RG with email alerts (e.g., 50/80/100%).
- Prefer dev SKUs (Basic/Serverless where appropriate).
- Auto-stop Databricks clusters; use small node types in dev.

---

## 10) Change Control

- Changes to this document require a PR in the repo.
- Record **what/why** in PR description.
- Version this doc with semantic headings; add a changelog section if changes are frequent.

---

## 11) Quick Variable Map (for scripts)

REGION="uaenorth"
PROJECT="retail"
ENV="dev"

RG="rg-${PROJECT}-${ENV}"
STORAGE="st${PROJECT}${ENV}01"
KEYVAULT="kv-${PROJECT}-${ENV}"
DATAFACTORY="df-${PROJECT}-${ENV}"
DATABRICKS="dbw-${PROJECT}-${ENV}"
AML="aml-${PROJECT}-${ENV}"
SQLSRV="sqlsrv-${PROJECT}-${ENV}"
SQLDB="sqldb-${PROJECT}-${ENV}"
APPPLAN="asp-${PROJECT}-${ENV}"
WEBAPP="app-${PROJECT}-${ENV}01"
LOGANALYTICS="law-${PROJECT}-${ENV}"

Tags
TAG_ENV="env=${ENV}"
TAG_OWNER="owner=haseeb"
TAG_PROJECT="project=${PROJECT}"
TAG_CC="cost-center=personal"
