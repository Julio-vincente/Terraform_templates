resource "aws_networkfirewall_firewall_policy" "example" {
  name = "example"

  firewall_policy {
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.example.arn
    }
    tls_inspection_configuration_arn = "arn:aws:network-firewall:REGION:ACCT:tls-configuration/example"
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }
}