# Terraform AWS Route53 Module 🌐

> **Comprehensive DNS management with health checks, traffic routing, and domain registration automation**

[![Terraform](https://img.shields.io/badge/Terraform-%E2%89%A5%201.3-623CE4?logo=terraform)](https://terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%E2%89%A5%205.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 **Overview**

This Terraform module manages AWS Route53 DNS services including hosted zones, record sets, health checks, and traffic policies. Designed for production DNS management with high availability, performance optimization, and automated failover capabilities.

## 🚀 **Features**

### **Core DNS Management**
- 🌐 **Hosted Zones** - Authoritative DNS zone management
- 📋 **Record Management** - A, AAAA, CNAME, MX, TXT, SRV records
- 🔄 **Alias Records** - AWS resource integration
- 🏥 **Health Checks** - Endpoint monitoring and failover
- 🎯 **Traffic Policies** - Advanced routing algorithms
- 🌍 **Geolocation Routing** - Geographic traffic distribution

### **Advanced Features**
- 📊 **Weighted Routing** - Load distribution across endpoints
- 🚀 **Latency-Based Routing** - Performance optimization
- 🔧 **Failover Routing** - Automatic disaster recovery
- 📈 **CloudWatch Integration** - DNS query metrics
- 🔒 **DNSSEC Support** - Domain security extensions
- 🌐 **Private Hosted Zones** - VPC-specific DNS resolution

## 📋 **Usage**

### **Basic Domain Setup**
```hcl
module "domain_dns" {
  source = "./terraform-aws-route53"

  # Primary Domain
  domain_name = "example.com"
  
  # Basic Records
  records = {
    # A Records
    "@" = {
      type = "A"
      ttl  = 300
      records = ["203.0.113.1"]
    }
    
    "www" = {
      type = "A"
      ttl  = 300
      records = ["203.0.113.1"]
    }
    
    # MX Records
    "@" = {
      type = "MX"
      ttl  = 3600
      records = [
        "10 mail.example.com",
        "20 mail2.example.com"
      ]
    }
    
    # TXT Records
    "@" = {
      type = "TXT"
      ttl  = 300
      records = [
        "v=spf1 include:_spf.google.com ~all",
        "google-site-verification=abc123..."
      ]
    }
  }
  
  project_name = "company-website"
  environment  = "production"
  
  tags = {
    Domain = "primary"
    Team   = "infrastructure"
  }
}
```

### **Multi-Region Setup with Health Checks**
```hcl
module "global_dns" {
  source = "./terraform-aws-route53"

  domain_name = "api.company.com"
  
  # Health Checks for Endpoints
  health_checks = {
    us_east_1 = {
      fqdn                     = "api-us-east-1.company.com"
      port                     = 443
      type                     = "HTTPS"
      resource_path            = "/health"
      failure_threshold        = 3
      request_interval         = 30
      cloudwatch_alarm_region  = "us-east-1"
      insufficient_data_health_status = "Failure"
      
      tags = {
        Name = "US East 1 API Health Check"
      }
    }
    
    us_west_2 = {
      fqdn                     = "api-us-west-2.company.com"
      port                     = 443
      type                     = "HTTPS"
      resource_path            = "/health"
      failure_threshold        = 3
      request_interval         = 30
      cloudwatch_alarm_region  = "us-west-2"
      insufficient_data_health_status = "Failure"
      
      tags = {
        Name = "US West 2 API Health Check"
      }
    }
    
    eu_west_1 = {
      fqdn                     = "api-eu-west-1.company.com"
      port                     = 443
      type                     = "HTTPS"
      resource_path            = "/health"
      failure_threshold        = 3
      request_interval         = 30
      cloudwatch_alarm_region  = "eu-west-1"
      insufficient_data_health_status = "Failure"
      
      tags = {
        Name = "EU West 1 API Health Check"
      }
    }
  }
  
  # Weighted Routing with Health Checks
  weighted_records = {
    "api" = {
      type = "A"
      
      endpoints = {
        us_east_1 = {
          records           = ["52.1.1.1"]
          weight           = 100
          health_check_id  = "us_east_1"
          set_identifier   = "US-East-1"
        }
        
        us_west_2 = {
          records           = ["52.2.2.2"]
          weight           = 50
          health_check_id  = "us_west_2"
          set_identifier   = "US-West-2"
        }
        
        eu_west_1 = {
          records           = ["52.3.3.3"]
          weight           = 25
          health_check_id  = "eu_west_1"
          set_identifier   = "EU-West-1"
        }
      }
    }
  }
  
  project_name = "global-api"
  environment  = "production"
}
```

### **Latency-Based Routing with CloudFront**
```hcl
module "cdn_dns" {
  source = "./terraform-aws-route53"

  domain_name = "cdn.company.com"
  
  # Latency-Based Routing
  latency_records = {
    "www" = {
      type = "A"
      
      regions = {
        us_east_1 = {
          records        = ["d123456.cloudfront.net"]
          region         = "us-east-1"
          set_identifier = "US-East-CloudFront"
          health_check_id = "us_east_cloudfront"
        }
        
        eu_west_1 = {
          records        = ["d789012.cloudfront.net"]
          region         = "eu-west-1"
          set_identifier = "EU-West-CloudFront"
          health_check_id = "eu_west_cloudfront"
        }
        
        ap_southeast_1 = {
          records        = ["d345678.cloudfront.net"]
          region         = "ap-southeast-1"
          set_identifier = "APAC-CloudFront"
          health_check_id = "apac_cloudfront"
        }
      }
    }
  }
  
  # CloudFront Health Checks
  health_checks = {
    us_east_cloudfront = {
      cloudfront_hosted_zone_id = "Z2FDTNDATAQYW2"
      fqdn                     = "d123456.cloudfront.net"
      type                     = "HTTPS"
      resource_path            = "/"
      failure_threshold        = 3
    }
    
    eu_west_cloudfront = {
      cloudfront_hosted_zone_id = "Z2FDTNDATAQYW2"
      fqdn                     = "d789012.cloudfront.net"
      type                     = "HTTPS"
      resource_path            = "/"
      failure_threshold        = 3
    }
    
    apac_cloudfront = {
      cloudfront_hosted_zone_id = "Z2FDTNDATAQYW2"
      fqdn                     = "d345678.cloudfront.net"
      type                     = "HTTPS"
      resource_path            = "/"
      failure_threshold        = 3
    }
  }
  
  project_name = "global-cdn"
  environment  = "production"
}
```

### **Geolocation Routing for Compliance**
```hcl
module "compliance_dns" {
  source = "./terraform-aws-route53"

  domain_name = "app.company.com"
  
  # Geolocation-Based Routing
  geolocation_records = {
    "www" = {
      type = "A"
      
      locations = {
        # Default (Worldwide)
        default = {
          records        = ["global.company.com"]
          location_type  = "default"
          set_identifier = "Global-Default"
        }
        
        # European Union
        eu = {
          records        = ["eu.company.com"]
          location_type  = "continent"
          continent_code = "EU"
          set_identifier = "EU-Compliance"
          health_check_id = "eu_compliance"
        }
        
        # United States
        us = {
          records        = ["us.company.com"]
          location_type  = "country"
          country_code   = "US"
          set_identifier = "US-Domestic"
          health_check_id = "us_domestic"
        }
        
        # China (Special Handling)
        china = {
          records        = ["cn.company.com"]
          location_type  = "country"
          country_code   = "CN"
          set_identifier = "China-Specific"
          health_check_id = "china_specific"
        }
        
        # California (State-level)
        california = {
          records        = ["ca.company.com"]
          location_type  = "subdivision"
          country_code   = "US"
          subdivision_code = "CA"
          set_identifier = "California-CCPA"
          health_check_id = "california_ccpa"
        }
      }
    }
  }
  
  project_name = "compliance-routing"
  environment  = "production"
  
  tags = {
    Compliance = "GDPR-CCPA"
    DataSovereignty = "required"
  }
}
```

### **Failover Configuration with Monitoring**
```hcl
module "disaster_recovery_dns" {
  source = "./terraform-aws-route53"

  domain_name = "critical-app.company.com"
  
  # Failover Routing
  failover_records = {
    "www" = {
      type = "A"
      
      primary = {
        records         = ["primary.company.com"]
        set_identifier  = "Primary-Site"
        failover        = "PRIMARY"
        health_check_id = "primary_site"
      }
      
      secondary = {
        records         = ["dr.company.com"]
        set_identifier  = "DR-Site"
        failover        = "SECONDARY"
        health_check_id = "dr_site"
      }
    }
  }
  
  # Comprehensive Health Checks
  health_checks = {
    primary_site = {
      fqdn                            = "primary.company.com"
      port                            = 443
      type                            = "HTTPS_STR_MATCH"
      resource_path                   = "/health"
      failure_threshold               = 3
      request_interval                = 10  # Fast failover
      search_string                   = "OK"
      cloudwatch_alarm_region         = "us-east-1"
      insufficient_data_health_status = "Failure"
      enable_sni                      = true
      
      tags = {
        Site = "Primary"
        Critical = "true"
      }
    }
    
    dr_site = {
      fqdn                            = "dr.company.com"
      port                            = 443
      type                            = "HTTPS_STR_MATCH"
      resource_path                   = "/health"
      failure_threshold               = 3
      request_interval                = 30
      search_string                   = "OK"
      cloudwatch_alarm_region         = "us-west-2"
      insufficient_data_health_status = "Success"  # Always healthy for DR
      enable_sni                      = true
      
      tags = {
        Site = "DR"
        Critical = "true"
      }
    }
  }
  
  # Health Check Alarms
  health_check_alarms = {
    primary_site = {
      alarm_name          = "Primary-Site-Health-Check-Failed"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = "2"
      threshold           = "1"
      alarm_description   = "Primary site health check failed"
      alarm_actions       = [aws_sns_topic.critical_alerts.arn]
    }
  }
  
  project_name = "disaster-recovery"
  environment  = "production"
}
```

### **Private Hosted Zone for Internal Services**
```hcl
module "internal_dns" {
  source = "./terraform-aws-route53"

  # Private Hosted Zone
  domain_name = "internal.company.local"
  zone_type   = "private"
  
  # VPC Associations
  vpc_associations = [
    {
      vpc_id     = module.networking.vpc_id
      vpc_region = "us-east-1"
    },
    {
      vpc_id     = module.dr_networking.vpc_id
      vpc_region = "us-west-2"
    }
  ]
  
  # Internal Service Records
  records = {
    # Database Cluster
    "db-primary" = {
      type = "CNAME"
      ttl  = 60
      records = ["db-cluster.cluster-xyz.us-east-1.rds.amazonaws.com"]
    }
    
    "db-readonly" = {
      type = "CNAME"
      ttl  = 60
      records = ["db-cluster.cluster-xyz.us-east-1.rds.amazonaws.com"]
    }
    
    # Internal Load Balancers
    "api-internal" = {
      type = "A"
      ttl  = 300
      records = ["10.0.1.100"]
    }
    
    # Service Discovery
    "user-service" = {
      type = "A"
      ttl  = 30
      records = ["10.0.2.100", "10.0.2.101", "10.0.2.102"]
    }
    
    "order-service" = {
      type = "A"
      ttl  = 30
      records = ["10.0.3.100", "10.0.3.101"]
    }
    
    # SRV Records for Service Discovery
    "_http._tcp.user-service" = {
      type = "SRV"
      ttl  = 60
      records = [
        "1 5 8080 user1.internal.company.local",
        "1 5 8080 user2.internal.company.local",
        "2 5 8080 user3.internal.company.local"
      ]
    }
  }
  
  project_name = "internal-services"
  environment  = "production"
  
  tags = {
    Zone = "private"
    Purpose = "service-discovery"
  }
}
```

## 📝 **Input Variables**

### **Required Variables**
| Name | Description | Type |
|------|-------------|------|
| `domain_name` | Domain name for hosted zone | `string` |

### **Hosted Zone Configuration**
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `zone_type` | Hosted zone type (public/private) | `string` | `"public"` |
| `comment` | Hosted zone comment | `string` | `""` |
| `delegation_set_id` | Delegation set ID | `string` | `""` |
| `force_destroy` | Allow zone deletion | `bool` | `false` |

### **Record Configuration**
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `records` | DNS record definitions | `map(object)` | `{}` |
| `alias_records` | AWS alias records | `map(object)` | `{}` |
| `weighted_records` | Weighted routing records | `map(object)` | `{}` |
| `latency_records` | Latency-based routing records | `map(object)` | `{}` |
| `geolocation_records` | Geolocation routing records | `map(object)` | `{}` |
| `failover_records` | Failover routing records | `map(object)` | `{}` |

### **Health Check Configuration**
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `health_checks` | Health check definitions | `map(object)` | `{}` |
| `health_check_alarms` | CloudWatch alarms for health checks | `map(object)` | `{}` |

### **Private Zone Configuration**
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `vpc_associations` | VPC associations for private zones | `list(object)` | `[]` |

## 📤 **Outputs**

| Name | Description |
|------|-------------|
| `hosted_zone_id` | Route53 hosted zone ID |
| `hosted_zone_arn` | Route53 hosted zone ARN |
| `name_servers` | Name servers for the hosted zone |
| `hosted_zone_name` | Name of the hosted zone |
| `record_names` | Names of created records |
| `record_fqdns` | FQDNs of created records |
| `health_check_ids` | IDs of created health checks |
| `health_check_arns` | ARNs of created health checks |

## 🏗️ **Architecture**

```
                    ┌─────────────────┐
                    │   DNS Query     │
                    │  (example.com)  │
                    └─────────┬───────┘
                              │
                    ┌─────────▼───────┐
                    │    Route53      │
                    │  Hosted Zone    │
                    └─────────┬───────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Primary   │     │Health Check │     │ Secondary   │
│  Endpoint   │     │ Monitoring  │     │ Endpoint    │
│ (US-East-1) │     │             │     │ (US-West-2) │
└─────────┬───┘     └─────────┬───┘     └─────────┬───┘
          │                   │                   │
          ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│Application  │     │ CloudWatch  │     │Application  │
│Load Balancer│     │   Alarms    │     │Load Balancer│
└─────────────┘     └─────────────┘     └─────────────┘
```

## 🔒 **Security Best Practices**

### **DNS Security**
- 🔐 **DNSSEC** - Domain Name System Security Extensions
- 🛡️ **Private Zones** - Internal service resolution
- 🔒 **IAM Policies** - Granular access control
- 📊 **Query Logging** - DNS query monitoring

### **Health Check Security**
- 🎯 **String Matching** - Content validation
- 🔒 **SNI Support** - SSL/TLS verification
- 🛡️ **Regional Isolation** - Multi-region monitoring
- 📈 **Alarm Integration** - Automated incident response

### **Access Control**
- 🔐 **Resource Policies** - Cross-account access
- 🛡️ **VPC Associations** - Private zone security
- 📊 **CloudTrail Logging** - API call auditing
- 🚨 **Anomaly Detection** - Unusual DNS patterns

## 💰 **Cost Optimization**

### **Pricing Components**
- **Hosted Zones**: $0.50 per hosted zone per month
- **Standard Queries**: $0.40 per million queries
- **Latency-Based Queries**: $0.60 per million queries
- **Geo DNS Queries**: $0.70 per million queries
- **Health Checks**: $0.50 per health check per month
- **Traffic Flow**: $50.00 per policy record per month

### **Cost-Saving Strategies**
- 🎯 **Query Optimization** - Reduce unnecessary queries
- 📊 **TTL Tuning** - Balance freshness and query reduction
- 🔄 **Health Check Consolidation** - Minimize health check count
- 📈 **Regional Optimization** - Use appropriate routing types

## 🧪 **Examples**

Check the [examples](examples/) directory for complete implementations:

- **[Global Website](examples/global-website/)** - Multi-region website deployment
- **[API Gateway](examples/api-gateway-dns/)** - REST API DNS management
- **[Microservices](examples/microservices-dns/)** - Service discovery setup
- **[Disaster Recovery](examples/disaster-recovery/)** - Failover configuration

## 🔧 **Requirements**

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0 |

## 🧪 **Testing**

```bash
# Validate Terraform configuration
terraform validate

# Test DNS resolution
nslookup example.com

# Check health check status
aws route53 get-health-check --health-check-id Z123456789

# Monitor DNS queries
aws route53 get-query-logging-config --id Z123456789

# Test failover
dig @8.8.8.8 www.example.com
```

## 📊 **Performance Optimization**

### **Query Performance**
- ⚡ **TTL Optimization** - Balance caching and freshness
- 🎯 **Anycast Network** - Global DNS resolution
- 📈 **Routing Policies** - Intelligent traffic distribution
- 🔄 **Health Check Intervals** - Optimal failover timing

### **Monitoring and Alerting**
```hcl
# DNS query monitoring
resource "aws_cloudwatch_metric_alarm" "dns_queries" {
  alarm_name          = "high-dns-query-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "QueryCount"
  namespace           = "AWS/Route53"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10000"
  alarm_description   = "High DNS query rate detected"
  
  dimensions = {
    HostedZoneId = aws_route53_zone.main.zone_id
  }
}
```

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/dns-enhancement`)
3. Commit your changes (`git commit -m 'Add DNS enhancement'`)
4. Push to the branch (`git push origin feature/dns-enhancement`)
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 **Related Modules**

- **[terraform-aws-acm](../terraform-aws-acm)** - SSL certificate integration
- **[terraform-aws-cloudfront](../terraform-aws-cloudfront)** - CDN domain configuration
- **[terraform-aws-networking](../terraform-aws-networking)** - Private zone VPC setup
- **[terraform-aws-cloudwatch](../terraform-aws-cloudwatch)** - DNS monitoring

---

**🌐 Built for enterprise-grade DNS management and traffic routing**

> *This module demonstrates advanced Route53 architecture patterns and DNS expertise suitable for production environments requiring global traffic distribution, high availability, and automated failover capabilities.*