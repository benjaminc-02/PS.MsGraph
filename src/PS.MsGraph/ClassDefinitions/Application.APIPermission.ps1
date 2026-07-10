# Contains the API Permissions that are tied to the application.
class PS_MsGraph_Application_APIPermission {
    # The Description of the API Permission.
    [string]$Description

    # The Id of the API Permission.
    [string]$Id

    # The Name of the API Permission.
    [string]$Name

    # The App Id of the Resource App that the API Permission is tied from.
    [string]$ResourceAppId

    # The DisplayName of the Resource App that the API Permission is tied from.
    [string]$ResourceAppName

    # The Type of API Permission.
    [ValidateSet('Delegated', 'Application')][string]$Type = 'Delegated'

    # Overloads
    PS_MsGraph_Application_APIPermission() {}
    PS_MsGraph_Application_APIPermission($Description, $Id, $Name, $ResourceAppId, $ResourceAppName, $Type) {
        $this.Description = $Description
        $this.Id = $Id
        $this.Name = $Name
        $this.ResourceAppId = $ResourceAppId
        $this.ResourceAppName = $ResourceAppName
        $this.Type = $Type
    }

    # Methods
    [string]ToString() {
        return ('{0}.{1}' -f $this.Type, $this.Name)
    }
}