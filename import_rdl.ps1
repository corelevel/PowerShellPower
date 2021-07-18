#
# A long time ago, created by github.com/corelevel
#

# Reporting Services PowerShell how to install and other info
# https://github.com/Microsoft/ReportingServicesTools

Clear-Host

# source file system folder
$SourceDirectory = "C:\Temp\Export\"
# destination SSRS catalog
$DestinationRsDirectory = "/Migrated/WMS Reports"

# SSRS URI
$sourceRsUri = 'http://msreports/ReportServer/ReportService2010.asmx?wsdl'

# proxy
$proxy = New-RsWebServiceProxy -ReportServerUri $sourceRsUri

# upload specified file system folder items to the catalog
Write-RsFolderContent -Proxy $proxy -Path $SourceDirectory -Destination $DestinationRsDirectory -Verbose