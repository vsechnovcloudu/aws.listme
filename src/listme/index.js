var AWS= require('aws-sdk');
const EC2 = new AWS.EC2();
const crypto = require('crypto');

exports.handler= async function(event, context, callback) {
  
  console.log(JSON.stringify(event));
  
  if (verifySignature(event)) { // This shall be isolated in API Authorization Lambda
    
    try {
      
      const params = await prepareParams(event);
      console.log(JSON.stringify(params));
      
      const instancesData = await EC2.describeInstances(params).promise();
      
      let instancesList = '';
      let instanceCount = 0;
      
      instancesData.Reservations.forEach(reservation => {
        reservation.Instances.forEach(instance => {
          instanceCount++;
          instancesList+= 'Instance id: ' + instance.InstanceId +
          '  type: ' + instance.InstanceType +
          '  Status: ' + instance.State.Name +'\n';
        });
      });
      
      let response = {
        'response_type': 'in_channel',
        'text': 'Instance count: ' + instanceCount + ' \n' + instancesList
      };
      
      callback(null, response);
      
    } catch (err) {
      callback(err.message);
    }
  } else {
    callback('Not authorized');
  }
};


async function prepareParams(event) {
  
  if (event.body) {
    if (event.body.text) {
      let text = event.body.text;
      var arr= text.split(" ").map(val => val);
      if (arr.length > 1){
        let params = {
          Filters: [
            {
              Name: 'tag:' + arr[0],
              Values: [arr[1]]
            }
          ]};
          return(params);
        } else {
          let params = {};
          return(params);
        }
      }
    }
  }
  
const verifySignature = function(event) {
  const signature = event.headers['X-Slack-Signature'] || event.headers['x-slack-signature'];
  const timestamp = event.headers['X-Slack-Request-Timestamp'] || event.headers['x-slack-request-timestamp'];
  if (verifyTimestamp(timestamp)) {
    const rawBody = event.rawRequest;
    const hmac = crypto.createHmac('sha256', process.env.SLACK_SIGNING_SECRET);
    const [version, hash] = signature.split('=');
    
    hmac.update(`${version}:${timestamp}:${rawBody}`);
    
    return hmac.digest('hex') === hash;
  } else {
    return false;
  }
}; 

const verifyTimestamp = function(timestamp){
  var currentTime = new Date().getTime() / 1000;
  return (currentTime - timestamp) < 60;
};
