/**
 * TABLE & FILTER COMPONENT
 * Bao gồm: Sorting, Resizing columns, Modal detail
 * Sử dụng: Chỉ cần include file này và gọi các hàm tương ứng
 */

// ==================== SIDEBAR & NAVIGATION ====================

/**
 * Toggle sidebar open/close
 */
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('mainContent');
    sidebar.classList.toggle('collapsed');
    mainContent.classList.toggle('expanded');
}

/**
 * Toggle submenu in sidebar
 * @param {Event} event - Click event
 */
function toggleSubmenu(event) {
    event.preventDefault();
    const submenu = event.target.closest('li').querySelector('.sidebar-submenu');
    if (submenu) {
        submenu.style.display = submenu.style.display === 'none' ? 'block' : 'none';
    }
}

// ==================== MODAL DETAIL ====================

/**
 * Show detail modal with data
 * @param {string} ma - Mã trung gian
 * @param {string} chude - Chủ đề trung gian
 * @param {string} phuongthuc - Phương thức
 * @param {string} giatien - Giá tiền
 * @param {string} benchiuphi - Bên chịu phí
 * @param {string} phitrunggian - Phí trung gian
 * @param {string} tongphi - Tổng phí cần
 * @param {string} nguoiban - Người bán
 * @param {string} thoigiantao - Thời gian tạo
 * @param {string} capnhat - Cập nhật cuối
 */
function showDetail(ma, chude, phuongthuc, giatien, benchiuphi, phitrunggian, tongphi, nguoiban, thoigiantao, capnhat) {
    // Set values to modal
    document.getElementById('detail-ma').textContent = ma;
    document.getElementById('detail-chude').textContent = chude || '(Chưa có dữ liệu)';
    document.getElementById('detail-phuongthuc').textContent = phuongthuc || '(Chưa có dữ liệu)';
    document.getElementById('detail-giatien').textContent = giatien + ' VNĐ';
    document.getElementById('detail-benchiuphi').textContent = benchiuphi;
    document.getElementById('detail-phitrunggian').textContent = phitrunggian + ' VNĐ';
    document.getElementById('detail-tongphi').textContent = tongphi + ' VNĐ';
    document.getElementById('detail-nguoiban').textContent = nguoiban;
    document.getElementById('detail-thoigiantao').textContent = thoigiantao;
    document.getElementById('detail-capnhat').textContent = capnhat;

    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('detailModal'));
    modal.show();
}

// ==================== MODAL ADD ====================

/**
 * Show add modal
 */
function showAddModal() {
    // Reset form
    document.getElementById('addForm').reset();
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('addModal'));
    modal.show();
}

/**
 * Handle add new record
 */
function handleAdd() {
    // Get form values
    const chude = document.getElementById('add-chude').value;
    const phuongthuc = document.getElementById('add-phuongthuc').value;
    const giatien = document.getElementById('add-giatien').value;
    const benchiuphi = document.getElementById('add-benchiuphi').value;
    const phitrunggian = document.getElementById('add-phitrunggian').value;
    const nguoiban = document.getElementById('add-nguoiban').value;

    // Validate
    if (!chude || !phuongthuc || !giatien || !benchiuphi || !phitrunggian || !nguoiban) {
        alert('Vui lòng điền đầy đủ thông tin!');
        return;
    }

    // TODO: Call API to add record
    console.log('Adding new record:', {
        chude,
        phuongthuc,
        giatien,
        benchiuphi,
        phitrunggian,
        nguoiban
    });

    // Close modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('addModal'));
    modal.hide();

    // Show success message
    alert('Thêm mới thành công!');
    
    // TODO: Reload table data
}

// ==================== MODAL EDIT ====================

/**
 * Show edit modal with data
 * @param {string} ma - Mã trung gian
 * @param {string} chude - Chủ đề trung gian
 * @param {string} phuongthuc - Phương thức
 * @param {string} giatien - Giá tiền
 * @param {string} benchiuphi - Bên chịu phí
 * @param {string} phitrunggian - Phí trung gian
 * @param {string} tongphi - Tổng phí cần
 * @param {string} nguoiban - Người bán
 */
