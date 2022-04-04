public class SheduleTheContactReviewBatch implements Schedulable {
  
    public void execute(SchedulableContext sc) {
        ContactsNeedReview batchforRemind = new ContactsNeedReview();
        Database.executebatch(batchforRemind);
    }
}