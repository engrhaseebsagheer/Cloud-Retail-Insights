# Runbook — Cloud-Based Retail Sales Analytics & Forecasting System

This runbook provides operational guidance for re-running pipelines, managing secrets, and recovering from common failures in the **Cloud-Based Retail Sales Analytics & Forecasting System**.

---

## 1. Re-Running Pipelines

### Azure Data Factory (ADF)

* **Manual Trigger:**

  * Navigate to **ADF Studio → Author → Pipelines**.
  * Select the pipeline (e.g., `pl_sales_ingest`).
  * Click **Trigger Now** to re-run.
* **Scheduled Trigger:**

  * Check under **Manage → Triggers**.
  * If a pipeline fails to run on schedule, re-enable or re-create the trigger.
* **Data Refresh:**

  * Ensure **staging tables** in SQL (`stg_sales`) are truncated before re-ingest.
  * Verify that Blob source files exist in `raw/` container.

### Databricks Notebooks

* Open **Databricks Workspace → Notebooks**.
* Attach the notebook to an active cluster.
* Select **Run All**.
* For reproducibility:

  * Ensure `.env` variables are loaded.
  * Verify paths for `processed/` and `curated/` data.

### Azure ML Pipelines

* Navigate to **Azure ML Studio → Pipelines**.
* Select the registered pipeline (e.g., `train_sales_forecast`).
* Click **Submit** to re-run with the latest dataset.

---

## 2. Secret Management

Since **Azure Key Vault** is not available in the student subscription, secrets are stored locally in `.env` (gitignored).

### Rotating Secrets

* Update `.env` with new values (e.g., DB password, Storage key).
* Restart Jupyter kernel or Databricks cluster to reload.
* For Azure SQL Database:

  * Reset password via **Azure Portal → SQL Server → Reset Password**.
* For Storage Account:

  * Regenerate access keys via **Portal → Storage Account → Access Keys**.
  * Update `.env` and ADF linked services with the new key.

---

## 3. Failure Recovery

### ADF Pipeline Fails

* Check **Monitor tab** in ADF for error details.
* Common causes:

  * Wrong schema mapping → Fix column mapping in Sink.
  * Authentication failure → Update linked service credentials.
  * Missing file in `raw/` → Ensure file exists before triggering.

### Databricks Job Fails

* Review job logs in **Databricks Job UI**.
* Common causes:

  * Missing libraries → Reinstall via `%pip install`.
  * Cluster stopped → Restart cluster and re-run.
  * Path not found → Check container mount paths (`dbutils.fs.ls`).

### Azure ML Model Training Fails

* Check **Run Logs** in AML Studio.
* Common causes:

  * Data version mismatch → Confirm correct dataset registered.
  * Timeout or quota issue → Reduce cluster size or runtime.

### SQL Connection Fails

* Verify `ODBC Driver` is installed.
* Ensure firewall rules allow client IP.
* Test connection with:

  ```bash
  sqlcmd -S sqlsrv-retail-dev.database.windows.net -d sqldb-retail-dev -U <username> -P <password>
  ```

---

## 4. Disaster Recovery

* **Blob Data Loss:** Restore from local Kaggle dataset backup.
* **SQL Data Loss:** Re-run ADF ingestion pipeline from Blob → SQL.
* **Corrupted Model Files:** Re-train models using saved notebooks in Databricks.
* **App Service Failure:** Restart App Service from Azure Portal.

---

## 5. Operational Best Practices

* Always keep `.env` updated and backed up securely (outside repo).
* Stop Databricks clusters and App Service when idle to save credits.
* Monitor cost usage in **Azure Cost Management + Billing**.
* Document changes in `/docs/changelog.md` for reproducibility.

---

✅ This runbook will evolve as the project matures and additional failure scenarios are identified.
