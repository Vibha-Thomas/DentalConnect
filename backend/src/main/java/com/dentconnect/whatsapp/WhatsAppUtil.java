package com.dentconnect.whatsapp;

import org.springframework.stereotype.Component;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Component
public class WhatsAppUtil {

    private static final String WA_BASE = "https://wa.me/";

    /**
     * Build a WhatsApp deep link for a phone number with an optional pre-filled message.
     *
     * @param phone   Phone number in international format (e.g. +919876543210). 
     *                Strips non-digit characters before building URL.
     * @param message Optional pre-filled message text. Pass null to omit.
     * @return        wa.me deep link URL string
     */
    public String buildLink(String phone, String message) {
        if (phone == null || phone.isBlank()) {
            return null;
        }
        String digits = phone.replaceAll("[^\\d]", "");
        String url = WA_BASE + digits;
        if (message != null && !message.isBlank()) {
            String encoded = URLEncoder.encode(message, StandardCharsets.UTF_8);
            url = url + "?text=" + encoded;
        }
        return url;
    }

    /**
     * Build a default WhatsApp link for clinic/job contact.
     */
    public String buildJobContactLink(String phone, String jobTitle, String clinicName) {
        String message = String.format(
            "Hi %s, I am interested in the %s position I found on DentConnect. " +
            "I would like to learn more about this opportunity.",
            clinicName, jobTitle
        );
        return buildLink(phone, message);
    }
}
