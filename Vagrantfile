Vagrant.configure('2') do |config|
  config.vm.box = 'base'

  config.vm.network 'forwarded_port', guest: 8080, host: 8080

  config.vm.provision 'shell' do |s|
    s.path = 'bootstrap.sh'
    s.privileged = false
    s.keep_color = true
  end

  config.vm.provider 'virtualbox' do |v|
    v.cpus = 2
    v.memory = 2048
  end
end
