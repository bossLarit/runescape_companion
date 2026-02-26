# ──────────────────────────────────────────────────────────────
# GitHub Repository Setup Script
# Creates branches (dev, qa) and sets branch protection rules.
#
# Prerequisites:
#   - GitHub CLI (gh) installed: https://cli.github.com/
#   - Authenticated:  gh auth login
#
# Usage:
#   .\scripts\setup_github.ps1
# ──────────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"

$owner = "bossLarit"
$repo = "runescape_companion"

Write-Host "`n=== GitHub Environment Setup ===" -ForegroundColor Cyan
Write-Host "Repository: $owner/$repo`n"

# ── 1. Verify gh CLI is available ────────────────────────────
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: GitHub CLI (gh) not found. Install from https://cli.github.com/" -ForegroundColor Red
    exit 1
}

# Verify auth
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not authenticated. Run 'gh auth login' first." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] GitHub CLI authenticated" -ForegroundColor Green

# ── 2. Create branches if they don't exist ───────────────────
Write-Host "`n--- Creating branches ---" -ForegroundColor Yellow

$branches = @("dev", "qa")
$defaultBranch = (gh api "repos/$owner/$repo" --jq '.default_branch') 2>&1

foreach ($branch in $branches) {
    gh api "repos/$owner/$repo/branches/$branch" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Branch '$branch' already exists" -ForegroundColor DarkGray
    }
    else {
        Write-Host "  Creating branch '$branch' from '$defaultBranch'..."
        $sha = gh api "repos/$owner/$repo/git/ref/heads/$defaultBranch" --jq '.object.sha'
        gh api "repos/$owner/$repo/git/refs" -X POST -f "ref=refs/heads/$branch" -f "sha=$sha" | Out-Null
        Write-Host "  Branch '$branch' created" -ForegroundColor Green
    }
}

# ── 3. Set branch protection rules ──────────────────────────
Write-Host "`n--- Setting branch protection rules ---" -ForegroundColor Yellow

# Helper function
function Set-BranchProtection {
    param(
        [string]$Branch,
        [bool]$RequirePR,
        [int]$RequiredReviewers,
        [bool]$RequireStatusChecks,
        [string[]]$StatusChecks,
        [bool]$EnforceAdmins,
        [bool]$AllowForcePush,
        [bool]$AllowDeletions
    )

    Write-Host "`n  Configuring protection for '$Branch'..."

    # Build the JSON body
    $body = @{
        enforce_admins                = $EnforceAdmins
        required_pull_request_reviews = $null
        required_status_checks        = $null
        restrictions                  = $null
        allow_force_pushes            = $AllowForcePush
        allow_deletions               = $AllowDeletions
    }

    if ($RequirePR) {
        $body.required_pull_request_reviews = @{
            required_approving_review_count = $RequiredReviewers
            dismiss_stale_reviews           = $true
        }
    }

    if ($RequireStatusChecks -and $StatusChecks.Count -gt 0) {
        $checks = $StatusChecks | ForEach-Object { @{ context = $_; app_id = -1 } }
        $body.required_status_checks = @{
            strict = $true
            checks = $checks
        }
    }

    $json = $body | ConvertTo-Json -Depth 5 -Compress

    $json | gh api "repos/$owner/$repo/branches/$Branch/protection" `
        -X PUT `
        --input - 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Protection set for '$Branch'" -ForegroundColor Green
    }
    else {
        Write-Host "  [WARN] Could not set protection for '$Branch'." -ForegroundColor Yellow
        Write-Host "         Branch protection requires a GitHub Pro/Team plan for private repos." -ForegroundColor DarkGray
    }
}

# ── main (prod) ──
Set-BranchProtection -Branch "main" `
    -RequirePR $true `
    -RequiredReviewers 1 `
    -RequireStatusChecks $true `
    -StatusChecks @("build-prod") `
    -EnforceAdmins $true `
    -AllowForcePush $false `
    -AllowDeletions $false

# ── qa ──
Set-BranchProtection -Branch "qa" `
    -RequirePR $true `
    -RequiredReviewers 0 `
    -RequireStatusChecks $true `
    -StatusChecks @("build-qa") `
    -EnforceAdmins $false `
    -AllowForcePush $false `
    -AllowDeletions $false

# ── dev ──
Set-BranchProtection -Branch "dev" `
    -RequirePR $false `
    -RequiredReviewers 0 `
    -RequireStatusChecks $false `
    -StatusChecks @() `
    -EnforceAdmins $false `
    -AllowForcePush $true `
    -AllowDeletions $false

# ── 4. Summary ───────────────────────────────────────────────
Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host @"

Branch Strategy:
  dev   -> Free push, CI builds + tests on every push
  qa    -> PR required, CI builds + tests, pre-release on tag (v*-rc*)
  main  -> PR required + 1 review, CI builds + tests, prod release on tag (v*.*.*)

Workflow:
  1. Develop on 'dev' branch (or feature branches -> dev)
  2. When ready for testing: merge dev -> qa
  3. Tag qa with 'v1.2.0-rc1' for pre-release builds
  4. When approved: merge qa -> main
  5. Tag main with 'v1.2.0' for production release

"@ -ForegroundColor White
