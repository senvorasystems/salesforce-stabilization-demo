public with sharing class AccountSyncController {
  @AuraEnabled
  public static Id enqueueSync(Id accountId) {
    if (accountId == null) {
      throw new AuraHandledException('An Account record is required.');
    }

    return AccountSyncQueueable.enqueue(accountId);
  }
}
