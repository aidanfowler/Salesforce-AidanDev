global class GoogleDocAPI {
    
    private static final String GOOGLE_SERVICE_ACCOUNT = 'salesforce@partnership-construct-auto-gen.iam.gserviceaccount.com';
    private static final String AUDIENCE_CLAIM = 'https://www.googleapis.com/oauth2/v4/token';
    private static final String CERTIFICATE = 'googledocintegrationcertificatev2'; // this is the name/label of the jks certificate we uplodaded in salesforce
    private static final String GOOGLE_DOCS_ENDPOINT = 'https://docs.googleapis.com/v1/documents/';
    private static final String GOOGLE_DOCS_SCOPE = 'https://www.googleapis.com/auth/documents';
    private static final String GOOGLE_DRIVE_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/';
    private static final String GOOGLE_DRIVE_SCOPE = 'https://www.googleapis.com/auth/drive';
    private static final String PARTNERSHIP_CONSTRUCT_TEMPLATE_URI = '1G_94CyITV3jOZw8Srvu_uXueNToiMYbraPY4Vh40HGU';
    
    private static String getAccessToken(String accessScope) {
        Auth.JWT jwt = new Auth.JWT();
        jwt.setAud(AUDIENCE_CLAIM);
        jwt.setIss(GOOGLE_SERVICE_ACCOUNT);
        jwt.setAdditionalClaims(new Map<String, Object>{ 'scope' => accessScope });
        //jwt.setSub('aidan.fowler@circle.com');(This only works with domain wide delegation)
        Auth.JWS jws = new Auth.JWS(jwt, CERTIFICATE);
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(jwt.getAud(),jws);
        if(test.isRunningTest()){
            return null;
        }
        return bearer.getAccessToken();
    }

    public static HttpResponse copyPartnershipConstructFromTemplate(String opportunityName){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GOOGLE_DRIVE_ENDPOINT + PARTNERSHIP_CONSTRUCT_TEMPLATE_URI+'/copy');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken(GOOGLE_DRIVE_SCOPE));
        request.setTimeout(25000);
        CopyDocumentRequest requestBody = new CopyDocumentRequest();
        requestBody.name = opportunityName + ' - Partnership Construct';
        request.setBody(System.JSON.serialize(requestBody));
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200){
            EmailService.sendErrorEmail('aidan.fowler@circle.com', 'Google Doc API Error - Partnership Construct', new CircleException('Failure To Copy Partnership Construct Template'+response.getBody()));
            return null;
        }
        return response;
    }

    public static HttpResponse shareNewDocument(String documentURI){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GOOGLE_DRIVE_ENDPOINT + documentURI+'/permissions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken(GOOGLE_DRIVE_SCOPE));
        request.setTimeout(10000);

        UpdatePermissionRequest requestPermission = new UpdatePermissionRequest();
        requestPermission.role = 'reader';
        requestPermission.type = 'domain';
        requestPermission.allowFileDiscovery = false;
        requestPermission.domain = 'circle.com';
        request.setBody(System.JSON.serialize(requestPermission));
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200){
            EmailService.sendErrorEmail('aidan.fowler@circle.com', 'Google Doc API Error - Partnership Construct', new CircleException('Failure To Share New Partnership Construct Template'+response.getBody()));
            return null;
        }
        return response;
    }

    public static HttpResponse batchUpdate(String requestUri, String oppId, PreviousConstruct prevConstruct) {
        Opportunity opp = [SELECT ID, Name, Owner.Name, CloseDate, Product_s__c, Objective__c, Hypothesis__c, Method__c, Risks_Dependencies__c, Success_Metrics__c,Success_Metrics_Details__c, Projected_Mews_Growth__c, Projected_Stablecoin_On_Platform_Growth__c, Projected_Total_Stablecoin_Volume__c, Success_Metrics_Tracking__C, StageName FROM Opportunity WHERE ID = :oppId];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GOOGLE_DOCS_ENDPOINT + requestUri + ':batchUpdate');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken(GOOGLE_DOCS_SCOPE));
        request.setTimeout(20000);
        request.setBody(JSON.serialize(buildBatchUpdateRequestUpdate(opp,prevConstruct)));
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200){
            EmailService.sendErrorEmail('aidan.fowler@circle.com', 'Google Doc API Error - Partnership Construct', new CircleException('Failure To Update Partnership Construct'+response.getBody()));
            return null;
        }
        return response;
    }

    /*public static void getDocument(String docuemntURI){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GOOGLE_DOCS_ENDPOINT + docuemntURI);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken(GOOGLE_DOCS_SCOPE));
        request.setTimeout(10000);
        HttpResponse response = http.send(request);
        String jsonResponse = response.getBody();
        system.debug('Get Doucment Response:' +jsonResponse);
        System.debug('status code get doc:'+response.getStatusCode());
    }*/

    public static HttpResponse deletethePO(String pcId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.googleapis.com/drive/v2/files/'+pcId);
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken(GOOGLE_DRIVE_SCOPE));
        request.setTimeout(10000);
        HttpResponse response = http.send(request);
        System.debug('response:'+String.valueOf(response));
        return null;
    }

    @future(callout=true)
    public static void deletePO(String oppId){
        Opportunity opp = [SELECT ID, Partnership_Construct_Document_ID__c FROM Opportunity WHERE ID = :oppId];
        deletethePO(opp.Partnership_Construct_Document_ID__c);
    }

    @future(callout=true)
    public static void createPartnershipContructDoc(String oppId, String opportunityName){
        HttpResponse copyDocRes = copyPartnershipConstructFromTemplate(opportunityName);
        if(copyDocRes != null){
            GoogleAPIResponse copyDocResponse = (GoogleAPIResponse) System.JSON.deserialize(copyDocRes.getBody(), GoogleAPIResponse.class);
            String newDocId = copyDocResponse.id;
            HttpResponse shareDocRes = shareNewDocument(newDocId);
            if(shareDocRes != null){
                HttpResponse batchUpdateRes = batchUpdate(newDocId,oppId,null);
                if(batchUpdateRes != null){
                    GoogleAPIResponse batchResponse = (GoogleAPIResponse) JSON.deserialize(batchUpdateRes.getBody(), GoogleAPIResponse.class);
                    Opportunity oppToUpdate = new Opportunity(Id = oppId, Partnership_Construct_Document_ID__c = batchResponse.documentId, Partnership_Construct_Last_Updated_Date__c = DateTime.now());
                    update oppToUpdate;
                }
            }
        }
    }

    @future(callout=true)
    public static void refreshPartnershipConstructDoc(String oppId, String documentId, String name, String closeDate, String owner, String products, String objecitve, String hypothesis, String risks, String method, String successMetrics, String successTracking, String projectedMetrics, String StageName){
        PreviousConstruct prevConstruct = new PreviousConstruct();
        prevConstruct.name = name;
        prevConstruct.closeDate = closeDate;
        prevConstruct.owner = owner;
        prevConstruct.products = products == null ? 'Products N/A' : products;
        prevConstruct.objective = objecitve == null ? 'Objective N/A' : objecitve;
        prevConstruct.hypothesis = hypothesis == null ? 'Hypothesis N/A' : hypothesis;
        prevConstruct.risks = risks == null ? 'Risks & Dependencies N/A' : risks;
        prevConstruct.method = method == null ? 'Method N/A' : method;
        prevConstruct.successMetrics = successMetrics == null ? 'Success Metrics N/A' : successMetrics;
        prevConstruct.successTracking = successTracking == null ? 'Success Metrics Tracking N/A' : successTracking;
        prevConstruct.projectedMetrics = projectedMetrics == '' ? 'Projected Metrics N/A' : projectedMetrics;
        prevConstruct.stageName = stageName;
        HttpResponse batchUpdateRes = batchUpdate(documentId, oppId,prevConstruct);
        if(batchUpdateRes != null){
            GoogleAPIResponse batchResponse = (GoogleAPIResponse) JSON.deserialize(batchUpdateRes.getBody(), GoogleAPIResponse.class);
            Opportunity oppToUpdate = new Opportunity(Id = oppId, Partnership_Construct_Document_ID__c = batchResponse.documentId, Partnership_Construct_Last_Updated_Date__c = DateTime.now());
            update oppToUpdate;
        }
    }

    public static BatchUpdateRequest buildBatchUpdateRequestUpdate(Opportunity opp, PreviousConstruct prevConstruct){
        List<GoogleDocRequest> textReplaceRequests = new List<GoogleDocRequest>();
        if(prevConstruct == null){
            textReplaceRequests.add(makeUpdateUrlRequest(URL.getOrgDomainUrl().toExternalForm()+'/'+opp.id));
        }
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '[$Deal_Name]' : '['+prevConstruct.name+']', '['+opp.name+']'));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Deal_Owner' :'\uFE00'+prevConstruct.owner, '\uFE00'+opp.Owner.Name));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Stage_Name' :'\uFE0B'+prevConstruct.stageName, '\uFE0B'+opp.StageName));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Deal_Name' :'\uFE01'+prevConstruct.name, '\uFE01'+opp.Name));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Close_Date' : '\uFE02'+ prevConstruct.closeDate, '\uFE02'+ String.valueOf(opp.CloseDate)));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Products' :'\uFE03'+prevConstruct.products, opp.Product_s__c != null ? '\uFE03' +  opp.product_s__c.replace(';',', ') : '\uFE03Products N/A'));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Objective' :'\uFE04'+prevConstruct.objective, opp.Objective__C != null ? '\uFE04' + opp.Objective__C : '\uFE04Objective N/A'));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Hypothesis' :'\uFE05'+prevConstruct.hypothesis, opp.Hypothesis__c != null ? '\uFE05' + opp.Hypothesis__c : '\uFE05Hypothesis N/A'));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Risks' :'\uFE06'+prevConstruct.risks, opp.Risks_Dependencies__c != null ? '\uFE06' + opp.Risks_Dependencies__c : '\uFE06Risks & Dependencies N/A'));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Method' :'\uFE07'+prevConstruct.method, opp.Method__c != null ? '\uFE07' + opp.Method__c : '\uFE07Method N/A'));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Success_Metrics' :'\uFE08'+prevConstruct.successMetrics, opp.Success_Metrics__c != null ? '\uFE08' + opp.Success_Metrics__c.replace(';',', ') : '\uFE08Success Metrics N/A'));
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Success_Tracking' :'\uFE09'+prevConstruct.successTracking, opp.Success_Metrics_Tracking__c != null && opp.Success_Metrics_Tracking__c != '' ? '\uFE09' +opp.Success_Metrics_Tracking__c : '\uFE09Success Metrics Tracking N/A'));
        String projectedMetrics = createProjectedMetricString(opp.Projected_Mews_Growth__c, opp.Projected_Stablecoin_On_Platform_Growth__c, opp.Projected_Total_Stablecoin_Volume__c, opp.Success_metrics_details__c);
        textReplaceRequests.add(makeReplaceTextRequest(prevConstruct == null ? '$Projected_Metrics' :'\uFE0A'+prevConstruct.projectedMetrics, projectedMetrics != '' ? '\uFE0A' +projectedMetrics : '\uFE0AProjected Metrics N/A'));
        BatchUpdateRequest batchUpdate = new BatchUpdateRequest();
        batchUpdate.requests = textReplaceRequests;
        return batchUpdate;
    }

    public static GoogleDocRequest makeReplaceTextRequest(String containsText, String replaceText){
        SubstringMatchCriteria matchCriteria = new SubstringMatchCriteria();
        matchCriteria.matchCase = false;
        containsText = containsText.replace('\r\n','\n');
        matchCriteria.text = containsText;

        ReplaceAllTextRequest replaceAllText = new ReplaceAllTextRequest();
        replaceAllText.containsText = matchCriteria;
        replaceText = replaceText.replace('\r\n','\n');
        replaceAllText.replaceText = replaceText;

        GoogleDocRequest googleRequest = new GoogleDocRequest();
        googleRequest.replaceAllText = replaceAllText;
        return googleRequest;
    }

    public static GoogleDocRequest makeUpdateUrlRequest(String newUrl){
        GoogleLink linkUrl = new GoogleLink();
        linkUrl.url = newUrl;
        TextStyleLinkURL styleLinkUrl = new TextStyleLinkUrl();
        styleLinkUrl.link = linkUrl;
        TextRange urlTexRange = new TextRange();
        urlTexRange.startIndex = 23;
        urlTexRange.endIndex = 36;

        UpdateTextStyleRequest updateUrlRequest = new UpdateTextStyleRequest();
        updateUrlRequest.fields = 'link';
        updateUrlRequest.range = urlTexRange;
        updateUrlRequest.textStyle = styleLinkUrl;

        GoogleDocRequest googleRequest = new GoogleDocRequest();
        googleRequest.updateTextStyle = updateUrlRequest;
        return googleRequest;
    }


    public static String createProjectedMetricString(Decimal mews, Decimal usdcOnPlatform, Decimal transactionVolume, String other){
        List<String> currencyFormatting = new String[]{'0','number','⌗⌗⌗,⌗⌗⌗,⌗⌗⌗,⌗⌗⌗'};
        String projectedMetrics = '';
        if(mews != null){
            projectedMetrics += 'Projected MeWs: '+String.format(mews.format(), currencyFormatting)+', ';
        }
        if(usdcOnPlatform != null){
            projectedMetrics += 'Projected USDC on Platform: $'+String.format(usdcOnPlatform.format(), currencyFormatting)+', ';
        }
        if(transactionVolume != null){
            projectedMetrics += 'Projected Transaction Volume: $'+String.format(transactionVolume.format(), currencyFormatting)+', ';
        }
        if(other != null && other != ''){
            projectedMetrics += 'Other Metric Details: '+other + ', ';
        }
        projectedMetrics = projectedMetrics.removeEnd(', ');
        return projectedMetrics;
    }

    public class GoogleAPIResponse{
        public String kind;
        public String id;
        public String name;
        public String mimeType;
        public String documentId;
    }

    public class CopyDocumentRequest{
        public String name;
    }

    public class UpdatePermissionRequest{
        public String type;
        public String role;
        public Boolean allowFileDiscovery;
        public String domain;
    } 
    
    public class BatchUpdateRequest{
        public List<GoogleDocRequest> requests;
    }

    public class GoogleDocRequest{
        public ReplaceAllTextRequest replaceAllText;
        public UpdateTextStyleRequest updateTextStyle;
    }

    public class ReplaceAllTextRequest{
        public String replaceText;
        public SubstringMatchCriteria containsText;
    }

    public class SubstringMatchCriteria{
        public String text;
        public Boolean matchCase;
    }

    public class UpdateTextStyleRequest{
        public TextStyleLinkURL textStyle;    
        public TextRange range;
        public String fields;
    }

    public class TextStyleLinkURL{
        public GoogleLink link;
    }

    public class GoogleLink{
        public string url;
    }

    public class TextRange{
        public Integer startIndex;
        public Integer endIndex;
    }

    public class PreviousConstruct{
        public String name;
        public String owner;
        public String closeDate;
        public String products;
        public String objective;
        public String hypothesis;
        public String risks;
        public String method;
        public String successMetrics;
        public String successMetricsDetails;
        public String successTracking;
        public String projectedMetrics;
        public String stageName;
    }
}