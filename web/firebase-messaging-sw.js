importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyC3U262Pciu3HNyyAJtY3rky1pjW7RiHZE",
  projectId: "izla-a2a3d",
  messagingSenderId: "178335024089",
  appId: "1:178335024089:web:c2f670b88742678937cfc8"
});

const messaging = firebase.messaging();