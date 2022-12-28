import { LightningElement, api, wire, track } from 'lwc';
import sendMessage from '@salesforce/apex/CalloutController.callQueueableFromLWC';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomSMSComponent extends LightningElement {

    @api recordId;
    smsBody = '';

    @wire(getRecord, { recordId: '$recordId', fields : [PHONE_FIELD] })
    account;

    accounts = [];

    getPhone() {
        return getFieldValue(this.account.data, PHONE_FIELD);
    }

    handleChange(event) {
        this.smsBody = event.target.value
    }

    get disabled() {
        return (this.smsBody.length === 0);
    }

    handleClick() {

        this.accounts.push(this.recordId);

        if(this.getPhone() != null) {
            sendMessage({accountIds: this.accounts, smsBody : this.smsBody, toNumber: this.getPhone()}).then(result=>{
               
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Message has been delivered',
                    variant: 'success',
                });
                this.dispatchEvent(event);

                this.handleResetInput();

            }).catch(error=>{
                
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'The message has not been delivered. Please try again',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            })
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please ensure the phone number field is populated on the Account',
                //message: reduceErrors(error),
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
       
    }

    handleResetInput() {
        this.template.querySelector('lightning-textarea[data-name="messageInput"]').value = '';
        
    }

    
}