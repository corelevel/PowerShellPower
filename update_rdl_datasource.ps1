#
# A long time ago, created by github.com/corelevel
#

# mapping existing DataSource values to the new values
$mapping = @{}
$mapping["Production"] = "/Data Sources/NewProduction"
$mapping["Dev"] = "/Data Sources/Dev"

# source file system folder 
$SourceDirectory = "C:\Temp\Reports\"
# destination file system folder
$DestinationDirectory = "C:\Temp\Reports\!Updated\"

function UpdateDataSource
{
    Param
    (
        [parameter(Mandatory=$true)]
        [string]$SourceReportFile
    )

    [System.Xml.XmlDocument]$doc = [System.Xml.XmlDocument]::new()
    $doc.Load($SourceDirectory + "\" + $SourceReportFile)

    [System.Xml.XmlNamespaceManager]$nsManager = [System.Xml.XmlNamespaceManager]::new($doc.NameTable)
    $nsManager.AddNamespace("ns", $doc.DocumentElement.NamespaceURI)
    [System.Xml.XmlNodeList]$nodes = $doc.SelectNodes("/ns:Report/ns:DataSources/ns:DataSource/ns:DataSourceReference", $nsManager)

    foreach ($node in $nodes)
    {
        $dataSource = $node.InnerText
        if ([string]::IsNullOrEmpty($datasource))
        {
            Write-Host ("DataSource value not found. Source report file '{0}'" -f $SourceReportFile)
            return
        }
        
        $newDataSource = $mapping[$dataSource]

        if ([string]::IsNullOrEmpty($newDataSource))
        {
            Write-Host ("Mapping not found for DataSource={0}. Source report file '{1}'" -f $dataSource, $SourceReportFile)
            return
        }
        else
        {
            $node.InnerText = $newDataSource
        }
    }
    Write-Host ("Data source(s) updated for the source report file '{0}'" -f $SourceReportFile)
    $doc.Save($DestinationDirectory + "\" + $SourceReportFile);
}

Clear-Host

try
{
    Get-ChildItem $SourceDirectory -Filter *.rdl |
    Foreach-Object {
        UpdateDataSource($_.Name)
    }
}
catch
{
	Write-Host ($_.Exception.ToString())
}
