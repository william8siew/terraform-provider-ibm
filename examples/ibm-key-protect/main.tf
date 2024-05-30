resource "ibm_resource_instance" "kms_instance" {
  name     = "schematics_test"
  service  = "kms"
  plan     = "tiered-pricing"
  location = "us-south"
  service_endpoints = "private"
  parameters = {
    allowed_network = "private-only"
  }
}
resource "ibm_kms_key" "key" {
  instance_id = ibm_resource_instance.kms_instance.guid
  key_name       = "key"
  standard_key   = false
}
# resource "ibm_kms_kmip_adapter" "myadapter" {
#      instance_id = ibm_resource_instance.kms_instance.guid
#      profile = "native_1.0"
#      profile_data = {
#        "crk_id" = ibm_kms_key.key.key_id,
#      }
#      # description = "adding a description"
#      name = "wakaka"
# }


resource "ibm_kms_instance_policies" "instance_policy" {
  instance_id = ibm_resource_instance.kms_instance.guid
  endpoint_type = "private"
  rotation {
    enabled = true
    interval_month = 3
  }
  dual_auth_delete {
      enabled = false
  }
  metrics {
      enabled = true
  }
  key_create_import_access {
      enabled = true
  }
}

# data "ibm_kms_kmip_adapter" "myadapter_byname" {
#     instance_id = ibm_resource_instance.kms_instance.guid
#     name = ibm_kms_kmip_adapter.myadapter.name
# }

# data "ibm_kms_kmip_adapter" "myadapter_byid" {
#     instance_id = ibm_resource_instance.kms_instance.guid
#     adapter_id = ibm_kms_kmip_adapter.myadapter.adapter_id
# }

