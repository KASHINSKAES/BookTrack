const functions = require('firebase-functions');
const admin = require('firebase-admin');
const twilio = require('twilio');

admin.initializeApp();
const db = admin.firestore();
const twilioClient = new twilio(
  process.env.TWILIO_SID,
  process.env.TWILIO_AUTH_TOKEN
);

exports.sendCode = functions.https.onCall(async (data, context) => {
  const phone = data.phone;
  if (!phone) throw new functions.https.HttpsError('invalid-argument', 'Phone required');

  const code = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 минут

  await db.collection('verificationCodes').add({
    phone,
    code,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt,
  });

  // Реальная отправка SMS (для теста используйте console.log)
  await twilioClient.messages.create({
    body: `Ваш код: ${code}`,
    to: phone,
    from: '+1234567890', // Ваш Twilio номер
  });

  return { success: true };
});

exports.verifyCode = functions.https.onCall(async (data, context) => {
  const { phone, code } = data;
  if (!phone || !code) throw new functions.https.HttpsError('invalid-argument', 'Invalid data');

  const snapshot = await db.collection('verificationCodes')
    .where('phone', '==', phone)
    .where('code', '==', code)
    .where('expiresAt', '>', new Date())
    .limit(1)
    .get();

  if (snapshot.empty) {
    throw new functions.https.HttpsError('not-found', 'Invalid code');
  }

  await snapshot.docs[0].ref.delete();

  const user = await db.collection('users')
    .where('phone', '==', phone)
    .limit(1)
    .get();

  return { userExists: !user.empty };
});