Hướng dẫn tích hợp "per-user serialization" cho luồng nạp tiền (VNPay)

Mục tiêu
- Mọi callback VNPay (xác nhận nạp tiền) và thao tác liên quan đến cùng 1 user sẽ được xử lý tuần tự.
- Giữa các user khác nhau xử lý song song.
- Kết hợp với @Transactional + idempotency để đảm bảo số dư chính xác.

Các file đã thêm
- `vn.group3.marketplace.util.PerUserSerialExecutor` : Per-user single-thread executors với cleanup khi idle.
- `vn.group3.marketplace.service.WalletTransactionQueueService` : Service để xử lý các giao dịch ví (nạp tiền, thanh toán) theo queue riêng cho mỗi user.

Bước 1: Tạo transaction record khi user bắt đầu nạp (đã có sẵn)
- Khi user bắt đầu nạp tiền, tạo một WalletTransaction với `paymentStatus = "PENDING"` và `paymentRef` duy nhất.
- Bạn đã có `WalletService.createPendingDeposit(...)` để làm việc này.

Bước 2: Controller/Callback VNPay gọi `enqueueDeposit`
- Thay vì gọi `walletService.processSuccessfulDeposit(paymentRef)` trực tiếp, hãy gọi:

```java
@Autowired
private WalletTransactionQueueService walletTransactionService;

@GetMapping("/vnpay-callback")
public String vnpayCallback(@RequestParam Map<String,String> params) {
    // ... xác thực vnpay ...
    String paymentRef = params.get("vnp_TxnRef");
    Long userId = ... // lấy từ transaction hoặc params
    walletTransactionService.enqueueDeposit(userId, paymentRef);
    return "redirect:/wallet?success";
}
```

Bước 3: `WalletTransactionQueueService` sẽ chạy task tuần tự cho user đó
- Lấy `WalletService` proxy từ `ApplicationContext` và gọi `processSuccessfulDeposit(paymentRef)` (phương thức @Transactional hiện có trong `WalletService`).
- Trong `processSuccessfulDeposit`, đã có kiểm tra idempotency: kiểm tra `paymentStatus == "PENDING"` trước khi cập nhật.

Bước 4: Đảm bảo idempotency & DB constraint
- Đặt `UNIQUE` constraint trên `wallet_transactions.payment_ref` để tránh tạo duplicate record khi callback gọi nhiều lần (nếu bạn muốn enforce). Hoặc luôn kiểm tra `findByPaymentRef` trong transaction trước khi insert/update.

Bước 5: Test local (mô phỏng nhiều callback đồng thời)
- Tạo một script/test đơn giản gửi nhiều request tới endpoint callback (vnpay-callback) cùng paymentRef và userId.
- Quan sát logs: các tasks sẽ được chạy theo thứ tự enqueue cho cùng 1 user; balance sẽ tăng từng lần một theo thứ tự tasks hoàn thành.

Ví dụ test bằng ApacheBench (PowerShell):

```powershell
# gửi 10 request gần như đồng thời (adjust URL)
ab -n 10 -c 10 "http://localhost:8080/wallet/vnpay-callback?paymentRef=REF123&userId=42"
```

Hoặc viết 1 đoạn Java/Python concurrency test để gọi URL nhiều lần.

Ghi chú vận hành
- Nếu bạn chạy app nhiều instance, per-user in-memory executor chỉ đảm bảo ordering trong cùng 1 instance. Để ordering across instances, chuyển sang Kafka/RabbitMQ/Redis Streams như đã trình bày ở phần trước.
- Theo dõi queue size / executor count để tránh tạo quá nhiều thread (PerUserSerialExecutor có cleanup idle executors).
- Bảo đảm `processSuccessfulDeposit` là idempotent và an toàn khi retry.

Nếu bạn muốn, tôi có thể:
- Cập nhật controller callback thực tế trong code của bạn để gọi `walletTransactionService.enqueueDeposit(...)` (y/n)
- Thêm unit/integration test mô phỏng nhiều callback đồng thời

