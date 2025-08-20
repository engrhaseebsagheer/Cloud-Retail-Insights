Project Summary:
"A cloud-based retail analytics and forecasting system. It utilized most of the data science and machine learning concepts including EDA, datasets, Azure, SQL, GitHub, algorithms, etc."

---

Day 1:
First of all, I created an Azure account. Thank God I had a student ID from my university and a student email, so I used it to create a free Azure Student Account. This account initially offers \$100 free credits for 365 days and also provides some additional free Azure cloud services.

Then, I installed Azure CLI on my macOS terminal so I could manage the Azure account directly from my system. I used the command:
`brew update && brew install azure-cli`

After installation, I logged in using:
`az login`

I had only one subscription in my account, but for safety, I still used the `--subscription` command to set my current working subscription for this project.

Next, I created a working directory for this project using the `mkdir` command and started working inside this directory. I also initialized Git in my project so I could use GitHub for version control.

---

My next task was to create a virtual environment (resources) in my Azure account for the cloud retail insights project, with variable names and tags for proper organization.

I used a series of commands for this. First, I ensured my Azure account was logged in, if not, I logged in using `az login`.

The commands for resource creation were:

* `REGION="centralindia"` → I chose the physical location of my Azure cloud services as Central India instead of UAE North, because it is cheaper (as I am a student, I cannot afford expensive ones 😀). Although the UAE North server is quite fast.
* `PROJECT="retail-analytics"` → to initialize the project roots (naming).
* `ENV="dev"`
* `RG="rg-$PROJECT-$ENV"` → so the final name becomes `rg-retail-analytics-dev`. This is because it fetched the values of PROJECT and ENV.

We defined ENV so that we can later work without collision between dev and prod environments.

* `STORAGE="stretaildev"` → used to name my storage account. It will be used to hold preprocessed and processed data (CSV files, etc.).
* `SQLSERVER="sqlsrv-retail-dev"`
* `SQLDB="sqldb-retail-dev"` → these two were used to create an Azure SQL server and its associated database.
* `DATAFACTORY="df-retail-dev"` → to create Data Factory for moving data from Blob to SQL.
* `DATABRICKS="dbw-retail-dev"` → to create an Azure Databricks workspace (Apache Spark). It is big data friendly and scalable for data processing, feature engineering, and model training (using Spark MLlib, PySpark, or scikit-learn).
* `KEYVAULT="kv-retail-dev"` → to create a Key Vault for storing SQL credentials, connection strings, API keys, etc. so that secrets are not hardcoded in Python.

I also created an Azure Machine Learning workspace to track experiments, register models, and deploy trained models as REST APIs.

---

Tags were also created for all resources:

* `TAG_ENV="env=$ENV"`
* `TAG_OWNER="owner=haseeb"`
* `TAG_PROJECT="project=$PROJECT"`
* `TAG_CC="cost-center=personal"`

Tags are very useful for proper organization, cost tracking, automation, and filtering based on owner and environment.

---

Next, I created the Azure Storage Account. Before creating, I ensured the name was available using:
`az storage account check-name -n "$STORAGE" -o table`

Once available, I created the storage account using:

```
az storage account create   --name "$SA"   --resource-group "$RG"   --location "$REGION"   --sku Standard_LRS   --kind StorageV2   --hierarchical-namespace true   --min-tls-version TLS1_2   --allow-blob-public-access false   --tags "$TAG_ENV" "$TAG_OWNER" "$TAG_PROJECT" "$TAG_CC"   -o table
```

Although I could have created this directly in the Azure portal, I preferred using CLI to master it 😀.

Then I created standard containers inside the storage account using the following commands:

```
ACCOUNT_KEY=$(az storage account keys list -g "$RG" -n "$SA" --query "[0].value" -o tsv)

az storage container create --name raw       --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table
az storage container create --name processed --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table
az storage container create --name curated   --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table
az storage container create --name logs      --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table
```

The storage account and containers were created successfully.

Next, I created the Azure SQL server and the database for storing cleaned data.

Data Factory was then created using the Azure portal (CLI was giving errors). It was successfully created. Similarly, Azure Databricks was also created via portal for ease of use.

