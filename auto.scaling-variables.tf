
################ ############################################### ########
################ Module [[[auto-scaling]]] Input Variables List. ########
################ ############################################### ########

### ############################## ###
### [[variable]] in_mandatory_tags ###
### ############################## ###

variable in_mandatory_tags {

    description = "Optional tags unless your organization mandates that a set of given tags must be set."
    type        = "map"
    default     = { }
}


### ################# ###
### in_ecosystem_name ###
### ################# ###

variable in_ecosystem_name {

    description = "Creational stamp binding all infrastructure components created on behalf of this ecosystem instance."
}


### ################ ###
### in_tag_timestamp ###
### ################ ###

variable in_tag_timestamp {

    description = "A timestamp for resource tags in the format ymmdd-hhmm like 80911-1435"
}


### ################## ###
### in_tag_description ###
### ################## ###

variable in_tag_description {

    description = "Ubiquitous note detailing who, when, where and why for every infrastructure component."
}
