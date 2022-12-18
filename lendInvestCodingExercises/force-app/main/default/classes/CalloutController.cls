/*
 * @Author: Billy Cavanagh
 * Date: 13.12.2022
 * Purpose: Method called from flow to send SMS message to CEO when an Account reaches Gold status
 */
public with sharing class CalloutController {

    public class CalloutWrapper {
        public List<Account> accounts;
        public String smsBody;
        public String toNumber;
        public Boolean custom;
    }
    
    // Invocable method that is called from the CheckAccountGoldStatus flow
    // Retrieves List of all accounts using the IDs passed from the flow
    // Passes list to Queueable Apex class
    @InvocableMethod(callout=true)
    public static void callQueueableCallout(List<ID> accountIds) {

        System.debug('Getting to here');

        CalloutWrapper cw = new CalloutWrapper();
        cw.accounts = [Select id, name from Account where Id IN :accountIds];
        cw.smsBody = '';
        cw.toNumber = '';
        cw.custom = false;


    }

    // AuraEnaabled method that is called from the customSMSComponent LWC
    // Parameters taken from user input on component
    @AuraEnabled
    public static void callQueueableFromLWC(List<ID> accountIds, String smsBody, String toNumber) {

        CalloutWrapper cw = new CalloutWrapper();
        cw.accounts = [Select id, name from Account where Id IN :accountIds];
        cw.smsBody = smsBody;
        cw.toNumber = toNumber;
        cw.custom = true;

        Id jobId = System.enqueueJob(new TwilioCalloutQueueable(cw));

    }


}
