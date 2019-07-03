Configuration VstsAgentConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $packageBasePath = "C:\DSC_Packages"

    $arch = "win-x64"
    $version = "2.150.3"
    $vstsFile = "vsts-agent-$arch-$version.zip"

    $vstsUrl = "https://vstsagentpackage.azureedge.net/agent/$version/$vstsFile"
    $packagePath = "$packageBasePath\$vstsFile"
    $installPath = "C:\Vsts_Agent"

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
    }
}