function showEditModal(ma, chude, phuongthuc, giatien, benchiuphi, phitrunggian, tongphi, nguoiban) {
    // Set form values
    document.getElementById('edit-ma').value = ma;
    document.getElementById('edit-chude').value = chude;
    document.getElementById('edit-phuongthuc').value = phuongthuc;
    document.getElementById('edit-giatien').value = giatien;
    document.getElementById('edit-benchiuphi').value = benchiuphi;
    document.getElementById('edit-phitrunggian').value = phitrunggian;
    document.getElementById('edit-nguoiban').value = nguoiban;

    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('editModal'));
    modal.show();
}

/**
 * Handle edit record
 */
function handleEdit() {
    // Get form values
    const ma = document.getElementById('edit-ma').value;
    const chude = document.getElementById('edit-chude').value;
    const phuongthuc = document.getElementById('edit-phuongthuc').value;
    const giatien = document.getElementById('edit-giatien').value;
    const benchiuphi = document.getElementById('edit-benchiuphi').value;
    const phitrunggian = document.getElementById('edit-phitrunggian').value;
    const nguoiban = document.getElementById('edit-nguoiban').value;

    // Validate
    if (!chude || !phuongthuc || !giatien || !benchiuphi || !phitrunggian || !nguoiban) {
        alert('Vui lòng điền đầy đủ thông tin!');
        return;
    }

    // TODO: Call API to update record
    console.log('Updating record:', {
        ma,
        chude,
        phuongthuc,
        giatien,
        benchiuphi,
        phitrunggian,
        nguoiban
    });

    // Close modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('editModal'));
    modal.hide();

    // Show success message
    alert('Cập nhật thành công!');
    
    // TODO: Reload table data
}

// ==================== MODAL DELETE ====================

/**
 * Show delete confirmation modal
 * @param {string} ma - Mã trung gian
 * @param {string} name - Tên để hiển thị
 */
function showDeleteModal(ma, name) {
    // Set data
    document.getElementById('delete-ma').value = ma;
    document.getElementById('delete-name').textContent = name;

    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
    modal.show();
}

/**
 * Handle delete record
 */
function handleDelete() {
    const ma = document.getElementById('delete-ma').value;

    // TODO: Call API to delete record
    console.log('Deleting record:', ma);

    // Close modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('deleteModal'));
    modal.hide();

    // Show success message
    alert('Xóa thành công!');
    
    // TODO: Reload table data
}

// ==================== TABLE SORTING ====================

/**
 * Initialize table sorting functionality
 * Cách sử dụng: Tự động chạy khi DOM loaded
 */
function initTableSorting() {
    const table = document.getElementById('resizableTable');
    if (!table) return;

    const headers = table.querySelectorAll('th.sortable');
    let currentSortColumn = null;
    let currentSortDirection = 'asc';

    headers.forEach(header => {
        header.addEventListener('click', (e) => {
            // Prevent sorting when clicking on resizer
            if (e.target.classList.contains('resizer')) {
                return;
            }

            const column = header.dataset.column;
            const dataType = header.dataset.type;

            // Toggle sort direction
            if (currentSortColumn === column) {
                currentSortDirection = currentSortDirection === 'asc' ? 'desc' : 'asc';
            } else {
                currentSortDirection = 'asc';
            }
            currentSortColumn = column;

            // Remove sort classes from all headers
            headers.forEach(h => {
                h.classList.remove('sort-asc', 'sort-desc');
            });

            // Add sort class to current header
            header.classList.add(currentSortDirection === 'asc' ? 'sort-asc' : 'sort-desc');

            // Sort table
            sortTable(table, column, dataType, currentSortDirection);
        });
    });
}

/**
 * Sort table by column
 * @param {HTMLElement} table - Table element
 * @param {string} columnIndex - Column index to sort
 * @param {string} dataType - Data type (text/number/date)
 * @param {string} direction - Sort direction (asc/desc)
 */
