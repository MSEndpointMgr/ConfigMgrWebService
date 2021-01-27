# Variables
$SecretKey = "<SecretKey>"

# Construct TSEnvironment object
try {
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
}
catch [System.Exception] {
    Write-Warning -Message "Unable to construct Microsoft.SMS.TSEnvironment object" ; exit 1
}

# Construct web service proxy
try {
    $URI = "http://server.domain.local/ConfigMgrWebService/ConfigMgr.asmx"
    $WebService = New-WebServiceProxy -Uri $URI -ErrorAction Stop
}
catch [System.Exception] {
    Write-Warning -Message "An error occured while attempting to calling web service. Error message: $($_.Exception.Message)" ; exit 2
}

# Read and amend SMSTSUDAUsers by removing domain name leaving only the samAccountName
$UserName = ($TSEnvironment.Value("SMSTSUDAUsers")).Split("\")[1]

# Retrieve all deployed apps for the primary user
$Applications = $WebService.GetCMDeployedApplicationsByUser($SecretKey, $UserName)
if ($Applications -ne $null) {
    $AppCount = 0
    foreach ($Application in $Applications) {
        $AppCount++
        $AppVariableName = -join("APPLICATION", $AppCount.ToString("00"))
        $TSEnvironment.Value($AppVariableName) = $Application.ApplicationName
    }
}