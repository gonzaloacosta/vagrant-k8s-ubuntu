# Issues

## Vagrant Failed to create host adatpter.
``````
❯ va up
Bringing machine 'kmaster' up with 'virtualbox' provider...
Bringing machine 'kworker1' up with 'virtualbox' provider...
Bringing machine 'kworker2' up with 'virtualbox' provider...
==> kmaster: Importing base box 'bento/ubuntu-18.04'...
==> kmaster: Matching MAC address for NAT networking...
==> kmaster: Checking if box 'bento/ubuntu-18.04' version '202012.21.0' is up to date...
==> kmaster: A newer version of the box 'bento/ubuntu-18.04' for provider 'virtualbox' is
==> kmaster: available! You currently have version '202012.21.0'. The latest is version
==> kmaster: '202112.19.0'. Run `vagrant box update` to update.
==> kmaster: Setting the name of the VM: kmaster
==> kmaster: Clearing any previously set network interfaces...
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["hostonlyif", "create"]

Stderr: 0%...
Progress state: NS_ERROR_FAILURE
VBoxManage: error: Failed to create the host-only adapter
VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory
VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterfaceWrap, interface IHostNetworkInterface
VBoxManage: error: Context: "RTEXITCODE handleCreate(HandlerArg *)" at line 95 of file VBoxManageHostonly.cpp
`````````

### Solution

[Solution](https://stackoverflow.com/questions/21069908/vboxmanage-error-failed-to-create-the-host-only-adapter)

I had the same problem today. The reason was that I had another VM running in VirtualBox.

Solution:

Open VirtualBox and shut down every VM running

Go to System Preferences > Security & Privacy Then hit the "Allow" button to let Oracle (VirtualBox) load.

Restart VirtualBox

`sudo "/Library/Application Support/VirtualBox/LaunchDaemons/VirtualBoxStartup.sh" restart`

You should now be able to run vagrant up or vagrant reload and have your new host configured.

As mentioned in this answer, recent versions of macOS can block VirtualBox.

Solution:
Go to System Preferences > Security & Privacy Then hit the "Allow" button to let Oracle (VirtualBox) load.


