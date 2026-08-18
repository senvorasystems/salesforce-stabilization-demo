public with sharing class ExternalAccountService {
  private static final String NAMED_CREDENTIAL = 'External_Account_API';
  private static final Integer TIMEOUT_MS = 10000;

  public class IntegrationException extends Exception {
  }

  public class AccountPayload {
    public Id salesforceId;
    public String name;
    public String industry;

    public AccountPayload(Account accountRecord) {
      salesforceId = accountRecord.Id;
      name = accountRecord.Name;
      industry = accountRecord.Industry;
    }
  }

  public class SyncResponse {
    public Boolean success;
    public Integer statusCode;
    public String externalId;
    public String message;
  }

  public static SyncResponse synchronize(Account accountRecord) {
    if (accountRecord == null || accountRecord.Id == null) {
      throw new IntegrationException('A persisted Account record is required.');
    }

    HttpRequest request = new HttpRequest();

    request.setEndpoint('callout:' + NAMED_CREDENTIAL + '/accounts');

    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setTimeout(TIMEOUT_MS);

    request.setBody(JSON.serialize(new AccountPayload(accountRecord)));

    Http http = new Http();
    HttpResponse response = http.send(request);

    return handleResponse(response);
  }

  private static SyncResponse handleResponse(HttpResponse response) {
    Integer statusCode = response.getStatusCode();

    if (statusCode < 200 || statusCode >= 300) {
      throw new IntegrationException(
        'External service returned HTTP ' + statusCode
      );
    }

    SyncResponse result;

    try {
      result = (SyncResponse) JSON.deserialize(
        response.getBody(),
        SyncResponse.class
      );
    } catch (Exception ex) {
      throw new IntegrationException(
        'External service returned an invalid response.'
      );
    }

    if (result == null) {
      throw new IntegrationException(
        'External service returned an empty response.'
      );
    }

    result.success = true;
    result.statusCode = statusCode;

    return result;
  }
}
