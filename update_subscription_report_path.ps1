#
# A long time ago, created by github.com/corelevel
#

# mapping existing DataSource values to the new values
$mapping = @{}
$mapping["/WMS Reports/"] = "/Migrated/WMS Reports/"

# source file system folder 
$SourceDirectory = "C:\Temp\Reports\Subscriptions\"
# destination file system folder
$DestinationDirectory = "C:\Temp\Reports\Subscriptions\!Updated\"

function UpdatePath
{
    Param
    (
        [parameter(Mandatory=$true)]
        [string]$SourceSubscriptionFile
    )

    [System.Xml.XmlDocument]$doc = [System.Xml.XmlDocument]::new()
    $doc.Load($SourceDirectory + "\" + $SourceSubscriptionFile)

    [System.Xml.XmlNamespaceManager]$nsManager = [System.Xml.XmlNamespaceManager]::new($doc.NameTable)
    $nsManager.AddNamespace("ns", $doc.DocumentElement.NamespaceURI)
    [System.Xml.XmlNodeList]$nodes = $doc.SelectNodes("/ns:Objs/ns:Obj/ns:MS/ns:S", $nsManager)

    $reportName = [io.path]::GetFileNameWithoutExtension($SourceSubscriptionFile)

    foreach ($node in $nodes)
    {
        if ($node.HasAttribute("N"))
        {
            if ($node.GetAttribute("N") -eq "Report")
            {
                $subscriptionReportName = $node.InnerText
                if ($subscriptionReportName -ne $reportName)
                {
                    Write-Host ("Report name '{0}' in subscription not equal subscription file name '{1}'. Source subscription file '{2}'" `
                        -f $subscriptionReportName, $reportName, $SourceSubscriptionFile)
                    return
                }
            }

            if ($node.GetAttribute("N") -eq "Path")
            {
                $fullPath = $node.InnerText

                $path = $fullPath.substring(0, $fullPath.length - $reportName.length)

                $newPath = $mapping[$path]
                if ([string]::IsNullOrEmpty($newPath))
                {
                    Write-Host ("Mapping not found for Path={0}. Source subscription file '{1}'" -f $path, $SourceSubscriptionFile)
                    return
                }
                else
                {
                    $node.InnerText = $newPath + $reportName
                }
            }
        }
    }
    Write-Host ("Path(s) updated for the source subscription file '{0}'" -f $SourceSubscriptionFile)
    $doc.Save($DestinationDirectory + "\" + $SourceSubscriptionFile);
}

Clear-Host
EXCELOPENXML
try
{
    Get-ChildItem $SourceDirectory -Filter *.xml |
    Foreach-Object {
        UpdatePath($_.Name)
    }
}
catch
{
	Write-Host ($_.Exception.ToString())
}
