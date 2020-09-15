function Set-localProxy {
    param (
        [Parameter(Mandatory=$true)]
        [string]$set
    )
    if($set -eq "Yes"){

        netsh winhttp import proxy source=ie
        $Wcl = new-object System.Net.WebClient
        $Wcl.Headers.Add("user-agent", "PowerShell Script")
        $Wcl.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

    }
}




