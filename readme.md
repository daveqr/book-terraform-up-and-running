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