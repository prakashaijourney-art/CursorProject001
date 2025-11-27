/**
 * @description Service class to calculate and update Account Health Scores
 * based on AnnualRevenue and Last_90_Day_Wins__c
 */
public with sharing class AccountHealthService {
    
    /**
     * @description Calculates and updates Health_Score__c for given Account IDs
     * @param accountIds Set of Account IDs to process
     */
    public static void updateHealthScores(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        
        List<Account> accountsToUpdate = new List<Account>();
        
        List<Account> accounts = [
            SELECT Id, AnnualRevenue, Last_90_Day_Wins__c, Health_Score__c
            FROM Account
            WHERE Id IN :accountIds
        ];
        
        for (Account acc : accounts) {
            Integer revenueScore = calculateRevenueScore(acc.AnnualRevenue);
            Integer recentWinsScore = calculateRecentWinsScore(acc.Last_90_Day_Wins__c);
            
            Decimal newHealthScore = revenueScore + recentWinsScore;
            
            if (acc.Health_Score__c != newHealthScore) {
                acc.Health_Score__c = newHealthScore;
                accountsToUpdate.add(acc);
            }
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    /**
     * @description Calculates Revenue Score based on AnnualRevenue
     * @param annualRevenue The Account's AnnualRevenue value
     * @return Integer score (0, 10, 30, or 50)
     */
    private static Integer calculateRevenueScore(Decimal annualRevenue) {
        if (annualRevenue == null || annualRevenue == 0) {
            return 0;
        } else if (annualRevenue > 0 && annualRevenue < 250000) {
            return 10;
        } else if (annualRevenue >= 250000 && annualRevenue < 1000000) {
            return 30;
        } else if (annualRevenue >= 1000000) {
            return 50;
        }
        return 0;
    }
    
    /**
     * @description Calculates Recent Wins Score based on Last_90_Day_Wins__c
     * @param last90DayWins The Account's Last_90_Day_Wins__c value
     * @return Integer score (0, 10, 30, or 50)
     */
    private static Integer calculateRecentWinsScore(Decimal last90DayWins) {
        if (last90DayWins == null || last90DayWins == 0) {
            return 0;
        } else if (last90DayWins > 0 && last90DayWins < 25000) {
            return 10;
        } else if (last90DayWins >= 25000 && last90DayWins < 100000) {
            return 30;
        } else if (last90DayWins >= 100000) {
            return 50;
        }
        return 0;
    }
}
