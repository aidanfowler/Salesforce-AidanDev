@isTest
global class RecaptchaMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String body = '{"success":true,"score": 6, "challenge_ts":"time","hostname":"host","error-codes":[]}';

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}