**Sửa trong report**

Hai bảng approval state (trang 4 và trang 13) cần cập nhật hàng đầu tiên:

| requires_approval | approval_granted | Valid statuses |
|---|---|---|
| FALSE | NULL | ~~Any~~ → **confirmed, cancelled** |
| TRUE | NULL | pending, cancelled |
| TRUE | TRUE | confirmed, cancelled |
| TRUE | FALSE | rejected |

Ngoài ra ở phần **Ambiguities (trang 6)**, hàng cuối bảng ghi:

> *"requires_approval is snapshotted onto Booking at creation time... Any (default pending, but also confirmed, cancelled, rejected)"*

Cần sửa thành **confirmed, cancelled** cho nhất quán.

Và ở **Design and Quality Review trang 15**, phần đọc approval state cũng có bảng tương tự — kiểm tra và cập nhật theo.



**2. Mô tả Q4 — trang 7**
Đổi từ *"Which equipment types appear most often in booked rooms?"* thành *"Which equipment types appear most often in rooms with at least one confirmed booking?"*

**3. Assumption 8 — trang 5**
Đổi từ *"enforced at the schema or application level"* thành *"enforced at the application level"* (vì schema không có constraint nào cho việc này).