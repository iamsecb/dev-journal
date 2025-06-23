---


```bash
 sudo tcpdump 'tcp[tcpflags] & (tcp-rst|tcp-syn|tcp-fin) != 0  and host $HOST_NAME' -i any
```

```bash
 00:00:00.000000 ens5  Out IP 10.61.69.173.50520 > 10.219.208.6.443: Flags [S], seq 358560042, win 62727, options [mss 8961,sackOK,TS val 4176215147 ecr 0,nop,wscale 7], length 0
 00:00:00.008208 ens5  In  IP 10.219.208.6.443 > 10.61.69.173.50520: Flags [S.], seq 897476341, ack 358560043, win 64240, options [mss 1375,nop,nop,sackOK,nop,wscale 7], length 0
 00:00:00.000046 ens5  Out IP 10.61.69.173.50520 > 10.219.208.6.443: Flags [.], ack 897476342, win 491, length 0
 00:00:00.000921 ens5  Out IP 10.61.69.173.50520 > 10.219.208.6.443: Flags [P.], seq 358560043:358560376, ack 897476342, win 491, length 333
 00:00:00.007416 ens5  In  IP 10.219.208.6.443 > 10.61.69.173.50520: Flags [.], ack 358560376, win 501, length 0
 00:00:00.000708 ens5  In  IP 10.219.208.6.443 > 10.61.69.173.50520: Flags [F.], seq 897476342, ack 358560376, win 501, length 0
 00:00:00.000085 ens5  Out IP 10.61.69.173.50520 > 10.219.208.6.443: Flags [P.], seq 358560376:358560383, ack 897476343, win 491, length 7
 00:00:00.000126 ens5  Out IP 10.61.69.173.50520 > 10.219.208.6.443: Flags [F.], seq 358560383, ack 897476343, win 491, length 0
 00:00:00.008942 ens5  In  IP 10.219.208.6.443 > 10.61.69.173.50520: Flags [R], seq 897476343, win 0, length 0
```
