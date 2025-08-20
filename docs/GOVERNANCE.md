# Governance & Naming Conventions (Updated)

## Project Overview

**Project:** Cloud-Based Retail Sales Analytics & Forecasting System
**Environment:** Development (`dev`)
**Owner:** Haseeb
**Goal:** Build an end-to-end retail analytics and forecasting platform using Azure cloud, SQL, Data Factory, and Machine Learning services.

---

## Final Resource Names

| Resource Type               | Name                     | Notes                                                    |
| --------------------------- | ------------------------ | -------------------------------------------------------- |
| Resource Group              | rg-retail-analytics-dev  | Holds all dev environment resources                      |
| Storage Account (ADLS Gen2) | stretaildev              | Stores raw, processed, curated, and log data             |
| Azure SQL Server            | sqlsrv-retail-dev        | Logical SQL server                                       |
| Azure SQL Database          | sqldb-retail-dev         | Stores cleaned/processed retail data                     |
| Data Factory                | df-retail-dev            | For ETL pipelines (Blob → SQL)                           |
| ~~Databricks Workspace~~    | dbw-retail-dev (dropped) | Removed due to CPU quota restrictions on student account |
| Azure ML Workspace          | aml-retail-dev           | For experiment tracking, model registry, and deployment  |
| App Service                 | app-retail-dev           | Hosts Streamlit app                                      |
| App Service Plan            | plan-retail-dev          | Linux-based plan for the app                             |
| Key Vault (optional)        | kv-retail-dev (deleted)  | Removed due to subscription admin restrictions           |

---

## Region Choice

**Selected Region:** `centralindia`
**Reasoning:**

* Cheaper pricing compared to `uaenorth` (important for student subscription credits).
* Still offers required services (Blob, SQL, ADF, AML).
* Latency is acceptable for project workload.

---

## Tag Structure

Applied consistently across resources for organization, cost tracking, and automation:

```
env=dev
owner=haseeb
project=retail-analytics
cost-center=personal
```

---

## Free-Tier Notes

* **Subscription:** Azure for Students
* **Credits:** \$100 free credits valid for 365 days.
* **Additional Free Services:** Certain SKUs and quotas for Azure SQL, App Service, and Blob Storage (within free tier limits).
* **Limits & Restrictions:**

  * Some advanced features (e.g., Key Vault secrets, higher CPU quotas) unavailable.
  * Databricks cannot be used due to CPU quota restrictions.
  * Limited VM sizes and premium SKUs.
* **Cost Control Practices:**

  * Stop App Service when idle.
  * Use smallest possible SKUs for dev.
  * Prefer SQL-based processing instead of Databricks (quota limitation workaround).

---

## Notes

* Resource names follow the pattern: `<resource-type>-<project-name>-<env>`.
* Environment separation (`dev`, later `prod`) avoids collisions.
* Secrets and credentials are stored locally in `.env` (gitignored) due to Key Vault restrictions.
* Architecture updated to use **Azure SQL + Python notebooks** for data processing instead of Databricks.
