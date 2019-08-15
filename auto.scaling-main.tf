
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

        for_each = local.mandatory_tags
        content {
            key   = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}


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


resource aws_key_pair ssh {
    key_name = "key-4-${ local.ecosystem_name }-${ module.resource-tags.out_tag_timestamp }"
    public_key = "${ var.in_ssh_public_key }"
}


