function Get-GitFolder {
    Param(
        [switch]
        $Throw
    )
    $currentDir = Get-Item -Path '.' -Force
    while ($true) {
        $putativePath = $currentDir.FullName + "\.git"
        if (Test-Path $putativePath) {
            return Get-Item -Path $putativePath -Force
        }
        if ($currentDir.Parent -eq $null) {
            if ($Throw) {
                throw "No .git folder found"
            } else {
                return
            }
        }
        $currentDir = $currentDir.Parent
    }
}

function Get-Branch {
    Param(
        [switch]
        $Remote
    )

    $branchesPath = (Get-GitFolder -Throw).FullName + "\refs\" + $(if ($remote) { "remotes\" } else { "heads\" })

    function cutPrefix([string] $prefix, [string] $target) {
        $index = $target.IndexOf($prefix)
        if ($index -gt -1) {
            return $target.Substring($index + $prefix.Length)
        } else {
            return $target
        }
    }

    if (Test-Path $branchesPath) {
        Get-ChildItem -Path $branchesPath -Recurse -File |
            % {@{
                    Name = (cutPrefix -prefix $branchesPath -target $_.FullName).Replace('\', '/')
                    Target = Get-Content -Path $_.FullName
                }}
    }
}

function Checkout-Branch {
    [CmdletBinding()]
    Param(
        [Parameter(position=1)]
        [switch] $Remote
    )

    DynamicParam {
        # Retrieve branch names
        $names = Get-Branch -Remote:$Remote | % { $_.Name }

        # Define -Name parameter
        $nameAtts = New-Object System.Management.Automation.ParameterAttribute
        $nameAtts.HelpMessage = "Branch to checkout: $names"
        $nameAtts.Mandatory = $true
        $nameAtts.Position = 0
        $nameValidation = New-Object System.Management.Automation.ValidateSetAttribute($names)
        $nameParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [String], @($nameAtts, $nameValidation))

        # Dynamic parameters to return
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