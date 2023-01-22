Projet for Application Gateway. Filtering http requests to different vms based on path.

Layer 7 load balancing. Regional.

Netwrorking:
    One virtual network.
    Two subnets - one for vm, one for APP Gateway.

Virtual Machines:
    Two Virtual machines with IIS installed via custom script.
    Each VM has its own custom script
    No public IP

Application Gateway:
    Requires its own subnet
    Requires public IP iddress for Frontend configuration
    Two backeend pools: one for videosvm, one for picturesvm
    Routing RuleA: 
            With Listener to frontend address on port 80 HTTP.
            Path based routing /images/ for imagesvm
            Path based routing /videos/ for videosvm
