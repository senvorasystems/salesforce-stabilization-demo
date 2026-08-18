@IsTest
private class ExternalAccountServiceTest {
  @IsTest
  static void synchronize_shouldReturnSuccessfulResponse() {
    Account accountRecord = new Account(
      Name = 'Senvora Demo Account',
      Industry = 'Technology'
    );

    insert accountRecord;

    Test.setMock(
      HttpCalloutMock.class,
      new ExternalAccountServiceMock(
        200,
        '{"externalId":"EXT-001","message":"Synchronized"}'
      )
    );

    Test.startTest();

    ExternalAccountService.SyncResponse result = ExternalAccountService.synchronize(
      accountRecord
    );

    Test.stopTest();

    System.assertEquals(true, result.success);
    System.assertEquals(200, result.statusCode);
    System.assertEquals('EXT-001', result.externalId);
    System.assertEquals('Synchronized', result.message);
  }

  @IsTest
  static void synchronize_shouldThrowExceptionForServerError() {
    Account accountRecord = new Account(Name = 'Senvora Demo Account');

    insert accountRecord;

    Test.setMock(
      HttpCalloutMock.class,
      new ExternalAccountServiceMock(500, '{"message":"Internal Server Error"}')
    );

    Test.startTest();

    try {
      ExternalAccountService.synchronize(accountRecord);

      System.assert(false, 'Expected IntegrationException.');
    } catch (ExternalAccountService.IntegrationException ex) {
      System.assert(ex.getMessage().contains('HTTP 500'));
    }

    Test.stopTest();
  }

  @IsTest
  static void synchronize_shouldRejectUnsavedAccount() {
    Account accountRecord = new Account(Name = 'Unsaved Account');

    try {
      ExternalAccountService.synchronize(accountRecord);

      System.assert(false, 'Expected IntegrationException.');
    } catch (ExternalAccountService.IntegrationException ex) {
      System.assertEquals(
        'A persisted Account record is required.',
        ex.getMessage()
      );
    }
  }
}
