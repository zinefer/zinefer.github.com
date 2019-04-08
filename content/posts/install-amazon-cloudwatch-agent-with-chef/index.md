+++
date = "2019-04-07T19:40:47-06:00"
title = "Install Amazon Cloudwatch Agent with Chef"
description = "Quick-guide to install the AWS Cloudwatch Agent"
categories = "Software"
tags = ["AWS", "Cloudwatch", "Chef", "System Administration", "Ruby"]
+++

This guide will give a quick outline on how to create a Chef recipe to install the Cloudwatch Agent. With the agent you can push system metrics and logs. The machine doesn't even need to be inside AWS (they refer to this situation as on-premise) to use these tools.

# Steps

- Add aws_cookbook dependancy
- Create credentials databag
- Create Cloudwatch config
- Create recipe to tie it all together

# Add `aws_cookbook` dependancy

We'll be using [aws_cloudwatch](https://github.com/gp42/aws_cloudwatch) to install the agent.

# Create credentials databag

I chose to encrypt my AWS credentials in a databag named `credentials` in a group `aws`. Use this format:

```json
{
  "id": "credentials",
  "access_key_id": "ABCDEF",
  "secret_access_key": "0a1b2c"
}
```

# Create Cloudwatch config

Next you'll need to create a template to tell the agent what metrics to collect. Here is one I worked up for an OpenVZ server (can't obtain detailed network/disk information) so it may not have everything you might find helpful. Start with with this and then follow up with the [documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html) once you start building dashboards.

Place this at `templates\default\amazon-cloudwatch-agent.json.erb`

```erb
{
  "agent": {
    "metrics_collection_interval": 10,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "resources": [
          "*"
        ],
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_nice",
          "cpu_usage_guest"
        ],
        "metrics_collection_interval": 10
      },
      "disk": {
        "resources": [
          "/",
          "/tmp"
        ],
        "measurement": [
          "free",
          "total",
          "used"
        ],
         "ignore_file_system_types": [
          "sysfs", "devtmpfs"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used",
          "swap_free",
        ]
      },
      "mem": {
        "measurement": [
          "mem_used",
          "mem_cached",
          "mem_total"
        ],
        "metrics_collection_interval": 1
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_syn_sent",
          "tcp_close"
        ],
        "metrics_collection_interval": 60
      },
      "processes": {
        "measurement": [
          "processes_running",
          "processes_sleeping",
          "processes_total",
          "processes_dead"
        ]
      }
    },
    "force_flush_interval" : 30
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          <%= node.default['aws']['cloudwatch']['log_files'].map{|file|
            %$
            {
              "file_path": "/var/log/#{file}",
              "log_group_name": "#{file}",
              "log_stream_name": "#{file}",
              "timezone": "UTC"
            } $
          }.join(',') %>
        ]
      }
    },
    "force_flush_interval" : 15
  }
}
```

You can use the `node.default['aws']['cloudwatch']['log_files']` attribute to build a list of interesting log files throughout your Chef build like so:

```ruby
node.default['aws']['cloudwatch']['log_files'] << 'auth.log'
```

_If you end up including this strategy you will likely need to default this attribute in `attributes/default.db`_

# Create recipe to tie it all together

```ruby
access_key_id     = data_bag_item('aws', 'credentials')['access_key_id']
secret_access_key = data_bag_item('aws', 'credentials')['secret_access_key']

directory 'root/.aws'

file 'root/.aws/config' do
  content "[AmazonCloudWatchAgent]\nregion=us-east-1\noutput=json"
end

file 'root/.aws/credentials' do
  content "[AmazonCloudWatchAgent]\naws_access_key_id = #{access_key_id}\naws_secret_access_key = #{secret_access_key}"
end

aws_cloudwatch_agent 'default' do
  action          [:install, :configure, :restart]
  json_config     'amazon-cloudwatch-agent.json.erb'
end
```