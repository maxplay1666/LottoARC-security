# Security review scope

Review the deployed contract logic for USDC accounting, access control, callback authentication, randomness trust, settlement finality, refund eligibility, and withdrawal behavior. The frontend and private operating infrastructure are outside this source release.

This package is a reproducibility aid, not an independent security audit. No bug bounty or payment commitment is implied. Do not test with other users' funds or publish exploit details in public issues. Use GitHub's private vulnerability reporting for this repository when available.

The permanent-coordinator-failure lock described in README.md is a known unresolved limitation. Source availability does not remove provider trust or upgrade risk.
