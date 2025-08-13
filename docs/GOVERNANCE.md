# Governance & Naming Conventions

## Project Overview
**Project:** Cloud-Based Retail Sales Analytics & Forecasting System  
**Environment:** Development (`dev`)  
**Owner:** Haseeb  
**Goal:** Build an end-to-end retail analytics and forecasting platform using Azure cloud, SQL, Databricks, Data Factory, and Machine Learning services.

---

## Final Resource Names

| Resource Type         | Name                         | Notes |
|-----------------------|-----------------------------|-------|
| Resource Group        | rg-retail-analytics-dev     | Holds all dev environment resources |
| Storage Account (ADLS Gen2) | stretaildev                | Used for raw, processed, curated, and log data |
| Azure SQL Server      | sqlsrv-retail-dev           | Logical SQL server |
| Azure SQL Database    | sqldb-retail-dev            | Stores cleaned/processed retail data |
| Data Factory          | df-retail-dev               | For ETL pipelines (Blob → SQL) |
| Databricks Workspace  | dbw-retail-dev              | For big data processing, EDA, and model training |
| Azure ML Workspace    | aml-retail-dev              | For experiment tracking, model registry, and deployment |
| App Service           | app-retail-dev              | Hosts Streamlit app |
| App Service Plan      | plan-retail-dev             | Linux-based plan for the app |
| Key Vault (optional)  | kv-retail-dev (deleted)     | Removed due to student subscription admin restrictions |

---

## Region Choice
**Selected Region:** `centralindia`  
**Reasoning:**  
- Cheaper pricing compared to `uaenorth` (important for student subscription credits).  
- Still offers all required services (Blob, SQL, ADF, Databricks, AML).  
- Latency is acceptable for project work.

---

## Tag Structure
Tags applied to all resources for organization, cost tracking, and automation:
env=dev
owner=haseeb
project=retail-analytics
cost-center=personal

---


---

## Free-Tier Notes
- **Subscription:** Azure for Students  
- **Credits:** $100 free credits valid for 365 days (started on account creation date).  
- **Additional Free Services:** Certain SKUs and quotas for services like Azure SQL, App Service, and Blob Storage (within free tier limits).  
- **Limits & Restrictions:**
  - No access to some admin-level features (e.g., full Key Vault management).
  - Some VM sizes and premium SKUs unavailable in free subscription.
- **Cost Control Practices:**
  - Stop Databricks clusters when not in use.
  - Stop App Service when idle.
  - Use the smallest possible SKUs for dev work and scale up only when needed.

---

## Notes
- Resource names follow the pattern: `<resource-type>-<project-name>-<env>`.
- Environment separation (`dev`, later `prod`) is built into naming to avoid collisions.
- Secrets and credentials are stored locally in `.env` (gitignored) due to Key Vault restrictions.
