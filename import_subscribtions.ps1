#
# A long time ago, created by github.com/corelevel
#

# Reporting Services PowerShell how to install and other info
# https://github.com/Microsoft/ReportingServicesTools

# destination SSRS catalog
$DestinationRsDirectory = "/Migrated/WMS Reports/"
# source file system folder with subscriptions XML
$SourceDirectory = "C:\Temp\Subscription\!Updated\"

# SSRS URI
$sourceRsUri = 'http://msreports/ReportServer/ReportService2010.asmx?wsdl'

# proxy
$proxy = New-RsWebServiceProxy -ReportServerUri $sourceRsUri

function ImportSubscription
{
    Param
    (
        [parameter(Mandatory=$true)]
        [string]$SubscriptionFile
    )

    $path = $SourceDirectory + $SubscriptionFile
    $rsItem = $DestinationRsDirectory + [io.path]::GetFileNameWithoutExtension($SubscriptionFile)

    Import-RsSubscriptionXml -Proxy $proxy -Path $path | Copy-RsSubscription -Proxy $proxy -RsItem $rsItem

    Write-Host ("Subscription imported successfully. Source subscription file '{0}'" -f $SubscriptionFile)
}

Clear-Host

try
{
    Get-ChildItem $SourceDirectory -Filter "*.xml" |
    Foreach-Object {
        ImportSubscription($_.Name)
    }
}
catch
{
	Write-Host ($_.Exception.ToString())
}
