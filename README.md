# DNS forward to aws

How to resolve Route 53 private hosted zones from an on-premises network via an Ubuntu instance?

You can resolve domain names for private zones from your on-premises network by configuring a DNS redirector. The instructions assume that your on-premises network is configured using a VPN or AWS Direct Connect in AWS VPC and that a private Route 53 hosted zone is associated with this VPC.

- Based upon bind9 named
- Embed Prometheus bind exporter
- Forward incoming DNS requests to the AWS DNS of the VPC
- Self-discovery of VPN DNS by AWS metadata

## Based 
Based on the [dnsforwardaws from Cohesive Networks](https://github.com/cohesive/dockerfiles/blob/master/dnsforwardaws )


## Docker Network
- port 53 tcp and udp for bind9 named
- port 9153 tcp for Prometheus bind exporter