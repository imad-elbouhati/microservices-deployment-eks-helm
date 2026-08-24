# Terraform — AWS infrastructure

Provisions the AWS infrastructure this project deploys to: networking, an
EKS cluster, a managed node group, IRSA for the EBS CSI driver, and the
IAM identity used by CI/CD.

## What gets created

| File | Resources |
|---|---|
| `provider.tf` | AWS/TLS provider configuration and version constraints |
| `variables.tf` | All configurable inputs (region, CIDRs, instance type, scaling, etc.) |
| `eks.tf` | VPC (via the `terraform-aws-modules/vpc/aws` module), EKS cluster, EKS managed node group, the CI/CD IAM user and its cluster access |
| `iam-oidc.tf` | IAM OIDC identity provider for the cluster (enables IRSA) |
| `csi-driver-iam.tf` | IRSA role for the EBS CSI driver, federated via the OIDC provider |
| `csi-driver-addon.tf` | The `aws-ebs-csi-driver` EKS add-on itself |
| `outputs.tf` | Cluster endpoint/CA and CI/CD IAM credentials (all sensitive) |

## Design notes

- **Networking**: a VPC across two AZs with public and private subnets and
  a single NAT gateway (cost-optimized for a demo/portfolio workload — a
  production setup would typically use one NAT gateway per AZ for
  availability).
- **Node group**: `t3.small`, scaling 1–2 nodes by default — sized for a
  small demo app, not production load. All three are `variables.tf`
  inputs, not hardcoded, so this is a one-line change.
- **IRSA over node-level IAM**: the EBS CSI driver gets its own federated
  IAM role scoped to its own service account (`iam-oidc.tf` +
  `csi-driver-iam.tf`), rather than broad permissions on the node role.
- **CI/CD cluster access**: the `gitlab` IAM user (`eks.tf`) is granted
  exactly `eks:DescribeCluster` on this cluster, plus an
  `aws_eks_access_entry` mapping it to the Kubernetes username `gitlab`.
  It has **no Kubernetes permissions from IAM** — authorization is handled
  entirely by the namespace-scoped `Role`/`RoleBinding` in
  `../k8s/roles/`. This closes a gap that existed before: without the
  access entry, this IAM user had no way to authenticate to the cluster
  at all, regardless of what the Kubernetes RBAC objects granted.
- **State**: local state only (`.gitignore`d) — no remote backend/locking
  is configured. Fine for a single-operator portfolio project; a team
  setting would need an S3 + DynamoDB (or Terraform Cloud) backend.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Override any default via `-var` or a `.tfvars` file, e.g.:

```bash
terraform apply -var="aws_region=us-east-1" -var="node_instance_type=t3.medium"
```

## Validation performed

`terraform fmt -check`, `terraform validate`, and `terraform plan` were
run against this configuration (with `terraform init -backend=false`) to
confirm it initializes, resolves the `terraform-aws-modules/vpc/aws`
module and AWS/TLS providers, and is structurally valid. `terraform plan`
was not run to completion since it requires real AWS credentials, which
were not configured in the environment this was verified in — it failed
at the credential-resolution step only, with no configuration errors
surfaced before that point.
