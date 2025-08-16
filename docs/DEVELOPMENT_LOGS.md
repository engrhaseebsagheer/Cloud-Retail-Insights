Project logs:
Project Summary: "A cloud based retail analytics and forecasting system, it utilized most the data science and ml concept including eda, dataset, azure, sql, github, algorithams, etc"

First of all i create an azure account, and thank god i had the student id from my university and student email i used it to create a free azure student account that initally offers $100 free credits for 365 days and also it offers some additional free azure cloud services as well.
Then i installed azure cli in my macOS terminal so i can manage the azure account from my MacOs terminal. I used the "brew update && brew install azure-cli" command to install the azure cli, and then using "az login" command i logged into my account and i had only 1 subscription in my account but still i usd  --subscription commant to set my current working subscripton for this project for a safe side., then i made a working direcotory for ths project using mkdir command and then started working on this directory on my MacOS
I also initlize git into my project so i can utilize github version control system

My next task was to create an virtual envorioment or resources in azure account for my cloud retail insights with some variable names and tags.

i used series of command for this; first of all i made sure the azure account is logged in if not hen i logged in using az login:
the commands for resource creation were:
REGION="centralindia" i choose the physical location of my azure cloud services i choose the central india over uaenorth because it cheaper (as i am a student cant afford expensive one :D)
although the uaenorth server is quite fast
PROJECT="retail-analytics" to initlize the project roots (naming)
then i used 
ENV="dev"
RG="rg-$PROJECT-$ENV" so after using this command my final name becoems
rg-retail-analytics-dev becuase it feteched the variable values of
PROJECT and ENV
we defined the EVN so later we can working without collision between dev/prod
STORAGE="stretaildev" command was useed to name my storage account it will be used to hold my preproceesed and proccesd data (csv etc)
SQLSERVER="sqlsrv-retail-dev" 
SQLDB="sqldb-retail-dev"

these two commands were used to create an Azure SQL server and it contqinas a azure sql database named "sqldb-retail-dev"

DATAFACTORY="df-retail-dev"
 to create a datafactory to move data from Blob to SQL etc.
 to make a Azure Databrcks an pachae spark worspace was created using command "DATABRICKS="dbw-retail-dev"
"
it is big data friendly and calable data processing + feature enginering + model training (Spark MLib or PySpark + scikit-learn)
a key vault was created to store the sql database credentails, connection string, api keys etc, so my app can directly read secrets from here instead of hardcoding them in pythong command used ="KEYVAULT="kv-retail-dev"

I have also create an azure machine learning workspace to track ecperiments, register models, and deploy my trained model here as a REST API

I also used tags for resoruces by using following commands in series:
TAG_ENV="env=$ENV"
TAG_OWNER="owner=haseeb"
TAG_PROJECT="project=$PROJECT"
TAG_CC="cost-center=personal"

tags are very useful for a proper organization, cost tracking, automation, and filtering based on the owner and env


and now i went to create the azure storage account and before creating i made sure the name is available to create the storage account using command "az storage account check-name -n "$STORAGE"  -o table"
and then the name was avialble then i used this command 
az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "$REGION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --hierarchical-namespace true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags "$TAG_ENV" "$TAG_OWNER" "$TAG_PROJECT" "$TAG_CC" \
  -o table


  to create the storage for myself and also i could have create this storage using directly the storage in azure portal but i prefered cli to master it :D 


  then i created the standard containers in storage account using these commands:
  ACCOUNT_KEY=$(az storage account keys list -g "$RG" -n "$SA" --query "[0].value" -o tsv)

az storage container create --name raw       --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table
az storage container create --name processed --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table
az storage container create --name curated   --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table
az storage container create --name logs      --account-name "$SA" --account-key "$ACCOUNT_KEY" -o table

the storage account and the containers in it succesffuly created


now the next step is to create the Azure SQl both server and the database for storing the cleaned data. i did this by running following commands 
Now created data factory using a tool called data factories on azure cloud, i did not use CLI commands here because it was causing too many errors so i prefered creating it from azure portal and it was creating successfully
similarlary created azure databricks using azure portal for ease of use, it willuse for scalibility ETL or feature engineerings and notebook jobs


and last  but not the least azure machine learning also known as AML workspace was added in resources using azure portal , i added it to track runs, register a forecasting model, and deploy an endpoint later. i was trying to store the azure machine learning data in existing create storage but it couldnt as the storage account has hirehcal data so it coulndt be used so i create new, and existing key vault was used for AML.

added key vault to store values for sql connection etc, the key vault was creating some errors and i was not able to store new secrets or keys because i was not the admin (as its a student account) so my university administration is the owner, so i deleted this key vault resource and stored the useable values directly in .env file and in gitignore i mentioned not to add this as these are my personal credentails. 

and finally i added these changes into github so my latest code can be viewed by anyone

this is the end of day one i have been working on this project, time invested is more than 5 hours for day 1, as i am new to azure clouds tools. 

Here comes day 2:
to be honest day 2 was missed due to some personal issues.
Day 3:
first of all created multiple tables in sql database that is on azure portal, and i executed multiple queries of Create table to create tables and those queries are in sql/create_tables.sql file, one of them is as follow: 
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

and these tables were created to store the strucuted data in the sql database server.
And then i went to azure data factor, and there i created new resources linked and conneted my blob storage and sql database accountes there,and once i connected i created new author resources factory and created 2 datasets there 1 for csv file from blob storage and second for storing data from csv to sql tables and 1 new pipeline that will do that stuff, and i tested this pipeline and it worked and then i published all to make the data factory live. 
then i created a new trigger for my pipeline and i used schedule type trigger it will auto refresh my datafrom blob storage and then convert it into sql schema, i did it becuase the data arrives daily for a shopkeeper, so we can get new reloaded fresh data.
I added this TRUNCATE TABLE dbo.stg_sales; prescript in my sink tab of pipline so each time when new data is loaded or whenever i click debug it will erase the existing table's data and we get new fresh data without duplicates, if we don't add this script then we may get appended data (means always it will append the existing table + new data (that inlcudes that old data as well))

then i monitored my piple and it was working perfectly :D
