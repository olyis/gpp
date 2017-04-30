function Get-GitFolder {
    $currentDir = Get-Item -Path '.' -Force
    while ($true) {
        $putativePath = $currentDir.FullName + "\.git"
        if (Test-Path $putativePath) {
            return Get-Item -Path $putativePath -Force
        }
        if ($currentDir.Parent -eq $null) {
            throw "No .git folder found"
        }
        $currentDir = $currentDir.Parent
    }
}

# TODO must include relative name part e.g. dev/branchName
function Get-Branch {
    $headsPath = (Get-GitFolder).FullName + "\refs\heads"
    if (Test-Path $headsPath) {
        Get-ChildItem -Path $headsPath -Recurse -File |
            % { @{Name = $_.Name; Ref = Get-Content -Path $_.FullName} }
    }
}

function Checkout-Branch {
    [CmdletBinding()]
    Param()

    DynamicParam {
        # Retrieve local branch names
        # TODO retrieve remotes or all based on optional flag param?
        $names = Get-Branch | % { $_.Name }

        # Define -Name parameter
        $nameAtts = New-Object System.Management.Automation.ParameterAttribute
        $nameAtts.HelpMessage = "Branch to checkout: $names"
        $nameAtts.Mandatory = $true
        $nameAtts.Position = 1
        $nameValidation = New-Object System.Management.Automation.ValidateSetAttribute($names)
        $nameParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], @($nameAtts, $nameValidation))

        # dynamic parameters to return
        $dynamicParams = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $dynamicParams.Add('Name', $nameParam)
        return $dynamicParams
    }

    Begin {
        $name = $PSBoundParameters.Name
    }

    Process {
        git checkout $name
    }
}