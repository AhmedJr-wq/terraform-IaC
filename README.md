# Kente Retail — Staging Stack (Terraform Starter)

Starter configuration for the "Codify It" lab. This is **deliberately incomplete or
partially wrong in one place** — everyone's copy of this starter is missing or has
degraded a different piece. Find it by reading `terraform validate`/`terraform plan`
output carefully and by checking your work against `kente-staging-infra-spec.md`
(one directory up) — don't assume the file you were handed is already correct.

## What this provisions

VPC, public subnet, internet gateway, route table, a security group, an EC2 instance,
an S3 bucket (with public access blocked), and an IAM role/instance profile scoped to
that one bucket. See the spec doc for the *why* behind each piece and the required
tagging convention.

## Before you run anything

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in real values —
   especially `project_tag` (used for tagging/naming — required for teardown to be
   verifiable) and `allowed_ssh_cidr` (your own IP/CIDR, never `0.0.0.0/0`).
2. Look up a current AMI ID for your own region and set `ami_id`. Don't reuse an AMI
   ID from someone else's account/region — it may not resolve for you.
3. Make sure the pinned Terraform version in `versions.tf` is what you have installed
   (`terraform version`). This module intentionally uses **local state only** — do not
   add a remote backend block (that's Module 4).

## Workflow

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Capture the `plan` and `apply` output (redirect to a file, or keep the terminal
transcript) — the Acceptance Criteria require lifecycle evidence, not just a working
end state.

After `apply`, prove the resources actually work — e.g. reach the instance on its
public IP/app port, and put/get an object in the bucket — before you consider this
done. Then, when your teardown deadline arrives:

```bash
terraform destroy
```

Keep evidence of the destroy too — an instructor will run an independent teardown
check against the sandbox account, not just take your word for it.

## Cost estimate

Produce a cost estimate for this stack (a tool like `terraform plan` combined with a
pricing calculator, or a manual line-item calculation against the AWS pricing page —
either is acceptable) and write one sentence justifying the size/type of each
resource. Put this in your one-page executive summary, not buried in a code comment.
