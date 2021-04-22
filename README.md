# :sunny: Multizone: Kubernetes in a private subnets and VPC load balancer in a public subnet

### Architecture
![](/diagrams/architecture_diagram.png)

### Steps

:construction: Complete steps coming soon

1. Clone the repo
2. `cp templates/local.env.template local.env`
3. Update the file and `source local.env`
4. `./scripts/main.sh`


#### Terraform structure

[![](/diagrams/terraform_visual.png)](diagrams/terraform_visual.png)
:point_up: Generated using [Terraform Visual](https://github.com/hieven/terraform-visual)

![](/diagrams/graph.png)
:point_up: Generated using `terraform graph | dot -Tpng > graph.png` command with some additional changes