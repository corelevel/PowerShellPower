$ProjectFile = 'C:\Users\corel.DESKTOP-IE04MSF\source\repos\WebApi\WebApi\bin\Development\WebApi.ispac'
$ServerName = 'REDALERT'
$FolderName = 'WebApi'
$ProjectName = 'WebApi'
$ParameterName = 'ApiUrl'
$ParameterValue = 'http://data.fixer.io/api/latest?format=1&access_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$ObjectName = 'Package.dtsx'

function Set-PackageParameter()
{
    Param
    (
    [Parameter(Mandatory)]
    $conection,
    [Parameter(Mandatory)]
    [string]$folder_name,
    [Parameter(Mandatory)]
    [string]$project_name,
    [Parameter(Mandatory)]
    [string]$parameter_name,
    [Parameter(Mandatory)]
    $parameter_value,
    [Parameter(Mandatory)]
    [string]$object_name,
    [string]$value_type = 'V'
    )

    Set-SSISParameter -conection $conection -folder_name $folder_name -project_name $project_name -object_type 30 `
        -parameter_name $parameter_name -parameter_value $parameter_value -object_name $object_name -value_type $value_type
}

function Set-ProjectParameter()
{
    Param
    (
    [Parameter(Mandatory)]
    $conection,
    [Parameter(Mandatory)]
    [string]$folder_name,
    [Parameter(Mandatory)]
    [string]$project_name,
    [Parameter(Mandatory)]
    [string]$parameter_name,
    [Parameter(Mandatory)]
    $parameter_value,
    [Parameter(Mandatory)]
    [string]$object_name,
    [string]$value_type = 'V'
    )

    Set-SSISParameter -conection $conection -folder_name $folder_name -project_name $project_name -object_type 20 `
        -parameter_name $parameter_name -parameter_value $parameter_value -object_name $object_name -value_type $value_type
}

function Set-SSISParameter()
{
    Param
    (
    [Parameter(Mandatory)]
    $conection,
    [int]$object_type, #Use the value 20 to indicate a project parameter or the value 30 to indicate a package parameter
    [Parameter(Mandatory)]
    [string]$folder_name,
    [Parameter(Mandatory)]
    [string]$project_name,
    [Parameter(Mandatory)]
    [string]$parameter_name,
    [Parameter(Mandatory)]
    $parameter_value,
    [Parameter(Mandatory)]
    [string]$object_name,
    [string]$value_type # V to indicate that parameter_value is a literal value, R to indicate that parameter_value is a referenced value
    )

    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.Connection = $conection
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure

    $cmd.CommandText = '[catalog].[set_object_parameter_value]'
    $cmd.Parameters.Add("@object_type",[system.data.SqlDbType]::SmallInt) | out-Null
    $cmd.Parameters['@object_type'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@object_type'].value = $object_type

    $cmd.Parameters.Add("@folder_name",[system.data.SqlDbType]::NVarChar) | out-Null
    $cmd.Parameters['@folder_name'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@folder_name'].value = $folder_name

    $cmd.Parameters.Add("@project_name",[system.data.SqlDbType]::NVarChar) | out-Null
    $cmd.Parameters['@project_name'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@project_name'].value = $project_name

    $cmd.Parameters.Add("@parameter_name",[system.data.SqlDbType]::NVarChar) | out-Null
    $cmd.Parameters['@parameter_name'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@parameter_name'].value = $parameter_name

    $cmd.Parameters.Add("@parameter_value",[system.data.SqlDbType]::Variant) | out-Null
    $cmd.Parameters['@parameter_value'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@parameter_value'].value = $parameter_value

    $cmd.Parameters.Add("@object_name",[system.data.SqlDbType]::NVarChar) | out-Null
    $cmd.Parameters['@object_name'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@object_name'].value = $object_name

    $cmd.Parameters.Add("@value_type",[system.data.SqlDbType]::Char, 1) | out-Null
    $cmd.Parameters['@value_type'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@value_type'].value = $value_type

    $cmd.ExecuteNonQuery() | out-Null
}

function Publish-Project
{
    Param
    (
    [Parameter(Mandatory)]
    $conection,
    [Parameter(Mandatory)]
    [string]$folder_name,
    [Parameter(Mandatory)]
    [string]$project_name,
    [Parameter(Mandatory)]
    [string]$project_file
    )

    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.Connection = $conn
    $cmd.CommandText = '[catalog].[deploy_project]'
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure

    $fs = New-Object System.IO.FileStream($project_file,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read)
    $project_stream = New-Object byte[] -ArgumentList $fs.Length
    $fs.Read($project_stream, 0, $project_stream.Length) | out-Null
    $fs.Close()

    # Set the destination project and folder
    $cmd.Parameters.Add("@folder_name",[system.data.SqlDbType]::NVarChar) | out-Null
    $cmd.Parameters['@folder_name'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@folder_name'].value = $folder_name

    $cmd.Parameters.Add("@project_name",[system.data.SqlDbType]::NVarChar) | out-Null
    $cmd.Parameters['@project_name'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@project_name'].value = $project_name

    $cmd.Parameters.Add("@project_stream",[system.data.SqlDbType]::VarBinary, $projectData.Length) | out-Null
    $cmd.Parameters['@project_stream'].Direction = [system.data.ParameterDirection]::Input
    $cmd.Parameters['@project_stream'].value = $project_stream

    $cmd.ExecuteNonQuery() | out-Null
}

try
{
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = 'Data Source=' + $ServerName + ';Initial Catalog=SSISDB;Integrated Security=True;'
    $conn.Open()
    
    # Deploy project
    Publish-Project -conection $conn -project_name $ProjectName -folder_name $FolderName -project_file $ProjectFile
    # Set package parameters
    Set-PackageParameter -conection $conn -project_name $ProjectName -folder_name $FolderName `
        -parameter_name $ParameterName -parameter_value $ParameterValue -object_name $ObjectName
}
catch
{
    throw $_
}
finally
{
    $conn.Close()
}
