public class ContactsNeedReview implements Database.Batchable<sObject>, Database.Stateful {

 	Set<Id> idOwnersForEmail;
	Map <List<Contact>,Id> contactwithSameOwner;
    public static  String CRON_EXP='0 0 10 1/1 * ? *';
    
    SheduleTheContactReviewBatch reminder = new SheduleTheContactReviewBatch();
        String remindTime = CRON_EXP;
        String jobOwnerID = System.schedule('Remind Contact Owners', remindTime, reminder);
    
    public Database.QueryLocator  start(Database.BatchableContext bc) {
       String contactQuery='SELECT Name, AccountId, OwnerId, Phone '+
           'FROM Contact Where Possible_Outdated__c = TRUE';
        return Database.getQueryLocator(contactQuery);
    }
   
    public void execute(Database.BatchableContext bc, List<Contact> records) {
    	
        contactwithSameOwner=new Map<List<Contact>,ID>();
        idOwnersForEmail= new Set<Id>();
        List<Contact> contacts= new List<Contact>();
        
        for(Contact contact: records){
            contacts.add(contact);
         
            for(Id owner: idOwnersForEmail) {
                    if(Contact.OwnerId==owner){
                        contactwithSameOwner.put(contacts, Contact.OwnerId);
                    } else{
                        idOwnersForEmail.add(Contact.OwnerId);
                        contactwithSameOwner.put(contacts, Contact.OwnerId);
                    }
            }
        }
        update contacts;
    }
    
    public void finish(Database.BatchableContext bc){
        
        for(Id owner: idOwnersForEmail ){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setReplyTo('alinashish94@icloud.com');
            mail.setSenderDisplayName('Batch Processing');
            EmailTemplate emailTemplate =[SELECT Id, Subject, Description,
                                          HtmlValue, DeveloperName, Body
                                          FROM EmailTemplate WHERE name =
                                          'ContactOutdate'];
            mail.setTemplateID(emailTemplate.Id);
            
            Messaging.SingleEmailMessage[] messages = new   
            List<Messaging.SingleEmailMessage> { mail}; 
                
            Messaging.SendEmailResult[] results =
                 Messaging.sendEmail(messages);
            
            if (results[0].success){
                System.debug('The email was sent successfully.');
            } else {      
                System.debug('The email failed to send: ' +
                         results[0].errors[0]);
            }
        }
    }
   
}

  
