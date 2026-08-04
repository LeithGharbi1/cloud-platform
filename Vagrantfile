Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"

  # Disable default shared folder
  config.vm.synced_folder ".", "/vagrant", disabled: true

nodes = {
  "ansible-controller" => { ip:"192.168.56.5", memory:2048, cpus:2 },
  "master" => { ip:"192.168.56.10", memory:6144, cpus:4 },
  "worker1" => { ip:"192.168.56.11", memory:4096, cpus:2 },
  "worker2" => { ip:"192.168.56.12", memory:4096, cpus:2 }
}

  nodes.each do |name, node_config|

    config.vm.define name do |node|

      node.vm.hostname = name

      node.vm.network "private_network",
        ip: node_config[:ip]

 # Mount Ansible project only inside controller
      if name == "ansible-controller"
        node.vm.synced_folder "infrastructure/ansible", "/home/vagrant/ansible"
      end

      node.vm.provider "virtualbox" do |vb|
        vb.name = name
        vb.memory = node_config[:memory]
        vb.cpus = node_config[:cpus] || 2
      end

      node.vm.provision "shell", inline: <<-SHELL
        apt-get update
        apt-get install -y \
          curl \
          wget \
          vim \
          git \
          net-tools \
          openssh-server
      SHELL

    end
  end

end