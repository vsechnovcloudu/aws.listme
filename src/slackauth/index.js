const crypto = require('crypto');
exports.handler = function(event, context, callback) {        
    console.log('Received event:', JSON.stringify(event, null, 2));

    // Retrieve request parameters from the Lambda function input:
    var headers = event.headers;
    var queryStringParameters = event.queryStringParameters;
    var pathParameters = event.pathParameters;
    var stageVariables = event.stageVariables;
    var requestContext = event.requestContext;
        
    // Parse the input for the parameter values
    var tmp = event.methodArn.split(':');
    var apiGatewayArnTmp = tmp[5].split('/');
    var awsAccountId = tmp[4];
    var region = tmp[3];
    var restApiId = apiGatewayArnTmp[0];
    var stage = apiGatewayArnTmp[1];
    var method = apiGatewayArnTmp[2];
    var resource = '/'; // root resource
    if (apiGatewayArnTmp[3]) {
        resource += apiGatewayArnTmp[3];
    }
        
    // Perform authorization to return the Allow policy for correct parameters and 
    // the 'Unauthorized' error, otherwise.
    var authResponse = {};
    var condition = {};
    condition.IpAddress = {};
    
    // Slack part:
    const signature = event.headers['X-Slack-Signature'] || event.headers['x-slack-signature'];
    const timestamp = event.headers['X-Slack-Request-Timestamp'] || event.headers['x-slack-request-timestamp'];
    const signingSecret = process.env.SLACK_SIGNING_SECRET;
    
    // Following part is disable, until AWS will forward raw body request to Authorizer lambda
    // const verifySignature = function(event) {
    //   const signature = event.headers['X-Slack-Signature'] || event.headers['x-slack-signature'];
    //   const timestamp = event.headers['X-Slack-Request-Timestamp'] || event.headers['x-slack-request-timestamp'];
    //   const rawBody = event.rawRequest;
    //   const hmac = crypto.createHmac('sha256', process.env.SLACK_SIGNING_SECRET);
    //   const [version, hash] = signature.split('=');
    // 
    //   hmac.update(`${version}:${timestamp}:${rawBody}`);
    // 
    //   return hmac.digest('hex') === hash;
    // }; 
    
    // Now the verification happens ONLY in the listme Lambda, this simply pass through as long headers are present
    if (signature && timestamp) {
        let response = generateAllow('me', event.methodArn);
        console.log(JSON.stringify(response));
        callback(null, response);
    }  else {
        let response = { "errorMessage": "Not authorized" };
        callback(response);
    }
}
     
// Help function to generate an IAM policy
var generatePolicy = function(principalId, effect, resource) {
    // Required output:
    var authResponse = {};
    authResponse.principalId = principalId;
    if (effect && resource) {
        var policyDocument = {};
        policyDocument.Version = '2012-10-17'; // default version
        policyDocument.Statement = [];
        var statementOne = {};
        statementOne.Action = 'execute-api:Invoke'; // default action
        statementOne.Effect = effect;
        statementOne.Resource = resource;
        policyDocument.Statement[0] = statementOne;
        authResponse.policyDocument = policyDocument;
    }
    // Optional output with custom properties of the String, Number or Boolean type.
    authResponse.context = {
        "stringKey": "empty",
        "numberKey": 0,
        "booleanKey": true
    };
    return authResponse;
}
     
var generateAllow = function(principalId, resource) {
    return generatePolicy(principalId, 'Allow', resource);
}
     
var generateDeny = function(principalId, resource) {
    return generatePolicy(principalId, 'Deny', resource);
}
