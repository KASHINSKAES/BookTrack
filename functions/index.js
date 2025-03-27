const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
const twilio = require('twilio'); // Для SMS

admin.initializeApp();

// 1. Настройка email (Gmail пример)
const gmailEmail = 'ваш@gmail.com';
const gmailPassword = 'ваш-пароль-приложения'; // Не основной пароль!

const mailTransport = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

// 2. Настройка Twilio (для SMS)
const twilioAccountSid = 'ACxxxxxxxxxx';
const twilioAuthToken = 'ваш-токен';
const twilioClient = twilio(twilioAccountSid, twilioAuthToken);

// 3. Cloud Function для отправки email
exports.sendEmailVerification = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const code = data.code;

  const mailOptions = {
    from: `BookApp <${gmailEmail}>`,
    to: email,
    subject: 'Ваш код подтверждения',
    text: `Ваш код для входа: ${code}`,
    html: `<p>Ваш код для входа: <strong>${code}</strong></p>`,
  };

  await mailTransport.sendMail(mailOptions);
  return { success: true };
});

// 4. Cloud Function для отправки SMS
exports.sendSmsVerification = functions.https.onCall(async (data, context) => {
  const phone = data.phone;
  const code = data.code;

  await twilioClient.messages.create({
    body: `Ваш код подтверждения: ${code}`,
    from: '+1234567890', // Ваш Twilio номер
    to: phone,
  });

  return { success: true };
});