// Create a new VPC Network (наша сеть)
resource "yandex_vpc_network" "student" {
  name = "student-fops-${var.flow}"
}

// Create a new VPC NAT Gateway (для выхода в интернет)
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "fops-gateway-${var.flow}"
  shared_egress_gateway {}
}

// Create a new VPC Route Table
// (сетевой машрут для выхода серверов web-a и web-b в интернет через NAT)
resource "yandex_vpc_route_table" "rt" {
  name       = "fops-route-table-${var.flow}"
  network_id = yandex_vpc_network.student.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

// Create a new VPC Subnet (подсеть зона a)
resource "yandex_vpc_subnet" "student_a" {
  name           = "student-fops-${var.flow}-ru-central1-a"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.1.0/24"]
  network_id     = yandex_vpc_network.student.id
  route_table_id = yandex_vpc_route_table.rt.id
}

// Create a new VPC Subnet (подсеть зона b)
resource "yandex_vpc_subnet" "student_b" {
  name           = "student-fops-${var.flow}-ru-central1-b"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.0.2.0/24"]
  network_id     = yandex_vpc_network.student.id
  route_table_id = yandex_vpc_route_table.rt.id
}

// Create a new VPC Security Group (firewall)
resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg-${var.flow}"
  network_id = yandex_vpc_network.student.id
  // разрешить входящий трафик TCP на порт SSH с любых адресов
  ingress {
    protocol       = "TCP"
    description    = "Allow 0.0.0.0/0"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  // разрешить входящий трафик TCP на порт HTTP с любых адресов
  ingress {
    protocol       = "TCP"
    description    = "Allow 0.0.0.0/0 - for Zabbix web server"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  // разрешить исходящий трафик любой на любые адреса с любых портов
  egress {
    protocol       = "TCP"
    description    = "Allow ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "LAN" {
  name       = "LAN-sg-${var.flow}"
  network_id = yandex_vpc_network.student.id
  // not best practic (надо разграничивать сетевые зоны)
  ingress {
    protocol       = "ANY"
    description    = "Allow 10.0.0.0/8"
    v4_cidr_blocks = ["10.0.0.0/8"]
    from_port      = 0
    to_port        = 65535
  }
  egress {
    protocol       = "ANY"
    description    = "Allow ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "agents-sg" {
  name       = "agents-sg-${var.flow}"
  network_id = yandex_vpc_network.student.id
  ingress {
    protocol       = "TCP"
    description    = "Для пассивного опроса сервером Zabbix агента (агент слушает)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10050
  }
  egress {
    protocol       = "ANY"
    description    = "Для передачи данных от агента Zabbix (активный режим)"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }
}
