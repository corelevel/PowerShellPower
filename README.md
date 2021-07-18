# PowerShellPower
DeployDTSX_Project - this is an example of a PowerShell script that deploys the SSIS project and its parameters on the server using the ispac file. It uses catalog.deploy_project the stored procedure from SSISDB

CheckReadOnlyRoutingList - script for checking the configuration of read-only routing for an Always On availability group

AlterCollation - script for changing the collation for string fields in the table in the entire database. It uses SQL Server Management Objects (SMO) for change script generation


SRSS scripts
export_rdl - exports SSRS catalog to the file system folder
update_rdl_datasource - updates RDL DataSource to the new value. It helps to avoid an error like this 
"The dataset 'BlaBlaBlaDataSet' refers to the shared data source 'BlaBlaBlaSource', which is not published on the report server" when you try to import RDL file to SSRS
import_rdl - imports file system folder to SSRS catalog
