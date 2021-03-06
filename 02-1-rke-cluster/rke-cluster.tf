locals {
  registered_masters = [for n in var.master_nodes : n if n.mode != "unregistered"]
  registered_workers = [for n in var.worker_nodes : n if n.mode != "unregistered"]
}

resource rke_cluster "rke-cluster" {
  delay_on_creation = 30
  cluster_name = var.rke_cluster_name
  kubernetes_version = var.rke_k8s_version
  ignore_docker_version = var.rke_ignore_docker_version
  prefix_path = var.rke_prefix_path
  cluster_yaml = file("configs/cluster.yaml")
  
  dynamic "nodes" {
    for_each = [ for vm in local.registered_masters: {
      name = "${var.vm_master_name_prefix}-${vm.sequence}"
      address = vm.ip
      role = lookup(var.profiles, vm.profile, {}).role
    }]

    content {
      hostname_override = nodes.value.name
      address = nodes.value.address
      internal_address = nodes.value.address
      user             = var.vm_user
      role             = nodes.value.role
      ssh_key          = file(var.rke_ssh_key_path)      
    }
  }

  dynamic "nodes" {
    for_each = [ for vm in local.registered_workers: {
      name = "${var.vm_worker_name_prefix}-${vm.sequence}"
      address = vm.ip
      role = lookup(var.profiles, vm.profile, {}).role
    }]

    content {
      hostname_override = nodes.value.name
      address = nodes.value.address
      internal_address = nodes.value.address
      user             = var.vm_user
      role             = nodes.value.role
      ssh_key          = file(var.rke_ssh_key_path)      
    }
  }
}
