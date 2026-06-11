# Vulnerability disclosure policy

## Where to report

- **GitHub Security Advisory** (private, preferred):
  <https://github.com/gio-salvador/wireguard-aws-express/security/advisories/new>
- If you cannot use GitHub, open a regular issue describing only that you have
  found a security concern (no details) and ask for a private channel.

Please report privately first. Do not open a public issue with exploit details.

## What to expect (timelines)

- **Acknowledgement** within **5 working days**
- **Initial triage** within **10 working days**
- **Resolution target** of **30 days** for High / Critical, **90 days** otherwise
- **Coordinated disclosure** with the reporter; default 90-day window

## In scope

- This repository: the Terraform configuration, the WireGuard setup shell
  scripts, the CI/CD workflows, and the supply chain that builds them.

## Out of scope

- Any infrastructure you deploy from this code into your own AWS account. You
  own and operate that deployment; secure it per the README guidance (restrict
  security groups, rotate keys, keep the host patched).
- Third-party services (AWS, the WireGuard project, upstream Terraform
  providers) — report to the respective vendor; we may help coordinate.
- Social engineering and physical security.
- Volumetric / network denial of service.

## Safe harbour

We will **not pursue legal action** against good-faith research that:

- Avoids privacy violations, data destruction, and service disruption
- Only touches your own accounts and test infrastructure
- Gives reasonable time before public disclosure (default 90 days)
- Does not exfiltrate data beyond what is needed to demonstrate the issue

## What we will not do

- We do not run a paid bug-bounty programme. We acknowledge good-faith
  reporters publicly with their consent.
- We will not publicly disclose your identity without your written consent.
