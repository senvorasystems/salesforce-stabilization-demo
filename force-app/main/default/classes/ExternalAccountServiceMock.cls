@IsTest
public class ExternalAccountServiceMock implements HttpCalloutMock {
  private Integer statusCode;
  private String responseBody;

  public ExternalAccountServiceMock(Integer statusCode, String responseBody) {
    this.statusCode = statusCode;
    this.responseBody = responseBody;
  }

  public HttpResponse respond(HttpRequest request) {
    System.assertEquals('POST', request.getMethod());

    System.assert(request.getEndpoint().contains('/accounts'));

    System.assertEquals('application/json', request.getHeader('Content-Type'));

    HttpResponse response = new HttpResponse();

    response.setStatusCode(statusCode);
    response.setHeader('Content-Type', 'application/json');
    response.setBody(responseBody);

    return response;
  }
}
