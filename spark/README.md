# Spark Cluster Setup with Packer

## Overview
The packer scripts are responsible for:

1. Installing Java 7 on each cluster node
2. Installing Spark 1.5 on each cluster node (with support for Hadoop 2.6)
3. Setting up SSH keys on the cluster
4. Uploading scripts to be executed manually on the master once the cluster machines are running.

It is also to explain the model from which the Packer scripts are based. Particularly, it is important to understand
which parts are run as the image is built, what is on the image afterwards, then what is run by the user or WIP automated
script.

1. Image: When Packer builds the image, it installs Java, Spark, and generates SSH keys. Any machines that will be
part of the cluster must use this image. Spark requires that the machines can use password-less SSH access to each
other. This is accomplished by generating a single set of SSH keys at image build and putting the public key in the list
of authorized keys. As new instances are created from this image, they all have the same ssh keys and can ssh to each
other since the same ssh key is authorized.
2. Contents of Image: The contents of the image are Spark and its dependencies. This amounts to a decompressed directory
in `/home/ubuntu/spark-1.5.0` (TODO: create a spark user). Any instance can become a master or slave at this point.
3. Runtime: From here, the user (or the WIP automation script) must login to the "master" node, run the
`setup-master.sh` script. This will bind Spark environment variables to match the node's ip address. Then all the slave
nodes need to be listed in the `conf/slaves` file. Finally, the cluster is started via `sbin/start-all.sh`. At this
point, the cluster is running.

## Instructions
1. First, you will need [install Packer](https://www.packer.io/intro/getting-started/setup.html)
2. You will need to setup authentication with Packer. A sample file (`env-vars.sh`) is provided which works with CU's
research cluster at [stack.cs.colorado.edu](stack.cs.colorado.edu). Fill in the required
fields and source it in the same shell that Packer is run. Packer uses OpenStack APIs to provision a new
image so this is required for it to authenticate to OpenStack. You can also find this information by downloading the
OpenStack RC file by going to the "access and Security" tab, then API access tab.
3. Once that is done, switch directories to `spark/`
4. Everything is now setup to run packer to validate and build the image. To
validate the file so run: `packer validate spark-packer.json`. Once this is done, then you are ready to build the image.
You can do this by running `packer build spark-packer.json`.
5. Once the image is finished building, it is time to create the instances. For this, go to the OpenStack web ui.
6. Before creating the instances, we need to add a security group that opens the ports that Spark uses. This can be done
by navigating to the "access and security" tab, then the "security groups" tab and clicking "Create Security Group".
Create rules that allow egress/ingress to ports: 4040, 7076, 7077, 8080, 8081, and 18080.
7. Now go to the "instances" tab and click "launch instances". From here you can name the instance
(which will be numbered starting from 1 to n), select the image "spark", and desired flavor. Under the security tab,
add the security group from step 6. Finally, add the public network and create the cluster.
NOTE: This places all the nodes on the web. If you are concerned about security, you could setup an additional instance
to act as a gateway to the cluster running on the private network.
8. After the instances launch, you will need to ssh to the master to configure and run the startup scripts. Choose one
node to be the master and ssh into it. Note the ip address of the other nodes. SSH using:
`ssh -i identity.pem ubuntu@master`, replacing master with the master node's ip address.
9. On the master, execute the `setup-master.sh` script. This will write environment variables spark needs to its
configuration directory. Following this, edit `spark-1.5.0/conf/slaves` and add the ip addresses of each slave on
separate lines.
10. Now we are ready to start the cluster. Within the spark directory, execute `./sbin/start-all.sh` to start the
cluster. The logs should indicate that a master has been started and that all the configured slaves have started too.
11. Browse to `http://master:8080` to confirm that the Spark UI appears and shows the correct number of slaves.
12. To confirm everything works, lets run a Spark sample. Execute
`MASTER=spark://192.12.242.239:7077 ./bin/run-example SparkPi` on the master or any other machine with Spark installed
and access to the master. It should succeed and appear under completed jobs in the Spark UI
13. To shut down the cluster, execute `./sbin/stop-all.sh` on the master

## Configuration
By default, the packer scripts will use the flavor `r620_4_8` to provision the image. This should not impact being able
to use the image on other flavors, but can be changed by running:
`packer build -var 'flavor=myflavor' spark-packer.json`.
