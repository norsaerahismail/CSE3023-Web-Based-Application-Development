package com.moonbae.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Util: PasswordUtil
 * Pengurusan hash kata laluan menggunakan SHA-256.
 */
public class PasswordUtil {

    /**
     * Cipta hash SHA-256 bagi password yang diberikan.
     * @param password Kata laluan teks biasa
     * @return String hexadecimal 64 aksara
     */
    public static String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(password.getBytes());

            // Tukar byte[] kepada hexadecimal String
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();

        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 tidak tersedia pada sistem ini.", e);
        }
    }

    /**
     * Sahkan password terhadap hash yang tersimpan.
     * @param plainPassword  Kata laluan yang dimasukkan pengguna
     * @param storedHash     Hash yang tersimpan dalam database
     * @return true jika sepadan
     */
    public static boolean verifyPassword(String plainPassword, String storedHash) {
        return hashPassword(plainPassword).equals(storedHash);
    }
}
