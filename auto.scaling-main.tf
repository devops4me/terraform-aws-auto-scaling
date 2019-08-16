
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
resource aws_autoscaling_group cluster {

    name                 = "${ local.ecosystem_name }-asg-${ module.resource-tags.out_tag_timestamp }"
    vpc_zone_identifier  = module.vpc-network.out_public_subnet_ids
    launch_configuration = aws_launch_configuration.cluster.name
    min_size             = 1
    max_size             = 3
    desired_capacity     = 1

    tag {

        key                 = "Name"
        value               = "${ local.ecosystem_name }-worker-${ module.resource-tags.out_tag_timestamp }"
        propagate_at_launch = true
    }

    tag {

        key                 = "Desc"
        value               = "This auto scaled ec2 instance ( for ${ local.ecosystem_name } ) ${ module.resource-tags.out_tag_description }"
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
resource aws_launch_configuration cluster {

    name_prefix          = "${ local.ecosystem_name }-launch-config-${ module.resource-tags.out_tag_timestamp }"
    image_id             = data.aws_ami.ecs-worker.id
    instance_type        = "t2.xlarge"
    iam_instance_profile = aws_iam_instance_profile.cluster-ec2-role.id
    key_name             = aws_key_pair.ssh.id

    security_groups = [ module.security-group.out_security_group_id ]
    user_data       = data.template_file.ecs_init.rendered

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
    key_name = "key-4-${ local.ecosystem_name }-${ module.resource-tags.out_tag_timestamp }"
    public_key = "${ var.in_ssh_public_key }"
}


