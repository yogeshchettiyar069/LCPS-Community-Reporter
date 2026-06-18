package utils;

import java.io.UnsupportedEncodingException;
import java.util.Properties;

import jakarta.mail.*;
import jakarta.mail.internet.*;

import db_config.AppConfig;

public class EmailUtil {

    private static final String HOST        = AppConfig.get("mail.smtp.host", "smtp.gmail.com");
    private static final String PORT        = AppConfig.get("mail.smtp.port", "587");
    private static final String FROM_EMAIL  = AppConfig.get("mail.from");
    private static final String APP_PASSWORD = AppConfig.get("mail.password");
    private static final String FROM_NAME   = AppConfig.get("mail.from.name", "LCPS System");

    public static void sendOTP(String toEmail, int otp) {

        Properties props = new Properties();
        props.put("mail.smtp.host",              HOST);
        props.put("mail.smtp.port",              PORT);
        props.put("mail.smtp.auth",              "true");
        props.put("mail.smtp.starttls.enable",   "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.ssl.protocols",     "TLSv1.2");

        Session session = Session.getInstance(props,
            new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            }
        );

        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Your OTP for LCPS Registration");

            String body = "Hello,"
                        + "\n\n"
                        + "Your OTP for LCPS registration is: " + otp
                        + "\n\n"
                        + "This OTP is valid for 2 minutes."
                        + "\n\n"
                        + "Do not share this OTP with anyone."
                        + "\n\n"
                        + "Regards,\nLCPS Team";

            msg.setText(body);
            msg.setSentDate(new java.util.Date());

            Transport.send(msg);

        } catch (UnsupportedEncodingException | MessagingException e) {
            throw new RuntimeException("Failed to send OTP email to " + toEmail, e);
        }
    }
}
