//Defining variables
variable "number-of-subnets" {
    type = number
    description = "Defines number of subnets"
    default = 2
    validation {
        condition = var.number-of-subnets < 5
        error_message = "The number of subnets must be less than 5!"
    }
}
variable "number-of-machines" {
    type = number
    description = "Defines number or virtual machines"
    default = 2
    validation {
      condition = var.number-of-machines < 5
      error_message = "The number of VMs can't  bet more than 5!"
    }
}
