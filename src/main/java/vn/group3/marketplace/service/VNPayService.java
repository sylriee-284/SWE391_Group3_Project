package vn.group3.marketplace.service;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.http.HttpServletRequest;

@Service
public class VNPayService {

    private static final Logger logger = LoggerFactory.getLogger(VNPayService.class);

    @Value("${thanh.vnpay.tmn-code}")
    private String vnpTmnCode;

    @Value("${thanh.vnpay.hash-secret}")
    private String secretKey;

    @Value("${thanh.vnpay.vnp-return-url}")
    private String vnpReturnUrl;

    @Value("${thanh.vnpay.vnp-url}")
    private String vnpPayUrl;

    public String generateVNPayURL(double amountDouble, String paymentRef, String ip)
            throws UnsupportedEncodingException {

        logger.debug("=== VNPay Service Debug ===");
        logger.debug("TMN Code: {}", vnpTmnCode);
        logger.debug("Secret Key: {}", (secretKey != null ? "Set (length: " + secretKey.length() + ")" : "NULL"));
        logger.debug("Payment URL: {}", vnpPayUrl);
        logger.debug("Return URL: {}", vnpReturnUrl);
        logger.debug("Order ID: {}", paymentRef);
        logger.debug("Amount: {}", amountDouble);
        logger.debug("IP Address: {}", ip);

        String vnpVersion = "2.1.0";
        String vnpCommand = "pay";
        String orderType = "other";

        long amount = (long) amountDouble * 100;

        String vnpTxnRef = paymentRef;
        String vnpIpAddr = ip;

        Map<String, String> vnpParams = new HashMap<>();
        vnpParams.put("vnp_Version", vnpVersion);
        vnpParams.put("vnp_Command", vnpCommand);
        vnpParams.put("vnp_TmnCode", vnpTmnCode);
        vnpParams.put("vnp_Amount", String.valueOf(amount));
        vnpParams.put("vnp_CurrCode", "VND");

        // if (bankCode != null && !bankCode.isEmpty()) {
        // vnp_Params.put("vnp_BankCode", bankCode);
        // }
        vnpParams.put("vnp_TxnRef", vnpTxnRef);
        vnpParams.put("vnp_OrderInfo", "Test thanh toan vnpay " + ", ref: " + vnpTxnRef);
        vnpParams.put("vnp_OrderType", orderType);

        vnpParams.put("vnp_Locale", "vn");
        vnpParams.put("vnp_ReturnUrl", vnpReturnUrl);
        vnpParams.put("vnp_IpAddr", vnpIpAddr);

        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnpCreateDate = formatter.format(cld.getTime());
        vnpParams.put("vnp_CreateDate", vnpCreateDate);

        cld.add(Calendar.MINUTE, 15);
        String vnpExpireDate = formatter.format(cld.getTime());
        vnpParams.put("vnp_ExpireDate", vnpExpireDate);

        List<String> fieldNames = new ArrayList<>(vnpParams.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();

        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = vnpParams.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                // Build hash data
                hashData.append(fieldName).append('=')
                        .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                // Build query
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()))
                        .append('=')
                        .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }
        String queryUrl = query.toString();
        String vnpSecureHash = hmacSHA512(secretKey, hashData.toString());
        queryUrl += "&vnp_SecureHash=" + vnpSecureHash;
        String paymentUrl = vnpPayUrl + "?" + queryUrl;

        logger.debug("Generated hash data: {}", hashData);
        logger.debug("Generated secure hash: {}", vnpSecureHash);
        logger.debug("Final payment URL: {}", paymentUrl);
        logger.debug("=== End VNPay Debug ===");

        return paymentUrl;
    }

    public String hmacSHA512(final String key, final String data) {
        try {

            if (key == null || data == null) {
                throw new NullPointerException();
            }
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes();
            final SecretKeySpec secretKeySpec = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKeySpec);
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = hmac512.doFinal(dataBytes);
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();

        } catch (Exception ex) {
            return "";
        }
    }

    public String getIpAddress(HttpServletRequest request) {
        String ipAdress;
        try {
            ipAdress = request.getHeader("X-FORWARDED-FOR");
            if (ipAdress == null) {
                ipAdress = request.getRemoteAddr();
            }
        } catch (Exception e) {
            ipAdress = "Invalid IP:" + e.getMessage();
        }
        return ipAdress;
    }
}
