// использовать самый свежий образ ubuntu
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

// создать ВМ bastion
resource "yandex_compute_instance" "bastion" {
  name        = "bastion" // имя ВМ в облачной консоли
  hostname    = "bastion" // формирует FQDN имя хоста, без hostname будет сгенерировано случайное имя
  platform_id = "standard-v3"
  zone        = "ru-central1-a" // зона ВМ должна совпадать с зоной subnet!

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    serial-port-enable = 1
    user-data          = "${file("./cloud-init.yml")}"
  }

  // прерываемая ВМ
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.student_a.id // зона ВМ должна совпадать с зоной subnet!
    nat                = true
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.bastion.id]
  }
}

