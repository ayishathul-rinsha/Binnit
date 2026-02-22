// =============================================================
// script.js — Emptico Admin Dashboard
// =============================================================

// ─── Login ───────────────────────────────────────────────────
document.getElementById('loginForm').addEventListener('submit', function (e) {
    e.preventDefault();
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;

    if (email && password) {
        document.getElementById('loginPage').style.display = 'none';
        document.getElementById('dashboard').classList.add('active');

        const adminName = email.split('@')[0];
        document.getElementById('adminName').textContent =
            adminName.charAt(0).toUpperCase() + adminName.slice(1);

        // Default to overview on login
        showPage('overview', document.getElementById('nav-overview'));
    } else {
        alert('Please enter valid credentials.');
    }
});

// ─── Page Navigation ─────────────────────────────────────────
const pageMap = {
    'overview': 'overviewPage',
    'bins': 'binsPage',
    'manual_bin': 'manual_binPage',
    'collections': 'collectionsPage',
    'routes': 'routesPage',
    'users': 'usersPage',
    'requests': 'requestsPage'
};

function showPage(pageName, navEl) {
    // Hide all pages
    document.querySelectorAll('.page').forEach(p => p.classList.add('hidden'));

    // Remove active from all menu items
    document.querySelectorAll('.menu-item').forEach(m => m.classList.remove('active'));

    // Show target page
    const pageId = pageMap[pageName];
    if (pageId) {
        const page = document.getElementById(pageId);
        if (page) page.classList.remove('hidden');
    }

    // Mark nav item active
    if (navEl) {
        navEl.classList.add('active');
    }

    // Close search dropdown if open
    closeSearchDropdown();
}

// ─── Logout ──────────────────────────────────────────────────
function logout() {
    document.getElementById('dashboard').classList.remove('active');
    document.getElementById('loginPage').style.display = 'flex';
    document.getElementById('email').value = '';
    document.getElementById('password').value = '';
}

