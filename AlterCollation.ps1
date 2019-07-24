# Import module for use SMO objects
Import-Module "SQLPS" -DisableNameChecking;
# load .NET assembly
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

$Server = 'REDALERT'
$Database = 'AdventureWorks2017'
$FileDropFK = 'C:\Temp\1.DropFK.sql'
$FileAlter = 'C:\Temp\2.Alter.sql'
$FileCreateFK = 'C:\Temp\3.CreateFK.sql'
$Collate = 'Cyrillic_General_CI_AS'

function WriteScript()
{
    Param([ref]$srv,[ref]$table,[ref]$row)

$scripter = New-Object('Microsoft.SqlServer.Management.Smo.Scripter') $srv.value

$scripter.Options.Indexes = $true
$scripter.Options.ClusteredIndexes = $true
$scripter.Options.ScriptBatchTerminator = $true
$scripter.Options.NoCommandTerminator = $false
$scripter.Options.ToFileOnly = $false

foreach ($t in $db.Tables)
{
    if ($t.Name -eq $row.Value['table'] -and $t.Schema -eq $row.Value['schema'])
    {
        '/********************************************************************/' | Out-File $FileAlter -Append
        # set drop option
        $scripter.Options.ScriptDrops = $true
        # drop indexes
        foreach ($v in $t.Indexes)
        {
            if ($v.IndexedColumns.Contains($row.Value['column']))
            {
                $scripter.Script($v) | Out-File $FileAlter -Append
                'go' | Out-File $FileAlter -Append
            }
        }
        # drop foreign keys
        foreach ($v in $t.ForeignKeys )
        {
            if ($v.Columns.Contains($row.Value['column']))
            {
                $scripter.Script($v) | Out-File $FileDropFK -Append
                'go' | Out-File $FileDropFK -Append
            }
        }
        $row.Value['alter'] | Out-File $FileAlter -Append
        'go' | Out-File $FileAlter -Append
        # set create option
        $scripter.Options.ScriptDrops = $false
        # create indexes
        foreach ($v in $t.Indexes)
        {
            if ($v.IndexedColumns.Contains($row.Value['column']))
            {
                $q = 'schema = ''' + $table.Value.Schema + ''' and table = ''' + $table.Value.Name + ''' and RowNum > ' + $row.Value['RowNum']
                if ($table.Value.select($q).Length -eq 0)
                {
                    $scripter.Script($v) | Out-File $FileAlter -Append
                    'go' | Out-File $FileAlter -Append
                }
            }
        }
        # create foreign keys
        foreach ($v in $t.ForeignKeys)
        {
            if ($v.Columns.Contains($row.Value['column']))
            {
                $q = 'schema = ''' + $table.Value.Schema + ''' and table = ''' + $table.Value.Name + ''' and RowNum > ' + $row.Value['RowNum']
                if ($table.Value.select($q).Length -eq 0)
                {
                    $scripter.Script($v) | Out-File $FileCreateFK -Append
                    'go' | Out-File $FileCreateFK -Append
                }
            }
        }
    }
}
}

function GetAlter()
{
    Param([ref]$db)

$alter = $db.value.ExecuteWithResults('
select	row_number() over (order by schema_name(o.[schema_id]), o.name, c.name) RowNum,
        schema_name(o.[schema_id]) [schema],
		o.name [table],
		c.name [column],
		''alter table ['' + schema_name(o.[schema_id]) + ''].['' + o.name + ''] alter column ['' + c.name + ''] '' + t.name + 
		case when t.name not in (''ntext'', ''text'') 
			then ''('' + 
				case
					when t.name in (''nchar'', ''nvarchar'') and c.max_length != -1 
						then cast(c.max_length / 2 as varchar(10))
					when t.name in (''char'', ''varchar'') and c.max_length != -1 
						then cast(c.max_length as varchar(10))
					when t.name in (''nchar'', ''nvarchar'', ''char'', ''varchar'') and c.max_length = -1 
						then ''max''
					else cast(c.max_length as varchar(10)) 
				end + '')''
			else ''''
		end + '' collate '' + ''' + $Collate + ''' + 
		case when c.is_nullable = 1 
			then '' null''
			else '' not null''
		end [alter]
from	sys.columns c
		join sys.objects o
		on c.[object_id] = o.[object_id]
		join sys.types t
		on c.system_type_id = t.system_type_id and c.user_type_id = t.user_type_id
where t.name in (''char'', ''varchar'', ''text'', ''nvarchar'', ''ntext'', ''nchar'')
    and c.collation_name != ''' + $Collate + '''
    and o.[type] = ''U''
    and o.name not in(''sysarticles'', ''sysschemaarticles'')
order by RowNum')

    return $alter
}

try
{
    $srv = New-Object('Microsoft.SqlServer.Management.Smo.Server') $Server

    $db = $srv.Databases[$Database]

    if ($db -eq $null)
    {
        throw 'Incorrect server or database name'
    }

    $alter = GetAlter ([ref]$db)

    'use [' + $Database + ']' | Out-File $FileDropFK
    'go' | Out-File $FileDropFK -Append

    'use [' + $Database + ']' | Out-File $FileAlter
    'go' | Out-File $FileAlter -Append

    'use [' + $Database + ']' | Out-File $FileCreateFK
    'go' | Out-File $FileCreateFK -Append

    foreach ($t in $alter.Tables)
    {
        foreach($row in $t.Rows)
        {
            WriteScript ([ref]$srv) ([ref]$t) ([ref]$row)
        }
    }
}
catch
{
	$message = $_.Exception.ToString();
	Write-Host "Failed $message"
}