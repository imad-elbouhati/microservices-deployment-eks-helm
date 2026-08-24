# Changelog

This project was originally built in August 2023 as a hands-on DevOps
exercise (AWS EKS + Terraform + Helm + GitLab CI/CD) and has been
maintained since as a reference implementation. The entries below cover
the 2026-08 audit pass; they are not a record of production releases.

## 2026-08 — Security and structure audit

**Security**
- Removed a hardcoded third-party API key and a hardcoded MySQL password
  from `docker-compose.yaml`; both are now sourced from environment
  variables (see `.env.example`).
- Removed a hardcoded JWT signing secret from the Go auth service and the
  Node UI service; both now require a `JWT_SECRET` environment variable
  and fail fast at startup if it is missing.
- Replaced the real, committed API key and MySQL password in the Kubernetes
  `Secret` manifests with placeholder values.
- Scoped the CI/CD `Role`/`RoleBinding` RBAC from a wildcard
  (`apiGroups: ["*"], resources: ["*"], verbs: ["*"]`) down to only the
  permissions needed to run `helm upgrade --install` against the
  application's own resources.
- Marked the Terraform-provisioned CI/CD IAM access key ID output as
  `sensitive`, alongside the secret key (already sensitive).
- Purged the leaked API key from the entire git history.

**Infrastructure/config correctness**
- Fixed the MySQL `StorageClass` to use the EBS CSI driver provisioner
  (`ebs.csi.aws.com`) instead of the deprecated in-tree provisioner
  (`kubernetes.io/aws-ebs`), matching the CSI driver already provisioned in
  Terraform.
- Enabled non-root `securityContext`/`podSecurityContext` defaults (dropped
  capabilities, `runAsNonRoot`, fixed UID) across all three Helm charts and
  Dockerfiles, instead of leaving them commented out.
- Rewrote `auth/Dockerfile` to use a standard `COPY`-based multi-stage
  build instead of `git clone`-ing the repository during the image build.
- Updated base images: `node:17` → `node:20-alpine`,
  `python:3.8-slim-buster` → `python:3.12-slim`, pinned `golang:1.22-alpine`
  / `alpine:3.19` for the auth service build.

**Structure**
- Moved the original raw Kubernetes manifests (pre-Helm) and the unused
  Alertmanager example config into `archive/legacy-k8s-manifests/`, with a
  note explaining they are historical, not the supported deployment path.
- Removed committed IDE metadata (`auth/.idea/`).
- Added a GitHub Actions workflow (`.github/workflows/ci.yml`) so the
  pipeline is actually visible and runnable on GitHub, alongside the
  existing `.gitlab-ci.yml`.
- Added `LICENSE` (MIT).
- Bumped all three Helm chart versions from `0.1.0` to `0.2.0` to reflect
  the above changes.

**Documentation**
- Rewrote `README.md` to document the architecture, security posture, and
  verification steps more thoroughly, and corrected a prior claim that
  Velero/EBS-snapshot disaster recovery was implemented — no
  Velero installation, backup schedule, or snapshot resource exists in this
  repository. The `StorageClass` provisions EBS-backed volumes (a
  prerequisite for snapshotting), but no backup/restore workflow is
  configured. This is now documented as a limitation, not a feature.
