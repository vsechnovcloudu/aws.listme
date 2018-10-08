List me...
==========

List me my EC2 instances - API GW and Lambda designed for Slack slash command.

[![CircleCI](https://circleci.com/gh/vsechnovcloudu/aws.listme.svg?style=svg)](https://circleci.com/gh/vsechnovcloudu/aws.listme)

# What is it?

It is a very simple application, which will describe your EC2 instances and 
returns back a list. You can also specify a tag and it's value to retrieve 
filtered results.  
Currently the function returns only EC2 instances from one AWS account and only 
from one region.  
Build, test and deployment is automated using CircleCI.  

# Installation

In your own AWS account, create new S3 bucket in desired region. The bucket will 
be used by CircleCI pipeline to offload artefacts and to store Terraform state 
file for each workspace.  
Fork the repository and provide minimum required information to file `/terraform/vars/master.tfvars`.  
CircleCI pipeline takes a *branch name* as an argument - for each branch, there 
will be one Terraform *workspace* and also one Terraform *variable file* is 
expected (identical filename as branch name). This is helpful for development, 
as any change can be tested in isolated workspace and then merged into `master` 
which is treated as production environment.    
Once deployed, copy a API endpoint URL from CircleCI output.
Create new app in your Slack workspace, assign a slash command (ie. `/listme`) 
and paste the URL from previous step.  
Copy over a Slack signing secret and put it into AWS Secret manager manually (ie. 
using command `aws secretsmanager update-secret --secret-id slack/secretsignature --secret-string '{"SLACK_TOKEN":"your_slack_signing_secret"}`).  
(In case you regenerate Slack signing secret, you have to update it manually).  

# How to use it?

`/listme` should simply give you a list of all instances in your account and 
region.  
`/listme Environment Production` shall retrieve all EC2 instances with tag 
`Environment` and value `Production`. It is case sensitive.  

![Screenshot](/docs/img/listme_slack.png)

# To uninstall

There is no automatic uninstallation process. Simply run `terraform destroy` 
locally and then delete operational bucket. On Slack side remove the app. That's 
it.
