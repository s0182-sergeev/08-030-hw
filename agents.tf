// создать ВМ agent-a
resource "yandex_compute_instance" "agent-a" {
  name        = "agent-a" // имя ВМ в облачной консоли
  hostname    = "agent-a" // формирует FQDN имя хоста, без hostname будет сгенерировано случайное имя
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
    user-data          = "${file("./cloud-init.yml")}"
    serial-port-enable = 1
  }

  // прерываемая ВМ
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.student_a.id // зона ВМ должна совпадать с зоной subnet!
    nat                = false
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.agents-sg.id]
  }
}

// создать ВМ agent-b
resource "yandex_compute_instance" "agent-b" {
  name        = "agent-b" // имя ВМ в облачной консоли
  hostname    = "agent-b" // формирует FQDN имя хоста, без hostname будет сгенерировано случайное имя
  platform_id = "standard-v3"
  zone        = "ru-central1-b" // зона ВМ должна совпадать с зоной subnet!

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
    user-data          = "${file("./cloud-init.yml")}"
    serial-port-enable = 1
  }
  // прерываемая ВМ
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.student_b.id // зона ВМ должна совпадать с зоной subnet!
    nat                = false
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.agents-sg.id]
  }
}
