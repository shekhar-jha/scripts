

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
