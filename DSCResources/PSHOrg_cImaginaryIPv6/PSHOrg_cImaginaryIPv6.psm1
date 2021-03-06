# cImaginaryIPv6 DSC Resource
# Author: Adrian Calinescu (foo@snobu.org, @evilSnobu)
# Description: Enable/Disable IPv6 Transition Mechanisms: 6to4, Teredo, ISATAP
# Windows 8+ / Windows Server 2012+ only

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
	param
	(	
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Default","Enabled","Disabled")]
        [String]$SixToFour,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Automatic","Client","Default","Disabled","Enterpriseclient","Server")]
        [String]$Teredo,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Default","Enabled","Disabled")]
        [String]$ISATAP
	)
	  
    @{
        SixToFour = (Get-Net6to4Configuration).State
        Teredo = (Get-NetTeredoConfiguration).Type
        ISATAP = (Get-NetIsatapConfiguration).State
    }
} #Get-TargetResource


function Set-TargetResource
{
    [CmdletBinding()]
	param
	(	
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Default","Enabled","Disabled")]
        [String]$SixToFour,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Automatic","Client","Default","Disabled","Enterpriseclient","Server")]
        [String]$Teredo,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Default","Enabled","Disabled")]
        [String]$ISATAP
	)

        Write-Verbose "Bringing 6to4 into desired state $SixToFour.."
        Set-Net6to4Configuration -State $SixToFour -ErrorAction Continue

        Write-Verbose "Bringing Teredo into desired state $Teredo.."
        Set-NetTeredoConfiguration -Type $Teredo -ErrorAction Continue

        Write-Verbose "Bringing ISATAP into desired state $ISATAP.."
        Set-NetIsatapConfiguration -ResolutionState $ISATAP -ErrorAction Continue
        Set-NetIsatapConfiguration -State $ISATAP -ErrorAction Continue
} #Set-TargetResource


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
	param
	(		
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Default","Enabled","Disabled")]
        [String]$SixToFour,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Automatic","Client","Default","Disabled","Enterpriseclient","Server")]
        [String]$Teredo,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Default","Enabled","Disabled")]
        [String]$ISATAP
	)

        #Compare current state and desired state
        Write-Verbose "SixToFour is $((Get-Net6to4Configuration).State). Desired: $SixToFour"
        Write-Verbose "Teredo is $((Get-NetTeredoConfiguration).Type). Desired: $Teredo"
        Write-Verbose "ISATAP is $((Get-NetIsatapConfiguration).State). Desired: $ISATAP"
        Write-Verbose "ISATAP ResolutionState is $((Get-NetIsatapConfiguration).ResolutionState). Should be the same as Desired ISATAP ($ISATAP)."

        #If compliant, return $True, else $False
        $SixToFour -eq (Get-Net6to4Configuration).State -and
           $Teredo -eq (Get-NetTeredoConfiguration).Type -and
          ($ISATAP -eq (Get-NetIsatapConfiguration).State -and
           $ISATAP -eq (Get-NetIsatapConfiguration).ResolutionState)
} #Test-TargetResource

Export-ModuleMember -function *-TargetResource
