const shim = require('fabric-shim');
const util = require('util');
const x509 = require('x509');
const PREFIXES = {
    'Entity': 'ENTITY-',
    'PublicKey': 'VERKEY-'
}
var Chaincode = class {

  // Initialize the chaincode
  async Init(stub) {
    console.info('========= Initializing ManageID =========');
    let ret = stub.getFunctionAndParameters();
    console.info(ret);
    let args = ret.params;

    // initialise only if 4 parameters passed.
    if (args.length % 4 !== 0) {
      console.info('========= Initialization failed =========');
      return shim.error('Incorrect number of arguments. Expecting stewards details in set of 4: DID, public key, role and reference DID.');
    }

    let errorDetails = "{";
    let errors = 0;
    for (let counter = 0; counter < args.length; counter=counter+4) {
        console.info('Processing item ' + counter);
        //TODO: Check DID, public key format & role value
        let newEntity = {};
        newEntity.did = args[counter];
        newEntity.verKey = args[counter+1];
        newEntity.role = args[counter+2];
        newEntity.referredByDID = args[counter+3];
        newEntity.status = 'active';
        try {
            await saveEntity(stub,newEntity, newEntity.did, 'Entity');
            await saveEntity(stub,newEntity, newEntity.verKey, 'PublicKey');
            errorDetails = errorDetails + " '" + args[counter] +"' : 'Success',";
        }catch (err) {
           errorDetails = errorDetails + " '" + args[counter] +"' : '" + err + "',";
           errors++;
       }
    }
    if (errors === 0) {
      return shim.success();
    } else {
      console.error('Instantiation failed due to errors ' + errorDetails);
      return shim.error(errorDetails);
    }
  }

  async Invoke(stub) {
    let ret = stub.getFunctionAndParameters();
    console.info(ret);
    let method = this[ret.fcn];
    if (!method) {
      console.log('no method of name:' + ret.fcn + ' found');
      return shim.success();
    }
    try {
      let payload = await method(stub, ret.params, this);
      return shim.success(payload);
    } catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }

  async invoke(stub, args, chainCode) {
    if (args.length < 1) {
      throw new Error('Incorrect number of arguments. Expecting atleast 1 with function code.');
    }
    let functionValue = args[0];
    let myInputs = args.slice(1);
    console.info('Invoking method');
    let payload = eval(functionValue);
    console.info('Invoked method');
    return payload;
  }
};

shim.start(new Chaincode());
