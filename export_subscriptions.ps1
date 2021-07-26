#
# A long time ago, created by github.com/corelevel
#

# Reporting Services PowerShell how to install and other info
# https://github.com/Microsoft/ReportingServicesTools

Clear-Host

# source SSRS catalog
$SourceRsDirectory = "/WMS Reports"
# destination file system folder
$DestinationDirectory = "C:\Temp\Subscription\WMS Reports"

# SSRS URI
$sourceRsUri = 'http://msreports/ReportServer/ReportService2010.asmx?wsdl'

# proxy
$proxy = New-RsWebServiceProxy -ReportServerUri $sourceRsUri

$reports = Get-RsFolderContent -Proxy $proxy -Path $SourceRsDirectory

foreach($report in $reports)
{
    Get-RsSubscription -Proxy $proxy -RsItem $($SourceRsDirectory + "/" + $report.Name) | Export-RsSubscriptionXml $($DestinationDirectory + "\" + $report.Name + ".xml")
}
