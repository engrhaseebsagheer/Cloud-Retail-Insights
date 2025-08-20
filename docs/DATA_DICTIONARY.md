# Data Dictionary

Dataset fields, data types, validation rules, and derivations. Updated through **Day 4**.

> **Source**: Kaggle — *Sales Forecasting* by Rohit Sahoo
> Link: [https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting](https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting)
> **Raw rows landed**: \~9,800 (single CSV).
> **Note**: Only a **train** CSV is provided by the dataset author; there is **no separate test file**. For modeling we perform a **time-based split** (80% oldest orders for training, 20% most recent for testing).

---

## 1) Raw → Staging (dbo.stg\_sales)

**Origin**: CSV (Blob `raw/`) → ADF Copy → Azure SQL `dbo.stg_sales` (text-first to avoid type errors).

| Column       | Type (staging)  | Description / Rules                                                | Example           |
| ------------ | --------------- | ------------------------------------------------------------------ | ----------------- |
| RowID        | `INT`           | Optional row index from source; not a business key. May be null.   | 32                |
| OrderID      | `NVARCHAR(50)`  | Order identifier (case-insensitive).                               | `US-2016-150630`  |
| OrderDate    | `NVARCHAR(50)`  | Date **as text** in `dd/MM/yyyy`. Parsed later.                    | `17/09/2016`      |
| ShipDate     | `NVARCHAR(50)`  | Date **as text** in `dd/MM/yyyy`. Parsed later.                    | `21/09/2016`      |
| ShipMode     | `NVARCHAR(50)`  | Shipping class/category.                                           | `Standard Class`  |
| CustomerID   | `NVARCHAR(50)`  | Customer unique ID.                                                | `TB-21520`        |
| CustomerName | `NVARCHAR(100)` | Customer name. Trim whitespace on ingest.                          | `Tracy Blumstein` |
| Segment      | `NVARCHAR(50)`  | Market segment values like `Consumer`, `Corporate`, `Home Office`. | `Consumer`        |
| Country      | `NVARCHAR(50)`  | Country name; dataset primarily `United States`.                   | `United States`   |
| City         | `NVARCHAR(50)`  | City.                                                              | `Philadelphia`    |
| State        | `NVARCHAR(50)`  | State/Province.                                                    | `Pennsylvania`    |
| PostalCode   | `NVARCHAR(20)`  | Postal/ZIP code (kept as text).                                    | `19140`           |
| Region       | `NVARCHAR(50)`  | Sales region (e.g., `East`, `West`, `Central`, `South`).           | `East`            |
| ProductID    | `NVARCHAR(50)`  | Product unique ID.                                                 | `OFF-AR-10001683` |
| Category     | `NVARCHAR(50)`  | Product category.                                                  | `Office Supplies` |
| SubCategory  | `NVARCHAR(50)`  | Product subcategory.                                               | `Art`             |
| ProductName  | `NVARCHAR(255)` | Product name/description.                                          | `Lumber Crayons`  |
| Sales        | `NVARCHAR(50)`  | Monetary value as text; parsed to numeric later.                   | `15.76`           |

**Staging rules**

* Keep all fields as text (except RowID) to avoid pipeline type failures.
* No trimming/standardization beyond safe leading/trailing space removal (optional) — transformation occurs in processed layer.
* All date parsing and numeric casting deferred to processed.

---

## 2) Processed (Cleaned dataset for analytics)

**Origin**: Read from `dbo.stg_sales` → cleaned in pandas → inserted into dims/fact.

### 2.1 Dimensions

**`dbo.dim_customer`**

* **Columns**:

  * `CustomerID NVARCHAR(50)` **PK** — canonical key from source
  * `CustomerName NVARCHAR(100)` — trimmed
  * `Segment NVARCHAR(50)` — standardized to known values
* **Rules**: De-duplicate by `CustomerID`; on reload we `TRUNCATE` then `INSERT` (SCD1/overwrite).
* **Examples**: `TB-21520`, `Tracy Blumstein`, `Consumer`.

**`dbo.dim_product`**

* **Columns**:

  * `ProductID NVARCHAR(50)` **PK**
  * `Category NVARCHAR(50)`
  * `SubCategory NVARCHAR(50)`
  * `ProductName NVARCHAR(255)`
* **Rules**: De-duplicate by `ProductID`; trim all strings.

**`dbo.dim_region`**

* **Columns**:

  * `Region NVARCHAR(50)` **PK** — values like `East`, `West`, `Central`, `South` (case-normalized)
* **Rules**: Populate distinct regions from cleaned data; unknowns → `Unknown`.

### 2.2 Fact

**`dbo.fact_sales`**

