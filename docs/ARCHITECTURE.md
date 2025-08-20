# Architecture (Dev)

High-level dataflow and components reflecting the **current** implementation (updated through **Day 4**).

---

## 1) High-level Dataflow (as-built)

```mermaid
flowchart LR
  subgraph Kaggle
    K[Superstore CSV (~9.8k rows)]
  end

  subgraph Azure_Storage
    R[(Blob: raw/)]
  end

  subgraph ADF[Azure Data Factory]
    ADFcopy[Pipeline: pl_ingest_sales\nCopy: Blob→SQL (staging)\nTrigger: manual (daily trigger planned)]
  end

  subgraph SQL[Azure SQL Database: sqldb-*-dev]
    STG[(dbo.stg_sales)]
    DIMC[(dbo.dim_customer)]
    DIMP[(dbo.dim_product)]
    DIMR[(dbo.dim_region)]
    FACT[(dbo.fact_sales)]
  end

  subgraph Local[Local Laptop]
    NB02[nbs: 02_data_processing.ipynb \n(Pandas ETL)]
    NB03[nbs: 03_eda.ipynb]
    NB04[nbs: 04_modeling.ipynb]
    MODELS[(models/*.pkl)]
    REPORTS[(reports/*.json, *.png)]
  end

  K -->|manual download| R
  R -->|ADF Copy| STG
  STG -->|read via SQLAlchemy| NB02
  NB02 -->|pandas clean/derive| DIMC
  NB02 -->|truncate+insert| DIMP
  NB02 -->|truncate+insert| DIMR
  NB02 -->|truncate+insert| FACT
  FACT -->|read| NB03
  FACT -->|read| NB04
  NB04 --> MODELS
  NB04 --> REPORTS
```

**Notes**

* Day 3 moved ETL to **pandas** (local) → SQL-side transforms were intentionally avoided to reduce friction.
* Databricks is **not used** due to compute constraints. All notebooks run locally.
* No Python-side uploads to Blob in Day 4 (local-only artifacts). ADF remains the only ingestion into SQL.

---

## 2) Cloud Resources (status)

| Layer            | Resource            | Name (dev)                               | Status                                                           |
| ---------------- | ------------------- | ---------------------------------------- | ---------------------------------------------------------------- |
| Subscription     | Azure Student       | —                                        | Active                                                           |
| Resource Group   | RG                  | `rg-retail-analytics-dev`                | Created                                                          |
| Storage          | Blob Storage        | `stretaildev`                            | Created (containers: `raw/`, `processed/`, `curated/`, `logs/`)  |
| Data Ingestion   | Azure Data Factory  | `df-retail-dev`                          | Created; pipeline **pl\_ingest\_sales** working (manual trigger) |
| Database         | Azure SQL Server/DB | `sqlsrv-retail-dev` / `sqldb-retail-dev` | Created; tables present                                          |
| Compute (ML/ETL) | Databricks          | `dbw-retail-dev`                         | **Not used** (insufficient quota). Replaced by local notebooks   |
| ML Ops           | Azure ML            | `aml-retail-dev`                         | Workspace created; **not used yet** (Day 5)                      |
| Secrets          | Key Vault           | `kv-retail-dev`                          | Not used (permissions). Using local `.env` (gitignored)          |

---

## 3) Data Model (Star Schema as implemented)

**Dimensions**

* `dbo.dim_customer(CustomerID PK, CustomerName, Segment)`
* `dbo.dim_product(ProductID PK, Category, SubCategory, ProductName)`
* `dbo.dim_region(Region PK)`

**Fact**

* `dbo.fact_sales(SalesID IDENTITY PK, OrderID, CustomerID, ProductID, Region, OrderDate, ShipDate, Sales)`

**Derived fields (in local ETL, not persisted as columns unless needed)**

* From `OrderDate`: `OrderYear`, `OrderMonth`, `OrderQuarter`, `OrderWeekOfYear`, `OrderMonthName`, `OrderIsWeekendOrder`, `OrderYearMonth`
* From `ShipDate`: `ShipYear`, `ShipMonth`, `ShipQuarter`, `ShipWeekOfYear`, `ShipMonthName`, `ShipIsWeekendShip`
* `DaysToShip = ShipDate − OrderDate`

**Grain**: Line-level per `(OrderID, ProductID, ProductName)` after cleaning and de-duplication.

---

## 4) Pipelines & Notebooks

### Azure Data Factory (ADF)

