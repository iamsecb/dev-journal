---
title: Linux Primer
tags:
  - networking
  - linux
---

### What is the linux kernel?

- Controls the hardware when the OS talks to the kernel via system calls. The 
  kernel translates these requests into instructions that the hardware can 
  understand. 
- Allocates memory and schedules processes to run applications.
- First piece of software loaded into a protected area of memory when a computer starts up so that it cannot be overwritten.

In the command `ps -ef` PID 1 is the initial process started by the kernel. 

### What is a system call?

When an application is run, by default it runs in user space. When it requires access to hardware like disk for example it must make a request to the kernel which is known as a "system call". 

Here are some common scenarios where applications make system calls to the kernel:

**File operations**: When an application needs to read from or write to files, it makes system calls to the kernel to perform file-related operations, such as opening files, reading data, writing data, closing files, and modifying file attributes.

**Network communication**: Applications that require network connectivity, such as web browsers or email clients, make system calls to the kernel to establish network connections, send data over the network, receive incoming data, and manage network sockets.

**Process management**: Applications may need to create new processes, terminate processes, or perform other process-related operations. These tasks involve system calls to the kernel, which handles process scheduling, memory management, and inter-process communication.

**Memory management**: When an application requires memory allocation or deallocation, it relies on system calls to the kernel to request memory resources. The kernel manages the system's memory and fulfills these requests, ensuring proper memory allocation and protection.

**Interacting with devices**: Applications make system calls to interact with hardware devices like disks, printers, graphics cards, and input/output devices. These system calls enable the application to perform operations on the devices with the assistance of the kernel and relevant device drivers.

If you run an application as root, it still runs within the user space but is granted elevated privilges that normally would not exist like modifying system files, changing system level configuration etc.

### Files

- `/bin`, `/sbin`, `/usr/bin`, and `/usr/sbin`: Where executable programs are stored.
- `/dev`: Where files representing hardware devices are stored. For example, if your Linux system had a floppy drive device, there would be a file named fd0 in the dev folder (/dev/fd0).
- `/etc`: Where configuration files are stored.
- `/home`: Where user home directories are stored, one for each
user.
- `/var`. Where variable-length files, like log files, are stored.

Should follow File System Hierachy guide as per https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

#### Log files

`syslog`: Contains the centralized logging system, called syslog, in which you’ll find messages related to the kernel, applications, and more. If configured, this could be the centralized log file for all Linux systems (or even all network devices) in your data center.

`auth.log`: Contains authentication failures and successes

`messages`: Contains general system messages of all types


### Network interfaces 

The **loopback (`lo`)** interface will have an IP address of 127.0.0.1, which represents the host itself.

The **ethernet 0** (`eth0`) interface is typically the connection to the local network. Even if you are running Linux in a virtual machine (VM), you’ll still have an `eth0` interface that connects to the physical network interface of the host. Most commonly, you should ensure that eth0 is in an UP state and has an IP address so that you can communicate with the local network and likely over the Internet.


### Commands

`ip link`         : Configure network interfaces and check link status 
`ip addr ...`     : Check and configure ip addresses for network interfaces
`ip -s link`      : Stats on our network e.g: How much data is sent? any errors? etc.
`netstat -l`      : Active listening services
`ip neighbour`    : ARP cache table (IP to MAC)
`ifup/ifdown` .   : Restart an interfaces without having to restart a servero

### Container networking made simple

The following are notes from the article https://iximiuz.com/en/posts/container-networking-is-simple/ (which is a must read).

<sub>Disclaimer: The notes are my own and if there are mistakes it is not relfective of the article.</sub>

#### What is a linux network stack?

An isolated network device, routing rules and any filters set by ip tables. The isolation provided by linux via a network namespace can be setup via the command `ip netns`.

The man page for this command says:

> A network namespace is logically another copy of the network stack, with its own routes, firewall rules, and network devices.

This is captured in the following script:

```bash
cat <<EOF > inspect-net-stack.sh
#!/usr/bin/env bash
echo "> Network devices"
ip link

echo -e "\n> Route table"
ip route

echo -e "\n> Iptables rules"
iptables --list-rules
EOF
```
Set permissions:

