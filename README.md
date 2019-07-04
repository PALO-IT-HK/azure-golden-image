# Azure Windows Golden Image
A sample repository to create Windows VM golden image on Azure

This repository demonstrate the source code and pipeline needed to build a golden image via Azure Resource Manager and Azure DevOps.


if testing dsc file locally on win vm.  go to directory of dsc file then run
```
$(ConfigurationName)
Start-DscConfiguration -Path .\$(ConfigurationName) -Wait -Force -Verbose
```
