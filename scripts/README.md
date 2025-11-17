# SpinneR Scripts

This directory contains utility scripts for SpinneR development and maintenance.

## create_github_issues.sh

**Purpose:** Automatically creates all 22 enhancement issues on GitHub for the SpinneR roadmap.

**Prerequisites:**
- GitHub CLI (`gh`) installed and authenticated
- Write access to the SpinneR repository

**Usage:**

```bash
# Navigate to repository root
cd /path/to/SpinneR

# Run the script
./scripts/create_github_issues.sh
```

**What it does:**

The script creates 22 detailed GitHub issues covering:

**Phase 1 - Foundation (Issues #1, #5, #10, #20, #22):**
- CRAN submission preparation
- Test coverage 90%+
- Error handling & debugging
- Code coverage badge
- Issue templates

**Phase 2 - Core Features (Issues #2, #7, #8, #13, #14, #15):**
- Customizable spinners
- Multi-line support
- Simplified installation
- Success/failure indicators
- Pause/resume functionality
- RStudio addins

**Phase 3 - Ecosystem Integration (Issues #3, #4, #9, #16, #17):**
- progressr integration
- pkgdown website
- future ecosystem support
- Rmarkdown/Quarto support
- Shiny integration

**Phase 4 - Polish & Marketing (Issues #6, #11, #12, #18, #19, #21):**
- Performance benchmarks
- Animated GIFs & demos
- Comparison vignette
- Logo & branding
- History/logging
- Rate limiting

**Output:**

The script will:
1. Create all 22 issues with proper labels
2. Include comprehensive descriptions and implementation details
3. Add priority and effort estimates
4. Link to relevant documentation

**After running:**

Visit https://github.com/SkanderMulder/SpinneR/issues to see all created issues.

**Troubleshooting:**

If the script fails:

1. **Check GitHub CLI authentication:**
   ```bash
   gh auth status
   ```

2. **Re-authenticate if needed:**
   ```bash
   gh auth login
   ```

3. **Verify repository access:**
   ```bash
   gh repo view SkanderMulder/SpinneR
   ```

4. **Run script with verbose output:**
   ```bash
   bash -x scripts/create_github_issues.sh
   ```

## Alternative: Manual Issue Creation

If you prefer to create issues manually, refer to:
- `ISSUES.md` - Core 12 issues (#1-12)
- `ISSUES_ADDITIONAL.md` - Additional 10 issues (#13-22)
- `ROADMAP.md` - Complete development roadmap

Copy the content from these files into GitHub's issue creation interface.

## Future Scripts

Additional scripts to be added:
- `run_benchmarks.sh` - Performance benchmark automation
- `generate_demos.sh` - Create animated GIFs
- `check_coverage.sh` - Test coverage reporting
- `prepare_cran.sh` - CRAN submission checklist
