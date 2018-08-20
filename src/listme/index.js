const AWS = require('aws-sdk');

exports.handler = async function(event, context, callback) {
  const EC2 = new AWS.EC2();
  
  
  try {
    
    const params = await createParams(event);
    
    const instancesData = await EC2.describeInstances(params).promise();
    
    //console.log(event.params.querystring.text);
    //if (event.params.querystring.text != '') {} else {
    
    //const instancesData = await EC2.describeInstances().promise();
    
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
};

function parseTags(slackText, callback) {
  var arr = slackText.split(" ").map(val => val);
  callback(arr);
}

function createParams(event, callback) {
  console.log(event);
  if (event.params){
    if(event.params.querystring){
      if (event.params.querystring.text){
        parseTags(event.params.querystring.text, function(tags) {
          
          let params = {
            Filters: [
              {
                Name: 'tag:' + tags[0],
                Values: [tags[1]]
              }
            ]
          };
          return params; 
        });
      } else {
        let params = {
          Filters: [
            {
              Name: null,
              Values: null
            }
          ]
        };
        return params;
      }
    }
    
  }
  
}
