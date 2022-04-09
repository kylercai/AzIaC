@description('Specifies the location of AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the K2 workflow engine subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param k2SubnetAddressPrefix string = '10.1.2.0/24'

@description('Specifies the k2 subnet name.')
param k2SubnetName string = 'k2sqlsubnet'

@description('Specifies the K2 workflow engine SQL subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param k2SQLSubnetAddressPrefix string = '10.1.3.0/24'

@description('Specifies the k2 SQL vm subnet name.')
param k2SQLSubnetName string = 'k2sqlsubnet'

@description('Specifies the k2 SQL vm subnet name.')
param k2MySQLSubnetName string = 'k2mysqlsubnet'
@description('Specifies the K2 workflow engine SQL subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param k2MySQLSubnetAddressPrefix string = '10.1.4.0/24'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.1.1.0/26'

@description('Specifies the name of the subnet which contains the virtual machine.')
param vmSubnetName string = 'VmSubnet'

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param vmSubnetAddressPrefix string = '10.1.0.0/24'

@description('Specifies the name of the default subnet hosting the AKS cluster.')
param aksSubnetName string = 'AksSubnet'

@description('Specifies the address prefix of the subnet hosting the AKS cluster.')
param aksSubnetAddressPrefix string = '10.0.0.0/16'

@description('Specifies the name of the virtual network.')
param virtualNetworkName string

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetNsgName = '${bastionSubnetName}Nsg'

var vmSubnetNsgName = '${vmSubnetName}Nsg'
var k2SubnetNsgName = '${k2SubnetName}Nsg'
var k2SQLSubnetNsgName = '${k2SQLSubnetName}Nsg'
var k2MySQLSubnetNsgName = '${k2MySQLSubnetName}Nsg'

resource vmSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: vmSubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSshInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource bastionSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: bastionSubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'bastionInAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'bastionControlInAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRanges: [
            '443'
            '4443'
          ]
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
        }
      }
      {
        name: 'bastionInDeny'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 900
          direction: 'Inbound'
        }
      }
      {
        name: 'bastionVnetOutAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'bastionAzureOutAllow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource k2SubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: k2SubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDPInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
resource k2SQLSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: k2SQLSubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDPInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowSQLInbound'
        properties: {
          priority: 200
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '1433'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }      
    ]
  }
}

resource k2MySQLSubnetNsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: k2MySQLSubnetNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowMySQLInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3306'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: vmSubnetName
        properties: {
          addressPrefix: vmSubnetAddressPrefix
          networkSecurityGroup: {
            id: vmSubnetNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
          networkSecurityGroup: {
            id: bastionSubnetNsg.id
          }
        }
      }
      {
        name: k2SubnetName
        properties: {
          addressPrefix: k2SubnetAddressPrefix
          networkSecurityGroup: {
            id: k2SubnetNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: k2SQLSubnetName
        properties: {
          addressPrefix: k2SQLSubnetAddressPrefix
          networkSecurityGroup: {
            id: k2SQLSubnetNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: k2MySQLSubnetName
        properties: {
          addressPrefix: k2MySQLSubnetAddressPrefix
          networkSecurityGroup: {
            id: k2MySQLSubnetNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: bastionSubnetName
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: aksSubnetName
}

resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: vmSubnetName
}
resource k2Subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: k2SubnetName
}
resource k2SQLSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: k2SQLSubnetName
}
resource k2MySQLSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  parent: virtualNetwork
  name: k2MySQLSubnetName
}

output virtualNetworkResourceId string = virtualNetwork.id

// if I can use associative array then I can write match better code.
output bastionSubnetId string = bastionSubnet.id
output aksSubnetId string = aksSubnet.id
output vmSubnetId string = vmSubnet.id
output k2SubnetId string = k2Subnet.id
output k2SQLSubnetId string = k2SQLSubnet.id
output k2MySQLSubnetId string = k2MySQLSubnet.id
