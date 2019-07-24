cls
$conn=New-Object System.Data.SqlClient.SqlConnection

$conn.ConnectionString = "Data Source=tcp:AGListener.domain.local,24301;Initial Catalog=Foo1;Connection Timeout=240;Integrated Security=True;MultiSubnetFailover=True;"
$conn.Open()
$sql = 'select @@servername'
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql,$conn)
$message = "R/W server : " + $cmd.ExecuteScalar()
$conn.Close()

$conn.ConnectionString = "Data Source=tcp:AGListener.domain.local,24301;Initial Catalog=Foo1;Connection Timeout=240;Integrated Security=True;MultiSubnetFailover=True;ApplicationIntent=ReadOnly;"
$conn.Open()
$sql = 'select @@servername'
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql,$conn)
$message = $message + ", Read only server : " + $cmd.ExecuteScalar()
$conn.Close()

Write-Host $message