# resource "ibm_kms_kmip_client_cert" "mycert" {
#   instance_id = ibm_resource_instance.kms_instance.guid
#   adapter_id = ibm_kms_kmip_adapter.myadapter.adapter_id
#   certificate = "-----BEGIN CERTIFICATE-----\nMIIFRjCCAy4CCQDJeOJTTzej7DANBgkqhkiG9w0BAQsFADBlMQswCQYDVQQGEwJY\nWDELMAkGA1UECAwCVFgxDzANBgNVBAcMBkF1c3RpbjEMMAoGA1UECgwDSUJNMQsw\nCQYDVQQLDAJLUDEdMBsGA1UEAwwUQ29tbW9uTmFtZU9ySG9zdG5hbWUwHhcNMjQw\nNTE2MjEyMTA0WhcNMjQwNTE3MjEyMTA0WjBlMQswCQYDVQQGEwJYWDELMAkGA1UE\nCAwCVFgxDzANBgNVBAcMBkF1c3RpbjEMMAoGA1UECgwDSUJNMQswCQYDVQQLDAJL\nUDEdMBsGA1UEAwwUQ29tbW9uTmFtZU9ySG9zdG5hbWUwggIiMA0GCSqGSIb3DQEB\nAQUAA4ICDwAwggIKAoICAQDJjbVxUYBhQRoknc4Ov9b98GFStRuBgw3sL/r/iNpE\nCMmqf+a92zgvwQVx2yGU8TXMkDJf8K6CT5JiUQYzpa11/o4j4gwmVx2zGT7M8Yh6\nOivh4RVcoH+HVRMKFTyZ7K6tliLnGjYDqXf8/RnIUZu6NopijFFynDCGuNVP7fzF\ndAWGrIphMYsmswuzPrLm1G83BvzyYEey6g4Hq7iDnXVRdrm+jAInkzelUPoYDOAw\nK8Vkfi8lDoXudp67JYAqRfdJsQ6jjOzS9YkXKveFF+YjFJ6UAs58GN/rZsJsaO37\nrInc66Nq5qevEbCmxXGBuzB/xzd3PoN2kFM/HGYy1Z/ZxC980cXI+4WP6je5UpiW\nddNvXAGpNLPtxc/RdglEOofdlGUeOVjlpWoyhHAjQgtt1raZDEtsJ76q1CVC3Tw3\ncAg0nH718neCLvd9as5yMkWoWuaURZHe2vX+HvPcdMpK+Hy/LOT56M642Uxzpz5Z\noUedTH9GBTdf6G9rpSjgtefMZba8TnodUfmRsa+SO7As1P5CU6KEsljl6FWT0aX9\nicKjicvJI2n1E0TEqJjxG922qmaI8sgzc6bcZjDXXlxVpiBWxZ+ojjbjcm4+ETlH\ncbqtEwpLuj2g3F5I9DA+49SKbtPue09LQwKe0pe8o05b5Apu6TJ3aewg4bd4QEq9\noQIDAQABMA0GCSqGSIb3DQEBCwUAA4ICAQAjBwomZqdlSkcv2SEi5ggxNbV/UbEf\n/B6xWkWHijlEPI0/+OSl17fO1Qh41fPoK2PPiS0jy0XYs3FrsC2ccgoCu+uUoxt0\nHK+7cGDx6VMgx2+Li3m/Gks18floVn4pWj4wZZodtImyrPh8dp/M+iyY0XbhuhlF\ng1dv4u52UrA21tHY59KIJPZsOHCTMuakawXz3dKe2k9Ry7Wv/euN/KgN9mvnvdga\nFwAbQZEXj+RAdN6uT4RXoDkEzxL9xZKZNBOtHlM8rKkv+UgoNMfpZ4RT1/3nZy7m\nU5bnB2hrS7uAA0d7hxkDvQSpXmybbipFkUyZAtSSiyEiPi8HV0O6QFFEIuSpioE3\n9mxa9CVbwcQBpaAQHD94g3IJE+HjAMr3Zxe/G21z5j1n+RY8Kfr0aGOQZECGALyV\nxiNxDVop0Wp+0l/5tWJsiDy9KvyWjfT5aixStpOj97SYfyZ14avRflkjkcfwZpQp\nMPZaGxwpCSjbg4JRJPAE1F9E9Ui6uLahIlPMcrnViuBDcX3HNogIx7HCdBqaW+7a\nbNJuh8enpWdZboUc3ONQCSs8XE/5gxxHmf1KAYlhv5LRwR/PEfE3Emnu3WfBOZCn\noQryQhfiCXj5MFPAfBU8GbS+Jlz8kK2PWAzYLA0HwZsdTyO6QQ9vOH176adT/DRL\n2r8evBdH8svVWg==\n-----END CERTIFICATE-----"
#   name = "ayay"
# }

# data "ibm_kms_kmip_client_cert" "mycert_byname" {
#   instance_id = ibm_resource_instance.kms_instance.guid
#   adapter_name = ibm_kms_kmip_adapter.myadapter.name
#   name = ibm_kms_kmip_client_cert.mycert.name
# }

# data "ibm_kms_kmip_client_cert" "mycert_byid" {
#   instance_id = ibm_resource_instance.kms_instance.guid
#   adapter_id = ibm_kms_kmip_adapter.myadapter.adapter_id
#   cert_id = ibm_kms_kmip_client_cert.mycert.cert_id
# }



# resource "ibm_kms_key" "key_part_of_key_ring2" {
#   instance_id = ibm_resource_instance.kms_instance.guid
#   key_name       = "key_part_of_key_ring2"
#   description = "I am description of keyring22"
#   key_ring_id = ibm_kms_key_rings.key_ring.key_ring_id
#   standard_key   = true
#   expiration_date = "2024-02-01T23:20:50Z"
#   payload = "aW1wb3J0ZWQucGF5bG9hZA=="
# }

# resource "ibm_kms_kmip_adapter" "adapter1"{
#   instance_id = ibm_resource_instance.kms_instance.guid
#   name = "adapter-name"
#   profile = "native_1.0"
#   profile_data = {"crk_id":ibm_kms_key.key_part_of_key_ring.key_id}
# }

# resource "ibm_iam_authorization_policy" "policy" {
#   source_service_name = "cloud-object-storage"
#   target_service_name = "kms"
#   roles               = ["Reader"]
# }
