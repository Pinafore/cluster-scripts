# About Repository
This contains scripts for running various types of clusters on CU Boulder computing resources. This is primarily
targeted at running clusters on the [educational](openstack.cs.colorado.edu) and [research](stack.cs.colorado.edu).

If they work on other platforms that is unintentional/unsupported, but possible with changes to the Packer scripts.

The primary tool used to provision clusters is Packer.

Packer is a tool to create images with the correct software provisioned. Packer works by launching an instance in a
compute environment, then running a set of provisioning steps to bring the instance to the desired state. Packer then
takes a snapshot of the instance to make an image, destroys the instance, and publishes the image to the computing
environment.

Currently, this repository contains
1. Scripts for running a Spark cluster within `spark/`
2. Scripts for running a Docker Swarm cluster within `docker/`