```
chmod +x inspect-net-stack.sh
```

Create a custom ip tables rule to see the difference between the root network namespace and the custom namespace that will be created.

```bash
sudo iptables -N NS_ROOT
```

When you run this on the host (root network namespace) on a machine the output may look like this:

```bash
> Network devices
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:27:8b:50 brd ff:ff:ff:ff:ff:ff

> Route table
default via 10.0.2.2 dev eth0 proto dhcp metric 100
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100

> Iptables rules
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-N ROOT_NS
```


#### How to create a network namespace?

```bash
$ sudo ip netns add netns0
```

#### How do I use this namespace?

```bash
# Run bash in the namespace we created
$ sudo nsenter --net=/var/run/netns/netns0 bash

$ sudo ./inspect-net-stack.sh
> Network devices
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

> Route table

> Iptables rules
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
```

As you can see there is only a loopback interface (which is also `DOWN`), no routing rules and the custom ip tables chain `NS_ROOT` is not present which confirms that we are in the `netns0` networking stack.

At this point it is completely isolated and there is no network connectivity by default.

### How to make this network namespace useful?

To enable connectivity to the `netns0` namepace, we need to create a form of link to the root namespace. Linux provides a way to make this happen via **virtual ethernet devices**.

The man page for `veth` says:

> The  veth devices are virtual Ethernet devices.  They can act as tunnels between network namespaces to create a bridge to a physical network device in another namespace, but can also be used as standalone network devices.

Create a `veth` on the root networking namespace:

```bash 
$ sudo ip link add veth0 type veth peer name ceth0
```

The command highlights that we are creating the veth in pairs; veth0/ceth0. The purpose of creating veth interfaces in pairs is to establish a communication channel between different network namespaces. One end of the veth pair is typically assigned to the host's network namespace, while the other end is assigned to a specific network namespace, such as a container or another network namespace.

Running the network commands from earlier now shows:

```bash
sudo ./inspect-net-stack.sh
> Network devices
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:27:8b:50 brd ff:ff:ff:ff:ff:ff
3: ceth0@veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether da:c7:10:9f:f7:3c brd ff:ff:ff:ff:ff:ff
4: veth0@ceth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 8a:09:3b:a1:50:5d brd ff:ff:ff:ff:ff:ff

> Route table
default via 10.0.2.2 dev eth0 proto dhcp metric 100
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100

> Iptables rules
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-N ROOT_NS
```

To connect the root networking namespace to the `netns0` namespace we need to move one of the pairs over:

```bash
$ sudo ip link set ceth0 netns netns0

# Confirm it is not longer in the root namespace
$ ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:27:8b:50 brd ff:ff:ff:ff:ff:ff
4: veth0@if3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 8a:09:3b:a1:50:5d brd ff:ff:ff:ff:ff:ff link-netns netns0
```

#### Enabling connectivity

From the root networking namespace we can see that the device is `DOWN` and there is no IP address assigned:

```bash
4: veth0@if3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 8a:09:3b:a1:50:5d brd ff:ff:ff:ff:ff:ff link-netns netns0
```

We can fix that:

```bash 
sudo ip link set veth0 up
sudo ip addr add 172.18.0.11/16 dev veth0
```

!!! info "IP Addressing"

  Any ip address can be assigned to the interface because it is virtual. It doesn't have to be a real IP address that corresponds to a physical network device.

!!! info "LOWER_LAYER_DOWN"
  
  If you had run `ip link show veth0`, you will notice that the link state is `LOWERLAYERDOWN`. This is expected
  since the other end of the pair, `ceth0` is down.



Doing the same for `ceth0` in `netns0` namespace:

```bash
sudo nsenter --net=/var/run/netns/netns0
ip link set lo up
ip link set ceth0 up
ip addr add 172.18.0.10/16 dev ceth0
```

Review connectivity:

