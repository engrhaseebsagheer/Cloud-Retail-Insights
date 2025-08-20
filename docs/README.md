# Cloud-Based Retail Sales Analytics & Forecasting System

## 📌 Project Overview

This project builds an **end-to-end cloud-based retail sales analytics and forecasting platform** using Microsoft Azure, SQL, Data Factory, and Azure Machine Learning.
It covers the **full data lifecycle** — from ingestion and processing to machine learning model deployment and visualization.

The goal is to replicate **real-world enterprise architecture** while applying **data science and ML concepts**, including:

* Data ingestion and ETL
* Exploratory Data Analysis (EDA)
* Feature engineering
* Regression and forecasting models
* Cloud deployment
* KPI dashboards

---

## 📂 Project Progress

### ✅ Day 1 — Setup & Provisioning

* Created **Azure Student Account** using university email (\$100 credits and free services).
* Installed and configured **Azure CLI** on macOS.
* Initialized **GitHub repository** with `.gitignore` for secrets.
* Chose **Region:** `centralindia` (cheaper, still supports all services needed).
* Defined **naming conventions** and **tags** for resources.

**Azure Resources Created:**

* **Resource Group:** `rg-retail-analytics-dev`
* **Storage Account (ADLS Gen2):** `stretaildev` with containers: `raw/`, `processed/`, `curated/`, `logs/`
* **Azure SQL Server:** `sqlsrv-retail-dev`
* **Azure SQL Database:** `sqldb-retail-dev`
* **Azure Data Factory:** `df-retail-dev`
* **Azure Machine Learning Workspace:** `aml-retail-dev`
* **Key Vault:** Created but deleted due to subscription restrictions. Secrets stored locally in `.env` (gitignored).

---

### ✅ Day 2 — Data Ingestion Setup

* Connected **Blob Storage** and **SQL Database** to Azure Data Factory (ADF).
* Created ADF **datasets** for Blob (CSV input) and SQL (table output).
* Built first **pipeline** to load CSV data from Blob → SQL staging tables.
* Added **pre-script** to clear staging before load:

  ```sql
  TRUNCATE TABLE dbo.stg_sales;
  ```
* Configured **trigger** for daily automated refresh (simulated retail data arrival).
* Tested and validated pipeline runs successfully.

---

### ✅ Day 3 — SQL & Table Setup

* Created **SQL tables** in Azure SQL Database (`sqldb-retail-dev`) for staging and fact tables.
* Implemented schema in `sql/create_tables.sql` for **fact\_sales** and related dimensions.
* Validated ingestion by loading Kaggle dataset rows into staging table.

---

### ✅ Day 4 — Feature Engineering & ML Models

* Extracted dataset from SQL into local environment.
* Performed **feature engineering**:

  * Created date-based features (year, quarter, month, week, weekend flag).
  * Added categorical encodings for regions and month names.
* Built two modeling tasks:

  * **Forecasting (Regression):** ElasticNet, Random Forest, Gradient Boosting

    * Best: **ElasticNet** (lowest error)
  * **Classification:** Logistic Regression, Random Forest

    * Best: **Random Forest** (F1 = 0.235)
* Saved models, metrics, and plots locally under `notebooks/models/` and `notebooks/reports/`.

---

## 📦 Tech Stack

* **Cloud Platform:** Microsoft Azure
* **Storage:** Azure Blob Storage (ADLS Gen2)
* **ETL & Orchestration:** Azure Data Factory
* **Database:** Azure SQL Database
* **Machine Learning:** Azure ML Workspace (planned for model registry & deployment)
* **Version Control:** Git + GitHub
* **Visualization (planned):** Power BI, Streamlit (Azure App Service)

---

## 📜 Notes

* Databricks removed due to subscription issues — SQL + Python used instead.
* App Service not yet created — planned for Streamlit deployment.
* Secrets and credentials managed locally in `.env` (gitignored).
* Key Vault restricted under student subscription.

---

## 🚀 Next Steps

* Register trained models in Azure ML workspace.
* Deploy REST API endpoint for prediction.
* Build Power BI dashboards.
* Deploy Streamlit web app on Azure App Service for visualization.
