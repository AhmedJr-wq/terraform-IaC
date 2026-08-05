# Assumptions Log — Kente Retail Staging Stack ("Codify It")

## 1. Interpretation of "rebuildable on demand"

The CTO's brief deliberately doesn't say whether "rebuildable on demand" means a single
`terraform apply` with zero manual steps, or some acceptable amount of one-time manual
bootstrapping. I interpreted it as the latter, and judged the following as acceptable manual
bootstrapping rather than something that needs to be automated away:

- **Filling in `terraform.tfvars`** — `project_tag`, `allowed_ssh_cidr`, and `ami_id` have no
  safe default (the spec explicitly requires `allowed_ssh_cidr` to never default to something
  reachable, and `project_tag` has no default by design so nobody accidentally applies with a
  placeholder identifier). These are account/operator-specific values; hardcoding or
  auto-generating them would trade a five-minute manual step for a worse problem (a shared
  default CIDR or naming collision across learners' sandbox accounts).
- **`terraform init`** once per fresh checkout, to pull providers.

Given those two one-time steps, `terraform apply` alone reproduces the entire stack — VPC
through IAM role — with no console clicks. That's the bar I held "rebuildable on demand" to.

**Limitation worth flagging to the CTO:** this module intentionally uses local state only (spec
section 7 — remote state is Module 4's topic). "Rebuildable on demand" here means rebuildable
from the same operator's machine with their existing `terraform.tfstate`. If that state file or
machine were lost, recovery would mean either `terraform import`-ing the existing resources back
into a new state file, or tearing down and re-applying from scratch — not a true zero-touch
rebuild. That gap is by design for this lab, not an oversight, but it's a real constraint on
"on demand" that a production rollout would need to close with remote state.

## 2. Clarifying questions I'd ask the CTO in a real engagement

- Is proving network reachability + IAM/S3 wiring sufficient for this staging proof, or does
  the "app port" (8080) need an actual running service before this is considered done? (See
  gap in section 3 — I judged network-level reachability sufficient for this pass.)
- What's the exact teardown deadline date/time? The brief says "by end of the sprint," but I'd
  want a hard timestamp before treating a late destroy as compliant.
- Given AWS's 2024 change to bill all public IPv4 addresses regardless of attachment, is a
  public-facing staging box still the right default going forward, or should future iterations
  consider a bastion/NAT pattern to reduce the number of billed public IPs at scale?
- Should the security group's outbound rule stay unrestricted, or does Kente Retail have an
  egress policy (e.g., no direct internet access to third-party APIs) that a staging box should
  also honor for parity with production?

## 3. Other requirement gaps I filled in myself

- **Region mismatch in the starter:** `variables.tf` defaults `aws_region` to `eu-west-1`, but
  `terraform.tfvars.example` suggests `us-east-1`. I went with `eu-west-1` (the variable's
  actual default) rather than the example file's suggestion, since the variable definition is
  the authoritative source and the example is just a template. Worth a note back to whoever
  maintains the starter — the two files disagree.
- **CIDR ranges** — used the starter's defaults (`10.42.0.0/16` VPC, `10.42.1.0/24` subnet),
  confirmed the subnet range sits inside the VPC range as the spec requires (section 1).
- **Instance sizing** — kept the spec's reference size, `t3.micro` (see cost estimate in
  `EXECUTIVE_SUMMARY.md` for the justification).
- **Missing `key_name`/`user_data` on the EC2 instance** — the security group opens port 8080
  for "the app," but nothing in the starter installs or starts anything there, and there's no
  key pair wired up for SSH login either. I treated this as this copy's "deliberately missing
  piece" (per the starter README) rather than building an app, since the spec (section 2) only
  requires the instance have a public IP "reachable for the verification step," not a running
  service. I verified reachability at the TCP/sshd level instead of an app-level check — see
  the verification transcripts. Flagged as a gap rather than silently working around it.