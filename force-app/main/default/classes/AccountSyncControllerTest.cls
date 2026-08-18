@IsTest
private class AccountSyncControllerTest {
  @IsTest
  static void enqueueSync_shouldCreateQueueableJob() {
    Account accountRecord = new Account(
      Name = 'Controller Test Account',
      Industry = 'Technology'
    );

    insert accountRecord;

    Test.setMock(
      HttpCalloutMock.class,
      new ExternalAccountServiceMock(
        200,
        '{"externalId":"EXT-CONTROLLER-001","message":"Synchronized"}'
      )
    );

    Test.startTest();

    Id jobId = AccountSyncController.enqueueSync(accountRecord.Id);

    Test.stopTest();

    System.assertNotEquals(
      null,
      jobId,
      'A Queueable job should have been created.'
    );
  }

  @IsTest
  static void enqueueSync_shouldRejectNullAccountId() {
    try {
      AccountSyncController.enqueueSync(null);

      System.assert(false, 'Expected AuraHandledException.');
    } catch (AuraHandledException ex) {
      System.assertNotEquals(null, ex.getMessage());
    }
  }
}
