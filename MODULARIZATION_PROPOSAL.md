# Modularization Design Sketch — Kente Retail Staging Stack

**Purpose:** propose how this configuration should be split into reusable Terraform modules
ahead of Module 4. This is a design sketch for review, not an implementation — no module code
is built here.

## Guiding principle for the split

Module boundaries should follow **who changes it, how often, and how sensitive it is** — not
just "one module per AWS service." A boundary is worth paying for only if it lets one part of
the stack change, be reviewed, or be reused independently of another. Applied to this stack:

| Boundary drawn between... | Because... |
|---|---|
| Networking vs. everything else | The VPC/subnet/IGW/route table change rarely and are shared infrastructure. App-level changes (a new instance type, a new bucket) should never require re-planning the network. |
| Security (SG + IAM) vs. compute/storage | These are the two resource types this lab's incident and spec care about most (console fat-finger risk, wildcard IAM). Isolating them into a reviewed, reusable module means every app team gets the "restricted CIDR, scoped policy" guarantee by construction, not by each engineer remembering to do it right. |
| Compute vs. storage | These vary independently per app (instance type/count vs. bucket name/lifecycle rules) and are the pieces most likely to differ between a second app team's copy of this stack and this one. |

## Proposed modules

```
modules/
├── networking/    (vpc, subnet, igw, route table, association)
├── app-security/  (security group, scoped to caller-supplied ports/CIDR)
├── s3-app-bucket/ (bucket + public access block)
├── ec2-iam-role/  (role, policy scoped to one bucket ARN, instance profile)
└── app-instance/  (the EC2 instance itself)

environments/
└── staging/       (root module — composes the above, holds project_tag, tfvars)
```

**Dependency graph** (arrow = "needs an output from"):

```
networking ──► app-security ──► app-instance
    │                                 ▲
    └──► s3-app-bucket ──► ec2-iam-role ┘
```

### Module sketches (inputs / outputs only — no implementation)

- **`networking`** — in: `vpc_cidr`, `subnet_cidr`, `availability_zone`, `project_tag`. out:
  `vpc_id`, `subnet_id`, `igw_id`. Nothing here should ever take an app-specific input.
- **`app-security`** — in: `vpc_id`, `allowed_cidr`, `ingress_ports`, `project_tag`. out:
  `security_group_id`. Bakes in "never `0.0.0.0/0`" as a variable validation rule, not a
  convention someone has to remember — this is where the console-fat-finger protection
  actually gets enforced for every future caller.
- **`s3-app-bucket`** — in: `bucket_name`, `project_tag`. out: `bucket_arn`, `bucket_name`.
  Public access block is hardcoded on inside the module, not exposed as a variable — a caller
  shouldn't be able to opt out of it.
- **`ec2-iam-role`** — in: `bucket_arn` (from `s3-app-bucket`), `project_tag`. out: `role_name`,
  `instance_profile_name`. Takes a single bucket ARN, not a list, to keep the "scoped to one
  bucket, not `s3:*`" guarantee structural rather than a code-review checklist item.
- **`app-instance`** — in: `ami_id`, `instance_type`, `subnet_id`, `security_group_id`,
  `instance_profile_name`, `project_tag`. out: `instance_id`, `public_ip`.

The `staging` environment becomes a thin composition root: it sets `project_tag` once, wires
module outputs into the next module's inputs per the graph above, and holds nothing
account-specific beyond what's already in `terraform.tfvars`.

## What I'm deliberately *not* modularizing yet

- **One module per resource** (e.g., a standalone module just for the route table) — this
  stack has a single environment and no second consumer yet. A module only pays for itself once
  something else reuses it; splitting further now would just add indirection with zero reuse to
  show for it.
- **A combined "networking + security" module** — tempting since they're both provisioned
  together today, but they change for different reasons (network topology is infrastructure
  team's call; ingress rules are the app team's call) and conflating them would force one team
  to touch the other's resources to make their own change.

## Why this split pays off specifically for Kente Retail

1. It directly targets the CTO's stated incident: `app-security` and `ec2-iam-role` become the
   two places a bad rule or an over-broad policy would have to slip past a module's own
   variable validation, not just a code reviewer's attention.
2. It sets up Module 4 cleanly: modules with narrow, typed inputs/outputs are exactly what
   compose across remote state / workspaces later — this stack won't need restructuring when
   that lands, just a backend block and module version pins.
3. A second app team standing up their own staging box reuses `networking`, `app-security`,
   `s3-app-bucket`, and `ec2-iam-role` unchanged, and only needs to write their own thin
   `app-instance` call and tfvars — most of the "getting it right" work is done once, in one
   reviewed place.