Finally, I added Azure Machine Learning workspace (AML). It was added to track runs, register a forecasting model, and deploy endpoints later. I initially tried storing AML data in the previously created storage, but it failed because the storage account had hierarchical namespace enabled. So, I created a new one.

Key Vault: I tried to use it for storing values, but due to admin restrictions on the student account, I was not able to store new secrets. As a result, I deleted the Key Vault and stored the usable values directly in a `.env` file (excluded from Git using `.gitignore`).

At the end of Day 1, I pushed the changes to GitHub so my latest code could be viewed.

⏱ Time invested on Day 1: More than 5 hours (as I am new to Azure cloud tools).

---

Day 2:
To be honest, Day 2 was missed due to some personal issues.

---

Day 3:

* First of all, I created multiple tables in the SQL database (on Azure portal) using multiple `CREATE TABLE` queries. These are stored in `sql/create_tables.sql`.

Example:

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

* These tables were created to store structured data in the SQL database server.

* Next, I went to Azure Data Factory. There I created new linked resources and connected my Blob Storage and SQL Database accounts.

* Once connected, I authored new datasets:

  * One for CSV files from Blob Storage.
  * One for storing data into SQL tables.

* I also created a new pipeline to perform the data movement.

* I tested the pipeline and it worked. After that, I published everything to make the Data Factory live.

* Then, I created a new **trigger** for the pipeline. I used a **schedule trigger** so it would automatically refresh data from Blob Storage and load it into SQL tables daily (to simulate shopkeeper data arriving daily).

* I also added the following **pre-script** in the sink tab of the pipeline:

```sql
TRUNCATE TABLE dbo.stg_sales;
```

This ensures that every time the pipeline runs, old data is cleared and replaced with fresh data (avoiding duplicates). Without this, data would be appended every time.

* Finally, I monitored the pipeline and it was working perfectly 😀.

---

Day 4 (Revised Plan):
Originally, I planned to set up and use Azure Databricks for the **processing and feature engineering layer**. However, I ran into issues because my Azure Student account did not have enough CPU quota to provision the required Databricks cluster.

Due to this limitation, I dropped Databricks from the immediate workflow and **revised the architecture**. The new approach was to handle processing and feature engineering locally (using Jupyter/VS Code) and later store results back into Azure SQL for downstream tasks.

So instead of Spark MLlib on Databricks, I used **scikit-learn and pandas locally** to begin prototyping regression (forecasting) and classification tasks. I loaded data from Azure SQL (with fallbacks to local CSV/Parquet), performed transformations, and ran baseline models (ElasticNet, Random Forest, Gradient Boosting for regression; Logistic Regression, Random Forest for classification).

The results showed:

* Best regression: ElasticNet (MAE \~264)
* Best classification: Random Forest (F1 \~0.23, weak baseline)

Artifacts saved included:

* Cleaned datasets
* Model objects (`.pkl`)
* Metrics JSON
* Figures (actual vs predicted plots)

This completed the initial **processing + modeling iteration** without Databricks.

---

Day 5 (Processing Layer in Azure SQL):
With Databricks not available, I shifted the processing layer directly into **Azure SQL**.

Steps:

* Defined transformations (date-based derived fields like OrderMonth, OrderQuarter, Ship delays, etc.) directly inside SQL queries and views.
* Stored processed versions in separate SQL tables (e.g., `fact_sales_processed`).
* Connected local Python scripts to query processed data directly from SQL using pyodbc/sqlalchemy.
* Verified that all derived columns (OrderYear, OrderMonth, OrderQuarter, OrderYearMonth, OrderWeekOfYear, IsWeekend flags, etc.) are persisted in SQL rather than recomputed every time locally.

This helped centralize the feature engineering logic, making Azure SQL the **single source of truth** for downstream analytics and modeling.

---

✅ Outcome so far:

* Full Azure environment setup (Day 1).
* SQL + Data Factory ingestion pipeline (Day 3).
* Processing + baseline ML locally due to Databricks limitation (Day 4 revised).
* Processing logic migrated into Azure SQL (Day 5).
