@isTest
public with sharing class CalloutControllerTest {
    
    @TestSetup
    static void makeData(){
        CommonDataFactory.createTestData();
    }

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'testJsonResponse';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void testClassification() {

        Account a = [Select id, customer_classification__c,Total_Customer_Spend__c from Account LIMIT 1];

        Opportunity o = [Select ID, Amount from Opportunity where accountId = :a.id Limit 1];

        Test.startTest();
            o.Amount = 50000;
            update o;
        Test.stopTest();

        Account aAfter = [Select Id, customer_classification__c from account where id = :a.id];

        System.assertEquals('GOLD', aAfter.customer_classification__c, 'Classification does not match');

    }

    @isTest
    public static void testInvocable() {

        Test.setMock(HttpCalloutMock.class, new RestMock());

        List<Id> accountIds = new List<Id>();
        
        for (Account a : [Select id from Account Limit 2]) {
            accountIds.add(a.id);
        }

        Test.startTest();
           CalloutController.callQueueableCallout(accountIds);
        Test.stopTest();

        System.assertEquals('Completed', [SELECT Status FROM AsyncApexJob WHERE JobType = 'Queueable'].Status, 'Job has not completed');

    }

    @isTest
    public static void testLwcCallout() {

        Test.setMock(HttpCalloutMock.class, new RestMock());

        List<Id> accountIds = new List<Id>();
        
        for (Account a : [Select id from Account Limit 2]) {
            accountIds.add(a.id);
        }

        String smsBody = 'testSMSBody';
        String toNumber = 'testNumber';

        Test.startTest();
           CalloutController.callQueueableFromLWC(accountIds, smsBody, toNumber);
        Test.stopTest();

        System.assertEquals('Completed', [SELECT Status FROM AsyncApexJob WHERE JobType = 'Queueable'].Status, 'Job has not completed');

    }

}
