#
# A long time ago, created by github.com/corelevel
#

# Reporting Services PowerShell how to install and other info
# https://github.com/Microsoft/ReportingServicesTools

Clear-Host

# source SSRS catalog
$SourceRsDirectory = "/Analytics"
# destination file system folder
$DestinationDirectory = "C:\Temp\Export"

# SSRS URI
$sourceRsUri = 'http://msreports/ReportServer/ReportService2010.asmx?wsdl'

# proxy
$proxy = New-RsWebServiceProxy -ReportServerUri $sourceRsUri

# save specified catalog items to the file system folder
Out-RsFolderContent -Proxy $proxy -RsFolder $SourceRsDirectory -Destination $DestinationDirectory -Recurse