Configuration VstsAgentConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $packageBasePath = "C:\DSC_Packages"

    $arch = "win-x64"
    $version = "2.150.3"
    $vstsFile = "vsts-agent-$arch-$version.zip"

    $vstsUrl = "https://vstsagentpackage.azureedge.net/agent/$version/$vstsFile"
    $packagePath = "$packageBasePath\$vstsFile"
    $installPath = "C:\Vsts_Agent"

    $DnsName = "127.0.0.1"

    $Cert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $DnsName -Verbose
    $Password = ConvertTo-SecureString -String $DnsName -Force -AsPlainText -Verbose

    Export-Certificate -Cert $Cert -FilePath .\$DnsName.cer -Verbose
    Export-PfxCertificate -Cert $Cert -FilePath .\$DnsName.pfx -Password $Password -Verbose

    $CertThumbprint = $Cert.Thumbprint

    Node VstsAgent {
        File DownloadFolder {
            Type = "Directory"
            DestinationPath = "$packageBasePath"
            Ensure = "Present"
        }

        Script DownloadVstsAgent {
            SetScript = {
                Write-Host $vstsUrl
                Invoke-WebRequest -Uri "$using:vstsUrl" -OutFile "$using:packagePath"
            }
            GetScript = {
                @{
                    Result = $(Test-Path "$using:packagePath")
                }
            }
            TestScript = {
                Write-Verbose "Testing $using:packagePath"
                Test-Path "$using:packagePath"
            }
        }

        Archive InstallVstsAgent {
            Ensure = "Present"
            Path = "$packagePath"
            Destination = "$installPath"
        }

        Script EnableRemote {
            SetScript = {
                Enable-PSRemoting -Force -Verbose
                Set-Item WSMan:\localhost\Client\TrustedHosts * -Force -Verbose
                New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $CertThumbprint -Force -Verbose
                Restart-Service WinRM -Verbose
                New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "WinRMHTTPSIn" -Profile Any -LocalPort 5986 -Protocol TCP -Verbose
            }
            TestScript = {
              # Test-Path "C:\TempFolder\TestFile.txt"
            }
            GetScript = {
                @{
                    Result = (Get-Content C:\TempFolder\TestFile.txt)
                }
            }
        }
    }
}
