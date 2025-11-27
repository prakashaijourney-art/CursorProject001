# CursorProject2511

A Salesforce DX project containing Apex classes for Account Health Score calculation.

## Project Overview

This project includes custom Apex classes that calculate and manage Account Health Scores based on business metrics.

## Components

### AccountHealthService

A service class that calculates and updates `Health_Score__c` for Account records based on:

- **AnnualRevenue** - Scored from 0 to 50 points
- **Last_90_Day_Wins__c** - Scored from 0 to 50 points

#### Scoring Logic

| AnnualRevenue | Score |
|---------------|-------|
| 0 or null | 0 |
| > 0 and < 250,000 | 10 |
| >= 250,000 and < 1,000,000 | 30 |
| >= 1,000,000 | 50 |

| Last_90_Day_Wins__c | Score |
|---------------------|-------|
| 0 or null | 0 |
| > 0 and < 25,000 | 10 |
| >= 25,000 and < 100,000 | 30 |
| >= 100,000 | 50 |

**Maximum Health Score: 100** (50 + 50)

### AccountHealthServiceTest

Test class with 9 test methods covering:
- All revenue scoring buckets
- All wins scoring buckets
- Bulk operations
- Null/empty input handling
- Idempotent behavior (no update when score unchanged)

## Custom Fields Required

| Field | Object | Type |
|-------|--------|------|
| `Health_Score__c` | Account | Number |
| `Last_90_Day_Wins__c` | Account | Number/Currency |

## Deployment

```bash
# Deploy to org
sf project deploy start --source-dir force-app

# Run tests
sf apex run test --class-names AccountHealthServiceTest --result-format human
```

## GitHub Repository

- **Repo:** [CursorProject001](https://github.com/prakashaijourney-art/CursorProject001)

## Resources

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
