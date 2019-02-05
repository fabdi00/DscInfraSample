Write-Warning "---------->> Starting Configuration"
$BuildVersion = $Env:BuildVersion
Import-Module DscBuildHelpers -Scope Global

configuration "RootConfiguration"
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    #That Module is a configuration, should be defined in Configuration.psd1
    Import-DscResource -ModuleName SharedDscConfig -ModuleVersion 0.0.4
    Import-DscResource -ModuleName Chocolatey -ModuleVersion 0.0.58

    $module = Get-Module PSDesiredStateConfiguration
    $null = & $module {param($tag) $PSTopConfigurationName = "MOF_$($tag)" } "$BuildVersion"

    node $ConfigurationData.AllNodes.NodeName {
        $(Write-Warning "Processing Node $($Node.Name) : $($Node.nodeName)")
        (Lookup 'Configurations').Foreach{
            $ConfigurationName = $_
            $(Write-Warning "`tLooking up params for $ConfigurationName")
            $Properties = $(lookup $ConfigurationName -DefaultValue @{})
            Get-DscSplattedResource -ResourceName $ConfigurationName -ExecutionName $ConfigurationName -Properties $Properties
        }
    }
}

RootConfiguration -ConfigurationData $ConfigurationData -Out "$BuildRoot\BuildOutput\MOF\"
