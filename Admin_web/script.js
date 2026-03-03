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
    'requests': 'requestsPage',
    'transactions': 'transactionsPage'
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

    // Basic
    { text: 'Basic Bin Scheduled', page: 'manual_bin', navId: 'nav-manual_bin', icon: '🗑️', desc: 'Manual collection bins' },
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

// ─── Firebase Real-time DB Integration ───────────────────────
document.addEventListener('DOMContentLoaded', () => {
    if (typeof firebase === 'undefined' || !firebase.apps.length) return;

    const db = firebase.database();

    // Clear all dummy table contents first
    const tablesToClear = [
        'binActivityTable', 'overviewNormalBinsTable', 'smartBinsTable',
        'normalBinsTable', 'collectionsTable', 'routesTable', 'usersTable',
        'requestsTable', 'txHistoryTable', 'subscriptionsTable'
    ];
    tablesToClear.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            const tbody = el.querySelector('tbody');
            if (tbody) tbody.innerHTML = '';
        }
    });

    const getFillColor = (level) => level >= 80 ? '#ef4444' : level >= 60 ? '#f59e0b' : '#10b981';

    // 1. Fetch Smart Bins
    db.ref('smart_bins').on('value', (snapshot) => {
        const data = snapshot.val();
        const smartTable = document.querySelector('#smartBinsTable tbody');
        const activityTable = document.querySelector('#binActivityTable tbody');
        if (smartTable) smartTable.innerHTML = '';
        if (activityTable) activityTable.innerHTML = '';

        if (data) {
            Object.keys(data).forEach(key => {
                const bin = data[key];
                const tr = document.createElement('tr');
                const fillLvl = bin.fillLevel || 0;
                const fillHTML = `<div class="fill-bar"><div class="fill-inner" style="width:${fillLvl}%;background:${getFillColor(fillLvl)}"></div><span>${fillLvl}%</span></div>`;
                const statusHTML = `<span class="status ${bin.status === 'Online' ? 'online' : 'offline'}">${bin.status || 'Unknown'}</span>`;

                tr.innerHTML = `
                    <td>${bin.id || key}</td>
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${bin.type || 'General'}</td>
                    <td>${fillHTML}</td>
                    <td>${statusHTML}</td>
                    <td><button class="btn btn-primary">View</button><button class="btn btn-success">Collect</button></td>
                `;
                if (smartTable) smartTable.appendChild(tr);

                const trAct = document.createElement('tr');
                trAct.innerHTML = `
                    <td>${bin.id || key}</td>
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${fillHTML}</td>
                    <td>${statusHTML}</td>
                    <td>${bin.lastUpdated || 'Just now'}</td>
                `;
                if (activityTable) activityTable.appendChild(trAct);
            });
        }
    });

    // 2. Fetch Normal Bins
    db.ref('normal_bins').on('value', (snapshot) => {
        const data = snapshot.val();
        const normalTable = document.querySelector('#normalBinsTable tbody');
        const overviewNormalTable = document.querySelector('#overviewNormalBinsTable tbody');
        if (normalTable) normalTable.innerHTML = '';
        if (overviewNormalTable) overviewNormalTable.innerHTML = '';

        if (data) {
            Object.keys(data).forEach(key => {
                const bin = data[key];
                const statusClass = bin.status === 'Collected' ? 'online' : bin.status === 'Pending' ? 'pending' : 'offline';

                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${bin.type || 'General'}</td>
                    <td>${bin.scheduledDate || '-'}</td>
                    <td>${bin.scheduledTime || '-'}</td>
                    <td><span class="status ${statusClass}">${bin.status || 'Pending'}</span></td>
                    <td><button class="btn btn-primary">View</button><button class="btn btn-success">Collect</button></td>
                `;
                if (normalTable) normalTable.appendChild(tr);

                const trOver = document.createElement('tr');
                trOver.innerHTML = `
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${bin.type || 'General'}</td>
                    <td>${bin.scheduledDate || '-'}</td>
                    <td>${bin.collector || 'Unassigned'}</td>
                    <td><span class="status ${statusClass}">${bin.status || 'Pending'}</span></td>
                `;
                if (overviewNormalTable) overviewNormalTable.appendChild(trOver);
            });
        }
    });

    // 3. Generic setup for other collections
    const setupFetch = (path, tableSelector, rowBuilder) => {
        db.ref(path).on('value', (snapshot) => {
            const data = snapshot.val();
            const table = document.querySelector(tableSelector + ' tbody');
            if (table) table.innerHTML = '';
            if (data && table) {
                Object.keys(data).forEach(key => {
                    const tr = rowBuilder(key, data[key]);
                    if (tr) table.appendChild(tr);
                });
            }
        });
    };

    setupFetch('collections', '#collectionsTable', (key, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Completed' ? 'online' : item.status === 'In Progress' ? 'pending' : 'offline';
        tr.innerHTML = `<td>${item.id || key}</td><td>${item.zone || '-'}</td><td>${item.collector || '-'}</td><td>${item.binsCollected || 0}</td><td><span class="status ${s}">${item.status || 'Scheduled'}</span></td><td>${item.date || '-'}</td><td><button class="btn btn-primary">View</button></td>`;
        return tr;
    });

    setupFetch('routes', '#routesTable', (key, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Active' ? 'online' : item.status === 'In Progress' ? 'pending' : 'offline';
        tr.innerHTML = `<td>${item.id || key}</td><td>${item.name || '-'}</td><td>${item.zone || '-'}</td><td>${item.bins || 0}</td><td>${item.distance || 0}</td><td>${item.assignedCollector || '-'}</td><td><span class="status ${s}">${item.status || 'Idle'}</span></td><td><button class="btn btn-primary">View</button></td>`;
        return tr;
    });

    setupFetch('users', '#usersTable', (key, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Active' ? 'online' : 'offline';
        tr.innerHTML = `<td>${item.name || '-'}</td><td>${item.email || '-'}</td><td>${item.role || 'User'}</td><td>${item.plan || 'Free'}</td><td><span class="status ${s}">${item.status || 'Active'}</span></td><td>${item.joined || '-'}</td><td><button class="btn btn-warning">Edit</button></td>`;
        return tr;
    });

    setupFetch('requests', '#requestsTable', (key, item) => {
        const tr = document.createElement('tr');
        const pCls = item.priority === 'High' ? 'high' : item.priority === 'Medium' ? 'medium' : 'low';
        tr.innerHTML = `<td>${item.id || key}</td><td>${item.location || '-'}</td><td><span class="priority ${pCls}">${item.priority || 'Low'}</span></td><td>${item.user || '-'}</td><td><span class="status pending">${item.status || 'Pending'}</span></td><td>${item.date || '-'}</td><td><button class="btn btn-success">Assign</button></td>`;
        setTimeout(updateRequestBadge, 50);
        return tr;
    });

    setupFetch('transactions', '#txHistoryTable', (key, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Success' ? 'online' : item.status === 'Pending' ? 'pending' : 'offline';
        tr.innerHTML = `<td>${item.id || key}</td><td>${item.name || '-'}</td><td>${item.email || '-'}</td><td>${item.type || '-'}</td><td><span class="status ${s}">${item.status || 'Pending'}</span></td><td>${item.amount || '-'}</td><td>${item.date || '-'}</td>`;
        return tr;
    });

    setupFetch('subscriptions', '#subscriptionsTable', (key, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Active' ? 'online' : item.status === 'Pending' ? 'pending' : 'offline';
        tr.innerHTML = `<td>${item.id || key}</td><td>${item.user || '-'}</td><td>${item.plan || 'Free'}</td><td>${item.started || '-'}</td><td><span class="status ${s}">${item.status || 'Active'}</span></td><td>${item.renewal || '-'}</td><td>${item.amount || '-'}</td>`;
        return tr;
    });
});

console.log('✅ Emptico Admin Dashboard initialized successfully!');