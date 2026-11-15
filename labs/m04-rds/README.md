# Lab: RDS with Managed Credentials

**Module:** 4 | **Lesson:** 4 | **Time:** 60–90 minutes | **Cost:** ≈ $0.03/hour plus storage

## Goal

Create a private MySQL RDS instance with storage encryption, a dedicated subnet group, and an RDS-managed master password stored in Secrets Manager. The database is reachable only from inside the VPC.

## What you will learn

- How RDS subnet groups span availability zones
- How to keep a database out of public subnets
- How `manage_master_user_password` keeps passwords out of Terraform state
- Why `skip_final_snapshot` and `deletion_protection` matter for lab cleanup

## Before you start

- Complete [m04-vpc](../m04-vpc/) or understand VPC security groups
- Terraform 1.11+ and AWS credentials configured
- A budget alarm set — RDS bills hourly even when idle
- Your account must have a default VPC (the lab uses it for simplicity)

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | Subnet group, security group, RDS instance |
| `variables.tf` | Database name, user, class, engine |
| `outputs.tf` | Endpoint, port, secret ARN |

## Run it

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

RDS creation takes **5–10 minutes**. The apply may appear idle; that is normal.

```bash
terraform output
aws secretsmanager get-secret-value \
  --secret-id "$(terraform output -raw master_user_secret_arn)" \
  --query SecretString --output text
```

The secret is JSON containing `username` and `password`. Do not paste it into lesson notes or commit it.

## Expected output

```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

db_address             = "terraform-learning-db.abc123.us-east-1.rds.amazonaws.com"
db_endpoint            = "terraform-learning-db.abc123.us-east-1.rds.amazonaws.com:3306"
db_name                = "appdb"
db_port                = 3306
master_user_secret_arn = <sensitive>
security_group_id      = "sg-..."
```

Confirm in the RDS console:

- **Publicly accessible** is **No**
- **Storage encrypted** is **Yes**
- The instance is in the default VPC's subnets

## Break it

1. Set `publicly_accessible = true` and run `terraform plan`. Read the diff, then revert. A public database is almost never the right choice.
2. Change `instance_class` to `db.t3.small`. RDS applies the change during the next maintenance window unless `apply_immediately = true`.
3. Change `db_name`. RDS replaces the instance because the initial database name is immutable. Do this only in a sandbox.
4. Set `skip_final_snapshot = false` and `final_snapshot_identifier`. Destroy now creates a snapshot that continues to cost money. Revert before cleanup.
5. Add `backup_retention_period = 0` and observe that automated backups are disabled. This is cheaper but riskier.

## Connect from an EC2 instance

RDS is not reachable from your laptop because the security group only allows the VPC CIDR. To test connectivity:

1. Launch a small EC2 instance in the same VPC with the `m04-vpc` web security group.
2. Install a MySQL client: `sudo dnf install -y mariadb105`.
3. Connect using the endpoint and the credentials from Secrets Manager.

Destroy the EC2 instance when finished.

## Cost and cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

Destroy removes the database, subnet group, and security group. The RDS-managed secret is deleted with the instance. Check the RDS console for any final snapshots; snapshots are not deleted automatically.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `DBSubnetGroupDoesNotCoverEnoughAZs` | The subnet group needs subnets in at least two AZs |
| `InvalidParameterValue: DB instance class` | The class is not available in the region; try `db.t3.micro` |
| `Cannot create a DB instance because the VPC does not have a default subnet group` | Create a default VPC or pass your own subnets |
| `InsufficientDBInstanceCapacity` | Try another AZ or instance class |
| Apply seems stuck | RDS provisioning is slow; check the RDS console events |

## Production notes

- Use `multi_az = true` for high availability.
- Keep `deletion_protection = true` and `skip_final_snapshot = false` in production.
- Enable automated backups, performance insights, and enhanced monitoring.
- Put the database in private subnets from `m04-vpc`, not the default VPC.
- Use a customer-managed KMS key for encryption if your compliance regime requires it.

## Next

Continue to [m05-secrets](../m05-secrets/), then combine the network, compute, and data layers in the [capstone](../../capstone/).
