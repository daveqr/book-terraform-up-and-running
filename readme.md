# Notes on [Terraform: Up and Running: Writing Infrastructure as Code](https://smile.amazon.com/Terraform-Running-Writing-Infrastructure-Code/dp/1491977086?_encoding=UTF8&keywords=terraform&portal-device-attributes=desktop&qid=1497014530&ref_=sr_1_1&sr=8-1)

## Overview
Infrastructure as code -- write and execute code to define deploy and update infrastructure
can manage almost everything in code (servers, database, networks, etc)

four broad categories of IAC tools

* ad hoc scripts
* config managmenet tools
  * launch servers and configure by running the same code on each 
  * Chef, Puppet, Ansible, SaltStack
* server templating tools
  * create image of a server to be installed 
  * Docker, Packer, Vagrant
* server provisioning tools
  * responsible for creating servers themselves 
  * Terraform, CloudFormation. OpenStack

  
### Benefits of Infrastructure as Code
* self-service
* speed and safety
* documentation
* version control
* validation
* reuse
* happiness


### How Terraform Works
* define infrastructure in configuration files
* run Terraform commands to deploy
* all changes are made through configuration changes, not by updating manually

## Terraform

### Files
Terraform source is located in .tf and .tfvars files.

#### main.tf
The main source file is main.tf by convention, but Terraform will read any .tf file in the directory and build a graph of resources to create.

#### outputs.tf
Values that are exposed to other modules or components, for example, the generated name of a database instance which is used by a server.

#### vars.tf
Input variables. Think of this as the api or as arguments to a function.

#### terraform.tfvars
Filter variables. Might contain sensitive or environment-specific values, and generally is not committed to source control.

### Resources
* Resources are things to be created, including servers, databases and load balancers.

	General format
	
	```bash
	resource "PROVIDER_TYPE" "NAME" {
	  [CONFIG ...]
	}
	```
	
	For example
	
	```
	resource "aws_instance" example" {
	  ami           = "ami-40d28157"
	  instance_type = "t2.micro"
	}
	```

* Every resource exposes attributes you can access using interpolation

	```
	"${TYPE.NAME.ATTRIBUTE"
	```

* Most changes create a new instance.

### Commands

```bash
$ terraform plan
$ terraform apply
$ terraform ouput
$ terraform fmt
```

### State
* Terraform tracks state to determine changes.
  * Sometimes plan will indicate the change is ok, but apply will have an error. This is because Terraform uses state, not what is actually deployed, to plan. An error may have occurred when the two get out-of-synch, such as when a manual change has been made to the server. 
* Terragrunt is an open source tool with improved state control.




best not to do apply-all; doesn't always do things in the right order (like if you need a db address)

Use http://terraforming.dtan4.net/ to export existing config

## Testing

testing libs
 * https://github.com/newcontext-oss/kitchen-terraform
 * http://serverspec.org/
 
for testing, could run rspec tests against live env, and on commit, run integration tests in 'test' environment (not prod!) which runs terraform apply
  * completes  without errors
  * database, web server, load balancer all boot
  * can talk to web servers via load balancer
  * data is coming from db
  
do this using custom/hand-written scripts?

## Coding Guidelines

### Documentation

* Modules should have a readme
* API documentation and design docs that go deeper into how the code works and why it was built this way
* Comment code
* use description parameter
* example code, or how a module is meant to be used

### File Layout

Recommended layout:

```bash
- examples
  - foo
  - bar

- modules
  - foo
    main.tf
    outputs.tf
    vars.tf
  - bar
  
- tests
  foo_test.go
  bar_test.go

```