// ─── Global Search ───────────────────────────────────────────
const searchIndex = [
    // Overview
    { text: 'Dashboard Overview', page: 'overview', navId: 'nav-overview', icon: '📊', desc: 'System summary & stats' },
    { text: 'Total Smart Bins', page: 'overview', navId: 'nav-overview', icon: '📊', desc: 'Overview stat' },
    { text: 'Active Collections', page: 'overview', navId: 'nav-overview', icon: '📊', desc: 'Overview stat' },
    { text: 'Total Users', page: 'overview', navId: 'nav-overview', icon: '📊', desc: 'Overview stat' },
    { text: 'Waste Collected', page: 'overview', navId: 'nav-overview', icon: '📊', desc: 'Overview stat' },

    // Smart Bins
    { text: 'Smart Bin Management', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Premium IoT bins' },
    { text: 'BIN-001 Main Street', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Smart bin' },
    { text: 'BIN-002 Park Avenue', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Smart bin' },
    { text: 'BIN-003 Shopping Mall', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Smart bin' },
    { text: 'BIN-045 City Library', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Smart bin' },
    { text: 'Online Bins', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Status stat' },
    { text: 'Critical Bins', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Fill >90%' },

    // Normal Bins
    { text: 'Normal Bin Scheduled', page: 'manual_bin', navId: 'nav-manual_bin', icon: '🗑️', desc: 'Manual collection bins' },
    { text: 'Main Street Zone A', page: 'manual_bin', navId: 'nav-manual_bin', icon: '🗑️', desc: 'Normal bin' },
    { text: 'Park Avenue Zone B', page: 'manual_bin', navId: 'nav-manual_bin', icon: '🗑️', desc: 'Normal bin' },
    { text: 'Shopping Mall Zone C', page: 'manual_bin', navId: 'nav-manual_bin', icon: '🗑️', desc: 'Normal bin' },

    // Collections
    { text: 'Collections Log', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Completed & active collections' },
    { text: 'COL-101 Zone A', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Collection' },
    { text: 'COL-102 Zone B', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Collection' },
    { text: 'COL-103 Zone C', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Collection' },
    { text: 'John Collector', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Collector' },
    { text: 'Waste Tonnage', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Summary stat' },

    // Routes
    { text: 'Route Management', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Collection routes' },
    { text: 'RTE-01 North Loop', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Route' },
    { text: 'RTE-02 Park Circuit', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Route' },
    { text: 'RTE-03 Central Run', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Route' },
    { text: 'Active Routes', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Route stat' },
    { text: 'Fuel Saved', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Route stat' },

    // Users
    { text: 'User Management', page: 'users', navId: 'nav-users', icon: '👥', desc: 'All users & collectors' },
    { text: 'Sarah Admin', page: 'users', navId: 'nav-users', icon: '👥', desc: 'Administrator' },
    { text: 'Mike Driver', page: 'users', navId: 'nav-users', icon: '👥', desc: 'Collector' },
    { text: 'Priya Sharma', page: 'users', navId: 'nav-users', icon: '👥', desc: 'Premium user' },
    { text: 'Arjun Nair', page: 'users', navId: 'nav-users', icon: '👥', desc: 'Normal user' },
    { text: 'Premium Users', page: 'users', navId: 'nav-users', icon: '👥', desc: 'User stat' },
    { text: 'Collectors', page: 'users', navId: 'nav-users', icon: '👥', desc: 'Field staff' },

    // Requests
    { text: 'Collection Requests', page: 'requests', navId: 'nav-requests', icon: '📋', desc: 'Pending & resolved requests' },
    { text: 'REQ-234 Main Street', page: 'requests', navId: 'nav-requests', icon: '📋', desc: 'High priority' },
    { text: 'REQ-235 Park Avenue', page: 'requests', navId: 'nav-requests', icon: '📋', desc: 'Medium priority' },
    { text: 'REQ-236 City Center', page: 'requests', navId: 'nav-requests', icon: '📋', desc: 'Low priority' },
    { text: 'High Priority Request', page: 'requests', navId: 'nav-requests', icon: '📋', desc: 'Urgent' },
];

function globalSearch(query) {
    const dropdown = document.getElementById('searchResults');
    query = query.trim().toLowerCase();

    if (!query) { closeSearchDropdown(); return; }

    const matches = searchIndex.filter(item =>
        item.text.toLowerCase().includes(query) ||
        item.desc.toLowerCase().includes(query)
    ).slice(0, 8);

    if (matches.length === 0) {
        dropdown.innerHTML = '<div class="search-no-result">No results found for "<b>' + escapeHtml(query) + '</b>"</div>';
    } else {
        dropdown.innerHTML = matches.map(item => `
            <div class="search-result-item" onclick="navigateFromSearch('${item.page}','${item.navId}')">
                <span>${item.icon}</span>
                <span>${highlightMatch(item.text, query)}</span>
                <span class="result-page">${item.page.replace('_', ' ')}</span>
            </div>
        `).join('');
    }

    dropdown.classList.remove('hidden');
}

function highlightMatch(text, query) {
    const idx = text.toLowerCase().indexOf(query);
    if (idx === -1) return escapeHtml(text);
    return escapeHtml(text.slice(0, idx))
        + '<strong style="color:#10b981">' + escapeHtml(text.slice(idx, idx + query.length)) + '</strong>'
        + escapeHtml(text.slice(idx + query.length));
}

function navigateFromSearch(page, navId) {
    showPage(page, document.getElementById(navId));
    document.getElementById('globalSearch').value = '';
    closeSearchDropdown();
}

function closeSearchDropdown() {
    const d = document.getElementById('searchResults');
    if (d) d.classList.add('hidden');
}

function escapeHtml(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

// Close dropdown when clicking outside
document.addEventListener('click', function (e) {
    if (!e.target.closest('.search-bar-wrapper')) {
        closeSearchDropdown();
    }
});

// ─── Table Filter (per-page search within tables) ────────────
function filterTable(input, tableId) {
    const query = input.value.toLowerCase();
    const rows = document.querySelectorAll('#' + tableId + ' tbody tr');
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(query) ? '' : 'none';
    });
}

function filterBySelect(select, tableId, colIndex) {
    const value = select.value.toLowerCase();
    const rows = document.querySelectorAll('#' + tableId + ' tbody tr');
    rows.forEach(row => {
        const cell = row.cells[colIndex];
        if (!cell) { row.style.display = ''; return; }
        row.style.display = (!value || cell.textContent.toLowerCase().includes(value)) ? '' : 'none';
    });
}

// ─── Action Button Handlers ───────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    document.addEventListener('click', function (e) {
        // View
        if (e.target.classList.contains('btn-primary') && e.target.textContent.trim() === 'View') {
            const row = e.target.closest('tr');
            const label = row ? row.cells[0].textContent.trim() : 'item';
            alert(`📋 Viewing details for: ${label}`);
        }

        // Collect
        if (e.target.classList.contains('btn-success') && e.target.textContent.trim() === 'Collect') {
            const row = e.target.closest('tr');
            const label = row ? row.cells[0].textContent.trim() : 'bin';
            if (confirm(`🚛 Schedule collection for ${label}?`)) {
                alert(`✅ Collection scheduled for ${label}`);
            }
        }

        // Assign request
        if (e.target.classList.contains('btn-success') && e.target.textContent.trim() === 'Assign') {
            const row = e.target.closest('tr');
            const reqId = row ? row.cells[0].textContent.trim() : 'request';
            if (confirm(`Assign a collector to ${reqId}?`)) {
                row.remove();
                updateRequestBadge();
                alert(`✅ Collector assigned to ${reqId}`);
            }
        }

        // Delete user
        if (e.target.classList.contains('btn-danger') && e.target.textContent.trim() === 'Delete') {
            const row = e.target.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            if (confirm(`⚠️ Are you sure you want to delete ${name}?`)) {
                row.remove();
                alert(`🗑️ ${name} has been removed.`);
            }
        }

        // Cancel request
        if (e.target.classList.contains('btn-danger') && e.target.textContent.trim() === 'Cancel') {
            const row = e.target.closest('tr');
            const reqId = row ? row.cells[0].textContent.trim() : 'request';
            if (confirm(`Cancel ${reqId}?`)) {
                row.remove();
                updateRequestBadge();
                alert(`❌ ${reqId} has been cancelled.`);
            }
        }

        // Edit user
        if (e.target.classList.contains('btn-primary') && e.target.textContent.trim() === 'Edit') {
            const row = e.target.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            alert(`✏️ Editing profile for: ${name}\n(Full editor coming soon!)`);
        }

        // Report collection
        if (e.target.classList.contains('btn-warning') && e.target.textContent.trim() === 'Report') {
            const row = e.target.closest('tr');
            const id = row ? row.cells[0].textContent.trim() : 'item';
            alert(`📊 Generating report for ${id}…`);
        }

        // Edit route
        if (e.target.classList.contains('btn-warning') && e.target.textContent.trim() === 'Edit') {
            const row = e.target.closest('tr');
            const id = row ? row.cells[0].textContent.trim() : 'route';
            alert(`🗺️ Opening route editor for ${id}…`);
        }

        // View Map
        if (e.target.classList.contains('btn-primary') && e.target.textContent.trim() === 'View Map') {
            const row = e.target.closest('tr');
            const name = row ? row.cells[1].textContent.trim() : 'route';
            alert(`🗺️ Opening map for: ${name}\n(Map integration coming soon!)`);
        }
    });
});

// ─── Request Badge Count ──────────────────────────────────────
function updateRequestBadge() {
    const remaining = document.querySelectorAll('#requestsTable tbody tr').length;
    const badge = document.getElementById('requestsBadge');
    if (badge) badge.textContent = remaining;
}

// ─── Real-time Simulations ────────────────────────────────────
function updateBinLevels() {
    const fillLevels = document.querySelectorAll('#binActivityTable td:nth-child(3) .fill-inner');
    fillLevels.forEach(bar => {
        const current = parseInt(bar.style.width);
        if (current < 95) {
            const newLevel = Math.min(current + Math.floor(Math.random() * 3), 100);
            bar.style.width = newLevel + '%';
            bar.style.background = newLevel >= 80 ? '#ef4444' : newLevel >= 60 ? '#f59e0b' : '#10b981';

            const span = bar.closest('td').querySelector('span') || bar.parentElement.nextElementSibling;
            // Update text in the parent td
            const td = bar.closest('td');
            const spanEl = td ? td.querySelector('span') : null;
            // no text span in fill bar; skip
        }
    });
}

function updateTimestamps() {
    const timestamps = document.querySelectorAll('#binActivityTable td:nth-child(5)');
    const times = ['Just now', '1 min ago', '2 mins ago', '4 mins ago', '6 mins ago', '10 mins ago'];
    timestamps.forEach(cell => {
        cell.textContent = times[Math.floor(Math.random() * times.length)];
    });
}

function updateStatistics() {
    const el = document.getElementById('activeCollections');
    if (el) {
        const curr = parseInt(el.textContent);
        el.textContent = Math.max(10, curr + (Math.random() > 0.5 ? 1 : -1));
    }
}

setInterval(updateBinLevels, 5000);
setInterval(updateTimestamps, 10000);
setInterval(updateStatistics, 15000);

// ─── Notification Badge Simulation ───────────────────────────
function checkNotifications() {
    const badge = document.getElementById('requestsBadge');
    if (badge && Math.random() > 0.8) {
        const curr = parseInt(badge.textContent) || 0;
        badge.textContent = curr + 1;
    }
}

setInterval(checkNotifications, 30000);

console.log('✅ Emptico Admin Dashboard initialized successfully!');