//Defining variables
//Each VM has its own subnet so number of VMs must be equal or less than subnets.
//To pass variables when plan: terraform plan -out main.tfplan -var="number-of-subnets=3"

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
    default = 1
    validation {
      condition = var.number-of-machines < 5
      error_message = "The number of VMs can't  bet more than 5!"
    }
}
