/*
 * @Author: Billy Cavanagh
 * Date: 13.12.2022
 * Purpose: Data factory class to create data for test classes within the org.
 */
@isTest
public with sharing class CommonDataFactory {
    

    public static List<Account> makeAccounts(Integer numOfAccounts) {

        List<Account> accountsToInsert = new List<Account>();

        for(Integer i = 0; i<numOfAccounts; i++) {
            Account a = new Account(
                phone = '+441111111111',
                name = 'TestAccount'+i,
                Gold_SMS_sent__c = false
            );

            accountsToInsert.add(a);
        }

        return accountsToInsert;
    }

    public static List<Opportunity> makeOpps(List<Account> accounts, Integer numOfOpps) {

        List<Opportunity> oppsToInsert = new List<Opportunity>();

        for(Account a : accounts) {
            for(integer i = 0; i<numOfOpps; i++) {
                Opportunity o = new Opportunity(
                    accountId = a.id,
                    name = a.name + ' opportunity',
                    StageName = 'Closed Won',
                    CloseDate = System.today() + 5
                );

                oppsToInsert.add(o);
            }
            
        }

        return oppsToInsert;

    }

    public static API_Access_Data__c createCustomSettingAPI() {
        
        API_Access_Data__c apiData = new API_Access_Data__c(
            SID__C = 'testSID',
            token__c = 'testToken',
            Base_URL__c = 'testBaseUrl',
            Name = 'Twilio'
        );

        return apiData;
    }

    public static Phone_Number__c createCustomSettingPhone() {
        
        Phone_Number__c apiData = new Phone_Number__c(
            Number__c = '+111111111111',
            Name = 'CEO'
        );

        return apiData;
    }

    public static void createTestData() {

        List<Account> accounts = makeAccounts(3);
        insert accounts;

        List<Opportunity> opps = makeOpps(accounts, 3);
        insert opps;

        API_Access_Data__c apiData = createCustomSettingAPI();
        insert apiData;

        Phone_Number__c phoneSetting = createCustomSettingPhone();
        insert phoneSetting;
    }

}
