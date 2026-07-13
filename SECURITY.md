# Security Policy

## Supported Versions

StrainAway is a personal, hobby project maintained in my spare time.
There is no formal long-term support commitment for older releases.
Security fixes, where applicable, will be applied to the most recent
release for each platform (macOS and Windows).

| Version | Supported |
| ------- | --------- |
| Latest release | Yes |
| Older releases | No |

## Reporting a Vulnerability

If you believe you've found a security issue in StrainAway, please
report it privately rather than opening a public GitHub issue, so
there's time to address it before it's publicly disclosed.

You can report it via GitHub's private vulnerability reporting feature:
go to the **Security** tab of this repository, then **Report a
vulnerability**.

Please include, where possible:
- A description of the issue and its potential impact
- Steps to reproduce it
- The platform (macOS or Windows) and version affected

## What to Expect

This is a solo, unpaid, hobby project, so please set expectations
accordingly:
- I'll do my best to acknowledge reports within a reasonable time,
  but there's no guaranteed response window or SLA.
- Given the app's limited scope (a local notification reminder with
  no network requests and no data collection — see the Privacy
  section of the main README), the realistic attack surface is small,
  but I still take reports seriously.
- Credit will be given in release notes for confirmed, responsibly
  disclosed issues, if you'd like it.

## Scope

This policy covers the source code and released builds in this
repository. It does not cover third-party dependencies (e.g. Swift
frameworks, Python packages listed in requirements.txt) — please
report issues in those directly to their respective maintainers.
