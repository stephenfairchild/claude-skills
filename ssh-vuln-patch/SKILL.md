---
name: ssh-vuln-patch
description: Scan one or more servers over SSH for security vulnerabilities with Trivy, build a prioritized list of things to patch, then walk the user through patching them one at a time. Use when the user names servers (hostnames or ssh aliases) and asks to scan, audit, or patch them for vulnerabilities.
---

# Scan servers over SSH and patch what is found

The user gives you the servers to look at (ssh hostnames, aliases from `~/.ssh/config`, or `user@host`). If they gave none, ask which ones. Treat each host separately and finish one host before starting the next.

## Ground rules

- Scanning is read-only and needs no approval beyond the user naming the host. Installing software, patching, restarting services and rebooting all change the server: ask before each one, and say exactly what will run.
- Use plain `ssh <host> '<command>'` with `-o BatchMode=yes -o ConnectTimeout=10`. If SSH fails (timeout, auth), report it and move on to the next host; do not try other users or keys.
- Never run a patch the user has not approved in this walkthrough. Approval for one item does not cover the next.
- Do not print secrets that a scan surfaces. Name the file and rule only.
- Do not reboot or restart a service without asking, even when a patch needs it. Say it is pending and let the user choose when.

## 1. Check the host and Trivy

```
ssh -o BatchMode=yes -o ConnectTimeout=10 <host> 'uname -sm; cat /etc/os-release | head -3; command -v trivy && trivy --version; command -v docker'
```

If `trivy` is missing, tell the user and ask before installing. Prefer the distro route, in this order:

1. Debian/Ubuntu: add the official Trivy apt repo (`https://aquasecurity.github.io/trivy-repo/deb`, its signing key, then `apt-get install trivy`).
2. RHEL/Fedora: the official yum repo from the Trivy docs.
3. Anything else: the release tarball from `github.com/aquasecurity/trivy/releases`, checked against its published checksum, into `/usr/local/bin`.

Look up the current install steps in the Trivy docs rather than from memory. Installs need sudo; if sudo wants a password, ask the user to run the command themselves with `! ssh -t <host> 'sudo ...'`. Confirm with `trivy --version` after.

## 2. Scan

Run the scans on the server and pull back JSON to a scratchpad file, one per host. Do not pull the whole filesystem over SSH.

- OS packages and language dependencies:
  `ssh <host> 'sudo trivy rootfs / --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --skip-dirs /proc,/sys,/dev,/run,/var/lib/docker -q -f json'`
- Misconfigurations and secrets on disk (optional, ask first because it is slow and noisy): add `--scanners misconfig,secret` and scope to the directories the user cares about, for example `/etc` or their app directory.
- If `docker` is present, list running images with `docker ps --format '{{.Image}}'` and scan each with `trivy image --severity HIGH,CRITICAL --ignore-unfixed -q -f json <image>`. Report image findings separately: they are fixed by rebuilding or bumping the image, not by `apt upgrade` on the host.

If a scan fails, show the error and stop on that host.

## 3. Build the patch list

Parse the JSON (`jq`). Group findings by package (or by image), and for each give: package, installed version, fixed version, the highest severity, the CVE ids, and the fix type. Sort CRITICAL before HIGH, then by number of CVEs.

Fix types:

- **OS package** (`apt`/`dnf`): upgrade the single package, for example `sudo apt-get install --only-upgrade <pkg>`.
- **Kernel or libc/openssl-class package**: patch is a package upgrade but needs a reboot or service restarts to take effect. Flag it.
- **Language dependency in an app directory** (a lockfile such as `Cargo.lock`, `package-lock.json`): fixed in the app's source and redeployed, not on the host. Say which file and which version to bump.
- **Container image**: rebuild or pull a newer tag.
- **Misconfiguration or secret**: a manual change; describe it.

Show the user a numbered table per host, then a one-line total ("7 items: 2 CRITICAL, 5 HIGH, 3 need a restart"). If there is nothing to patch, say so plainly and stop. Mention that `--ignore-unfixed` hides findings that have no fix yet.

Ask whether to start the walkthrough, and whether to skip any items.

## 4. Walk through them one by one

For each item, in order:

1. State what it is, the risk in a sentence, the exact command you would run, and whether it needs a restart or reboot.
2. Ask for approval (yes / skip / stop). Do not batch several items into one question.
3. On yes, first record the current version (`dpkg -l <pkg>` or `rpm -q <pkg>`), run the patch, and show the result. For apt, use `sudo apt-get update` once per host first.
4. Verify: confirm the new version is installed and the package is no longer reported (re-run the targeted Trivy scan or compare versions). If the fix needs a restart, list the affected services (`sudo needrestart -r l` or `systemctl` checks) and ask whether to restart now or leave it pending.
5. On a failure (held package, dependency conflict, disk full), show the error, do not force it (`--force`, `-f`, removing packages), and ask how to proceed.

Items fixed in application source or images are not patched over SSH. For those, tell the user the exact change (file, old version, new version) and offer to make it if the project is open locally; otherwise leave it as a to-do.

## 5. Wrap up

After the last item on a host, re-run the scan from step 2 and report a before/after count. List anything skipped, failed, or waiting on a restart or reboot (with the reboot reason). Then continue with the next host, and finish with a short summary across all hosts.
