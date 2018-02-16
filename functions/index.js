/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const stripe = require('stripe')('STRIPE_TEST_SECRET_KEY');
const request = require('request');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

//** onUpdate
//** Send notification to poster when their job is accepted
/**
 * Triggers when a user gets a new follower and sends a notification.
 *
 * Followers add a flag to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}notificationTokens///{notificationToken}`.
 */
exports.sendFollowerNotification = functions.database.ref('/jobPosters/{posterID}/upcomingJobs/').onCreate(event => {
  const followerUid = event.params.posterID;
  const isAdmin = event.auth.admin;
  
  //***const uid = event.auth.variable.uid;
  //const followedUid = event.params.studentID;
  // If un-follow we exit the function.
  //if (!event.data.val()) {
    console.log('User ', uid, 'accepted Job from', followerUid);
  //}
  //console.log('Some one has accepted your job:', followerUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/jobPosters/${followerUid}/deviceToken`).once('value');

  // Get the follower profile.
 //***const getFollowerProfilePromise = admin.auth().getUser(uid);

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
    //**const follower = results[1];
    console.log('tokenSnapshot ',tokensSnapshot)
    //**console.log('follower ', follower)
    //const tokens = Object.keys(tokensSnapshot.val()).map(e => tokensSnapshot.val()[e]);
 

    // Check if there are any device tokens.
    //if (!tokensSnapshot.hasChildren()) {
      //return console.log('There are no notification tokens to send to.');
    //}
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
   //*** console.log('Fetched follower profile', follower);
  //*** ${follower.displayName} 
    // Notification details.
    const payload = {
      notification: {
        title: 'Your job has been accepted!',
        body: `Someone has accepted your job.`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    // Listing all tokens.
    //const tokens = [getDeviceTokensPromise];
    //console.log('tokenlist', tokens)
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});

//** onUpdate
//** Send notification to poster when their job is accepted

exports.sendFollowerNotificationUpdate = functions.database.ref('/jobPosters/{posterID}/upcomingJobs/{job}/').onCreate(event => {
  const followerUid = event.params.posterID;
  const isAdmin = event.auth.admin;
  //***const uid = event.auth.variable ? event.auth.variable.uid : null;
  //const followedUid = event.params.studentID;
  // If un-follow we exit the function.
  //if (!event.data.val()) {
   //** console.log('User ', uid, 'accepted Job from', followerUid);
  //}
  //console.log('Some one has accepted your job:', followerUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/jobPosters/${followerUid}/deviceToken`).once('value');

  // Get the follower profile.
  //**const getFollowerProfilePromise = admin.auth().getUser(uid);

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
    //**const follower = results[1];
    console.log('tokenSnapshot ',tokensSnapshot)
    //console.log('follower ', follower)
    //const tokens = Object.keys(tokensSnapshot.val()).map(e => tokensSnapshot.val()[e]);
 

    // Check if there are any device tokens.
    //if (!tokensSnapshot.hasChildren()) {
      //return console.log('There are no notification tokens to send to.');
    //}
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'Your job has been accepted!',
        body: `Someone has accepted your job.`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    // Listing all tokens.
    //const tokens = [getDeviceTokensPromise];
    //console.log('tokenlist', tokens)
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});






/**
 * Triggers when a user gets a new follower and sends a notification.
 * onUpdate
 * Followers add a flag to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}/notificationTokens/{notificationToken}`.
 */
exports.sendPosterNotificationJobExpire = functions.database.ref('/jobPosters/{posterID}/expiredJobs/{job}/').onCreate(event => {
  const followerUid = event.params.posterID;
  const isAdmin = event.auth.admin;
  //const uid = event.auth.variable ? event.auth.variable.uid : null;
  //const followedUid = event.params.studentID;
  // If un-follow we exit the function.
  //if (!event.data.val()) {
    //console.log('User ', uid, 'accepted Job from', followerUid);
  //}
  //console.log('Some one has accepted your job:', followerUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/jobPosters/${followerUid}/deviceToken`).once('value');

  // Get the follower profile.
  //const getFollowerProfilePromise = admin.auth().getUser(uid);

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
    //const follower = results[1];
    console.log('tokenSnapshot ',tokensSnapshot)
    //console.log('follower ', follower)
    //const tokens = Object.keys(tokensSnapshot.val()).map(e => tokensSnapshot.val()[e]);
 

    // Check if there are any device tokens.
    //if (!tokensSnapshot.hasChildren()) {
      //return console.log('There are no notification tokens to send to.');
    //}
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'A job you posted has expired',
        body: `Would you like to repost the job?`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    // Listing all tokens.
    //const tokens = [getDeviceTokensPromise];
    //console.log('tokenlist', tokens)
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});


/**
 * onCreate
 * Triggers when a user gets a new follower and sends a notification.
 *
 * Followers add a flag to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}/notificationTokens/{notificationToken}`.
 */
exports.sendPosterNotificationJobExpire = functions.database.ref('/jobPosters/{posterID}/expiredJobs').onCreate(event => {
  const followerUid = event.params.posterID;
  const isAdmin = event.auth.admin;
  //const uid = event.auth.variable ? event.auth.variable.uid : null;
  //const followedUid = event.params.studentID;
  // If un-follow we exit the function.
  //if (!event.data.val()) {
    //console.log('User ', uid, 'accepted Job from', followerUid);
  //}
  //console.log('Some one has accepted your job:', followerUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/jobPosters/${followerUid}/deviceToken`).once('value');

  // Get the follower profile.
  //const getFollowerProfilePromise = admin.auth().getUser(uid);

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
    //const follower = results[1];
    console.log('tokenSnapshot ',tokensSnapshot)
    //console.log('follower ', follower)
    //const tokens = Object.keys(tokensSnapshot.val()).map(e => tokensSnapshot.val()[e]);
 

    // Check if there are any device tokens.
    //if (!tokensSnapshot.hasChildren()) {
      //return console.log('There are no notification tokens to send to.');
    //}
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'A job you posted has expired',
        body: `Would you like to repost the job?`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    // Listing all tokens.
    //const tokens = [getDeviceTokensPromise];
    //console.log('tokenlist', tokens)
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});




//onUpdate
// Firebase function to send students a 
// notification anytime a job is posted in their area that matches
// one of the skills that the student has listed on their profile

exports.sendNotificationNearbyJobUpdate = functions.database.ref('/students/{studentID}/nearbyJobs/{job}/').onCreate(event => {
  const studentUid = event.params.studentID;
  const isAdmin = event.auth.admin;
  //const uid = event.auth.variable ? event.auth.variable.uid : null;
  //const followedUid = event.params.studentID;
  // If un-follow we exit the function.
  //if (!event.data.val()) {
    console.log('Student ', studentUid);
  //}
  //console.log('Some one has accepted your job:', followerUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

  // Get the follower profile.
  //const getFollowerProfilePromise = admin.auth().getUser(uid);

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   // const follower = results[1];
    console.log('tokenSnapshot ',tokensSnapshot)
   // console.log('follower ', follower)
    //const tokens = Object.keys(tokensSnapshot.val()).map(e => tokensSnapshot.val()[e]);
 

    // Check if there are any device tokens.
    //if (!tokensSnapshot.hasChildren()) {
      //return console.log('There are no notification tokens to send to.');
    //}
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'New jobs posted near you!',
        body: `Jobs that match your skills have been posted in your area`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    // Listing all tokens.
    //const tokens = [getDeviceTokensPromise];
    //console.log('tokenlist', tokens)
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});



// onCreate
// Firebase function to send students a 
// notification anytime a job is posted in their area that matches
// one of the skills that the student has listed on their profile

exports.sendNotificationNearbyJobCreate = functions.database.ref('/students/{studentID}/nearbyJobs/').onCreate(event => {
  const studentUid = event.params.studentID;
  const isAdmin = event.auth.admin;
  
  //console.log('Some one has accepted your job:', followerUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

  // Get the follower profile.
  //const getFollowerProfilePromise = admin.auth().getUser(uid);

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   // const follower = results[1];
    console.log('tokenSnapshot ',tokensSnapshot)
   // console.log('follower ', follower)
    //const tokens = Object.keys(tokensSnapshot.val()).map(e => tokensSnapshot.val()[e]);
 

    // Check if there are any device tokens.
    //if (!tokensSnapshot.hasChildren()) {
      //return console.log('There are no notification tokens to send to.');
    //}
    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'New jobs posted near you!',
        body: `Jobs that match your skills have been posted in your area`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    // Listing all tokens.
    //const tokens = [getDeviceTokensPromise];
    //console.log('tokenlist', tokens)
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});




//Firebase function to sender students a notification anytime their promo code gets used telling them that they have received $5

exports.sendStudentPromoUsageNotification = functions.database.ref('/students/{studentID}/promoCode/{promoID}/').onUpdate(event => {
  const studentUid = event.params.studentID;
  const promoCode = event.params.promoID;
  const isAdmin = event.auth.admin;
      
  
  console.log('Some one has accepted your job:', studentUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'You just received $5 QuikFix cash!',
        body: `Someone used your promo code to sign up!`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});



//Firebase function to sender jobPosters a notification anytime their promo code gets used telling them that they have received $5

exports.sendPosterPromoUsageNotification = functions.database.ref('/jobPosters/{posterID}/promoCode/{promoID}/').onUpdate(event => {
  const posterUid = event.params.posterID;
  const promoCode = event.params.promoID;
  const isAdmin = event.auth.admin;
      
  
  console.log('Some one has accepted your job:', posterUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${posterUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'You just received $5 QuikFix cash!',
        body: `Someone used your promo code to sign up!`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});



//Firebase function triggered twelve hours before a job. Sent to students.

exports.sendTwelveHourNoticeToStudents = functions.database.ref('/students/{studentID}/twelveHoursToStart/').onCreate(event => {
  const studentUid = event.params.studentID;
  const posterUid = admin.database().ref(`/students/${studentUid}/twelveHoursToStart`).once('value');
  
  const isAdmin = event.auth.admin;
      
  
  //console.log('Some one has accepted your job:', posterUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'Job Reminder!',
        body: `You have a job scheduled in exactly 12 hours!`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});



exports.finishStripeConnect = functions.database.ref('/students/{studentID}/{stripeConnectToken}/').onCreate(event => {
  const studentUid = event.params.studentID;
  //const stripeToken = event.params.stripeTok;
  //const posterUid = admin.database().ref(`/students/${studentUid}/twelveHoursToStart`).once('value');
  
  const isAdmin = event.auth.admin;
      
  
  console.log('Some one has accepted your job:', studentUid);

  // Get the list of device notification tokens.
const connectID = event.params.stripeConnectToken
console.log('please work:', connectID);
request.post('https://connect.stripe.com/oauth/token', {
    form: {
      client_secret: 'sk_test_LV43Yng4WPSPXvyNElx2dwg0',
      code: connectID,
      grant_type: 'authorization_code'
    },
    json: true
  }, (err, response, body) => {
    if (err || body.error) {
      //console.log('The Stripe onboarding process has not succeeded1.', body.error);
      console.log('The Stripe onboarding process has not succeeded2.', err);

    } else {
      // Update the model and store the Stripe account ID in the datastore.
      // This Stripe account ID will be used to pay out to the pilot.
      const stripeAccountId = body.stripe_user_id;
      admin.database().ref(`/students/${studentUid}`).update({'stripeToken': stripeAccountId});

    }
	return Promise.all(connectID);

});


 
});




//Firebase function triggered twelve hours before a job. Sent to students.

exports.sendThreeHourNoticeToStudents = functions.database.ref('/students/{studentID}/threeHoursToStart/').onCreate(event => {
  const studentUid = event.params.studentID;
  const posterUid = admin.database().ref(`/students/${studentUid}/threeHoursToStart`).once('value');
  
  const isAdmin = event.auth.admin;
      
  
  //console.log('Some one has accepted your job:', posterUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'Job Reminder!',
        body: `You have a job scheduled in exactly 3 hours!`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});


//Firebase function triggered twelve hours before a job. Sent to students.

exports.sendThirtyMinNoticeToStudents = functions.database.ref('/students/{studentID}/thirtyMinToStart/').onCreate(event => {
  const studentUid = event.params.studentID;
  const posterUid = admin.database().ref(`/students/${studentUid}/threeHoursToStart`).once('value');
  
  const isAdmin = event.auth.admin;
      
  
  //console.log('Some one has accepted your job:', posterUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'Job Reminder!',
        body: `You have a job scheduled in exactly 30 minutes!`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});





exports.sendStudentThatPosterCancelled = functions.database.ref('/students/{studentID}/posterCancelled/').onCreate(event => {
  const studentUid = event.params.studentID;
 // const posterUid = admin.database().ref(`/students/${studentUid}///posterCancelled`).once('value');
  const posterName = admin.database().ref(`/students/${studentUid}/posterCancelled`).once('value')
  
  const isAdmin = event.auth.admin;
      
  
  console.log('Some one has cancelled your job:', posterName);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'Job Cancelled',
        body:  `One of your upcoming jobs has been cancelled by the job poster.`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});

exports.sendPosterThatStudentHasCancelled = functions.database.ref('/jobPosters/{posterID}/studentCancelled/').onCreate(event => {
  const posterUid = event.params.posterID;
  const studentName = admin.database().ref(`/jobPosters/${posterUid}/studentCancelled`).once('value');
 // const studentName = admin.database().ref(`/students/${studentUid}/name`).once('value')
  
  const isAdmin = event.auth.admin;
      
  
  console.log('Some one has cancelled your job:', studentName);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/jobPosters/${posterUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'A Student Has Cancelled',
        body:  `A QuikFix worker can no longer work one of your jobs but we are actively seeking a replacement and you will be notified as soon as we find one.`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});




exports.unreadMessagesNoticeToStudents = functions.database.ref('/students/{studentID}/unreadMessages/').onCreate(event => {
  const studentUid = event.params.studentID;
  //**const posterUid = admin.database().ref(`/students/${studentUid}/threeHoursToStart`).once('value');
  
  const isAdmin = event.auth.admin;
      
  
  //console.log('Some one has accepted your job:', posterUid);

  // Get the list of device notification tokens.
  const getDeviceTokensPromise = admin.database().ref(`/students/${studentUid}/deviceToken`).once('value');

 

  return Promise.all([getDeviceTokensPromise]).then(results => {
    const tokensSnapshot = results[0];
   
  console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.', 'tokens', tokensSnapshot);
    //console.log('Fetched follower profile', follower);

    // Notification details.
    const payload = {
      notification: {
        title: 'New Message!',
        body: `You have received a new message.`,
        icon: 'https://media.npr.org/assets/img/2017/04/25/istock-115796521_wide-2f8afeb04be5bf8290f13dd1a5a9e107f63ee2fd.jpg?s=1400'
      }
    };

    
    const tokens = Object.keys(tokensSnapshot.val());

    // Send notifications to all tokens.
    return admin.messaging().sendToDevice(tokens, payload).then(response => {
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });
  });
});


//exports.unreadMessagesNoticeToPoster = functions.database.ref('/jobPosters/{posterID}/unreadMessages/').onCreate(event => {
 // const posterUid = event.params.posterID;
  //**const posterUid = admin.database().ref(`/students/${studentUid}/threeHoursToStart`).once('value');
  
  //const isAdmin = event.auth.admin;
      
  
  //console.log('Some one has accepted your job:', posterUid);

  // Get the list of device notification tokens.
  //const getDeviceTokensPromise = admin.database().ref(`/jobPosters/${posterUid}/deviceToken`).once('value');