* **Pipeline**: `pl_ingest_sales`

  * **Linked services**: `ls_blob_storage` (Blob), `ls_sql_db` (Azure SQL)
  * **Datasets**: Blob CSV (header, ","), SQL table `dbo.stg_sales`
  * **Activities**: Copy (Blob→SQL staging)
  * **Trigger**: Manual (daily time trigger to be enabled later)
  * **Validation**: Row count check \~9.8k; robust CSV handling (quote/escape); delimiter=`,`

### Local Notebooks (Python)

* **`notebooks/02_data_processing.ipynb`**

  * Reads `dbo.stg_sales` via SQLAlchemy
  * Cleans types, parses dates (dd/MM/yyyy → datetime), trims strings
  * Derives date features & `DaysToShip`
  * **Reload strategy**: `TRUNCATE` dims & fact, then append from pandas (idempotent)
  * Writes to: `dbo.dim_customer`, `dbo.dim_product`, `dbo.dim_region`, `dbo.fact_sales`

* **`notebooks/03_eda.ipynb`**

  * Reads from `dbo.fact_sales` (and joins dims if needed)
  * Validates counts, distributions, trends (monthly sales, region/category splits)
  * Exports key visuals to `docs/` or `reports/`

* **`notebooks/04_modeling.ipynb`** *(Day 4)*

  * Loads cleaned data (SQL or local fallback)
  * **Regression**: ElasticNet, RandomForest, GradientBoosting → best = **ElasticNet** (baseline)
  * **Classification**: LogisticRegression, RandomForest → best = **RandomForest** (F1 \~0.23 baseline)
  * Saves local artifacts only: `models/*.pkl`, `reports/*.json`, `reports/*.png`

---

## 5) Operational Details

**Secrets & Config**

* Local secrets file (not committed):

  * `/Users/haseebsagheer/Documents/Python Learning/Cloud-Retail-Insights/secrets/.env`
  * Keys: `SQL_SERVER`, `SQL_DATABASE`, `SQL_USERNAME`, `SQL_PASSWORD`, `AZURE_STORAGE_CONNECTION_STRING` (unused on Day 4)
* Git: `.env` path is **gitignored**; do not commit credentials.

**Execution**

* Ingestion: run `pl_ingest_sales` in ADF (manual for now)
* Processing: run **02** notebook locally → reload dims/fact
* Analytics: run **03** (EDA) and **04** (modeling) locally

**Validation**

* ADF Monitor: success status, row counts in `stg_sales`
* SQL checks: `SELECT COUNT(*)` from dims/fact; spot-check dates & duplicates
* Modeling: metrics JSON + plot saved locally; quick read-back sanity

---

## 6) Current Limitations / Decisions

* **No Databricks**: intentionally removed due to student quota; local notebooks provide equivalent functionality for this dataset size.
* **No Python uploads to Blob** (Day 4): to avoid auth/network friction.
* **SQL ETL minimized**: transformations done in pandas; SQL used mainly as serving store (dims/fact).
* **ADF dynamic file selection**: manual trigger used; dynamic latest-file logic deferred.

---

## 7) Next Steps (Day 5 preview)

* **Diagnostics**: Feature importance (RF), coefficients (ElasticNet)
* **Feature engineering**: Product/Customer/Region aggregates, lags, rolling windows
* **Tuning**: XGBoost/LightGBM + hyperparameter search
* **Deployment path**: Register model (Azure ML) or deploy FastAPI on Azure App Service; wire Streamlit UI
* **Power BI**: Connect to Azure SQL `fact_sales` for live dashboards

---

## 8) Repo Map (current)

```
retail_sales_cloud_project/
├── notebooks/
│   ├── 02_data_processing.ipynb
│   ├── 03_eda.ipynb
│   └── 04_modeling.ipynb
├── sql/
│   └── create_tables.sql  (staging + dims + fact)
├── data/                  (optional local copies)
├── models/                (Day 4 artifacts, local)
├── reports/               (metrics & plots, local)
├── docs/
│   ├── DATA_DICTIONARY.md
│   └── RUNBOOK.md
└── README.md
```

---

## 9) Talking Points (for interviews)

* **Why pandas ETL?** Faster iteration, fewer portal/permission issues, and ample for \~10k rows; SQL remains authoritative store for analytics & BI.
* **Idempotent loads**: Truncate+insert ensures clean dims/fact on every run while you iterate.
* **Time-aware modeling**: Split by order date to mimic real forecasting; avoided leakage by excluding Ship\* features.
* **Cloud fundamentals still present**: ADF, Blob, Azure SQL, Azure ML workspace — with a pragmatic path to production.
