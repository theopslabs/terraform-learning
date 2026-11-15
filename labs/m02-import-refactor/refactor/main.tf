# The "legacy" data source is only present in state if you applied an older
# version of this configuration. On a fresh state the moved block is a no-op
# and is safe to keep as documentation of the rename.
moved {
  from = terraform_data.legacy
  to   = terraform_data.current
}

# The "temporary" resource is not declared in this configuration. If it exists
# in state (for example, after removing the declaration), this block forgets
# it without destroying the underlying object.
removed {
  from = terraform_data.temporary

  lifecycle {
    destroy = false
  }
}

resource "terraform_data" "current" {
  input = {
    name    = "current"
    purpose = "demonstrates moved blocks"
  }
}

resource "terraform_data" "kept" {
  input = {
    name    = "kept"
    purpose = "stays in place during refactors"
  }
}
