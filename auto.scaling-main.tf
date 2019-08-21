
/*
 | --
 | -- When the clustered ec2 instances are reaching the end of their
 | -- tether this auto scaling group (and launch configuration) sees
 | -- to it that more are automatically provisioned.
 | --
 | -- Dynamic tags are used here because the auto-scaling group will
 | -- be responsible for placing tags on the provisioned ec2 intances.
 | --
*/
resource aws_autoscaling_group this {

    name                 = "${ var.in_ecosystem_name }-asg-${ var.in_tag_timestamp }"
    vpc_zone_identifier  = var.in_subnet_ids
    launch_configuration = aws_launch_configuration.this.name
    min_size             = var.in_minimum_instances
    max_size             = var.in_maximum_instances
    desired_capacity     = var.in_desired_instances

    tag {

        key                 = "Name"
        value               = "${ var.in_ecosystem_name }-worker-${ var.in_tag_timestamp }"
        propagate_at_launch = true
    }

    tag {

        key                 = "Desc"
        value               = "This auto scaled ec2 instance ( for ${ var.in_ecosystem_name } ) ${ var.in_tag_description }"
        propagate_at_launch = true
    }

    dynamic tag {

        for_each = var.in_mandatory_tags
        content {
            key   = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}


/*
 | --
 | -- This launch configuration ensures that
 | --
 | --   a) a given AMI is used to raise the instances
 | --   b) the instance type is of a particular ilk
 | --   c) the ec2 instance adopts a role profile carrying access policies
 | --   d) each instance is plied with a public SSH key
 | --   e) the security group for each instance is the one stated
 | --   f) the user data scripts are run after the instance boots up
 | --
*/
resource aws_launch_configuration this {

    name_prefix          = "${ var.in_ecosystem_name }-launch-config-${ var.in_tag_timestamp }"
    image_id             = var.in_ami_id
    instance_type        = var.in_instance_type
    iam_instance_profile = var.in_instance_profile_id
    key_name             = aws_key_pair.ssh.id
    security_groups      = [ var.in_security_group_id ]
    user_data            = var.in_user_data_script

    lifecycle {
        create_before_destroy = true
    }

}


/*
 | --
 | -- The ec2 instances fashioned by the launch configuration are
 | -- plied with this public key to enable troubleshooters to go in
 | -- and diagnose issues.
 | --
 | -- Best practise is to block ssh on production systems but if
 | -- and when you need to get out of jail free, you place a security
 | -- group rule allowing it and proceed to perform diagnosis.
 | --
*/
resource aws_key_pair ssh {
    key_name = "key-4-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
    public_key = var.in_ssh_public_key
}
