# Cloud-Based Retail Sales Analytics & Forecasting System

## 📌 Project Overview
<<<<<<< HEAD
This project aims to build an **end-to-end cloud-based retail sales analytics and forecasting platform** using Microsoft Azure, SQL, Databricks, Data Factory, and Azure Machine Learning.  
It will cover the **full data lifecycle** — from ingestion and processing to machine learning model deployment and visualization.

The goal is to replicate **real-world enterprise architecture** while applying **data science and ML concepts** such as:
- Data ingestion and ETL
- Exploratory Data Analysis (EDA)
- Feature engineering
- Regression and classification modeling
=======
This project builds an **end-to-end cloud-based retail sales analytics and forecasting platform** using Microsoft Azure, SQL, Databricks, Data Factory, and Azure Machine Learning.  
It covers the **full data lifecycle** — from ingestion and processing to machine learning model deployment and visualization.

The goal is to replicate **real-world enterprise architecture** while applying **data science and ML concepts**, including:
- Data ingestion and ETL
- Exploratory Data Analysis (EDA)
- Feature engineering
- Regression and forecasting models
>>>>>>> 75e4310 (Day 2: Implemented data ingestion pipeline)
- Cloud deployment
- KPI dashboards

---

<<<<<<< HEAD
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
=======
## 📂 Project Progress

### ✅ Day 1 — Setup & Provisioning
- Created **Azure Student Account** using university email (with $100 credits and free services).
- Installed and configured **Azure CLI** on macOS using Homebrew.
- Logged in with `az login` and set subscription for project scope.
- Initialized **GitHub repository** with `.gitignore` for secrets.  
- Created a working directory on macOS for the project.  

**Resource Naming Conventions:**
- Region: `centralindia` (chosen over `uaenorth` for cost efficiency).  
- Project: `retail-analytics`  
- Environment: `dev`  
- Tags applied to all resources:
  - `env=dev`
  - `owner=haseeb`
  - `project=retail-analytics`
  - `cost-center=personal`

**Azure Resources Created (via CLI & Portal):**
- **Resource Group:** `rg-retail-analytics-dev`
- **Storage Account (ADLS Gen2):** `stretaildev`  
  - Containers: `raw/`, `processed/`, `curated/`, `logs/`
>>>>>>> 75e4310 (Day 2: Implemented data ingestion pipeline)
- **Azure SQL Server:** `sqlsrv-retail-dev`
- **Azure SQL Database:** `sqldb-retail-dev`
- **Azure Data Factory:** `df-retail-dev`
- **Azure Databricks Workspace:** `dbw-retail-dev`
- **Azure Machine Learning Workspace:** `aml-retail-dev`
<<<<<<< HEAD
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
=======
- **Key Vault:** Created but later deleted due to student subscription restrictions.  
  - Secrets stored locally in `.env` (gitignored).

**Notes:**
- Tested storage account availability before creation.
- Successfully created blob containers (`raw`, `processed`, `curated`, `logs`).

⏱ Time invested: ~5 hours (as a beginner to Azure services).

---

### 🚫 Day 2
- Missed due to personal issues.  

---

### ✅ Day 3 — SQL & Data Factory Setup
- Created multiple **SQL tables** in Azure SQL Database (`sqldb-retail-dev`) using `sql/create_tables.sql`.  
  Example schema:
  ```sql
  CREATE TABLE fact_sales (
      SalesID INT IDENTITY PRIMARY KEY,
      OrderID NVARCHAR(50),
      CustomerID NVARCHAR(50),
      ProductID NVARCHAR(50),
      Region NVARCHAR(50),
      OrderDate DATE,
      ShipDate DATE,
      Sales FLOAT,
      Quantity INT,
      Discount FLOAT,
      Profit FLOAT
  );
  ```

- Connected **Blob Storage** and **SQL Database** to Azure Data Factory (ADF).  
- Created and published ADF **datasets** for Blob (CSV input) and SQL (table output).  
- Built first **pipeline** to load CSV data from Blob → SQL staging tables.  
- Added **pre-script** in pipeline sink tab:
  ```sql
  TRUNCATE TABLE dbo.stg_sales;
  ```
  Ensures fresh reload each run (avoiding duplicates from appended data).  

- Configured **trigger (schedule)** for daily automated refresh (simulating daily retail data arrival).  
- Pipeline tested and monitored — runs successfully.  

---

## 🏷 Resource Tagging Structure
Tags applied across all resources for cost and ownership tracking:
- `env=dev`
- `owner=haseeb`
- `project=retail-analytics`
- `cost-center=personal`
>>>>>>> 75e4310 (Day 2: Implemented data ingestion pipeline)

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
<<<<<<< HEAD
- No Databricks compute cluster created yet — will be provisioned during ETL/ML phases.
- No App Service created yet — will be provisioned for Streamlit deployment in the final phase.
- Secrets and credentials stored locally in `.env` and excluded from version control.
=======
- Databricks and AML created via portal (CLI caused issues).  
- No Databricks cluster created yet (to be provisioned during ETL/ML phases).  
- No App Service created yet — planned for final Streamlit deployment.  
- Key Vault deleted due to subscription restrictions. Secrets managed via `.env` (excluded from Git).  
- GitHub updated with latest code and SQL files.  

---

## 🚀 Next Steps
- Upload Kaggle Superstore dataset to `raw/` container in Blob Storage.
- Extend ADF pipelines for **processed** and **curated** zones.  
- Implement Databricks notebooks for ETL, feature engineering, and ML model training.  
- Register trained model in Azure ML, deploy REST API endpoint.  
- Build Power BI dashboard & Streamlit web app for visualization.  
>>>>>>> 75e4310 (Day 2: Implemented data ingestion pipeline)
