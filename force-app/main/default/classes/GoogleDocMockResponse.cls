@IsTest
global class GoogleDocMockResponse implements HttpCalloutMock {
    public Integer statusCode = 200;
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"documentId":"1234567", "id":"1234567"}');
        res.setStatusCode(statusCode);
        return res;
    }
}