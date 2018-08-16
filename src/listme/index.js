const AWS = require('aws-sdk');

exports.handler = async function(event, context, callback) {
  const EC2 = new AWS.EC2();
  
  try {

    // TODO: filter based on provided parameters, tags
    // let params = {
    //   Filters: [
    //     {
    //       Name: "", 
    //       Values: []
    //     }
    //   ]
    // };
    // const instancesData = await EC2.describeInstances(params).promise();
    
    const instancesData = await EC2.describeInstances().promise();
    
    let instancesList ='';
    
    instancesData.Reservations.forEach(reservation => {
      reservation.Instances.forEach(instance => {
        console.log(instance);
        instancesList+= 'Name: ' + instance.Tags[0].Value +
        '  id: ' + instance.InstanceId +
        '  type: ' + instance.InstanceType +
        '  Status: ' + instance.State.Name +'\n';
      });
    });
    
    //console.log(instancesList);
    
    let response = {
      'response_type': 'in_channel',
      'text': instancesList
    };
    
    callback(null, response);
    
  } catch (err) {
    callback(err.message);
  }
};