function sortTable(table, columnIndex, dataType, direction) {
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));

    rows.sort((a, b) => {
        const aValue = a.cells[columnIndex].textContent.trim();
        const bValue = b.cells[columnIndex].textContent.trim();

        let comparison = 0;

        if (dataType === 'number') {
            // Remove commas and convert to number
            const aNum = parseFloat(aValue.replace(/,/g, '')) || 0;
            const bNum = parseFloat(bValue.replace(/,/g, '')) || 0;
            comparison = aNum - bNum;
        } else if (dataType === 'date') {
            // Parse date (format: DD/MM/YYYY H...)
            const aDate = parseDate(aValue);
            const bDate = parseDate(bValue);
            comparison = aDate - bDate;
        } else {
            // Text comparison
            comparison = aValue.localeCompare(bValue, 'vi');
        }

        return direction === 'asc' ? comparison : -comparison;
    });

    // Re-append sorted rows
    rows.forEach(row => tbody.appendChild(row));
}

/**
 * Parse date string to Date object
 * @param {string} dateStr - Date string in format DD/MM/YYYY
 * @returns {Date} Date object
 */
function parseDate(dateStr) {
    if (!dateStr) return new Date(0);
    const parts = dateStr.split(/[\s/]/);
    if (parts.length >= 3) {
        // DD/MM/YYYY
        return new Date(parts[2], parts[1] - 1, parts[0]);
    }
    return new Date(0);
}

// ==================== TABLE RESIZING ====================

/**
 * Initialize table column resizing functionality
 * Cách sử dụng: Tự động chạy khi DOM loaded
 */
function initTableResizing() {
    const table = document.getElementById('resizableTable');
    if (!table) return;

    const cols = table.querySelectorAll('th');
    let currentResizer = null;
    let currentCol = null;
    let startX = 0;
    let startWidth = 0;

    cols.forEach((col) => {
        const resizer = col.querySelector('.resizer');
        if (!resizer) return;

        resizer.addEventListener('mousedown', (e) => {
            currentResizer = resizer;
            currentCol = col;
            startX = e.pageX;
            startWidth = col.offsetWidth;
            
            currentResizer.classList.add('resizing');
            document.body.style.cursor = 'col-resize';
            document.body.style.userSelect = 'none';
            
            e.preventDefault();
            e.stopPropagation(); // Prevent triggering sort
        });
    });

    document.addEventListener('mousemove', (e) => {
        if (!currentResizer) return;

        const diff = e.pageX - startX;
        const newWidth = startWidth + diff;
        
        // Minimum width 50px
        if (newWidth >= 50) {
            currentCol.style.width = newWidth + 'px';
            
            // Update corresponding body cells
            const colIndex = Array.from(currentCol.parentElement.children).indexOf(currentCol);
            const rows = table.querySelectorAll('tbody tr');
            rows.forEach(row => {
                const cell = row.children[colIndex];
                if (cell) {
                    cell.style.width = newWidth + 'px';
                }
            });
        }
    });

    document.addEventListener('mouseup', () => {
        if (currentResizer) {
            currentResizer.classList.remove('resizing');
            currentResizer = null;
            currentCol = null;
            document.body.style.cursor = '';
            document.body.style.userSelect = '';
        }
    });
}

// ==================== RESPONSIVE SIDEBAR ====================

/**
 * Handle responsive sidebar on window resize
 */
function initResponsiveSidebar() {
    window.addEventListener('resize', () => {
        if (window.innerWidth > 768) {
            const sidebar = document.getElementById('sidebar');
            if (sidebar) {
                sidebar.classList.remove('show');
            }
        }
    });
}

// ==================== INITIALIZE ALL ====================

/**
 * Initialize all components when DOM is loaded
 */
document.addEventListener('DOMContentLoaded', function() {
    initTableSorting();
    initTableResizing();
    initResponsiveSidebar();
    
    console.log('✅ Table & Filter components initialized');
});

