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

# Retrieve your Workspace Informations
$customerId = Get-AutomationVariable -Name 'workspace_id'
$sharedKey = Get-AutomationVariable -Name 'workspace_key'
$tenant_id = Get-AutomationVariable -Name 'tenant_id'
$credentials = Get-AutomationPSCredential -Name 'AzureMonitor'
$ClientCertificate = Get-AutomationCertificate -Name 'MyAzure'
$LogType = "AppRegistrationAudit"

# Optional name of a field that includes the timestamp for the data.
$TimeStampField = ""

$accessToken = Get-MsalToken -TenantId $tenant_id -ClientId $credentials.UserName -ClientCertificate $ClientCertificate | Select-Object -Property AccessToken

# MS Graph Apps URI

$aadAppsURI = 'https://graph.microsoft.com/v1.0/applications'

# MS Graph Directory Audit URI

$signInsURI = 'https://graph.microsoft.com/v1.0/auditLogs/directoryAudits'

# Report Template

$aadAppReportTemplate = [pscustomobject][ordered]@{
  displayName     = $null
  createdDateTime = $null
  signInAudience  = $null
}

# Get Apps

$aadApplications = @()
$Logs = @()

$aadApps = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } -Uri  $aadAppsURI -Method Get

if ($aadApps.value) {

  $aadApplications += $aadApps.value

  # More Apps?

  if ($aadApps.'@odata.nextLink') {

    $nextPageURI = $aadApps.'@odata.nextLink'

    do {

      $aadApps = $null

      $aadApps = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } -Uri  $nextPageURI -Method Get

      if ($aadApps.value) {

        $aadApplications += $aadApps.value

        $aadApplications.value.Count

      }

      if ($aadApps.'@odata.nextLink') {

        $nextPageURI = $aadApps.'@odata.nextLink'

      }

      else {

        $nextPageURI = $null

      }

    } until (!$nextPageURI)

  }

}

$aadApplications = $aadApplications | Sort-Object -Property createdDateTime -Descending

foreach ($app in $aadApplications) {

  # Report Output

  $reportData = $aadAppReportTemplate.PsObject.Copy()
  $reportData.displayName = $app.displayName
  $reportData.createdDateTime = $app.createdDateTime
  $reportData.signInAudience = $app.signInAudience

  # SignIns

  $appSignIns = $null

  $appSignIns = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } -Uri "$($signInsURI)?&`$filter=targetResources/any(t: t/id eq `'$($app.id)`')" -Method Get

  if ($appSignIns.value) {

    $Log = New-Object System.Object

    $Log | Add-Member -MemberType NoteProperty -Name "ApplicationName" -Value $app.DisplayName
    $Log | Add-Member -MemberType NoteProperty -Name "AppId" -Value $app.AppId
    $Log | Add-Member -MemberType NoteProperty -Name "RecentSignIns" -Value $appSignIns.value.count

    $Logs += $Log

  }

  else {

    $Log = New-Object System.Object

    $Log | Add-Member -MemberType NoteProperty -Name "ApplicationName" -Value $app.DisplayName
    $Log | Add-Member -MemberType NoteProperty -Name "AppId" -Value $app.AppId
    $Log | Add-Member -MemberType NoteProperty -Name "RecentSignIns" -Value $appSignIns.value.count

    $Logs += $Log

  }
    
  $appAudit = $Logs | convertto-json

}

Update-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($appAudit)) -logType $logType