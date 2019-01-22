# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "bento/ubuntu-18.04"

    # Mount shared folder using NFS
    config.vm.synced_folder ".", "/vagrant",
        id: "core",
        :nfs => true,
        mount_options: ['rw', 'vers=3', 'tcp'],
        linux__nfs_options: ['rw', 'no_subtree_check', 'all_squash', 'async']
    # vers=3    specifies version 3 of the NFS protocol to use
    # tcp       specifies for the NFS mount to use the TCP protocol.
    # fsc       will make NFS use FS-Cache
    # actimeo=2 absolute time for which file and directory entries are kept in the file-attribute cache after an update
    # mount_options: ['rw', 'vers=3', 'tcp', 'fsc', 'actimeo=2'],
    # linux__nfs_options: ['rw', 'no_subtree_check', 'all_squash', 'async']

    # see http://stackoverflow.com/a/23887366
    config.nfs.map_uid = Process.uid
    config.nfs.map_gid = Process.gid

    # Do some network configuration
    config.vm.network "private_network", ip: "192.168.33.10"

    # Assign a quarter of host memory and all available CPU's to VM
    # Depending on host OS this has to be done differently.
    config.vm.provider :virtualbox do |vb|
        host = RbConfig::CONFIG['host_os']

        if host =~ /darwin/
            cpus = `sysctl -n hw.ncpu`.to_i
            mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4

        elsif host =~ /linux/
            cpus = `nproc`.to_i
            mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4

        # Windows...
        else
            cpus = 4
            mem = 8192
        end

        vb.customize ["modifyvm", :id, "--memory", mem]
        vb.customize ["modifyvm", :id, "--cpus", cpus]
        vb.customize ['modifyvm', :id, '--cpuexecutioncap', '99']
        vb.name = 'serverbuild-1804'

    end

    config.vm.provision :shell, :path => "bootstrap.sh"
    config.vm.provision :shell, path: "restart.sh", run: "always"

end