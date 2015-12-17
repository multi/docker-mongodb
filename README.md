### mongodb 3.0.7 + wiredtiger 2.7.0

disable `transparent_hugepage` (recommended by mongodb)

```
$ docker-machine ssh ...
```

then add to `/var/lib/boot2docker/profile`

```
if test -f /sys/kernel/mm/transparent_hugepage/khugepaged/defrag; then
  echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
```