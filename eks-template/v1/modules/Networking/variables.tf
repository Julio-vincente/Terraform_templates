variable "subnets" {
  default = {
    pub-1a  = { az = "us-east-1a", cidr = "172.16.10.0/24", type = "public" }
    pub-1b  = { az = "us-east-1b", cidr = "172.16.20.0/24", type = "public" }
    priv-1a = { az = "us-east-1a", cidr = "172.16.30.0/24", type = "private" }
    priv-1b = { az = "us-east-1b", cidr = "172.16.40.0/24", type = "private" }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# variable "sg-ALBEgress" {
#     default = {
#         rule1 = {ip_protocol="tcp", cidr_ipv4="0.0.0.0/0", from_port=443, to_port=443}
#         rule2 = {ip_protocol="tcp", cidr_ipv4="0.0.0.0/0", from_port=80, to_port=80}
#     } 
# }
