Azure VNET
=============

This module deploys an Azure VNET and all necessary components to prepare an environment for connectivity to the Internet and Express Route.

The goal of this project is to provide a streamlined, simple Terraform script to deploy and start running a network in Azure.


Example
------------
```
module "vnet" {
  source = "git::https://github.com/fstuck37/terraform-azure-vnet.git"
  log-storage-account = var.log-storage-account
  region = var.region
  name-vars = var.name-vars
  vnet-cidrs = var.vnet-cidrs
  subnets = var.subnets  
  domain_name_servers = var.domain_name_servers
  tags = var.tags
}

variable "log-storage-account" {
  default = "/subscriptions/12345678-abcd-1234-def1-1234567890ab/resourceGroups/rg_storageaccount/providers/Microsoft.Storage/storageAccounts/logsexample"
}

variable "region" {
  default = "eastus2"
}

variable "name-vars" {
  type = map(string)
  default = {
    account = "dev"
    name    = "poc"
  }
}

variable "vnet-cidrs" {
  type = list(string)
  default = ["172.16.0.0/22"]
}

variable "subnets" {
  type = map(list(string))
  default = {
    pub   = ["172.16.0.0/24"]
    priv1 = ["172.16.1.0/24"]
    priv2 = ["172.16.2.0/24"]
    priv3 = ["172.16.3.0/24"]
  }
}

variable "domain_name_servers" {
  type = list(string)
  default = ["8.8.8.8", "8.8.4.4"]
}

variable "tags" {
  type = map(string)
  default = {
    dept = "Development"
    Billing = "12345"
    Contact = "F. Stuck"
    Environment = "POC"
    Notes  = "This is a test environment"
  }
}
```

Argument Reference
------------
   * **region** - Required : The Azure Region to deploy the VNET to.
   * **name-vars** - Required : Map with two keys account and name. Names of elements are created based on these values.
   * **vnet-name** - Optional : Override the calculated VNET name.
   * **tags** - Optional : A map of tags to assign to the resource.
   * **resource-tags** - Optional : A map of maps of tags to assign to specifc resource types.  The key must be one of the following: azurerm_virtual_network, azurerm_resource_group, azurerm_subnet, azurerm_route_table, azurerm_network_security_group, azurerm_network_watcher_flow_log, azurerm_network_watcher, azurerm_public_ip, azurerm_virtual_network_gateway, or azurerm_express_route_circuit otherwise it will be ignored.
   ```
   variable "resource-vars" {
     default = {
       azurerm_virtual_network = {
         vnet-tag = "test vnet"
       }
       azurerm_subnet = {
         subnet-tag = "test subnet"
       }
     }
   }
   ```
   * **vnet-cidrs** - Required : List of CIDRs to apply to the VNET.
   * **domain_name_servers** - Optional : List of DNS Servers for DHCP Options
   * **default_deny_all** - Optional : Boolean to add default deny statements to security groups. Defaults to true.
   * **subnets** - Optional : Keys are used for subnet names and values are the subnets for the various layers. 'pub' & 'GatewaySubnet' are the only special names used for the public and gateway subnets
   * **next_hop_in_ip_address** - Optional : Override the default gatway for specific subnets. The keys must match those in subnets and the value must either be Internet or a appliance (e.g. Load Balancer, Firewall) IP address as the next hop. Defaults to Internet. If utilized 'pub' and 'GatewaySubnet' should not be specified.
   ```
   variable "next_hop_in_ip_address" {
     type = map(string)
     default = {
       priv1 = "172.16.1.5"
       priv2 = "172.16.2.5"
       priv3 = "172.16.3.5"
     }
   }
   ```
   * **service_endpoints** - (Optional) The list of Service endpoints to associate with the subnets. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web.
   * **log-storage-account** - Required: Name or ID of the storage account in which to save the flow logs.
   * **log-retention** - Optional: Number of days to retain logs, default is 365
   * **peer_vnet_id** - Optional: Map of maps to manage virtual network peering which links VNETs together.
   ```
   variable "peer_vnet_id" {
     default = {
       vnet2 = {
         remote_virtual_network_id    = "test"
         allow_virtual_network_access = true
         allow_forwarded_traffic      = false
         allow_gateway_transit        = false
         use_remote_gateways          = false
       }
       vnet3 = {
         remote_virtual_network_id    = "test"
         allow_virtual_network_access = true
         allow_forwarded_traffic      = false
         allow_gateway_transit        = false
         use_remote_gateways          = false
       }
     }
   }
   ```
   * **express_route_circuit** - Optional: Map of maps to manage Express Route Circuits.
   ```
   variable "express_route_circuit" {
     default = {
       primary = {
         service_provider_name         = "Equinix"
         peering_location              = "Washington DC"
         bandwidth_in_mbps             = 500
         tier                          = "Standard"
         family                        = "MeteredData"
         peering_type                  = "AzurePrivatePeering" 
         peer_asn                      = 65001
         primary_peer_address_prefix   = "172.16.254.0/30"
         shared_key                    = "lzdshflkdsjflsdf"
         secondary_peer_address_prefix = "172.16.254.4/30"
         vlan_id                       = 100
       }
       secondary = {
         service_provider_name         = "Equinix"
         peering_location              = "Seattle WA"
         bandwidth_in_mbps             = 500
         tier                          = "Standard"
         family                        = "MeteredData"
         peering_type                  = "AzurePrivatePeering" 
         peer_asn                      = 65002
         primary_peer_address_prefix   = "172.16.254.8/30"
         shared_key                    = "lzdshflkdsjflsdf"
         secondary_peer_address_prefix = "172.16.254.16/30"
         vlan_id                       = 200
       }
     }
   }
   ```
   * **azurerm_virtual_network_gateway_type** - (Optional) The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute. Changing the type forces a new resource to be created. Default is ExpressRoute. Options to establish a VPN are not defined yet.
   * **azurerm_virtual_network_gateway_enable_bgp** - (Optional) If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway. Defaults to true
   * **azurerm_virtual_network_gateway_sku** - (Optional) Configuration of the size and capacity of the virtual network gateway. Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4,VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ,VpnGw4AZ and VpnGw5AZ and depend on the type, vpn_type and generation arguments. A PolicyBased gateway only supports the Basic sku. Further, the UltraPerformance sku is only supported by an ExpressRoute gateway. Defaults to Standard.
   * **network_watcher_name** - (Optional) The name of the Network Watcher to send flow logs. If this is not specified flowlogs will not be sent. Changing this forces a new resource to be created.
   * **set_subnet_specific_next_hop_in_ip_address** - Optional : Sends routes for various subnets within the VNET via a security appliance such as a firewall. The keys must match those in subnets and the value must either be the appliance/LB IP address of the next hop. If utilized 'pub' should not be specified.
   ```
   variable "set_subnet_specific_next_hop_in_ip_address" {
     default = {
       priv1 = "172.16.1.5"
       priv2 = "172.16.2.5"
       priv3 = "172.16.3.5"
     }
   }
   ```

Output Reference
------------
   * **azurerm_virtual_network_id** - VNET id
   * **azurerm_virtual_network_name** - VNET Name
   * **subnets** - Map of subnets where the keys are those in the subnets argument and the elements are the subnet's address_prefix, address_prefixes, id, and name.
   * **route_table_ids** - Map of route tables where the keys are those in the subnets argument and the value is the route table's ID
   * **azurerm_resource_group_name** - The name of teh Resource Group
   * **network_security_group_names** - Map of security groups where the keys are those in the subnets argument and the value is the security group's name.
