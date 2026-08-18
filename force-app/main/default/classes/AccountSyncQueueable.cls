public with sharing class AccountSyncQueueable implements Queueable, Database.AllowsCallouts {
  private final Id accountId;

  public AccountSyncQueueable(Id accountId) {
    if (accountId == null) {
      throw new IllegalArgumentException('Account Id is required.');
    }

    this.accountId = accountId;
  }

  public void execute(QueueableContext context) {
    List<Account> accounts = [
      SELECT Id, Name, Industry
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];

    if (accounts.isEmpty()) {
      return;
    }

    ExternalAccountService.synchronize(accounts[0]);
  }

  public static Id enqueue(Id accountId) {
    return System.enqueueJob(new AccountSyncQueueable(accountId));
  }
}
