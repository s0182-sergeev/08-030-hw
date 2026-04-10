// создать файл hosts.ini на управляющем хосте в текущем каталоге
resource "local_file" "inventory" {
  content  = <<-XYZ
    [bastion]
    ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
    # подключение ssh user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
    # адрес во внутренней сети ${yandex_compute_instance.bastion.network_interface.0.ip_address}

    [agents]
    ${yandex_compute_instance.agent-a.network_interface.0.ip_address} # адрес agent-a
    # подключение ssh user@${yandex_compute_instance.agent-a.network_interface.0.ip_address} -J user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
    ${yandex_compute_instance.agent-b.network_interface.0.ip_address} # адрес agent-b
    # подключение ssh user@${yandex_compute_instance.agent-b.network_interface.0.ip_address} -J user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

    [agents:vars]
    ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
    XYZ
  filename = "./hosts.ini"
}
