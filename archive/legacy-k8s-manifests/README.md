# Legacy raw Kubernetes manifests

This directory holds the project's original, pre-Helm deployment approach:
plain `Deployment`/`Service`/`ConfigMap`/`Secret`/`StorageClass` manifests
applied directly with `kubectl`.

It is kept as a record of how the project evolved, not as a supported
deployment method. **The `helm/` directory at the repository root is the
current, documented way to deploy this application** — see the root
[README](../../README.md) for instructions.

Contents:

- `weather/` — the original raw manifests for the auth, weather, and UI
  services (including a MySQL `Deployment` used before the Helm chart
  switched to the Bitnami MySQL subchart).
- `alerts/` — an Alertmanager routing config example. It is **not**
  deployed by anything in this repository (no Prometheus/Alertmanager
  release exists here) and uses placeholder values (webhook URL, wiki
  link). Kept only as an example of Alertmanager routing configuration.

If you want to try these manifests, note that all `Secret` values in this
directory are placeholders (`CHANGEME`) and must be replaced before use.