* **Grain**: One line per `(OrderID, ProductID, ProductName)` after deduplication (project choice).
* **Columns**:

  * `SalesID INT IDENTITY` **PK** (surrogate)
  * `OrderID NVARCHAR(50)` — natural key
  * `CustomerID NVARCHAR(50)` — FK to `dim_customer`
  * `ProductID NVARCHAR(50)` — FK to `dim_product`
  * `Region NVARCHAR(50)` — FK-ish to `dim_region`
  * `OrderDate DATE` — parsed from `dd/MM/yyyy`
  * `ShipDate DATE` — parsed from `dd/MM/yyyy`
  * `Sales DECIMAL(18,2)` — parsed from text, non-negative
* **Reload strategy**: `TRUNCATE` then `INSERT` each run (idempotent for this project stage).

**Validation**

* `OrderDate ≤ ShipDate` (when both present) — otherwise flagged or dropped in cleaning.
* `Sales ≥ 0` — negative values removed.
* Strings are trimmed; `Region/Category/SubCategory/Segment` standardized to consistent case.

---

## 3) Derived Analytics Fields (computed in pandas during cleaning)

> Not all are persisted in SQL columns; primarily used in modeling/EDA and can be exported to Parquet or views as needed.

| Field               | Type           | Source                 | Rule / Definition                                              |
| ------------------- | -------------- | ---------------------- | -------------------------------------------------------------- |
| DaysToShip          | `INT`          | `ShipDate - OrderDate` | Difference in calendar days (can be null if any date missing). |
| OrderYear           | `INT`          | `OrderDate`            | Calendar year.                                                 |
| OrderMonth          | `INT`          | `OrderDate`            | Month number (1–12).                                           |
| OrderQuarter        | `INT`          | `OrderDate`            | Quarter (1–4).                                                 |
| OrderWeekOfYear     | `INT`          | `OrderDate`            | ISO week number.                                               |
| OrderMonthName      | `NVARCHAR(20)` | `OrderDate`            | Month name (e.g., `January`).                                  |
| OrderIsWeekendOrder | `BIT`          | `OrderDate`            | 1 if day of week is Saturday/Sunday, else 0.                   |
| OrderYearMonth      | `NVARCHAR(7)`  | `OrderDate`            | `YYYY-MM` period label.                                        |
| ShipYear            | `INT`          | `ShipDate`             | Calendar year.                                                 |
| ShipMonth           | `INT`          | `ShipDate`             | Month number (1–12).                                           |
| ShipQuarter         | `INT`          | `ShipDate`             | Quarter (1–4).                                                 |
| ShipWeekOfYear      | `INT`          | `ShipDate`             | ISO week number.                                               |
| ShipMonthName       | `NVARCHAR(20)` | `ShipDate`             | Month name.                                                    |
| ShipIsWeekendShip   | `BIT`          | `ShipDate`             | 1 if weekend, else 0.                                          |

---

## 4) Quality & Normalization Rules

* **Date parsing**: Source dates are `dd/MM/yyyy`; convert with `dayfirst=True`. Invalid rows are dropped or flagged.
* **Numeric casting**: `Sales` coerced to decimal; non-parsable set to null then dropped.
* **Whitespace**: Trim all textual columns.
* **Casing**: Normalize `Region`, `Category`, `SubCategory`, `Segment` to title/upper as chosen.
* **Duplicates**: Define duplicate at `(OrderID, ProductID, ProductName)`; keep first or aggregate (project uses keep-first for now).

---

## 5) Modeling Split Policy

* No separate test file in the Kaggle dataset. We simulate a production split by **time**:

  * **Train**: Oldest 80% of orders by `OrderDate`
  * **Test**: Most recent 20% by `OrderDate`
* **Leakage control**: Exclude shipment-derived fields (e.g., `Ship*`, `DaysToShip`) from training features used to predict `Sales` at order time.

---

## 6) Known Limitations / TODO

* **No Quantity/Discount/Profit** columns in this dataset variant; all analytics rely on `Sales` only.
* **Processed Parquet**: kept local for now; optional SQL→Parquet copy can be added later.
* **Dynamic file selection in ADF**: manual trigger used; latest-file logic deferred.

---

## 7) Quick Lookup (types as used in SQL dims/fact)

```sql
-- dim_customer
CustomerID     NVARCHAR(50)  NOT NULL PRIMARY KEY,
CustomerName   NVARCHAR(100) NULL,
Segment        NVARCHAR(50)  NULL

-- dim_product
ProductID      NVARCHAR(50)  NOT NULL PRIMARY KEY,
Category       NVARCHAR(50)  NULL,
SubCategory    NVARCHAR(50)  NULL,
ProductName    NVARCHAR(255) NULL

-- dim_region
Region         NVARCHAR(50)  NOT NULL PRIMARY KEY

-- fact_sales
SalesID     INT IDENTITY PRIMARY KEY,
OrderID     NVARCHAR(50)  NULL,
CustomerID  NVARCHAR(50)  NULL,
ProductID   NVARCHAR(50)  NULL,
Region      NVARCHAR(50)  NULL,
OrderDate   DATE          NULL,
ShipDate    DATE          NULL,
Sales       DECIMAL(18,2) NULL
```
