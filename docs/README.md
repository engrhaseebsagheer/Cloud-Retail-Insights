# Cloud-Based Retail Sales Analytics & Forecasting System

## 📌 Project Overview
This project aims to build an **end-to-end cloud-based retail sales analytics and forecasting platform** using Microsoft Azure, SQL, Databricks, Data Factory, and Azure Machine Learning.  
It will cover the **full data lifecycle** — from ingestion and processing to machine learning model deployment and visualization.

The goal is to replicate **real-world enterprise architecture** while applying **data science and ML concepts** such as:
- Data ingestion and ETL
- Exploratory Data Analysis (EDA)
- Feature engineering
- Regression and classification modeling
- Cloud deployment
- KPI dashboards

---

## 📂 Current Project Status — Day 1 (Setup & Provisioning)
### ✅ Completed
- Created **Azure Student Account** with $100 free credits for 12 months.
- Installed and configured **Azure CLI** on macOS.
- Initialized **GitHub repository** and `.gitignore` for Python and secrets.
- Chose **Region:** `centralindia` (cheaper, still supports all services needed).
- Defined **naming conventions** and **tags** for resources.

### 🏗 Azure Resources Created
- **Resource Group:** `rg-retail-analytics-dev`
- **Storage Account (ADLS Gen2):** `stretaildev` with containers:
  - `raw/`
  - `processed/`
  - `curated/`
  - `logs/`
- **Azure SQL Server:** `sqlsrv-retail-dev`
- **Azure SQL Database:** `sqldb-retail-dev`
- **Azure Data Factory:** `df-retail-dev`
- **Azure Databricks Workspace:** `dbw-retail-dev`
- **Azure Machine Learning Workspace:** `aml-retail-dev`
- **Key Vault:** Created but deleted due to student subscription restrictions — secrets stored locally in `.env` (gitignored).

---

## 🎯 Next Steps (Day 2 Plan)
- Upload Kaggle dataset to Blob Storage (`raw/`).
- Create ADF linked services for Blob and SQL.
- Build and run first ETL pipeline (Blob → SQL staging).
- Create initial SQL staging tables.

---

## 🏷 Tag Structure
Applied to all Azure resources:
env=dev
owner=haseeb
project=retail-analytics
cost-center=personal

---

## 📦 Tech Stack
- **Cloud Platform:** Microsoft Azure
- **Storage:** Azure Blob Storage (ADLS Gen2)
- **ETL & Orchestration:** Azure Data Factory
- **Big Data Processing:** Azure Databricks (PySpark, Spark MLlib)
- **Database:** Azure SQL Database
- **Machine Learning:** Azure ML Workspace
- **Version Control:** Git + GitHub
- **Visualization (planned):** Power BI, Streamlit (Azure App Service)

---

## 📜 Notes
- No Databricks compute cluster created yet — will be provisioned during ETL/ML phases.
- No App Service created yet — will be provisioned for Streamlit deployment in the final phase.
- Secrets and credentials stored locally in `.env` and excluded from version control.
