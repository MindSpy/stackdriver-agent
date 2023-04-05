
variable "registry_repository" {  }
variable "image_name" {  }
variable "image_ver" {  }


group "default" {
  targets = [  "agent" ]
}

target "agent" {
  platforms = [ "linux/amd64" ]
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  tags = [
     "${registry_repository}/${image_name}:${image_ver}",
     "${registry_repository}/${image_name}:latest"
     ]
  args = {
      image_ver = "${image_ver}"
    }
}