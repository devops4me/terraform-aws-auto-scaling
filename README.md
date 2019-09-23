
# Auto-scaling Group and Launch Configuration

This module creates an AWS auto-scaling group and launch configuration.

## Module Usage

    module vpc-network
    {
        source  = "devops4me/auto-scaling/aws"
        version = "~> 1.0.0"

        in_ami_id         = "ami-12345678"
        in_subnet_ids     = var.in_private_subnet_ids
        in_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E...asdf/fghDF ec2 keypair"
        in_instance_type  = "t2.medium"

        in_instance_profile_id = module.ec2-role-profile.out_instance_profile_id
        in_security_group_id   = module.security-group.out_security_group_id
        in_user_data_script    = module.ecs-cluster.out_user_data_script
    }

Create new ec2 instances of this type with this AMI ID. Ply them with this public SSH key. Use this instance profile to define the access each instance has to AWS resources. Use this security group to constrain traffic to the instances. Create each instance in one of this list of subnets in a round robin fashion. Run this user data script when the instance boots up.


---


## Module Inputs

| Input Variable               | Type    | Description                                                   |
|:---------------------------- |:-------:|:------------------------------------------------------------- |
| **`in_minimum_instances`**   | number  | The minimum number of instancees to maintain during cold periods. |
| **`in_maximum_instances`**   | number  | The maximum number of instances no matter the heat applied. |
| **`in_desired_instances`**   | number  | The desired number of instances to have up and running. |
| **`in_ami_id`**              | string  | Create new ec2 instances with this AMI ID.       |
| **`in_subnet_ids`**          | list    | Create each instance in one of this list of subnets in a round robin fashion. |
| **`in_ssh_public_key`**      | string  | Ply each ec2 instance with this public SSH key.               |
| **`in_instance_type`**       | string  | Create instances from this instance type class. |
| **`in_instance_profile_id`** | string  | The ID of the profile that defines each the AWS resource access given to each ec2 instance. |
| **`in_security_group_id`**   | string  | Use this security group to constrain the traffic to and from the ec2 instances. |
| **`in_user_data_script`**    | string  | Run this user data script when the instance boots up. |


### Optional Resource Tag Inputs

Most organisations have a mandatory set of tags that must be placed on AWS resources for cost and billing reports. Typically they denote owners and specify whether environments are prod or non-prod.

| Input Variable    | Variable Description | Input Example
|:----------------- |:-------------------- |:----- |
**`in_ecosystem`** | the ecosystem (environment) name these resources belong to | **`my-app-test`** or **`kubernetes-cluster`**
**`in_timestamp`** | the timestamp in resource names helps you identify which environment instance resources belong to | **`1911021435`** as **`$(date +%y%m%d%H%M%S)`**
**`in_description`** | a human readable description usually stating who is creating the resource and when and where | "was created by $USER@$HOSTNAME on $(date)."

Try **`echo $(date +%y%m%d%H%M%S)`** to check your timestamp and **`echo "was created by $USER@$HOSTNAME on $(date)."`** to check your description. Here is how you can send these values to terraform.

```
export TF_VAR_in_timestamp=$(date +%y%m%d%H%M%S)
export TF_VAR_in_description="was created by $USER@$HOSTNAME on $(date)."
```
