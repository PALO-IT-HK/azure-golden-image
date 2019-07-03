Configuration VstsAgentConfig {
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

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
            DestinationPath = $packageBasePath
            Ensure = "Present"
        }

        xRemoteFile VstsPackage {
            Uri = $vstsUrl
            DestinationPath = $packagePath
        }

        Archive InstallVstsAgent {
            Ensure = "Present"
            Path = "$packagePath"
            Destination = "$installPath"
            DependsOn = "[xRemoteFile]VstsPackage"
        }
    }
}
