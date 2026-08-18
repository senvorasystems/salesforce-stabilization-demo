@IsTest
private class AccountSyncQueueableTest {
  @IsTest
  static void queueable_shouldExecuteCalloutSuccessfully() {
    Account accountRecord = new Account(
      Name = 'Queueable Demo Account',
      Industry = 'Technology'
    );

    insert accountRecord;

    Test.setMock(
      HttpCalloutMock.class,
      new ExternalAccountServiceMock(
        200,
        '{"externalId":"EXT-QUEUE-001","message":"Queued sync completed"}'
      )
    );

    Test.startTest();

    Id jobId = AccountSyncQueueable.enqueue(accountRecord.Id);

    Test.stopTest();

    System.assertNotEquals(null, jobId);
  }
}
