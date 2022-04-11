# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  #config.vm.provision "shell", path: "bootstrap.sh"

  # Kubernetes Master Server
  config.vm.define "master" do |master|
    master.vm.box = "mpasternak/focal64-arm"
    master.vm.hostname = "master.k8s.gonza.cc"
    master.vm.network "private_network", ip: "172.20.10.100"
    master.vm.provider "virtualbox" do |v|
      v.name = "master"
      v.memory = 2048
      v.cpus = 2
    end
    #master.vm.provision "shell", path: "bootstrap_master.sh"
  end

  NodeCount = 2

  # Kubernetes Worker Nodes
  (1..NodeCount).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.box = "mpasternak/focal64-arm"
      worker.vm.hostname = "worker#{i}.k8s.gonza.cc"
      worker.vm.network "private_network", ip: "172.20.10.10#{i}"
      worker.vm.provider "virtualbox" do |v|
        v.name = "worker#{i}"
        v.memory = 2048
        v.cpus = 2
      end
      #worker.vm.provision "shell", path: "bootstrap_worker.sh"
    end
  end

end
