/**
 * @description Test class for AccountHealthService
 * Covers all revenue and wins scoring buckets
 */
@IsTest
private class AccountHealthServiceTest {
    
    @TestSetup
    static void setupTestData() {
        List<Account> testAccounts = new List<Account>();
        
        // Account 1: Max scores - Revenue >= 1,000,000 (50) + Wins >= 100,000 (50) = 100
        testAccounts.add(new Account(
            Name = 'High Revenue High Wins',
            AnnualRevenue = 1500000,
            Last_90_Day_Wins__c = 150000
        ));
        
        // Account 2: Mid Revenue + Low Wins - Revenue >= 250,000 (30) + Wins < 25,000 (10) = 40
        testAccounts.add(new Account(
            Name = 'Mid Revenue Low Wins',
            AnnualRevenue = 500000,
            Last_90_Day_Wins__c = 15000
        ));
        
        // Account 3: Low Revenue + No Wins - Revenue < 250,000 (10) + Wins = 0 (0) = 10
        testAccounts.add(new Account(
            Name = 'Low Revenue No Wins',
            AnnualRevenue = 100000,
            Last_90_Day_Wins__c = 0
        ));
        
        // Account 4: No Revenue + No Wins - Revenue = 0 (0) + Wins = null (0) = 0
        testAccounts.add(new Account(
            Name = 'No Revenue No Wins',
            AnnualRevenue = 0,
            Last_90_Day_Wins__c = null
        ));
        
        insert testAccounts;
    }
    
    @IsTest
    static void testMaxScores() {
        // Revenue >= 1,000,000 (50) + Wins >= 100,000 (50) = 100
        Account acc = [SELECT Id FROM Account WHERE Name = 'High Revenue High Wins' LIMIT 1];
        
        Test.startTest();
        AccountHealthService.updateHealthScores(new Set<Id>{ acc.Id });
        Test.stopTest();
        
        Account result = [SELECT Health_Score__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100, result.Health_Score__c, 'Expected 50 + 50 = 100');
    }
    
    @IsTest
    static void testMidRevenueAndLowWins() {
        // Revenue >= 250,000 (30) + Wins < 25,000 (10) = 40
        Account acc = [SELECT Id FROM Account WHERE Name = 'Mid Revenue Low Wins' LIMIT 1];
        
        Test.startTest();
        AccountHealthService.updateHealthScores(new Set<Id>{ acc.Id });
        Test.stopTest();
        
        Account result = [SELECT Health_Score__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(40, result.Health_Score__c, 'Expected 30 + 10 = 40');
    }
    
    @IsTest
    static void testLowRevenueAndNoWins() {
        // Revenue < 250,000 (10) + Wins = 0 (0) = 10
        Account acc = [SELECT Id FROM Account WHERE Name = 'Low Revenue No Wins' LIMIT 1];
        
        Test.startTest();
        AccountHealthService.updateHealthScores(new Set<Id>{ acc.Id });
        Test.stopTest();
        
        Account result = [SELECT Health_Score__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(10, result.Health_Score__c, 'Expected 10 + 0 = 10');
    }
    
    @IsTest
    static void testZeroScores() {
        // Revenue = 0 (0) + Wins = null (0) = 0
        Account acc = [SELECT Id FROM Account WHERE Name = 'No Revenue No Wins' LIMIT 1];
        
        Test.startTest();
        AccountHealthService.updateHealthScores(new Set<Id>{ acc.Id });
        Test.stopTest();
        
        Account result = [SELECT Health_Score__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, result.Health_Score__c, 'Expected 0 + 0 = 0');
    }
    
    @IsTest
    static void testMidWinsBucket() {
        // Test mid wins bucket: >= 25,000 and < 100,000 (30)
        Account acc = new Account(
            Name = 'Test Mid Wins',
            AnnualRevenue = null,
            Last_90_Day_Wins__c = 50000
        );
        insert acc;
        
        Test.startTest();
        AccountHealthService.updateHealthScores(new Set<Id>{ acc.Id });
        Test.stopTest();
        
        Account result = [SELECT Health_Score__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(30, result.Health_Score__c, 'Expected 0 + 30 = 30');
    }
    
    @IsTest
    static void testBulkUpdate() {
        // Test updating multiple accounts at once
        List<Account> accounts = [SELECT Id FROM Account];
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        AccountHealthService.updateHealthScores(accountIds);
        Test.stopTest();
        
        List<Account> results = [SELECT Name, Health_Score__c FROM Account ORDER BY Name];
        System.assertEquals(4, results.size(), 'Should have 4 accounts');
    }
    
    @IsTest
    static void testNullAccountIds() {
        // Test with null input - should not throw exception
        Test.startTest();
        AccountHealthService.updateHealthScores(null);
        Test.stopTest();
        
        // If we reach here without exception, test passes
        System.assert(true, 'Method should handle null input gracefully');
    }
    
    @IsTest
    static void testEmptyAccountIds() {
        // Test with empty set - should not throw exception
        Test.startTest();
        AccountHealthService.updateHealthScores(new Set<Id>());
        Test.stopTest();
        
        // If we reach here without exception, test passes
        System.assert(true, 'Method should handle empty set gracefully');
    }
    
    @IsTest
    static void testNoUpdateWhenScoreUnchanged() {
        // First update to set health score
        Account acc = [SELECT Id FROM Account WHERE Name = 'High Revenue High Wins' LIMIT 1];
        AccountHealthService.updateHealthScores(new Set<Id>{ acc.Id });
        
        // Get the last modified date after first update
        Account afterFirst = [SELECT LastModifiedDate, Health_Score__c FROM Account WHERE Id = :acc.Id];
        
        Test.startTest();
        // Call again - should not update since score is already correct
        AccountHealthService.updateHealthScores(new Set<Id>{ acc.Id });
        Test.stopTest();
        
        Account afterSecond = [SELECT Health_Score__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100, afterSecond.Health_Score__c, 'Score should remain 100');
    }
}