```bash
$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
3: ceth0@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 82:95:96:e2:c0:00 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

#### Testing connectivity

From `netns0` namespace to `veth0`:

```bash
sudo nsenter --net=/var/run/netns/netns0
```
Ping `veth0` in host namespace:

```bash
$ ping -c 2 172.18.0.11
PING 172.18.0.10 (172.18.0.10) 56(84) bytes of data.
64 bytes from 172.18.0.10: icmp_seq=1 ttl=64 time=0.073 ms
64 bytes from 172.18.0.10: icmp_seq=2 ttl=64 time=0.046 ms
...
```

Make sure to exit from `ns0` namespace:

```bash
exit
```

From root namespace to `ceth0`:

```bash
$ ping -c 2 172.18.0.10
PING 172.18.0.11 (172.18.0.11) 56(84) bytes of data.
64 bytes from 172.18.0.11: icmp_seq=1 ttl=64 time=0.038 ms
64 bytes from 172.18.0.11: icmp_seq=2 ttl=64 time=0.040 ms
...
```

From `netns0` to root namespace `eth0` interface:

```bash
# Get eth0 ip
$ ip addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:e3:27:77 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 84057sec preferred_lft 84057sec
    inet6 fe80::5054:ff:fee3:2777/64 scope link
       valid_lft forever preferred_lft forever
```

Switch to `ns0` namespace:

```bash
sudo nsenter --net=/var/run/netns/netns0
```

```
# Try host's eth0
$ ping 10.0.2.15
connect: Network is unreachable

# Try something from the Internet
$ ping 8.8.8.8
connect: Network is unreachable
```

To understand why you can't ping the host's `eth0` interface you, we need to verify if a route exists. 

```bash
$ ip route
172.18.0.0/16 dev ceth0 proto kernel scope link src 172.18.0.10
```

There is only a route to reach `172.18.0.0/16` network. To fix this we can add a default route:

```bash
ip route add default via 172.18.0.11
```

!!! info "Default Route"

    The default route is the next hop. It is not an interface on your host. Think about a router in your home
    network for example to reach the internet.


Now if ping `eth0` it will have a way to reach it:

```bash
$ ping -c2 10.0.2.15
PING 10.0.2.15 (10.0.2.15) 56(84) bytes of data.
64 bytes from 10.0.2.15: icmp_seq=1 ttl=64 time=0.040 ms
64 bytes from 10.0.2.15: icmp_seq=2 ttl=64 time=0.062 ms
...
```

However, accessing the internet as per our `ping 8.8.8.8` command still fails.

#### NAT

The article linked above describes it best:

> Before going to the external network, packets originated by the containers will get their source IP addresses replaced with the host's external interface address. The host also will track all the existing mappings and on arrival, it'll be restoring the IP addresses before forwarding packets back to the containers.

This is achieved by the following `iptables` rule:

```bash
sudo sysctl net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 172.18.0.0/16 -o eth0 -j MASQUERADE
```

This rule ensures that any packet originating from the `172.18.0.0/16` network and going out through the `eth0` interface will have its source IP address changed to match the IP address of the `eth0` interface. This allows devices in the `172.18.0.0/16` network to communicate with the internet using the IP address of the `eth0` interface.

To be continued..

### Summary

```bash
sudo ip netns add netns0
sudo ip link add veth0 type veth peer name ceth0
sudo ip link set veth0 up
sudo ip addr add 172.18.0.11/16 dev veth0
sudo ip link set ceth0 netns netns0
sudo nsenter --net=/var/run/netns/netns0
ip link set lo up
ip link set ceth0 up
ip addr add 172.18.0.10/16 dev ceth0
ip route add default via 172.18.0.11
exit

sudo ip netns add netns1
sudo ip link add veth1 type veth peer name ceth1
sudo ip link set veth1 up
sudo ip addr add 172.18.0.21/16 dev veth1
sudo ip link set ceth1 netns netns1

sudo nsenter --net=/var/run/netns/netns1
ip link set lo up
ip link set ceth1 up
ip addr add 172.18.0.20/16 dev ceth1
ip route add default via 172.18.0.21
# my host eth0 ip is 10.0.2.15
arping -c 1 -I ceth1 10.0.2.15
exit

sudo ip route del 172.18.0.0/16 dev veth0 proto kernel scope link src 172.18.0.11
sudo nsenter --net=/var/run/netns/netns1
arping -c 1 -I ceth1 10.0.2.15
```