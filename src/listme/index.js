var AWS= require('aws-sdk');
const EC2 = new AWS.EC2();

exports.handler= async function(event, context, callback) {
  console.log(JSON.stringify(event));

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
  
};

async function prepareParams(event) {
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
