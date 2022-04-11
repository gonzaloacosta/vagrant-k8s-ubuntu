# Vagrant failed in M1

```log
==> master: Mounting shared folders...
    master: /vagrant => /Users/gonza/Documents/TechDocs/vagrant/vagrant-k8s-ubuntu
Vagrant was unable to mount Parallels Desktop shared folders. This is usually
because the filesystem "prl_fs" is not available. This filesystem is
made available via the Parallels Tools and kernel module.
Please verify that these guest tools are properly installed in the
guest. This is not a bug in Vagrant and is usually caused by a faulty
Vagrant box. For context, the command attempted was:

mount -t prl_fs -o uid=1000,gid=1000,_netdev vagrant /vagrant

The error output from the command was:

mount: /vagrant: unknown filesystem type 'prl_fs'.
```

## Solution

Update box to `mpasternak/focal64-arm`