package com.dentconnect.common.service;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.google.firebase.cloud.StorageClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URL;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Centralized file storage abstraction.
 * Currently backed by Firebase Storage.
 * Swap implementation to switch to AWS S3 or Azure Blob.
 *
 * IMPORTANT: Never store signed URLs in the database.
 * Store only storage_path and generate signed URLs on demand.
 */
@Slf4j
@Service
public class FileService {

    @Value("${app.firebase.storage-bucket:}")
    private String storageBucket;

    @Value("${app.profile.signed-url-expiry-minutes:60}")
    private int signedUrlExpiryMinutes;

    /**
     * Upload a file to Firebase Storage.
     *
     * @param file        the multipart file to upload
     * @param storagePath the full path within the storage bucket (e.g. "dentists/{userId}/resume.pdf")
     * @return StoredFile record containing path, SHA-256 hash, mime type, size
     */
    public StoredFile upload(MultipartFile file, String storagePath) {
        validateBucketConfigured();
        try {
            byte[] bytes = file.getBytes();
            String sha256 = sha256Hex(bytes);
            String contentType = file.getContentType() != null ? file.getContentType() : "application/octet-stream";

            com.google.firebase.cloud.StorageClient.getInstance()
                    .bucket(storageBucket)
                    .create(storagePath, bytes, contentType);

            log.info("Uploaded file to Firebase Storage: path={}, size={}", storagePath, bytes.length);

            return new StoredFile(storagePath, sha256, contentType, (long) bytes.length);
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload file to storage: " + e.getMessage(), e);
        }
    }

    /**
     * Generate a signed, time-limited download URL for a stored file.
     * Signed URLs expire automatically — documents remain private.
     *
     * @param storagePath the path in the bucket
     * @return a signed URL valid for {@code signedUrlExpiryMinutes} minutes
     */
    public String getSignedUrl(String storagePath) {
        validateBucketConfigured();
        try {
            Storage storage = StorageClient.getInstance().bucket(storageBucket).getStorage();
            BlobId blobId = BlobId.of(storageBucket, storagePath);
            BlobInfo blobInfo = BlobInfo.newBuilder(blobId).build();
            URL signedUrl = storage.signUrl(
                    blobInfo,
                    signedUrlExpiryMinutes,
                    TimeUnit.MINUTES,
                    Storage.SignUrlOption.withV4Signature()
            );
            return signedUrl.toString();
        } catch (Exception e) {
            log.error("Failed to generate signed URL for path={}: {}", storagePath, e.getMessage());
            throw new RuntimeException("Could not generate signed URL", e);
        }
    }

    /**
     * Delete a file from Firebase Storage.
     *
     * @param storagePath the path in the bucket
     */
    public void delete(String storagePath) {
        validateBucketConfigured();
        try {
            StorageClient.getInstance().bucket(storageBucket).get(storagePath).delete();
            log.info("Deleted file from Firebase Storage: path={}", storagePath);
        } catch (Exception e) {
            log.warn("Could not delete file at path={}: {}", storagePath, e.getMessage());
        }
    }

    /**
     * Build a deterministic storage path for a dentist document.
     * Pattern: dentists/{userId}/{docType}/{version}_{uuid}.{ext}
     */
    public String buildDentistDocPath(String userId, String docType, String originalFilename, int version) {
        String ext = getExtension(originalFilename);
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return String.format("dentists/%s/%s/v%d_%s%s",
                userId, docType.toLowerCase(), version, uuid, ext);
    }

    /**
     * Build a storage path for a dentist profile photo.
     */
    public String buildPhotoPath(String userId) {
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return String.format("dentists/%s/photos/photo_%s.jpg", userId, uuid);
    }

    // ── Immutable value record ────────────────────────────────────────────────

    public record StoredFile(String storagePath, String sha256Hash, String contentType, long sizeBytes) {}

    // ── Private helpers ───────────────────────────────────────────────────────

    private void validateBucketConfigured() {
        if (storageBucket == null || storageBucket.isBlank()) {
            throw new IllegalStateException(
                    "Firebase Storage bucket is not configured. " +
                    "Set FIREBASE_STORAGE_BUCKET environment variable.");
        }
    }

    private static String sha256Hex(byte[] bytes) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(bytes));
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 unavailable", e);
        }
    }

    private static String getExtension(String filename) {
        if (filename == null) return "";
        int dot = filename.lastIndexOf('.');
        return dot >= 0 ? filename.substring(dot) : "";
    }
}
