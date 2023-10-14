

### Get credential
Used to start authentication sequence

```javascript
setTimeout(async() => {
var challengeVal = (new TextEncoder()).encode("ThisIsAVeryLongChallenge"); 
var inputObj = { 
    "publicKey": {
        "challenge": challengeVal
    }
}
navigator.credentials.get(inputObj).then(function(newCredInfo){credValue=newCredInfo}).catch(function(err){console.log("PasskeyError: " + err)})
}, 3000)
```

### Create credential
Used to start authentication sequence

```javascript
setTimeout(async() => {
var challengeVal = (new TextEncoder()).encode("ThisIsAVeryLongChallenge");
var userId = (new TextEncoder()).encode("ARandomUserIdThatDoesNotClashWithActualUserName");
var inputObj = {
    publicKey: { 
        "rp": {
            "name": "ACME"
        },
        "user": {
            "id": userId,
            "name": "aRandomUser",
            "displayName": "A Random User"
        },
        "challenge": challengeVal,
        "pubKeyCredParams": [
            {
                "type": "public-key",
                "alg": -7
            },
            {
                "type": "public-key",
                "alg": -257
            }
        ]
    }
}
navigator.credentials.create(inputObj).then(function(newCredInfo){credValue=newCredInfo}).catch(function(err){console.log("PasskeyError: " + err)})
}, 3000)
```
