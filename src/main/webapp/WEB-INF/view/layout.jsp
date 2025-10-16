<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                </title>

                <!-- Include common head with all CSS and JS -->
                <jsp:include page="common/head.jsp" />
            </head>

            <body>
                <!-- Include Navbar -->
                <jsp:include page="common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="common/sidebar.jsp" />

                <!-- Sidebar Overlay for Mobile -->
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <!-- Main Content Area -->
                <div class="content" id="content">
                    <!-- Page Content will be inserted here -->
                    <div class="container-fluid">
                        <h1>Welcome to MMO Market System</h1>
                        <p>Your trusted marketplace for digital goods and services.</p>
                    </div>
                    <div class="filter-section">
                        <!-- Row 1: Basic Filters -->
                        <div class="row filter-row">
                            <div class="col-md-2">
                                <div class="filter-label">Mã trung gian</div>
                                <input type="text" class="form-control" placeholder="Mã trung gian">
                            </div>
                            <div class="col-md-2">
                                <div class="filter-label">Chủ đề trung gian</div>
                                <input type="text" class="form-control" placeholder="Chủ đề">
                            </div>
                            <div class="col-md-2">
                                <div class="filter-label">Phương thức...</div>
                                <input type="text" class="form-control" placeholder="Phương thức">
                            </div>
                            <div class="col-md-3">
                                <div class="filter-label">Giá tiền</div>
                                <div class="row g-2">
                                    <div class="col">
                                        <input type="text" class="form-control" placeholder="Từ">
                                    </div>
                                    <div class="col">
                                        <input type="text" class="form-control" placeholder="Đến">
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="filter-label">Bên chịu phí...</div>
                                <select class="form-select">
                                    <option>All</option>
                                    <option>Bên bán</option>
                                    <option>Bên mua</option>
                                </select>
                            </div>
                        </div>

                        <!-- Row 2: Advanced Filters -->
                        <div class="row filter-row">
                            <div class="col-md-2">
                                <div class="filter-label">Phí trung gian</div>
                                <input type="text" class="form-control" placeholder="Phí">
                            </div>
                            <div class="col-md-2">
                                <div class="filter-label">Tổng phí cần...</div>
                                <input type="text" class="form-control" placeholder="Tổng phí">
                            </div>
                            <div class="col-md-2">
                                <div class="filter-label">Người bán</div>
                                <input type="text" class="form-control" placeholder="Người bán">
                            </div>
                            <div class="col-md-3">
                                <div class="filter-label">Thời gian tạo</div>
                                <div class="row g-2">
                                    <div class="col">
                                        <input type="date" class="form-control">
                                    </div>
                                    <div class="col">
                                        <input type="date" class="form-control">
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="filter-label">Cập nhật cuối</div>
                                <div class="row g-2">
                                    <div class="col">
                                        <input type="date" class="form-control">
                                    </div>
                                    <div class="col">
                                        <input type="date" class="form-control">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Row 3: Action Buttons -->
                        <div class="row mt-3">
                            <div class="col-md-12 d-flex justify-content-between">
                                <div>
                                    <button class="btn btn-add me-2">+</button>
                                    <button class="btn btn-light me-2">Từ</button>
                                    <button class="btn btn-light me-2">Đến</button>
                                    <button class="btn btn-light me-2">Từ</button>
                                    <button class="btn btn-light">Đến</button>
                                </div>
                                <div>
                                    <button class="btn btn-collapse me-2">
                                        <i class="bi bi-x-circle"></i> BỎ LỌC
                                    </button>
                                    <button class="btn btn-outline-secondary">THU GỌN ></button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="table-container">
                        <table class="resizable-table" id="resizableTable">
                            <thead>
                                <tr>
                                    <!-- Column 0: Mã trung gian (text) -->
                                    <th class="sortable" style="width: 120px;" data-column="0" data-type="text">
                                        Mã trung gian
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 1: Chủ đề (text) -->
                                    <th class="sortable" style="width: 150px;" data-column="1" data-type="text">
                                        Chủ đề trung...
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 2: Phương thức (text) -->
                                    <th class="sortable" style="width: 120px;" data-column="2" data-type="text">
                                        Phương thức...
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 3: Giá tiền (number) -->
                                    <th class="sortable" style="width: 100px;" data-column="3" data-type="number">
                                        Giá tiền
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 4: Bên chịu phí (text) -->
                                    <th class="sortable" style="width: 100px;" data-column="4" data-type="text">
                                        Bên chịu phí...
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 5: Phí trung gian (number) -->
                                    <th class="sortable" style="width: 120px;" data-column="5" data-type="number">
                                        Phí trung gian
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 6: Tổng phí (number) -->
                                    <th class="sortable" style="width: 120px;" data-column="6" data-type="number">
                                        Tổng phí cần...
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 7: Người bán (text) -->
                                    <th class="sortable" style="width: 120px;" data-column="7" data-type="text">
                                        Người bán
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 8: Thời gian tạo (date) -->
                                    <th class="sortable" style="width: 140px;" data-column="8" data-type="date">
                                        Thời gian tạo
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 9: Cập nhật cuối (date) -->
                                    <th class="sortable" style="width: 140px;" data-column="9" data-type="date">
                                        Cập nhật cuối
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 10: Hành động (no sort) -->
                                    <th style="width: 120px;">
                                        Hành động
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Sample Row 1 -->
                                <tr>
                                    <td>1feb71d0-82...</td>
                                    <td>Tài khoản vô...</td>
                                    <td>123</td>
                                    <td>20,000,000</td>
                                    <td>Bên bán</td>
                                    <td>1,000,000</td>
                                    <td>20,000,000</td>
                                    <td>Thaloke</td>
                                    <td>26/08/2025 0...</td>
                                    <td>26/08/2025 0...</td>
                                    <td>
                                        <!-- View Details Button -->
                                        <button class="btn btn-sm btn-info me-1" title="Xem chi tiết"
                                            onclick="showDetail('1feb71d0-82...', 'Tài khoản vô...', '123', '20,000,000', 'Bên bán', '1,000,000', '20,000,000', 'Thaloke', '26/08/2025 0...', '26/08/2025 0...')">
                                            <i class="fas fa-info-circle"></i>
                                        </button>
                                        <!-- Edit Button -->
                                        <button class="btn btn-sm btn-warning me-1" title="Chỉnh sửa"
                                            onclick="showEditModal('1feb71d0-82...', 'Tài khoản vô...', '123', '20,000,000', 'Bên bán', '1,000,000', '20,000,000', 'Thaloke')">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <!-- Delete Button -->
                                        <button class="btn btn-sm btn-danger" title="Xóa"
                                            onclick="showDeleteModal('1feb71d0-82...', 'Tài khoản vô...')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>

                                <!-- Sample Row 2 -->
                                <tr>
                                    <td>9ccdb5f0-d4...</td>
                                    <td>account fifa</td>
                                    <td>Facebook</td>
                                    <td>100,000</td>
                                    <td>Bên mua</td>
                                    <td>5,000</td>
                                    <td>105,000</td>
                                    <td>hoan456</td>
                                    <td>27/02/2024 0...</td>
                                    <td>27/02/2024 0...</td>
                                    <td>
                                        <!-- View Details Button -->
                                        <button class="btn btn-sm btn-info me-1" title="Xem chi tiết"
                                            onclick="showDetail('9ccdb5f0-d4...', 'account fifa', 'Facebook', '100,000', 'Bên mua', '5,000', '105,000', 'hoan456', '27/02/2024 0...', '27/02/2024 0...')">
                                            <i class="fas fa-info-circle"></i>
                                        </button>
                                        <!-- Edit Button -->
                                        <button class="btn btn-sm btn-warning me-1" title="Chỉnh sửa"
                                            onclick="showEditModal('9ccdb5f0-d4...', 'account fifa', 'Facebook', '100,000', 'Bên mua', '5,000', '105,000', 'hoan456')">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <!-- Delete Button -->
                                        <button class="btn btn-sm btn-danger" title="Xóa"
                                            onclick="showDeleteModal('9ccdb5f0-d4...', 'account fifa')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="pagination-container">
                        <nav>
                            <ul class="pagination mb-0">
                                <li class="page-item disabled">
                                    <a class="page-link" href="#" aria-label="First">
                                        <span aria-hidden="true">&laquo;&laquo;</span>
                                    </a>
                                </li>
                                <li class="page-item disabled">
                                    <a class="page-link" href="#" aria-label="Previous">
                                        <span aria-hidden="true">&laquo;</span>
                                    </a>
                                </li>
                                <li class="page-item active">
                                    <a class="page-link" href="#">1</a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="#">2</a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="#">3</a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="#">4</a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="#">5</a>
                                </li>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="#">73</a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="#" aria-label="Next">
                                        <span aria-hidden="true">&raquo;</span>
                                    </a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="#" aria-label="Last">
                                        <span aria-hidden="true">&raquo;&raquo;</span>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </div>

                    <!-- ==================== DETAIL MODAL (View) ==================== -->
                    <div class="modal fade" id="detailModal" tabindex="-1" aria-labelledby="detailModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-info text-white">
                                    <h5 class="modal-title" id="detailModalLabel">
                                        <i class="bi bi-info-circle-fill"></i> Chi tiết đơn trung gian
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="container-fluid">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Mã trung gian:</label>
                                                    <div class="detail-value" id="detail-ma"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Người bán:</label>
                                                    <div class="detail-value" id="detail-nguoiban"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <div class="detail-item">
                                                    <label class="detail-label">Chủ đề trung gian:</label>
                                                    <div class="detail-value" id="detail-chude"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Phương thức:</label>
                                                    <div class="detail-value" id="detail-phuongthuc"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Giá tiền:</label>
                                                    <div class="detail-value text-success fw-bold" id="detail-giatien">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-4">
                                                <div class="detail-item">
                                                    <label class="detail-label">Bên chịu phí:</label>
                                                    <div class="detail-value" id="detail-benchiuphi"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="detail-item">
                                                    <label class="detail-label">Phí trung gian:</label>
                                                    <div class="detail-value text-warning fw-bold"
                                                        id="detail-phitrunggian"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="detail-item">
                                                    <label class="detail-label">Tổng phí cần:</label>
                                                    <div class="detail-value text-danger fw-bold" id="detail-tongphi">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Thời gian tạo:</label>
                                                    <div class="detail-value" id="detail-thoigiantao"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Cập nhật cuối:</label>
                                                    <div class="detail-value" id="detail-capnhat"></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Đóng
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ==================== ADD MODAL (Create) ==================== -->
                    <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-success text-white">
                                    <h5 class="modal-title" id="addModalLabel">
                                        <i class="bi bi-plus-circle-fill"></i> Thêm đơn trung gian
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <form id="addForm">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Chủ đề trung gian <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="add-chude" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Phương thức <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="add-phuongthuc" required>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Giá tiền <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="add-giatien"
                                                    placeholder="VD: 1,000,000" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Bên chịu phí <span
                                                        class="text-danger">*</span></label>
                                                <select class="form-select" id="add-benchiuphi" required>
                                                    <option value="">Chọn...</option>
                                                    <option value="Bên bán">Bên bán</option>
                                                    <option value="Bên mua">Bên mua</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Phí trung gian <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="add-phitrunggian"
                                                    placeholder="VD: 50,000" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Người bán <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="add-nguoiban" required>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Hủy
                                    </button>
                                    <button type="button" class="btn btn-success" onclick="handleAdd()">
                                        <i class="bi bi-check-circle"></i> Thêm mới
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ==================== EDIT MODAL (Update) ==================== -->
                    <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-warning text-dark">
                                    <h5 class="modal-title" id="editModalLabel">
                                        <i class="bi bi-pencil-fill"></i> Chỉnh sửa đơn trung gian
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <form id="editForm">
                                        <input type="hidden" id="edit-ma">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Chủ đề trung gian <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="edit-chude" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Phương thức <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="edit-phuongthuc" required>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Giá tiền <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="edit-giatien"
                                                    placeholder="VD: 1,000,000" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Bên chịu phí <span
                                                        class="text-danger">*</span></label>
                                                <select class="form-select" id="edit-benchiuphi" required>
                                                    <option value="">Chọn...</option>
                                                    <option value="Bên bán">Bên bán</option>
                                                    <option value="Bên mua">Bên mua</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Phí trung gian <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="edit-phitrunggian"
                                                    placeholder="VD: 50,000" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Người bán <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="edit-nguoiban" required>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Hủy
                                    </button>
                                    <button type="button" class="btn btn-warning" onclick="handleEdit()">
                                        <i class="bi bi-check-circle"></i> Cập nhật
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ==================== DELETE MODAL (Confirm Delete) ==================== -->
                    <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-danger text-white">
                                    <h5 class="modal-title" id="deleteModalLabel">
                                        <i class="bi bi-exclamation-triangle-fill"></i> Xác nhận xóa
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <p class="mb-0">Bạn có chắc chắn muốn xóa đơn trung gian:</p>
                                    <h5 class="text-danger mt-2" id="delete-name"></h5>
                                    <input type="hidden" id="delete-ma">
                                    <p class="text-muted mt-3 mb-0"><small>Hành động này không thể hoàn tác!</small></p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Hủy
                                    </button>
                                    <button type="button" class="btn btn-danger" onclick="handleDelete()">
                                        <i class="bi bi-trash-fill"></i> Xóa
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>


                </div>

                <!-- Include Footer s-->
                <jsp:include page="common/footer.jsp" />

                <!-- Script to display notifications using iziToast -->
                <c:if test="${not empty successMessage}">
                    <script>
                        iziToast.success({
                            title: 'Success!',
                            message: '${successMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>

                <c:if test="${not empty errorMessage}">
                    <script>
                        iziToast.error({
                            title: 'Error!',
                            message: '${errorMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>

                <!-- Page-specific JavaScript -->
                <c:if test="${not empty pageJS}">
                    <c:forEach var="js" items="${pageJS}">
                        <script src="${pageContext.request.contextPath}${js}"></script>
                    </c:forEach>
                </c:if>

                <!-- Common JavaScript -->
                <script>
                    // Toggle sidebar function
                    function toggleSidebar() {
                        var sidebar = document.getElementById('sidebar');
                        var content = document.getElementById('content');
                        var overlay = document.getElementById('sidebarOverlay');

                        if (sidebar && content) {
                            sidebar.classList.toggle('active');
                            content.classList.toggle('shifted');

                            // Toggle overlay for mobile
                            if (overlay) {
                                overlay.classList.toggle('active');
                            }
                        }
                    }

                    // Close sidebar when clicking outside on mobile
                    document.addEventListener('click', function (event) {
                        var sidebar = document.getElementById('sidebar');
                        var overlay = document.getElementById('sidebarOverlay');
                        var menuToggle = document.querySelector('.menu-toggle');

                        if (sidebar && sidebar.classList.contains('active') &&
                            !sidebar.contains(event.target) &&
                            !menuToggle.contains(event.target)) {
                            toggleSidebar();
                        }
                    });

                    // Auto-hide alerts after 5 seconds
                    document.addEventListener('DOMContentLoaded', function () {
                        var alerts = document.querySelectorAll('.alert');
                        alerts.forEach(function (alert) {
                            setTimeout(function () {
                                alert.style.opacity = '0';
                                setTimeout(function () {
                                    alert.remove();
                                }, 300);
                            }, 5000);
                        });
                    });

                    // Table functionality
                    document.addEventListener('DOMContentLoaded', function () {
                        // Initialize table sorting and resizing if table exists
                        var table = document.getElementById('resizableTable');
                        if (table) {
                            initializeTableFeatures();
                        }
                    });

                    function initializeTableFeatures() {
                        // Add sorting functionality
                        var headers = document.querySelectorAll('.resizable-table th.sortable');
                        headers.forEach(function (header, index) {
                            header.addEventListener('click', function () {
                                sortTable(index, this);
                            });
                        });

                        // Add resizing functionality
                        var resizers = document.querySelectorAll('.resizer');
                        resizers.forEach(function (resizer) {
                            resizer.addEventListener('mousedown', function (e) {
                                startResize(e, this);
                            });
                        });
                    }

                    function sortTable(columnIndex, header) {
                        // Basic sorting implementation
                        var table = document.getElementById('resizableTable');
                        var tbody = table.querySelector('tbody');
                        var rows = Array.from(tbody.querySelectorAll('tr'));

                        var isAsc = !header.classList.contains('sort-asc');

                        // Remove existing sort classes
                        document.querySelectorAll('.resizable-table th').forEach(th => {
                            th.classList.remove('sort-asc', 'sort-desc');
                        });

                        // Add current sort class
                        header.classList.add(isAsc ? 'sort-asc' : 'sort-desc');

                        // Sort rows
                        rows.sort(function (a, b) {
                            var aVal = a.cells[columnIndex].textContent.trim();
                            var bVal = b.cells[columnIndex].textContent.trim();

                            if (isAsc) {
                                return aVal > bVal ? 1 : -1;
                            } else {
                                return aVal < bVal ? 1 : -1;
                            }
                        });

                        // Reorder rows
                        rows.forEach(row => tbody.appendChild(row));
                    }

                    function startResize(e, resizer) {
                        e.preventDefault();
                        resizer.classList.add('resizing');

                        var startX = e.clientX;
                        var startWidth = resizer.parentElement.offsetWidth;

                        function doResize(e) {
                            var newWidth = startWidth + e.clientX - startX;
                            resizer.parentElement.style.width = newWidth + 'px';
                        }

                        function stopResize() {
                            resizer.classList.remove('resizing');
                            document.removeEventListener('mousemove', doResize);
                            document.removeEventListener('mouseup', stopResize);
                        }

                        document.addEventListener('mousemove', doResize);
                        document.addEventListener('mouseup', stopResize);
                    }
                </script>
            </body>

            </html>