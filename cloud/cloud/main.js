// In this app, we use Cloud Code afterSave handlers to securely send pushes.
// To trigger a push, clients save a Parse Object with information about where
// the push should be sent to. For more about why this approach is preferred,
// see http://blog.parse.com/2014/09/03/the-dangerous-world-of-client-push/
//
// To learn more about Cloud Code afterSave handlers, see
// https://www.parse.com/docs/cloud_code_guide#functions-onsave
//
// Please use JS SDK v1.4.0 or later (for Parse.Session APIs). You specify this
// by calling "parse jssdk 1.4.0" from your Cloud Code CLI. Alternatively, you 
// can also edit your Cloud Code config/global.json's global.parseVersion field.

// When the device saves an Event object, this method finds the installations
// of the current user's phones and sends a push to each phone.
// The Session class has information about other installations where
// the current user is logged in. To learn more about Session objects,
// see https://www.parse.com/docs/js_guide#sessions
Parse.Cloud.afterSave("Event", function(request, response) {
  // We need to use the master key because the device has a restricted session,
  // and restricted sessions cannot see the phones' unrestricted sessions.
  Parse.Cloud.useMasterKey();

  var event = request.object;

  // The Event object has an installationId field that denotes the
  // installation that saved the Event object.
  var installationObjectId = event.get("installationId");
  if (installationObjectId !== null && installationObjectId !== undefined) {
    var query = new Parse.Query(Parse.Installation);
    query.include("latestEvent");
    query.equalTo("objectId", installationObjectId);
    query.first({
      success: function(installationObject) {
        installationObject.set("latestEvent", event);
        installationObject.save(null, {
          success: function(installation) {
            // Latest Event was saved successfully. No action needed.
          },
          error: function(installation, error) {
            console.error("Error while saving latest event: " + error.code + " " + error.message);
          }
        });

        var query = new Parse.Query(Parse.Session);

        // Cloud Code automatically populates the request object with the user that
        // saved the Event (authenticated by the session token from that device).
        query.equalTo("user", request.user);
        query.equalTo("installationId", installationObject.get("installationId"));

        // We query for the session object for the device so that we can include its
        // object ID in the push notification to the phone.
        query.first({
          success: function(sessionObject) {
            var sessionQuery = new Parse.Query(Parse.Session);
            sessionQuery.equalTo("user", request.user);

            var query = new Parse.Query(Parse.Installation);
            query.equalTo("owner", sessionObject.get("user"));
            query.containedIn("deviceType", ["ios", "android"]);
            query.matchesKeyInQuery("installationId", "installationId", sessionQuery);

            // Parse currently does not support pushing to queries that include a
            // join with the _Session class, so the currently recommended approach is to
            // run this query here to find the target installationIds, and then push to
            // those installations with a containedIn query.  For more about push-to-query,
            // see https://www.parse.com/docs/push_guide#sending-queries/JavaScript
            query.find({
              success: function(results) {
                if (results.length > 0) {
                  var ids = [];
                  for (var r in results) {
                    ids.push(results[r].get("installationId"));
                  }
                  var query = new Parse.Query(Parse.Installation);
                  query.containedIn("installationId", ids);

                  var deviceName = installationObject.get("deviceName");
                  var state = event.get("value").state;
                  if (state === "blink") {
                    state = "blinking";
                  }
                  var eventMessage = "Device " + deviceName + " is " + state;
                  Parse.Push.send({
                      where: query,
                      data: {
                        action: "com.parse.anydevice.EVENT",
                        userSessionId: sessionObject.id,
                        installationId: installationObject.get("installationId"),
                        event: event,
                        alert: eventMessage
                      }
                    },
                    {
                      success: function() {
                        console.log("Sending Push to Phone (EVENT)")
                      },
                      error: function(err) {
                        console.error(err);
                      }
                    });
                      }
                    },
                    error: function(error) {
                      console.log("Error: " + error.code + " " + error.message);
                    }
                  });

          },
          error: function(err) {
            console.error(err);
          }
        })
      },
      error: function(err) {
        console.error(err);
      }
    });
  }
});

// When the phone saves a Message object, this method sends a push to the device
// that has the same installationId as the Message object saved by the phone.
Parse.Cloud.afterSave("Message", function(request, response) {
  var installationId = request.object.get("installationId");
  var query = new Parse.Query(Parse.Installation);
  if (installationId !== null && installationId !== undefined) {
    query.equalTo("installationId", installationId);
  } else {
    return;
  }

  Parse.Push.send({
    where: query,
    data: request.object.get("value"),
  },
  {
    success: function() {
      console.log("sending push to device");
    }, error: function(err) {
      console.log(err);
    }
  });
});

