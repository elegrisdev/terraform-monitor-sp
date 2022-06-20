Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource) {
  $xHeaders = "x-ms-date:" + $date
  $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

  $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
  $keyBytes = [Convert]::FromBase64String($sharedKey)

  $sha256 = New-Object System.Security.Cryptography.HMACSHA256
  $sha256.Key = $keyBytes
  $calculatedHash = $sha256.ComputeHash($bytesToHash)
  $encodedHash = [Convert]::ToBase64String($calculatedHash)
  $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
  return $authorization
}

Function Update-LogAnalyticsData($customerId, $sharedKey, $body, $logType) {
  $method = "POST"
  $contentType = "application/json"
  $resource = "/api/logs"
  $rfc1123date = [DateTime]::UtcNow.ToString("r")
  $contentLength = $body.Length
  $signature = Build-Signature `
    -customerId $customerId `
    -sharedKey $sharedKey `
    -date $rfc1123date `
    -contentLength $contentLength `
    -method $method `
    -contentType $contentType `
    -resource $resource
  $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

  $headers = @{
    "Authorization"        = $signature;
    "Log-Type"             = $logType;
    "x-ms-date"            = $rfc1123date;
    "time-generated-field" = $TimeStampField;
  }

  $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
  return $response.StatusCode
}

# Connect in Azure with Service Principal
$spCredential = Get-AutomationPSCredential -Name 'AzureMonitor'
$tenantID = Get-AutomationVariable -Name 'tenant_id'

Try {
  Connect-AzAccount -ServicePrincipal -Credential $spCredential -Tenant $tenantId
}
catch {
  write-error "$($_.Exception)"
  throw "$($_.Exception)"
}

# Retrieve your Workspace Informations
$customerId = Get-AutomationVariable -Name 'workspace_id'
$sharedKey = Get-AutomationVariable -Name 'workspace_key'
$LogType = "AppRegistrationExpiration"

# Optional name of a field that includes the timestamp for the data.
$TimeStampField = ""

# Get the full list of Azure AD App Registrations and Azure AD Enterprise Applications (Service Principals)
$applications = Get-AzADApplication
$appWithCredentials = @()

Write-output 'Retrieving app registrations that have credentials...'

$appWithCredentials += $applications | Sort-Object -Property DisplayName | ForEach-Object {

  $application = $_

  Write-Verbose ('Fetching information for application {0}' -f $application.DisplayName)

  # Create an array with desired columns and fields
  $application | Get-AzADAppCredential -ErrorAction SilentlyContinue | Select-Object `
    -Property @{Name = 'DisplayName'; Expression = { $application.DisplayName } }, `
  @{Name = 'ObjectId'; Expression = { $application.Id } }, `
  @{Name = 'ApplicationId'; Expression = { $application.AppId } }, `
  @{Name = 'KeyId'; Expression = { $_.KeyId } }, `
  @{Name = 'KeyDisplayName'; Expression = { $_.displayName } }, `
  @{Name = 'Type'; Expression = { $_.Type } }, `
  @{Name = 'StartDate'; Expression = { $_.StartDateTime -as [datetime] } }, `
  @{Name = 'EndDate'; Expression = { $_.EndDateTime -as [datetime] } }
}

Write-output 'Validating expiration data...'
$timeStamp = Get-Date -format o
$today = (Get-Date).ToUniversalTime()
$warningDate = ($today).addDays(60)
$appWithCredentials | Sort-Object EndDate | ForEach-Object {
  # First if catches certificates & secrets that are expired
  if ($_.EndDate -lt $today) {
    $days = ($_.EndDate - $today).Days
    $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Expired'
    $_ | Add-Member -MemberType NoteProperty -Name 'TimeStamp' -Value "$timestamp"
    $_ | Add-Member -MemberType NoteProperty -Name 'DaysToExpiration' -Value $days
  }
  elseif ($_.EndDate -lt $warningDate) {
    $days = ($_.EndDate - $today).Days
    $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Expire Soon'
    $_ | Add-Member -MemberType NoteProperty -Name 'TimeStamp' -Value "$timestamp"
    $_ | Add-Member -MemberType NoteProperty -Name 'DaysToExpiration' -Value $days
  }
  else {
    $days = ($_.EndDate - $Today).Days
    $_ | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Valid'
    $_ | Add-Member -MemberType NoteProperty -Name 'TimeStamp' -Value "$timestamp"
    $_ | Add-Member -MemberType NoteProperty -Name 'DaysToExpiration' -Value $days
  }
}

# Convert the list in JSON format
$appWithCredentialsJSON = $appWithCredentials | convertto-json
 
# Submit data in Log Analytics Workspace
Try {
  Update-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($appWithCredentialsJSON)) -logType $logType
  Write-output 'Completed'
}
catch {
  write-error "$($_.Exception)"
  throw "$($_.Exception)"
}

  
