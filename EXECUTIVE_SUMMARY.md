# Executive Summary — Kente Retail Staging Stack ("Codify It")

**Prepared for:** Kente Retail CTO
**Project identifier:** `kente-cloth`
**Region:** eu-west-1

## 1. What was built

The staging environment specified in `kente-staging-infra-spec.md` was provisioned entirely
through Terraform — no console clicks: one VPC, one public subnet, an internet gateway and
route table, a security group restricted to a specific CIDR, an EC2 instance, an S3 bucket
with public access blocked, and an IAM role/instance profile scoped to that one bucket. Full
lifecycle evidence (plan, apply, verification) is captured in the repo's commit history and
`verify_*.txt` transcripts.

## 2. Cost estimate

| Resource | Rate | Basis |
|---|---|---|
| EC2 `t3.micro` (Linux) | $0.0116/hr | on-demand, eu-west-1 |
| Public IPv4 (in-use) | $0.005/hr | flat rate, all regions, since Feb 2024 |
| EBS root volume, 8 GiB gp3 | $0.0952/GB-mo (~$0.76/mo) | AL2023 default volume size |
| S3 Standard storage + requests | $0.023/GB-mo + per-request | a handful of test objects — effectively $0 |
| VPC, subnet, IGW, route table, SG, IAM role/profile | $0.00 | no charge for these resource types |
| Data transfer out | $0.00 | well under the 100 GB/month free allowance |

**Estimated cost for the two-week sprint (~336 hrs, if left running the whole time): ~$5.90.**
**Estimated cost if left running a full month: ~$12.88.**

*Note: EC2/EBS/S3 rates are current published AWS list prices for eu-west-1, not pulled live
from the Pricing API (the sandbox role lacks `pricing:GetProducts`); the public IPv4 rate was
confirmed live. Cross-check against calculator.aws if an authoritative tooling-generated quote
is required.*

### Sizing justifications
- **t3.micro** — smallest burstable instance that avoids CPU-credit exhaustion under light
  staging traffic, and it's the spec's stated reference size.
- **8 GiB gp3 root volume** — the AL2023 default; enough for OS + package cache without paying
  for space a short-lived staging box won't use.
- **S3 Standard (not IA/Glacier)** — data is actively read/written during the sprint, so a
  class with per-GB retrieval fees would cost more than the marginal storage savings at this
  scale.
- **Public IPv4** — unavoidable now that AWS bills every public IPv4 regardless of attachment;
  the instance must be internet-reachable per spec, so there's no cheaper alternative.
- **VPC/subnet/IGW/route table/SG/IAM role** — free resource types; the cost lever here is
  correctness (scoped IAM policy, restricted CIDR), not sizing.

## 3. Three benefits of Infrastructure as Code — demonstrated in this lab

1. **The exact failure mode the CTO described can't happen here.** The incident that started
   this lab was a security group rule fat-fingered in the console. Every rule in this stack —
   including the SSH CIDR restriction — is a reviewable line in `main.tf`, checked into git.
   A bad change would show up as a diff in a pull request, not as a silent click nobody can
   trace afterward.

2. **Gaps became visible before they became incidents, not after.** Reading this starter's
   `aws_instance` resource against the infra spec surfaced a real gap — no `key_name` or
   `user_data`, so the security group opens an app port nothing is listening on. Because the
   config is declarative and diffable, that gap was caught by inspection during verification.
   In a console-built environment, the same gap would have stayed invisible until someone
   actually needed port 8080 and the outage traced back to a step nobody remembered taking.

3. **The running stack is auditable without logging into the console.** `terraform output`
   and `terraform.tfstate` gave a complete, scriptable inventory of every resource ID (VPC,
   subnet, SG, instance, bucket) used directly to drive the verification commands — proving
   the EC2 instance is reachable and the S3 bucket accepts an object — without any manual
   console lookups.

## 4. Teardown confirmation

**Status: Pending.** Per the spec, the stack stays up through the sprint and is torn down by
the teardown deadline via `terraform destroy`, with the destroy transcript and an independent
account check as evidence. This section will be updated with that confirmation once teardown
is complete — do not treat this summary as final until it is.