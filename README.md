# PowerShellPower

## SRSS scripts

Reporting Services PowerShell must be installed to use SRSS scripts. How to install and other info https://github.com/Microsoft/ReportingServicesTools

+ *export_rdl* - exports SSRS catalog (rdl definitions) to the file system folder
+ *update_rdl_datasource* - updates RDL DataSource to the new value. It helps to avoid an error like this 
"The dataset 'BlaBlaBlaDataSet' refers to the shared data source 'BlaBlaBlaSource', which is not published on the report server" when you try to import RDL file to the destination SSRS server
+ *import_rdl* - imports file system folder (rdl definitions) to SSRS catalog
+ *export_subscriptions* - exports SSRS subscriptions from the specified catalog to the file system folder in XML format
+ *update_subscription_report_path* - updates path to the report in the subscription XML file. You don't need to use it if you don't change the report catalog on the destination SSRS server
+ *import_subscribtions* - imports subscriptions from file system folder to SSRS catalog

# random scripts
+ *DeployDTSX_Project* - this is an example of a PowerShell script that deploys the SSIS project and its parameters on the server using the ispac file. It uses catalog.deploy_project the stored procedure from SSISDB
+ *CheckReadOnlyRoutingList* - script for checking the configuration of read-only routing for an Always On availability group
+ *AlterCollation* - script for changing the collation for string fields in the table in the entire database. It uses SQL Server Management Objects (SMO) for change script generation
