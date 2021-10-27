variable "region" {
  type        = string
  description = "Required : The Azure Region to deploy the VNET to"
  
  validation {
    condition = (
      contains(["eastus", "eastus2", "southcentralus", "westus2", "australiaeast", "southeastasia", "northeurope", "uksouth", "westeurope", "centralus", "northcentralus", "westus", "southafricanorth", "centralindia", "eastasia", "japaneast", "jioindiawest", "koreacentral", "canadacentral", "francecentral", "germanywestcentral", "norwayeast", "switzerlandnorth", "uaenorth", "brazilsouth", "centralusstage", "eastusstage", "eastus2stage", "northcentralusstage", "southcentralusstage", "westusstage", "westus2stage", "asia", "asiapacific", "australia", "brazil", "canada", "europe", "global", "india", "japan", "uk", "unitedstates", "eastasiastage", "southeastasiastage", "centraluseuap", "eastus2euap", "westcentralus", "westus3", "southafricawest", "australiacentral", "australiacentral2", "australiasoutheast", "japanwest", "koreasouth", "southindia", "westindia", "canadaeast", "francesouth", "germanynorth", "norwaywest", "switzerlandwest", "ukwest", "uaecentral", "brazilsoutheast"], var.region)
    )
    error_message = "The region is not valid."
  }
}

variable "name-vars" {
  description = "Required : Map with two keys account and name. Names of elements are created based on these values."
  type = map(string)

  validation {
    condition = (
      contains(keys(var.name-vars), "account") && 
      contains(keys(var.name-vars), "name")
    )
    error_message = "The input name-vars must contain two elements account and name."
  }
}

variable "vnet-name" {
  type        = string
  description = "Optional : Override the calculated VNET name."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Optional : A map of tags to assign to the resource."
  default     = {}
}

variable "resource-tags" {
  type        = map(map(string))
  description = "Optional : A map of maps of tags to assign to specifc resource types.  The key must be one of the following: azurerm_virtual_network, azurerm_resource_group, azurerm_subnet, azurerm_route_table, azurerm_network_security_group, azurerm_network_watcher_flow_log, azurerm_network_watcher, azurerm_public_ip, azurerm_virtual_network_gateway, or azurerm_express_route_circuit otherwise it will be ignored."
  default     = {}
}

variable "vnet-cidrs" {
  type        = list(string)
  description = "Required : List of CIDRs to apply to the VNET."
  default     = ["10.0.0.0/20"]
  validation {
    condition = (
      length(var.vnet-cidrs)>0
    )
    error_message = "At least one CIDR block must be provided."
  }
}

variable "domain_name_servers" {
  type        = list(string)
  description = "Optional : List of DNS Servers for DHCP Options"
  default     = []
}

variable "subnets" {
  type = map(list(string))
  description = "Optional : Keys are used for subnet names and values are the subnets for the various layers. 'pub' & 'GatewaySubnet' are the only special names used for the public and gateway subnets"
  default = {
    GatewaySubnet = ["10.0.0.0/27"]
    pub           = ["10.0.128.0/25"]
    web           = ["10.0.1.0/24"]
    app           = ["10.0.2.0/24"]
    db            = ["10.0.3.0/24"]
    mgt           = ["10.0.4.0/24"]
  }
}

variable "next_hop_in_ip_address" {
  type = map(string)
  description = "Optional : Override the default gatway for specific subnets. The keys must match those in subnets and the value must either be Internet or a appliance (e.g. Load Balancer, Firewall) IP address as the next hop. Defaults to Internet. If utilized 'pub' and 'GatewaySubnet' should not be specified."
  validation {
    condition = (
      !contains(keys(var.next_hop_in_ip_address),"GatewaySubnet") && 
      !contains(keys(var.next_hop_in_ip_address),"pub")
    )
    error_message = "GatewaySubnet should not override the next hop IP address."
  }
  default = {  }
}

variable "service_endpoints" {
  type = list(string)
  description = "(Optional) The list of Service endpoints to associate with the subnets. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web."
  default = []
}

variable "log-storage-account" {
  type = string
  description = "Required: Name or ID of the storage account in which to save the flow logs."
  default = ""
}

variable "log-retention" {
  type = number
  description = "Optional: Number of days to retain logs, default is 365"
  default = 365
}

variable "peer_vnet_id" {
  type = map(object({
    remote_virtual_network_id = string
    allow_virtual_network_access = bool
    allow_forwarded_traffic = bool
    allow_gateway_transit = bool
    use_remote_gateways = bool
  }))
  description = "Optional: Map of maps to manage virtual network peering which links VNETs together."
  default = {}
}

variable "express_route_circuit" {
  type = map(object({
    service_provider_name              = string
    peering_location                   = string
    bandwidth_in_mbps                  = number
    tier                               = string
    family                             = string
    peering_type                       = string 
    peer_asn                           = number
    primary_peer_address_prefix        = string
    shared_key                         = string
    secondary_peer_address_prefix      = string
    vlan_id                            = number
  }))
  description = "Optional: Map of maps to manage Express Route Circuits."
  default = {}
}

variable "azurerm_virtual_network_gateway_type" {
  type = string
  description = "(Optional) The type of the Virtual Network Gateway. Valid options are Vpn or ExpressRoute. Changing the type forces a new resource to be created. Default is ExpressRoute. Options to establish a VPN are not defined yet."
  default = "ExpressRoute"
}

variable "azurerm_virtual_network_gateway_enable_bgp" {
  type = string
  description = "(Optional) If true, BGP (Border Gateway Protocol) will be enabled for this Virtual Network Gateway. Defaults to true"
  default = "true"
}

variable "azurerm_virtual_network_gateway_sku" {
  type = string
  description = "(Optional) Configuration of the size and capacity of the virtual network gateway. Valid options are Basic, Standard, HighPerformance, UltraPerformance, ErGw1AZ, ErGw2AZ, ErGw3AZ, VpnGw1, VpnGw2, VpnGw3, VpnGw4,VpnGw5, VpnGw1AZ, VpnGw2AZ, VpnGw3AZ,VpnGw4AZ and VpnGw5AZ and depend on the type, vpn_type and generation arguments. A PolicyBased gateway only supports the Basic sku. Further, the UltraPerformance sku is only supported by an ExpressRoute gateway. Defaults to Standard."
  default = "Standard"
}

variable "network_watcher_name" {
  type = string
  description = "(Optional) The name of the Network Watcher to send flow logs. If this is not specified flowlogs will not be sent. Changing this forces a new resource to be created."
  default = ""
}

variable "set_subnet_specific_next_hop_in_ip_address" {
  type = map(string)
  description = "Optional : Sends routes for various subnets within the VNET via a security appliance such as a firewall. The keys must match those in subnets and the value must either be the appliance/LB IP address of the next hop. If utilized 'pub' should not be specified."
  validation {
    condition = (
      !contains(keys(var.set_subnet_specific_next_hop_in_ip_address),"pub")
    )
    error_message = "GatewaySubnet should not override the next hop IP address."
  }
  default = {}
}


  