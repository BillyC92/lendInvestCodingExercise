/*
 * @Author: Billy Cavanagh
 * Date: 13.12.2022
 * Purpose: Queueable class that performs the callout to the Twilio Rest API.
 */
public with sharing class TwilioCalloutQueueable implements Queueable, Database.AllowsCallouts {

    List<Account> accs;
    String customSMS;
    Boolean custom;
    String customNumber;

    public TwilioCalloutQueueable(CalloutController.CalloutWrapper cw) {
        this.accs = cw.accounts;
        this.customSMS = cw.smsBody;
        this.custom = cw.custom;
        this.customNumber = cw.toNumber;
    }

    public class RequestWrapper {
        String endPoint;
        String toNumber;
        Blob credentials;
        String smsMessageBody;

        public RequestWrapper(String endPoint, String toNumber, Blob credentials, String smsMessageBody) {
            this.endPoint = endPoint;
            this.toNumber = toNumber;
            this.credentials = credentials;
            this.smsMessageBody = smsMessageBody;
        }
    }

    // Exectue method of Queueable Apex to make callout to Twilio API
    // Process list of Accounts and sets the Account name dynamically before sending the message
    public void execute(QueueableContext context) {

        API_Access_Data__c twilAcc = API_Access_Data__c.getInstance('Twilio');
        Phone_Number__c phoneNumberSetting = Phone_Number__c.getInstance('CEO');

        String accountSid = twilAcc.SID__c;
        String token = twilAcc.token__c;

        String endPoint = twilAcc.Base_URL__c + accountSid + '/SMS/Messages.json';
        
        for(Account a : accs) {
            List<String> params = new List<String>{a.name};
            String smsMessageBody = '';
            String toNumber = '';

            if(custom) {
                smsMessageBody = customSMS;
                toNumber = customNumber;
            } else {
                smsMessageBody = String.format(System.Label.SMS_Gold_Message,params);
                toNumber = phoneNumberSetting.Number__c;
            }

            Blob credentials = Blob.valueOf(accountSid+':' +token);

            RequestWrapper callWrap = new RequestWrapper(endPoint, toNumber, credentials, smsMessageBody);
 
            HTTPResponse res = postMessageToTwilio(callWrap);

            //TODO : Add error handling if the Status code returned is not 201

        }        
        
    }

    // Method to send the request to Twilio using parameters set in the Request Wrapper class
    // Returns the HttpResponse
    public static HttpResponse postMessageToTwilio(RequestWrapper rw) {

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();

        req.setEndpoint(rw.endPoint);
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(rw.credentials));

        // TODO : Update From number to be another custom setting rather than hardcoded
        req.setBody('To=' + EncodingUtil.urlEncode(rw.toNumber, 'UTF-8') + '&From=' + EncodingUtil.urlEncode('+44 7862 128659','UTF-8') + '&Body=' + rw.smsMessageBody);
        res = http.send(req);

        return res;
    }


}

