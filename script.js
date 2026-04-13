// =============================================================
// script.js – Emptico Admin Dashboard  |  Firebase Firestore
// =============================================================

// ─── Auth State Observer ──────────────────────────────────────────────────────
firebase.auth().onAuthStateChanged(async function (user) {
    if (user) {
        try {
            // Verify if the user is actually an administrator
            const adminDoc = await db.collection('admins').doc(user.uid).get();
            if (adminDoc.exists) {
                showDashboardForUser(user);
            } else {
                // Not an admin! Kick them out immediately.
                await firebase.auth().signOut();
                alert("⛔ Access Denied! Your account does not have administrator privileges.");
                document.getElementById('loginPage').style.display = 'flex';
                document.getElementById('dashboard').classList.remove('active');
                
                // Show generic login error for better UX
                const err = document.getElementById('loginError');
                if(err) err.textContent = 'Account exists, but is not an administrator.';
            }
        } catch (error) {
            console.error("Error verifying admin permissions:", error);
            await firebase.auth().signOut();
            document.getElementById('loginPage').style.display = 'flex';
            document.getElementById('dashboard').classList.remove('active');
        }
    } else {
        document.getElementById('loginPage').style.display = 'flex';
        document.getElementById('dashboard').classList.remove('active');
    }
});

// ─── Modal Controls for Adding Admin ──────────────────────────────────────────
function showAddAdminModal() {
    document.getElementById('addAdminModalOverlay').classList.remove('hidden');
    // Pre-warm the secondary Firebase app if not already initialized
    if (!firebase.apps.length) return;
    if (!firebase.apps.find(app => app.name === "AdminCreatorApp")) {
        firebase.initializeApp(firebaseConfig, "AdminCreatorApp");
    }
}

function closeAddAdminModal() {
    document.getElementById('addAdminModalOverlay').classList.add('hidden');
    document.getElementById('addAdminForm').reset();
    document.getElementById('createAdminError').textContent = '';
    
    const btn = document.getElementById('createAdminBtn');
    btn.disabled = false;
    btn.textContent = 'Create Admin Account';
}

// ─── Creating Admins ─────────────────────────────
document.getElementById('addAdminForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const name = document.getElementById('newAdminName').value.trim();
    const email = document.getElementById('newAdminEmail').value.trim();
    const password = document.getElementById('newAdminPassword').value;
    const btn = document.getElementById('createAdminBtn');
    const errorEl = document.getElementById('createAdminError');

    errorEl.textContent = '';
    if (!name) { errorEl.textContent = 'Please enter full name.'; return; }
    if (password.length < 6) { errorEl.textContent = 'Password must be min 6 characters.'; return; }

    // Enhanced Loading State
    btn.disabled = true;
    btn.innerHTML = '<span style="display:flex; align-items:center; justify-content:center; gap:8px;">⏳ Provisioning Account...</span>';

    // Get the secondary app instance
    const adminCreatorApp = firebase.apps.find(app => app.name === "AdminCreatorApp") || firebase.initializeApp(firebaseConfig, "AdminCreatorApp");

    // Force memory-only persistence so it doesn't overwrite the primary admin's IndexedDB session
    adminCreatorApp.auth().setPersistence(firebase.auth.Auth.Persistence.NONE)
        .then(() => {
            return adminCreatorApp.auth().createUserWithEmailAndPassword(email, password);
        })
        .then(function (userCredential) {
            btn.innerHTML = '<span style="display:flex; align-items:center; justify-content:center; gap:8px;">⏳ Securing Permissions...</span>';
            const user = userCredential.user;
            const updateProfile = user.updateProfile({ displayName: name });
            const saveDoc = db.collection('admins').doc(user.uid).set({
                uid: user.uid,
                name: name,
                email: email,
                role: 'admin',
                status: 'Active',
                created_at: new Date().toISOString()
            });
            return Promise.all([updateProfile, saveDoc]);
        })
        .then(function () {
            // Sign out of the secondary instance to clear its state
            adminCreatorApp.auth().signOut();
            closeAddAdminModal();
            showToast('✅ New Admin Successfully Created!', 'Success');
            btn.textContent = 'Create Admin Account';
            btn.disabled = false;
        })
        .catch(function (error) {
            btn.disabled = false;
            btn.textContent = 'Create Admin Account';
            const code = error.code;
            let msg = 'Failed to create internal admin.';
            if (code === 'auth/email-already-in-use') msg = 'Email already registered.';
            else if (code === 'auth/invalid-email') msg = 'Invalid email address.';
            errorEl.textContent = msg;
        });
});

// ─── Sign In ──────────────────────────────────────────────────────────────────
document.getElementById('loginForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const btn = document.getElementById('loginBtn');
    const errorEl = document.getElementById('loginError');

    errorEl.textContent = '';
    btn.disabled = true;
    btn.textContent = 'Signing in…';

    firebase.auth().signInWithEmailAndPassword(email, password)
        .then(function () {
            btn.textContent = 'Sign In';
            btn.disabled = false;
        })
        .catch(function (error) {
            btn.disabled = false;
            btn.textContent = 'Sign In';
            const code = error.code;
            let msg = 'Login failed. Please try again.';
            if (code === 'auth/user-not-found' || code === 'auth/wrong-password' || code === 'auth/invalid-credential')
                msg = 'Invalid email or password. Please check and try again.';
            else if (code === 'auth/invalid-email') msg = 'Please enter a valid email address.';
            else if (code === 'auth/too-many-requests') msg = 'Too many failed attempts. Please wait and try again.';
            else if (code === 'auth/network-request-failed') msg = 'Network error. Please check your connection.';
            errorEl.textContent = msg;
        });
});

// ─── Show Dashboard After Auth ─────────────────────────────────────────────
function showDashboardForUser(user) {
    document.getElementById('loginPage').style.display = 'none';
    document.getElementById('dashboard').classList.add('active');

    const displayName = user.displayName || user.email.split('@')[0];
    document.getElementById('adminName').textContent =
        displayName.charAt(0).toUpperCase() + displayName.slice(1);

    showPage('overview', document.getElementById('nav-overview'));
    initFirebaseData();
    setTimeout(loadUsersPage, 500);
    setTimeout(loadSmartPage, 600);
}

// ─── Load Users Page Data ──────────────────────────────────────────────────
async function loadUsersPage() {
    const tbody = document.getElementById('usersTableBody');
    if (!tbody) return;

    tbody.innerHTML = '<tr class="loading-row"><td colspan="9">⏳ Fetching users and admins from Firestore…</td></tr>';

    try {
        const [usersSnap, adminsSnap] = await Promise.all([
            db.collection('users').get(),
            db.collection('admins').get()
        ]);

        tbody.innerHTML = '';
        let total = 0, freeCount = 0, premium = 0;
        const allUsers = [];

        usersSnap.forEach(doc => allUsers.push({ id: doc.id, col: 'users', data: doc.data() }));
        adminsSnap.forEach(doc => allUsers.push({ id: doc.id, col: 'admins', data: doc.data() }));

        if (allUsers.length === 0) {
            tbody.innerHTML = '<tr class="loading-row"><td colspan="9">No records found.</td></tr>';
            return;
        }

        allUsers.sort((a, b) => {
            const pa = (a.data.subscriptionPlan || a.data.plan || '').toLowerCase();
            const pb = (b.data.subscriptionPlan || b.data.plan || '').toLowerCase();
            return (pa === 'pro' || pa === 'premium' ? 0 : 1) - (pb === 'pro' || pb === 'premium' ? 0 : 1);
        });

        allUsers.forEach(({ id, col, data: u }) => {
            const planRaw = u.subscriptionPlan || u.plan || u.subscription || '';
            const planL = planRaw.toLowerCase();
            const role = u.role || (col === 'admins' ? 'admin' : 'user');
            
            total++;
            if (planL === 'pro' || planL === 'premium') premium++;
            else freeCount++;

            const isPro = planL === 'pro' || planL === 'premium';
            const planDisplay = isPro
                ? '<span class="badge-label" style="border-color:#7c3aed;color:#7c3aed">★ Pro</span>'
                : (col === 'admins' ? '<span class="badge-label" style="border-color:#10b981;color:#10b981">Admin</span>' : '<span class="badge-label">Basic</span>');

            let dateStr = '-';
            if (u.createdAt && u.createdAt.toDate) {
                dateStr = u.createdAt.toDate().toLocaleDateString('en-GB');
            } else if (u.created_at) {
                dateStr = u.created_at;
            } else if (u.joined) {
                dateStr = u.joined;
            }

            const displayName = u.fullName || u.name || '-';
            const ecoPoints = u.ecoPoints !== undefined ? u.ecoPoints : 0;
            const wasteRecycled = u.totalWasteRecycled !== undefined ? u.totalWasteRecycled : 0;

            const statusVal = u.status || 'Active';
            const sc = statusVal.toLowerCase() === 'active' ? 'online' : 'offline';

            let actionBtn = `<button class="btn btn-warning">Edit</button> <button class="btn btn-danger">Delete</button>`;
            if (col === 'admins') {
                // Determine if it's the currently logged-in admin
                const isCurrentUser = firebase.auth().currentUser && firebase.auth().currentUser.uid === id;
                if (isCurrentUser) {
                    actionBtn = `<span style="font-size:12px; color:#9ca3af;">(You)</span>`;
                } else {
                    actionBtn = `<button class="btn btn-danger" onclick="deleteAdmin('${id}')">Revoke Admin</button>`;
                }
            }

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${displayName}</td>
                <td>${u.email || '-'}</td>
                <td><strong style="color: ${role==='admin'?'#ef4444':'inherit'}">${role}</strong></td>
                <td>${planDisplay}</td>
                <td><span class="status ${sc}">${statusVal}</span></td>
                <td style="text-align:center"><span style="color:#10b981;font-weight:600">🌿 ${ecoPoints}</span></td>
                <td style="text-align:center">${wasteRecycled} kg</td>
                <td>${dateStr}</td>
                <td>${actionBtn}</td>`;
            tbody.appendChild(tr);
        });

        const setStat = (id, val) => {
            const el = document.getElementById(id);
            if (el) el.textContent = val;
        };
        setStat('statTotalUsers', total.toLocaleString());
        setStat('statActiveUsers', freeCount.toLocaleString());
        setStat('statPremiumUsers', premium.toLocaleString());
        setStat('statOverviewTotalUsers', total.toLocaleString());

        const badge = document.getElementById('usersBadge');
        if (badge) badge.textContent = total;

    } catch (err) {
        console.error('[loadUsersPage]', err);
        let msg = err.message;
        if (err.code === 'permission-denied') {
            msg = '⛔ Permission denied — please check Firestore rules.';
        }
        tbody.innerHTML = `<tr class="loading-row"><td colspan="9" style="color:#ef4444">${msg}</td></tr>`;
    }
}

// Delete Admin Functionality
async function deleteAdmin(adminId) {
    if (!confirm("Are you sure you want to revoke this user's admin privileges?")) return;
    try {
        await db.collection('admins').doc(adminId).delete();
        showToast('✅ Admin privileges revoked.', 'Success');
        loadUsersPage(); // refresh
    } catch (err) {
        console.error('Failed to delete admin', err);
        alert('Failed to delete admin: ' + err.message);
    }
}

// ─── Load Smart (Pro) Page Data ──────────────────────────────────────────────
function loadSmartPage() {
    const tbody = document.getElementById('smartBinsTable');
    if (!tbody) return;

    tbody.innerHTML = '<tr class="loading-row"><td colspan="7">⏳ Fetching Pro users from Firestore…</td></tr>';

    db.collection('users').get().then(snapshot => {
        tbody.innerHTML = '';

        let proCount = 0;
        const proUsers = [];

        snapshot.forEach(doc => {
            const u = doc.data();
            // Cache user name for cross-referencing in pickup requests
            const _uname = u.fullName || u.name || u.displayName || '';
            if (_uname) window._userNameCache[doc.id] = _uname;
            const planRaw = (u.subscriptionPlan || u.plan || u.subscription || '').toLowerCase();
            if (planRaw === 'pro' || planRaw === 'premium') {
                proCount++;
                proUsers.push({ id: doc.id, data: u });
            }
        });

        document.getElementById('statProUsers') && (document.getElementById('statProUsers').textContent = proCount);
        document.getElementById('statActiveProUsers') && (document.getElementById('statActiveProUsers').textContent = proCount);

        if (proUsers.length === 0) {
            tbody.innerHTML = '<tr class="loading-row"><td colspan="7">No Pro plan users found.</td></tr>';
            return;
        }

        proUsers.forEach(({ id, data: u }) => {
            const displayName = u.fullName || u.name || '-';

            let dateStr = '-';
            if (u.createdAt && u.createdAt.toDate) {
                dateStr = u.createdAt.toDate().toLocaleDateString('en-GB');
            } else if (u.created_at) {
                dateStr = u.created_at;
            } else if (u.joined) {
                dateStr = u.joined;
            }

            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><strong>${displayName}</strong></td>
                <td>${u.email || '-'}</td>
                <td>${u.phone || u.phoneNumber || '-'}</td>
                <td><span class="badge-label" style="border-color:#7c3aed;color:#7c3aed">★ Pro</span></td>
                <td><span class="status online">Active</span></td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-warning">Edit</button>
                    <button class="btn btn-danger">Delete</button>
                </td>`;
            tbody.appendChild(tr);
        });

    }).catch(err => {
        console.error('[loadSmartPage]', err);
        let msg = err.message;
        if (err.code === 'permission-denied') {
            msg = '⛔ Permission denied — check Firestore rules in the Firebase console.';
        }
        tbody.innerHTML = `<tr class="loading-row"><td colspan="7" style="color:#ef4444">${msg}</td></tr>`;
    });
}

// ─── Logout ───────────────────────────────────────────────────────────────────
function logout() {
    firebase.auth().signOut().then(function () {
        document.getElementById('dashboard').classList.remove('active');
        document.getElementById('loginPage').style.display = 'flex';
        document.getElementById('email').value = '';
        document.getElementById('password').value = '';
        document.getElementById('loginError').textContent = '';
    }).catch(function (err) { console.error('Logout error:', err); });
}

// ─── Page Navigation ──────────────────────────────────────────────────────────
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
    document.querySelectorAll('.page').forEach(p => p.classList.add('hidden'));
    document.querySelectorAll('.menu-item').forEach(m => m.classList.remove('active'));
    const page = document.getElementById(pageMap[pageName]);
    if (page) page.classList.remove('hidden');
    if (navEl) navEl.classList.add('active');
    closeSearchDropdown();
}

// ─── Global Search ────────────────────────────────────────────────────────────
const searchIndex = [
    { text: 'Dashboard Overview', page: 'overview', navId: 'nav-overview', icon: '📊', desc: 'System summary & stats' },
    { text: 'Smart Bin Management', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Premium IoT bins' },
    { text: 'Basic Bin Scheduled', page: 'manual_bin', navId: 'nav-manual_bin', icon: '🗑️', desc: 'Manual collection bins' },
    { text: 'Collections Log', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Completed & active collections' },
    { text: 'Route Management', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Collection routes' },
    { text: 'User Management', page: 'users', navId: 'nav-users', icon: '👥', desc: 'All users & collectors' },
    { text: 'Collection Requests', page: 'requests', navId: 'nav-requests', icon: '📋', desc: 'Pending & resolved requests' },
    { text: 'Transactions', page: 'transactions', navId: 'nav-transactions', icon: '💳', desc: 'Payments & subscriptions' },
];

function globalSearch(query) {
    const dropdown = document.getElementById('searchResults');
    query = query.trim().toLowerCase();
    if (!query) { closeSearchDropdown(); return; }

    const matches = searchIndex.filter(i =>
        i.text.toLowerCase().includes(query) || i.desc.toLowerCase().includes(query)
    ).slice(0, 8);

    dropdown.innerHTML = matches.length === 0
        ? '<div class="search-no-result">No results found for "<b>' + escapeHtml(query) + '"</b></div>'
        : matches.map(i => `
            <div class="search-result-item" onclick="navigateFromSearch('${i.page}','${i.navId}')">
                <span>${i.icon}</span>
                <span>${highlightMatch(i.text, query)}</span>
                <span class="result-page">${i.page.replace('_', ' ')}</span>
            </div>`).join('');

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
document.addEventListener('click', e => {
    if (!e.target.closest('.search-bar-wrapper')) closeSearchDropdown();
});

// ─── Table Filter ─────────────────────────────────────────────────────────────
function getRows(tableId) {
    const el = document.getElementById(tableId);
    if (!el) return [];
    const selector = el.tagName === 'TBODY' ? '#' + tableId + ' tr' : '#' + tableId + ' tbody tr';
    return Array.from(document.querySelectorAll(selector));
}
function filterTable(input, tableId) {
    const q = input.value.toLowerCase();
    getRows(tableId).forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
function filterBySelect(select, tableId, colIndex) {
    const value = select.value.toLowerCase();
    getRows(tableId).forEach(row => {
        const cell = row.cells[colIndex];
        if (!cell) { row.style.display = ''; return; }
        row.style.display = (!value || cell.textContent.toLowerCase().includes(value)) ? '' : 'none';
    });
}

// ─── Action Button Handlers ───────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    document.addEventListener('click', function (e) {
        const btn = e.target.closest('button');
        if (!btn) return;
        const text = btn.textContent.trim();

        if (btn.classList.contains('btn-primary') && text === 'View') {
            const row = btn.closest('tr');
            alert(`📋 Viewing details for: ${row ? row.cells[0].textContent.trim() : 'item'}`);
        }
        if (btn.classList.contains('btn-success') && text === 'Collect') {
            const row = btn.closest('tr');
            const label = row ? row.cells[0].textContent.trim() : 'bin';
            if (confirm(`🚛 Schedule collection for ${label}?`)) alert(`✅ Collection scheduled for ${label}`);
        }
        // ── ASSIGN button: open collector modal ────────────────────────────────
        if (btn.classList.contains('btn-success') && text === 'Assign') {
            const row = btn.closest('tr');
            if (row) openAssignModal(row);
        }
        if (btn.classList.contains('btn-danger') && text === 'Delete') {
            const row = btn.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            if (confirm(`⚠️ Are you sure you want to delete ${name}?`)) {
                row.remove(); alert(`🗑️ ${name} has been removed.`);
            }
        }
        if (btn.classList.contains('btn-danger') && text === 'Cancel') {
            const row = btn.closest('tr');
            const docId = row ? row.dataset.docId : null;
            const reqId = row ? row.cells[0].textContent.trim() : 'request';
            if (confirm(`Cancel pickup ${reqId}?`) && docId) {
                db.collection('pickupRequests').doc(docId).update({
                    status: 'CANCELLED',
                    cancelledAt: new Date().toISOString()
                }).then(() => {
                    showToast(`❌ ${reqId} has been cancelled.`);
                }).catch(err => {
                    console.error('[cancel]', err);
                    alert('⚠ Failed to cancel: ' + err.message);
                });
            }
        }
        if (btn.classList.contains('btn-primary') && text === 'Edit') {
            const row = btn.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            alert(`✏️ Editing profile for: ${name}\n(Full editor coming soon!)`);
        }
        if (btn.classList.contains('btn-warning') && text === 'Report') {
            const row = btn.closest('tr');
            alert(`📊 Generating report for ${row ? row.cells[0].textContent.trim() : 'item'}…`);
        }
        if (btn.classList.contains('btn-warning') && text === 'Edit') {
            const row = btn.closest('tr');
            alert(`🗺️ Opening route editor for ${row ? row.cells[0].textContent.trim() : 'route'}…`);
        }
        if (btn.classList.contains('btn-primary') && text === 'View Map') {
            const row = btn.closest('tr');
            const name = row ? row.cells[1].textContent.trim() : 'route';
            alert(`🗺️ Opening map for: ${name}\n(Map integration coming soon!)`);
        }
    });
});

// ─── Request Badge ────────────────────────────────────────────────────────────
function updateRequestBadge() {
    const remaining = document.querySelectorAll('#requestsTable tbody tr:not(.loading-row)').length;
    const badge = document.getElementById('requestsBadge');
    if (badge) badge.textContent = remaining;
}


// --- Firestore Live Data ---------------------------------------------------
function initFirebaseData() {

    // ── Helpers ──────────────────────────────────────────────────────────────

    const getFillColor = l => l >= 80 ? '#ef4444' : l >= 60 ? '#f59e0b' : '#10b981';

    function fmt(ts) {
        if (!ts) return '-';
        if (ts.toDate) return ts.toDate().toLocaleDateString('en-GB');
        if (typeof ts === 'string') return ts;
        if (ts.seconds) return new Date(ts.seconds * 1000).toLocaleDateString('en-GB');
        return '-';
    }

    function setLoading(tbodyId, cols) {
        const el = document.getElementById(tbodyId);
        if (!el) return null;
        const tbody = el.tagName === 'TBODY' ? el : el.querySelector('tbody');
        if (tbody) tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">Loading from Firestore…</td></tr>`;
        return tbody;
    }

    function listenCollection(collectionName, tbodyId, cols, rowBuilder) {
        const tbody = setLoading(tbodyId, cols);
        db.collection(collectionName).onSnapshot(snapshot => {
            if (!tbody) return;
            tbody.innerHTML = '';
            if (snapshot.empty) {
                tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">No records found in Firestore.</td></tr>`;
                return;
            }
            snapshot.forEach(doc => {
                const tr = rowBuilder(doc.id, doc.data());
                if (tr) tbody.appendChild(tr);
            });
        }, err => {
            console.error(`[${collectionName}]`, err);
            if (tbody) tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">⚠ ${err.message}</td></tr>`;
        });
    }

    function setStat(id, val) {
        const el = document.getElementById(id);
        if (el) el.textContent = (val !== undefined && val !== null) ? val : '-';
    }

    function statusClass(s) {
        const sl = (s || '').toLowerCase();
        if (sl === 'active' || sl === 'approved' || sl === 'online' || sl === 'completed' || sl === 'success') return 'online';
        if (sl === 'pending' || sl === 'assigned') return 'pending';
        return 'offline';
    }

    // ── 1. Smart Bins (smart_bins) ──────────────────────────────────────────
    db.collection('smart_bins').onSnapshot(snapshot => {
        setStat('statTotalSmartBins', snapshot.size.toLocaleString());
        setStat('statTotalSmartBinsChange', snapshot.size + ' smart bins registered');
        setStat('statOverviewTotalBins', snapshot.size.toLocaleString());
        setStat('statOverviewBinsChange', 'Live from system');

        const activityTbody = document.getElementById('binActivityTable');
        if (activityTbody) {
            activityTbody.innerHTML = '';
            if (snapshot.empty) {
                activityTbody.innerHTML = '<tr class="loading-row"><td colspan="5">No smart bin activity yet.</td></tr>';
            } else {
                snapshot.forEach(doc => {
                    const bin = doc.data();
                    const fillLvl = bin.fillLevel || bin.fill_level || 0;
                    const fillHTML = `<div class="fill-bar"><div class="fill-inner" style="width:${fillLvl}%;background:${getFillColor(fillLvl)}"></div><span>${fillLvl}%</span></div>`;
                    const sc = bin.status === 'Online' || bin.status === 'online' ? 'online' : 'offline';
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td>${bin.binId || bin.id || doc.id}</td>
                        <td>${bin.location || bin.address || 'Unknown'}</td>
                        <td>${fillHTML}</td>
                        <td><span class="status ${sc}">${bin.status || 'Unknown'}</span></td>
                        <td>${fmt(bin.lastUpdated || bin.last_updated)}</td>`;
                    activityTbody.appendChild(tr);
                });
            }
        }
    }, err => console.error('[smart_bins]', err));

    // ── 2. User-facing bins (bins) ─────────────────────────────────────────
    db.collection('bins').onSnapshot(snapshot => {
        setStat('statUserBinsCount', snapshot.size.toLocaleString());
    }, err => console.warn('[bins]', err.message));

    // ── 3. Pro Users (Smart page table + stat cards) ───────────────────────
    const smartTbody = setLoading('smartBinsTable', 7);
    db.collection('users').onSnapshot(snapshot => {
        if (!smartTbody) return;
        smartTbody.innerHTML = '';
        let proCount = 0, activeProCount = 0;
        const proUsers = [];
        snapshot.forEach(doc => {
            const u = doc.data();
            const planRaw = u.subscriptionPlan || u.plan || u.subscription || '';
            const planL = planRaw.toLowerCase();
            if (planL === 'pro' || planL === 'premium') {
                proCount++;
                const sl = (u.status || '').toLowerCase();
                if (sl === 'active' || sl === 'approved') activeProCount++;
                proUsers.push({ id: doc.id, data: u });
            }
        });
        setStat('statProUsers', proCount.toLocaleString());
        setStat('statActiveProUsers', activeProCount.toLocaleString());
        if (proUsers.length === 0) {
            smartTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No Pro plan users found.</td></tr>';
            return;
        }
        proUsers.forEach(({ data: u }) => {
            const dateStr = fmt(u.createdAt || u.created_at) || u.joined || '-';
            const displayName = u.fullName || u.name || '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${displayName}</td>
                <td>${u.email || '-'}</td>
                <td>${u.phone || u.phone_number || '-'}</td>
                <td><span class="badge-label" style="border-color:#7c3aed;color:#7c3aed">★ Pro</span></td>
                <td><span class="status ${statusClass(u.status)}">${u.status || 'Active'}</span></td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-warning">Edit</button>
                    <button class="btn btn-danger">Delete</button>
                </td>`;
            smartTbody.appendChild(tr);
        });
    }, err => {
        console.error('[pro users]', err);
        if (smartTbody) smartTbody.innerHTML = `<tr class="loading-row"><td colspan="7">⚠ ${err.message}</td></tr>`;
    });

    // ── 4. Free Users (Basic page table + stat cards) ─────────────────────
    const normalTbody = setLoading('normalBinsTable', 6);
    db.collection('users').onSnapshot(snapshot => {
        if (!normalTbody) return;
        normalTbody.innerHTML = '';
        let freeCount = 0, activeFreeCount = 0, inactiveFreeCount = 0;
        const freeUsers = [];
        snapshot.forEach(doc => {
            const u = doc.data();
            const planRaw = u.subscriptionPlan || u.plan || u.subscription || '';
            const planL = planRaw.toLowerCase();
            if (planL === 'basic' || planL === 'free' || planL === '') {
                freeCount++;
                const sl = (u.status || '').toLowerCase();
                if (sl === 'active' || sl === 'approved') activeFreeCount++;
                else inactiveFreeCount++;
                freeUsers.push({ id: doc.id, data: u });
            }
        });
        setStat('statFreeUsers', freeCount.toLocaleString());
        setStat('statActiveFreeUsers', activeFreeCount.toLocaleString());
        setStat('statInactiveFreeUsers', inactiveFreeCount.toLocaleString());
        if (freeUsers.length === 0) {
            normalTbody.innerHTML = '<tr class="loading-row"><td colspan="6">No Basic plan users found.</td></tr>';
            return;
        }
        freeUsers.forEach(({ data: u }) => {
            const dateStr = fmt(u.createdAt || u.created_at) || u.joined || '-';
            const displayName = u.fullName || u.name || '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${displayName}</td>
                <td>${u.email || '-'}</td>
                <td>${u.phone || u.phone_number || '-'}</td>
                <td><span class="badge-label">Basic</span></td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-warning">Edit</button>
                    <button class="btn btn-danger">Delete</button>
                </td>`;
            normalTbody.appendChild(tr);
        });
    }, err => {
        console.error('[free users]', err);
        if (normalTbody) normalTbody.innerHTML = `<tr class="loading-row"><td colspan="6">⚠ ${err.message}</td></tr>`;
    });

    // ── 5. Collectors (Collections page) ───────────────────────────────────
    const collLogTbody = setLoading('collectionsTableBody', 8);
    db.collection('collectors').onSnapshot(snapshot => {
        setStat('statCollInProgress', snapshot.size.toLocaleString());
        if (!collLogTbody) return;
        collLogTbody.innerHTML = '';
        if (snapshot.empty) {
            collLogTbody.innerHTML = '<tr class="loading-row"><td colspan="8">No collectors found.</td></tr>';
            return;
        }
        snapshot.forEach(doc => {
            const u = doc.data();
            const vehicleType = (u.vehicle && u.vehicle.vehicle_type)
                ? u.vehicle.vehicle_type.replace(/_/g, ' ')
                : (u.vehicle_type ? u.vehicle_type.replace(/_/g, ' ') : '-');
            const rating = u.rating !== undefined ? u.rating : '-';
            const pickups = u.total_pickups !== undefined ? u.total_pickups : '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${u.name || '-'}</td>
                <td>${u.email || '-'}</td>
                <td>${u.phone || u.phone_number || '-'}</td>
                <td>${u.city || u.zone || u.location || '-'}</td>
                <td>${rating}</td>
                <td>${pickups}</td>
                <td>${vehicleType}</td>
                <td>
                    <button class="btn btn-primary">View</button>
                    <button class="btn btn-warning">Edit</button>
                </td>`;
            collLogTbody.appendChild(tr);
        });
    }, err => {
        console.error('[collectors]', err);
        if (collLogTbody) collLogTbody.innerHTML = `<tr class="loading-row"><td colspan="8">⚠ ${err.message}</td></tr>`;
    });

    // ── 6. Routes ──────────────────────────────────────────────────────────
    db.collection('routes').onSnapshot(snapshot => {
        setStat('statActiveRoutes', snapshot.size.toString());
        setStat('statActiveRoutesChange', 'Live active');
        setStat('statStopsToday', (snapshot.size * 4).toString());
        setStat('statStopsTodayChange', 'Estimated');
        setStat('statFuelSaved', (snapshot.size * 2).toString() + ' L');
        setStat('statFuelSavedChange', 'Estimated');
    });
    listenCollection('routes', 'routesTable', 8, (id, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Active' ? 'online' : item.status === 'In Progress' ? 'pending' : 'offline';
        tr.innerHTML = `
            <td>${item.id || id}</td>
            <td>${item.name || '-'}</td>
            <td>${item.zone || '-'}</td>
            <td>${item.bins || 0}</td>
            <td>${item.distance || 0}</td>
            <td>${item.assignedCollector || item.assigned_collector || '-'}</td>
            <td><span class="status ${s}">${item.status || 'Idle'}</span></td>
            <td>
                <button class="btn btn-primary">View Map</button>
                <button class="btn btn-warning">Edit</button>
            </td>`;
        return tr;
    });

    // ── 7. All Users (Users Management page) ───────────────────────────────
    const usersTbody = setLoading('usersTableBody', 9);
    db.collection('users').onSnapshot(snapshot => {
        if (!usersTbody) return;
        usersTbody.innerHTML = '';
        let total = 0, freeCount = 0, premium = 0;
        const allUsers = [];
        snapshot.forEach(doc => allUsers.push({ id: doc.id, data: doc.data() }));
        const planRank = p => (p === 'pro' || p === 'premium') ? 0 : 1;
        allUsers.sort((a, b) => {
            const pa = (a.data.subscriptionPlan || a.data.plan || a.data.subscription || '').toLowerCase();
            const pb = (b.data.subscriptionPlan || b.data.plan || b.data.subscription || '').toLowerCase();
            return planRank(pa) - planRank(pb);
        });
        if (allUsers.length === 0) {
            usersTbody.innerHTML = '<tr class="loading-row"><td colspan="9">No users found.</td></tr>';
        }
        allUsers.forEach(({ id, data: u }) => {
            const planRaw = u.subscriptionPlan || u.plan || u.subscription || '';
            const planL = planRaw.toLowerCase();
            total++;
            if (planL === 'basic' || planL === 'free' || planL === '') freeCount++;
            if (planL === 'premium' || planL === 'pro') premium++;
            const isPro = planL === 'premium' || planL === 'pro';
            const planDisplay = isPro
                ? '<span class="badge-label" style="border-color:#7c3aed;color:#7c3aed">★ Pro</span>'
                : '<span class="badge-label">Basic</span>';
            const dateStr = fmt(u.createdAt || u.created_at) || u.joined || '-';
            const displayName = u.fullName || u.name || '-';
            const ecoPoints = u.ecoPoints !== undefined ? u.ecoPoints : '-';
            const wasteRecycled = u.totalWasteRecycled !== undefined ? u.totalWasteRecycled + ' kg' : '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${displayName}</td>
                <td>${u.email || '-'}</td>
                <td>${u.role || 'user'}</td>
                <td>${planDisplay}</td>
                <td><span class="status ${statusClass(u.status)}">${u.status || 'Active'}</span></td>
                <td style="text-align:center"><span style="color:#10b981;font-weight:600">${ecoPoints}</span></td>
                <td style="text-align:center">${wasteRecycled}</td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-warning">Edit</button>
                    <button class="btn btn-danger">Delete</button>
                </td>`;
            usersTbody.appendChild(tr);
        });
        setStat('statTotalUsers', total.toLocaleString());
        setStat('statActiveUsers', freeCount.toLocaleString());
        setStat('statPremiumUsers', premium.toLocaleString());
        setStat('statOverviewTotalUsers', total.toLocaleString());
        const usersBadge = document.getElementById('usersBadge');
        if (usersBadge) usersBadge.textContent = total;
        // Re-render pickup table now that user names are cached
        if (typeof _renderPickupTable === 'function') _renderPickupTable();
    }, err => {
        console.error('[users]', err);
        if (usersTbody) usersTbody.innerHTML = `<tr class="loading-row"><td colspan="9">⚠ ${err.message}</td></tr>`;
    });

    // Cache of userId -> userName for cross-referencing
    window._userNameCache = window._userNameCache || {};

    // ── 8. Pickup Requests (Requests page) ─────────────────────────────────
    const reqTbody = setLoading('requestsTableBody', 8);

    // Sort state: true = latest first (descending), false = oldest first
    window._requestSortDesc = true;
    window._pickupDocs = [];

    window.toggleRequestSort = function() {
        window._requestSortDesc = !window._requestSortDesc;
        const btn = document.getElementById('sortRequestsBtn');
        if (btn) btn.textContent = window._requestSortDesc ? '\u2193 Latest First' : '\u2191 Oldest First';
        _renderPickupTable();
    };

    function _parseDate(raw) {
        if (!raw) return new Date(0);
        if (raw.toDate) return raw.toDate();
        if (raw.seconds) return new Date(raw.seconds * 1000);
        if (typeof raw === 'string') { const d = new Date(raw); return isNaN(d) ? new Date(0) : d; }
        return new Date(0);
    }

    function _extractWasteType(r) {
        if (r.type && r.type !== '-') return r.type;
        if (r.wasteTypes && Array.isArray(r.wasteTypes) && r.wasteTypes.length > 0) return r.wasteTypes.join(', ');
        return r.wasteType || r.waste_type || r.category || '-';
    }

    function _extractUserName(r) {
        if (r.userName && r.userName !== '-') return r.userName;
        if (r.user_name && r.user_name !== '-') return r.user_name;
        if (r.name && r.name !== '-') return r.name;
        // Fall back to looking up from cached users collection
        const uid = r.userId || r.user_id || r.uid || '';
        if (uid && window._userNameCache[uid]) return window._userNameCache[uid];
        if (r.userEmail || r.user_email) return r.userEmail || r.user_email;
        if (uid) return uid.slice(0, 8) + '…';
        return '-';
    }

    function _renderPickupTable() {
        if (!reqTbody) return;
        reqTbody.innerHTML = '';
        const sorted = [...window._pickupDocs];
        sorted.sort((a, b) => {
            const da = _parseDate(a.data.createdAt || a.data.created_at || a.data.date);
            const db2 = _parseDate(b.data.createdAt || b.data.created_at || b.data.date);
            return window._requestSortDesc ? (db2 - da) : (da - db2);
        });
        if (sorted.length === 0) {
            reqTbody.innerHTML = '<tr class="loading-row"><td colspan="8">No pickup requests found.</td></tr>';
            return;
        }
        sorted.forEach(item => {
            const r = item.data;
            const docId = item.id;
            const sl = (r.status || '').toLowerCase();
            const reqId = r.requestId || r.request_id || docId.slice(0, 8).toUpperCase();
            const location = r.userAddress || r.address || r.location || '-';
            const wasteType = _extractWasteType(r);
            const reqBy = _extractUserName(r);
            const assignedTo = r.collectorName || r.collector_name || r.driverName || r.collectorId || '-';
            const dateStr = fmt(r.createdAt || r.created_at || r.date || r.scheduledDate);
            let sc = 'offline';
            if (sl === 'completed') sc = 'online';
            else if (sl === 'pending' || sl === 'assigned' || sl === 'accepted') sc = 'pending';
            const statusLabel = (r.status || '-').charAt(0).toUpperCase() + (r.status || '-').slice(1).toLowerCase();
            const tr = document.createElement('tr');
            tr.dataset.docId = docId;
            if (sl === 'waiting') tr.style.background = '#fff5f5';
            tr.innerHTML = `
                <td title="${docId}">${reqId}</td>
                <td title="${location}">${location.length > 40 ? location.slice(0, 40) + '\u2026' : location}</td>
                <td>${wasteType}</td>
                <td>${reqBy}</td>
                <td>${assignedTo}</td>
                <td><span class="status ${sc}">${statusLabel}</span></td>
                <td>${dateStr}</td>
                <td>
                    ${sl === 'pending' || sl === 'waiting' ? '<button class="btn btn-success">Assign</button>' : ''}
                    ${sl !== 'completed' && sl !== 'cancelled' ? '<button class="btn btn-danger">Cancel</button>' : ''}
                </td>`;
            reqTbody.appendChild(tr);
        });
    }

    db.collection('pickupRequests').onSnapshot(snapshot => {
        let total = 0, pending = 0, assigned = 0, completed = 0, waiting = 0;
        window._pickupDocs = [];
        snapshot.forEach(doc => {
            const r = doc.data();
            total++;
            const sl = (r.status || '').toLowerCase();
            if (sl === 'pending') pending++;
            else if (sl === 'assigned' || sl === 'accepted') assigned++;
            else if (sl === 'completed') completed++;
            else if (sl === 'waiting') waiting++;
            window._pickupDocs.push({ id: doc.id, data: r });
        });
        _renderPickupTable();
        setStat('statTotalRequests', total.toLocaleString());
        setStat('statPendingRequests', pending.toLocaleString());
        setStat('statAssignedRequests', assigned.toLocaleString());
        setStat('statCompletedRequests', completed.toLocaleString());
        setStat('statWaitingRequests', waiting.toLocaleString());
        setStat('activeCollections', (pending + assigned + waiting).toString());
        setStat('activeCollectionsChange', 'Currently active');
        const badge = document.getElementById('requestsBadge');
        if (badge) badge.textContent = pending + assigned;
    }, err => {
        console.error('[pickupRequests]', err);
        if (reqTbody) reqTbody.innerHTML = `<tr class="loading-row"><td colspan="8">\u26A0 ${err.message}</td></tr>`;
    });

    // ── 9. Resolved Requests ───────────────────────────────────────────────
    listenCollection('resolved_requests', 'resolvedRequestsTable', 5, (id, r) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${r.requestId || r.request_id || id.slice(0, 8).toUpperCase()}</td>
            <td>${r.address || r.location || '-'}</td>
            <td>${r.collectorName || r.collector_name || '-'}</td>
            <td>${fmt(r.resolvedAt || r.resolved_at || r.updatedAt)}</td>
            <td><span class="status online">Resolved</span></td>`;
        return tr;
    });

    // ── 10. Transactions ───────────────────────────────────────────────────
    const txTbody = setLoading('txHistoryTable', 7);
    db.collection('transactions').onSnapshot(snapshot => {
        if (!txTbody) return;
        txTbody.innerHTML = '';
        let totalRevenue = 0, txToday = 0, failedCount = 0;
        const today = new Date(); today.setHours(0,0,0,0);

        if (snapshot.empty) {
            txTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No transactions found.</td></tr>';
            setStat('statTotalRevenue', '\u20b90');
            setStat('statTotalRevenueChange', 'No transactions yet');
            setStat('statTxToday', '0');
            setStat('statTxTodayChange', 'No activity today');
            setStat('statFailedPayments', '0');
            setStat('statFailedPaymentsChange', 'All clear');
            return;
        }
        const txList = [];
        snapshot.forEach(doc => txList.push({ id: doc.id, data: doc.data() }));
        txList.sort((a, b) => {
            const da = a.data.createdAt?.seconds || a.data.date || 0;
            const db2 = b.data.createdAt?.seconds || b.data.date || 0;
            return db2 - da;
        });
        txList.forEach(({ id, data: t }) => {
            const amt = parseFloat(t.amount) || 0;
            const sl = (t.status || '').toLowerCase();
            if (sl === 'success' || sl === 'completed' || sl === 'paid') totalRevenue += amt;
            if (sl === 'failed') failedCount++;
            // Check if today
            const txDate = t.createdAt?.toDate ? t.createdAt.toDate() : (t.createdAt?.seconds ? new Date(t.createdAt.seconds * 1000) : null);
            if (txDate && txDate >= today) txToday++;

            const sc = statusClass(t.status);
            const amount = t.amount !== undefined ? '\u20b9' + Number(t.amount).toLocaleString('en-IN') : '-';
            const dateStr = fmt(t.date || t.createdAt || t.created_at);
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${t.txnId || t.transaction_id || id.slice(0, 10).toUpperCase()}</td>
                <td>${t.userName || t.user_name || '-'}</td>
                <td>${t.userEmail || t.user_email || '-'}</td>
                <td>${t.type || t.transaction_type || '-'}</td>
                <td><span class="status ${sc}">${t.status || '-'}</span></td>
                <td>${amount}</td>
                <td>${dateStr}</td>`;
            txTbody.appendChild(tr);
        });
        setStat('statTotalRevenue', '\u20b9' + totalRevenue.toLocaleString('en-IN'));
        setStat('statTotalRevenueChange', txList.length + ' total transactions');
        setStat('statTxToday', txToday.toString());
        setStat('statTxTodayChange', 'Today so far');
        setStat('statFailedPayments', failedCount.toString());
        setStat('statFailedPaymentsChange', failedCount === 0 ? 'All clear' : 'Needs follow-up');
    }, err => {
        console.error('[transactions]', err);
        if (txTbody) txTbody.innerHTML = `<tr class="loading-row"><td colspan="7">\u26a0 ${err.message}</td></tr>`;
    });

    // ── 11. Subscriptions ──────────────────────────────────────────────────
    const subTbody = setLoading('subscriptionsTable', 7);
    db.collection('subscriptions').onSnapshot(snapshot => {
        if (!subTbody) return;
        subTbody.innerHTML = '';
        let totalSubs = 0, activeSubs = 0;
        if (snapshot.empty) {
            subTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No subscriptions found.</td></tr>';
            setStat('statActiveSubscriptions', '0');
            setStat('statActiveSubscriptionsChange', 'No subscriptions yet');
            return;
        }
        snapshot.forEach(doc => {
            totalSubs++;
            const _sl = (doc.data().status || '').toLowerCase();
            if (_sl === 'active') activeSubs++;
            const s = doc.data();
            const sc = statusClass(s.status);
            const plan = s.plan || s.planName || s.plan_name || '-';
            const amount = s.amount !== undefined ? '₹' + Number(s.amount).toLocaleString('en-IN') + '/mo' : '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${s.subId || s.subscription_id || doc.id.slice(0, 8).toUpperCase()}</td>
                <td>${s.userName || s.user_name || s.userId || '-'}</td>
                <td>${plan}</td>
                <td>${fmt(s.startDate || s.start_date || s.createdAt)}</td>
                <td><span class="status ${sc}">${s.status || '-'}</span></td>
                <td>${fmt(s.renewalDate || s.renewal_date || s.expiryDate)}</td>
                <td>${amount}</td>`;
            subTbody.appendChild(tr);
        });
        // Populate active subscriptions stat
        setStat('statActiveSubscriptions', activeSubs.toString());
        setStat('statActiveSubscriptionsChange', totalSubs + ' total subscriptions');
    }, err => {
        console.error('[subscriptions]', err);
        if (subTbody) subTbody.innerHTML = `<tr class="loading-row"><td colspan="7">\u26a0 ${err.message}</td></tr>`;
    });

    // \u2500\u2500 12. Overview — Recent Users ─────────────────────────────────────────
    const overviewNormalTbody = document.getElementById('overviewNormalBinsTable');
    db.collection('users').onSnapshot(snapshot => {
        if (!overviewNormalTbody) return;
        overviewNormalTbody.innerHTML = '';
        const recent = [];
        snapshot.forEach(doc => recent.push({ id: doc.id, data: doc.data() }));
        recent.sort((a, b) => {
            const da = a.data.createdAt?.seconds || 0;
            const db2 = b.data.createdAt?.seconds || 0;
            return db2 - da;
        });
        if (recent.length === 0) {
            overviewNormalTbody.innerHTML = '<tr class="loading-row"><td colspan="5">No users yet.</td></tr>';
            return;
        }
        recent.slice(0, 10).forEach(({ data: u }) => {
            const planRaw = u.subscriptionPlan || u.plan || u.subscription || '';
            const planL = planRaw.toLowerCase();
            const isPro = planL === 'premium' || planL === 'pro';
            const planDisplay = isPro ? '★ Pro' : 'Basic';
            const displayName = u.fullName || u.name || '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${displayName}</td>
                <td>${u.email || '-'}</td>
                <td>${planDisplay}</td>
                <td><span class="status ${statusClass(u.status)}">${u.status || 'Active'}</span></td>
                <td>${fmt(u.createdAt || u.created_at) || u.joined || '-'}</td>`;
            overviewNormalTbody.appendChild(tr);
        });
    }, err => console.error('[overview users]', err));


    // Kick off auto-assignment engines
    initAutoAssignmentEngine();
    initCompletionCleanupEngine();
    initActiveAssignmentsPanel();
    initLiveAdminMap();

} // end initFirebaseData

// =============================================================
// AUTO-ASSIGNMENT ENGINE
// Watches pickupRequests where status=="pending" and auto-assigns
// the nearest online, non-busy collector via Firestore batch write.
// Runs entirely in the admin browser tab (free-tier compatible).
// =============================================================

let adminMapInstance = null;
let mapMarkers = {}; // Keep track of marker layers

function initLiveAdminMap() {
    const mapContainer = document.getElementById('liveAdminMap');
    if (!mapContainer || typeof L === 'undefined') return;

    if (!adminMapInstance) {
        adminMapInstance = L.map('liveAdminMap').setView([12.9716, 77.5946], 12);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '© OpenStreetMap Binnit Admin'
        }).addTo(adminMapInstance);
        
        // Handle tab switches - leaflet needs invalidateSize to render properly after being hidden
        document.querySelectorAll('.menu-item').forEach(btn => {
            btn.addEventListener('click', () => {
                setTimeout(() => adminMapInstance.invalidateSize(), 300);
            });
        });
    }

    // 1. Listen to all pending/assigned pickupRequests
    db.collection('pickupRequests')
      .where('status', 'in', ['pending', 'PENDING', 'assigned', 'ASSIGNED', 'waiting', 'WAITING'])
      .onSnapshot(snap => {
         snap.docChanges().forEach(change => {
            const docId = change.doc.id;
            const markerId = 'req_' + docId;
            const data = change.doc.data();
            
            if (change.type === 'removed' || ['completed', 'cancelled'].includes((data.status || '').toLowerCase())) {
                if (mapMarkers[markerId]) { adminMapInstance.removeLayer(mapMarkers[markerId]); delete mapMarkers[markerId];}
                return;
            }
            
            const reqLocation = (data.latitude && data.longitude) 
                ? { lat: data.latitude, lng: data.longitude } 
                : (data.location || null);
                
            if (!reqLocation || !reqLocation.lat) return;
            
            let color = '#f59e0b'; // orange for pending
            if (data.status === 'assigned') color = '#3b82f6'; // blue
            if (data.status === 'waiting') color = '#ef4444'; // red
            
            if (mapMarkers[markerId]) {
                mapMarkers[markerId].setLatLng([reqLocation.lat, reqLocation.lng]);
                mapMarkers[markerId].setStyle({ fillColor: color });
                mapMarkers[markerId].bindPopup(`<b>Request:</b> ${data.requestId || docId}<br><b>Status:</b> ${data.status}`);
            } else {
                const marker = L.circleMarker([reqLocation.lat, reqLocation.lng], {
                   radius: 8,
                   fillColor: color,
                   color: '#fff',
                   weight: 2,
                   opacity: 1,
                   fillOpacity: 0.9
                }).addTo(adminMapInstance);
                marker.bindPopup(`<b>Request:</b> ${data.requestId || docId}<br><b>Status:</b> ${data.status}`);
                mapMarkers[markerId] = marker;
            }
         });
      }, err => console.warn('[LiveMap Request listener error]', err));

    // 2. Listen to active collector locations
    db.collection('collectorLocations')
      .onSnapshot(snap => {
         snap.docChanges().forEach(change => {
            const docId = change.doc.id;
            const markerId = 'coll_' + docId;
            const data = change.doc.data();
            
            if (change.type === 'removed') {
                if (mapMarkers[markerId]) { adminMapInstance.removeLayer(mapMarkers[markerId]); delete mapMarkers[markerId];}
                return;
            }
            
            if (!data.latitude || !data.longitude) return;
            
            if (mapMarkers[markerId]) {
                mapMarkers[markerId].setLatLng([data.latitude, data.longitude]);
            } else {
                const truckIcon = L.divIcon({
                    html: '<div style="background:#10b981;width:30px;height:30px;border-radius:15px;border:3px solid white;display:flex;align-items:center;justify-content:center;color:white;font-size:16px;box-shadow:0 4px 6px rgba(0,0,0,0.3);">🚚</div>',
                    className: '',
                    iconSize: [30, 30],
                    iconAnchor: [15, 15]
                });
                
                const marker = L.marker([data.latitude, data.longitude], {icon: truckIcon}).addTo(adminMapInstance);
                
                // Fetch collector name for popup
                db.collection('collectors').doc(docId).get().then(cDoc => {
                    let name = docId;
                    if (cDoc.exists) name = cDoc.data().name || docId;
                    marker.bindPopup(`<b>🚚 Collector:</b> ${name}<br>Status: Online`);
                });
                
                mapMarkers[markerId] = marker;
            }
         });
      }, err => console.warn('[LiveMap Collector listener error]', err));
}

/** Haversine distance in km between two GeoPoints (or {lat,lng} objects) */
function _haversineKm(a, b) {
    if (!a || !b) return Infinity;
    const R = 6371;
    const toRad = x => x * Math.PI / 180;
    const lat1 = typeof a.latitude !== 'undefined' ? a.latitude : a.lat;
    const lon1 = typeof a.longitude !== 'undefined' ? a.longitude : a.lng;
    const lat2 = typeof b.latitude !== 'undefined' ? b.latitude : b.lat;
    const lon2 = typeof b.longitude !== 'undefined' ? b.longitude : b.lng;
    if (lat1 == null || lat2 == null) return Infinity;
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const sinLat = Math.sin(dLat / 2);
    const sinLon = Math.sin(dLon / 2);
    const a2 = sinLat * sinLat + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * sinLon * sinLon;
    return R * 2 * Math.atan2(Math.sqrt(a2), Math.sqrt(1 - a2));
}

// Track request IDs currently being processed to prevent double-processing
const _processingRequests = new Set();
let isAutoAssignEnabled = true;

function initAutoAssignmentEngine() {
    const statusEl = document.getElementById('autoEngineStatus');
    if (statusEl) statusEl.textContent = '\uD83D\uDFE2 Engine Active';

    // UI Toggle Listener
    const toggleEl = document.getElementById('autoAssignToggle');
    const toggleText = document.getElementById('autoAssignStatusText');
    if (toggleEl) {
        toggleEl.addEventListener('change', (e) => {
            isAutoAssignEnabled = e.target.checked;
            toggleText.textContent = isAutoAssignEnabled ? 'ON' : 'OFF';
            toggleText.style.color = isAutoAssignEnabled ? '#10b981' : '#64748b';
            console.log('[AutoAssign] Engine state toggled:', isAutoAssignEnabled ? 'ON' : 'OFF');
        });
    }

    db.collection('pickupRequests')
        .where('status', 'in', ['pending', 'PENDING'])
        .onSnapshot(snapshot => {
            snapshot.docChanges().forEach(change => {
                // Only handle newly added pending requests
                if (change.type !== 'added') return;
                
                // If the auto-assign engine is turned off via UI, we do nothing.
                // The request will remain pending and can be manually assigned.
                if (!isAutoAssignEnabled) {
                    console.log('[AutoAssign] Engine is OFF. Skipping auto-assign for:', change.doc.id);
                    return;
                }

                const docId = change.doc.id;
                const reqData = change.doc.data();

                // Skip if already being processed (prevent duplicate handling)
                if (_processingRequests.has(docId)) return;
                _processingRequests.add(docId);

                console.log('[AutoAssign] New pending request:', docId, reqData);
                _autoAssignRequest(docId, reqData).finally(() => {
                    _processingRequests.delete(docId);
                });
            });
        }, err => {
            console.error('[AutoAssign] Listener error:', err);
            if (statusEl) statusEl.textContent = '\u26A0\uFE0F Engine Error';
            if (statusEl) statusEl.style.color = '#ef4444';
        });
}

async function _autoAssignRequest(requestDocId, reqData) {
    const city       = reqData.city || '';
    const reqLocation = (reqData.latitude && reqData.longitude) 
        ? { lat: reqData.latitude, lng: reqData.longitude } 
        : (reqData.location || null);
    const userId     = reqData.userId || '';
    const address    = reqData.address || '';

    try {
        // ── Step 1: Get actively busy collector IDs from collectorAssign ──
        const activeAssignSnap = await db.collection('collectorAssign')
            .where('status', 'in', ['assigned', 'in_progress'])
            .get();
        const busyCollectorIds = new Set();
        activeAssignSnap.forEach(d => busyCollectorIds.add(d.data().collectorId));

        // ── Step 2: Query active collector locations (live trackers) ──
        const activeLocationsSnap = await db.collection('collectorLocations').get();
        
        let candidates = [];
        
        for (let doc of activeLocationsSnap.docs) {
            const collectorId = doc.id;
            if (busyCollectorIds.has(collectorId)) continue;
            
            const locData = doc.data();
            const loc = { lat: locData.latitude, lng: locData.longitude };
            
            // Check collector profile
            const cDoc = await db.collection('collectors').doc(collectorId).get();
            if (!cDoc.exists) continue;
            
            const c = cDoc.data();
            if (c.isBusy === true) continue;
            
            candidates.push({ id: collectorId, data: c, liveLocation: loc });
        }

        // If no one is streaming locations, fallback to online query
        if (candidates.length === 0) {
            const collSnap = await db.collection('collectors').where('isOnline', '==', true).get();
            collSnap.forEach(doc => {
                const c = doc.data();
                if (c.isBusy === true) return;
                if (busyCollectorIds.has(doc.id)) return;
                const cLoc = c.location || c.currentLocation;
                candidates.push({ id: doc.id, data: c, liveLocation: cLoc });
            });
        }

        // ── Step 3: Sort by distance and enforce 10km radius limit ──
        if (reqLocation) {
            candidates = candidates.map(c => {
                 c.distance = _haversineKm(reqLocation, c.liveLocation);
                 return c;
            }).filter(c => c.distance <= 10) // STRICT 10KM LIMIT
            .sort((a, b) => a.distance - b.distance);
        } else {
            console.warn('[AutoAssign] Pickup request lacks GPS coordinates, skipping 10km filter.');
        }

        if (candidates.length === 0) {
            // No collector available within radius — set status to waiting
            await db.collection('pickupRequests').doc(requestDocId).update({
                status: 'waiting',
                updatedAt: firebase.firestore.FieldValue.serverTimestamp()
            });
            console.log('[AutoAssign] No collectors within 10km for', requestDocId, '— status: waiting');
            showToast('\u26A0\uFE0F No collectors within 10km — request queued');
            return;
        }

        const chosen = candidates[0];
        const collectorId = chosen.id;
        const collectorName = chosen.data.name || collectorId;

        // ── Step 4: Batch write — atomic, prevents partial failure ──
        const batch = db.batch();

        // Create collectorAssign document
        const assignRef = db.collection('collectorAssign').doc();
        const assignId  = assignRef.id;
        batch.set(assignRef, {
            requestId:   requestDocId,
            userId:      userId,
            collectorId: collectorId,
            assignedBy:  'system',
            status:      'assigned',
            city:        city,
            address:     address,
            assignedAt:  firebase.firestore.FieldValue.serverTimestamp()
        });

        // Update pickupRequests status
        const reqRef = db.collection('pickupRequests').doc(requestDocId);
        batch.update(reqRef, {
            status:        'assigned',
            collectorId:   collectorId,
            collectorName: collectorName,
            assignId:      assignId,
            assignedAt:    firebase.firestore.FieldValue.serverTimestamp()
        });

        // Mark collector as busy
        const collRef = db.collection('collectors').doc(collectorId);
        batch.update(collRef, {
            isBusy:         true,
            currentAssignId: assignId
        });

        await batch.commit();

        console.log('[AutoAssign] \u2705 Assigned', requestDocId, '\u2192 collector', collectorId, '| assign:', assignId);
        showToast(`\u2705 Auto-assigned to ${collectorName}`);

    } catch (err) {
        console.error('[AutoAssign] Error assigning', requestDocId, err);
        // On failure, reset to pending so it retries when listener fires again
        try {
            await db.collection('pickupRequests').doc(requestDocId).update({ status: 'pending' });
        } catch (_) { /* ignore */ }
    }
}

// =============================================================
// COMPLETION CLEANUP ENGINE
// Watches collectorAssign where status=="completed" and:
// archives the doc, deletes the active records, restores collector.
// =============================================================

// Track processed completions to avoid double-archiving
const _processingCompletions = new Set();

function initCompletionCleanupEngine() {
    db.collection('collectorAssign')
        .where('status', '==', 'completed')
        .onSnapshot(snapshot => {
            snapshot.docChanges().forEach(change => {
                if (change.type !== 'added' && change.type !== 'modified') return;
                const assignId = change.doc.id;
                if (_processingCompletions.has(assignId)) return;
                _processingCompletions.add(assignId);

                const data = change.doc.data();
                console.log('[Cleanup] Completed assignment:', assignId, data);
                _cleanupCompletedAssignment(assignId, data)
                    .finally(() => setTimeout(() => _processingCompletions.delete(assignId), 30000));
            });
        }, err => console.error('[Cleanup] Listener error:', err));
}

async function _cleanupCompletedAssignment(assignId, data) {
    const { requestId, collectorId } = data;
    try {
        const batch = db.batch();

        // 1. Archive to assignmentArchive
        const archiveRef = db.collection('assignmentArchive').doc(assignId);
        batch.set(archiveRef, {
            ...data,
            archivedAt: firebase.firestore.FieldValue.serverTimestamp()
        });

        // 2. Delete active collectorAssign doc
        const assignRef = db.collection('collectorAssign').doc(assignId);
        batch.delete(assignRef);

        // 3. Keep the original pickupRequest for User History
        // If we delete it here, the user's "Completed" history screen will be blank.
        // We leave the document in Firestore—its status was already set to COMPLETED by the collector.

        // 4. Restore collector availability
        if (collectorId) {
            const collRef = db.collection('collectors').doc(collectorId);
            batch.update(collRef, {
                isBusy:          false,
                currentAssignId: null
            });
        }

        await batch.commit();
        console.log('[Cleanup] \u2705 Archived & cleaned up assignment:', assignId);
        showToast('\u2705 Assignment completed & archived');
    } catch (err) {
        console.error('[Cleanup] Error cleaning up', assignId, err);
    }
}

// =============================================================
// ACTIVE ASSIGNMENTS PANEL
// Live real-time table in the Requests page showing all active
// collectorAssign documents with status and Mark Complete action.
// =============================================================

function initActiveAssignmentsPanel() {
    const tbody = document.getElementById('activeAssignmentsTableBody');
    if (!tbody) return;

    function fmt(ts) {
        if (!ts) return '-';
        if (ts.toDate) return ts.toDate().toLocaleString('en-GB');
        if (ts.seconds) return new Date(ts.seconds * 1000).toLocaleString('en-GB');
        if (typeof ts === 'string') return ts;
        return '-';
    }

    window._allAssignments = [];
    
    window.filterAssignments = function() {
        const tbody = document.getElementById('activeAssignmentsTableBody');
        if (!tbody) return;
        const filterVal = document.getElementById('activeAssignmentsFilter')?.value || 'active';
        
        tbody.innerHTML = '';
        const filtered = window._allAssignments.filter(doc => {
            const sl = (doc.data().status || '').toLowerCase();
            const isActive = sl === 'assigned' || sl === 'pending' || sl === 'accepted' || sl === 'in_progress' || sl === 'on_the_way' || sl === 'reached' || sl === 'awaiting_response';
            
            if (filterVal === 'active') return isActive;
            if (filterVal === 'inactive') return !isActive;
            return true; // all
        });

        if (filtered.length === 0) {
            tbody.innerHTML = `<tr class="loading-row"><td colspan="8">No ${filterVal === 'all' ? '' : filterVal} assignments right now.</td></tr>`;
            return;
        }

        filtered.forEach(doc => {
            const a = doc.data();
            const sl = (a.status || '').toLowerCase();

            let statusBadge;
            if (sl === 'assigned') {
                statusBadge = '<span class="status pending">assigned</span>';
            } else if (sl === 'in_progress' || sl === 'on_the_way' || sl === 'reached') {
                statusBadge = `<span class="status online">${sl.replace('_', ' ')}</span>`;
            } else if (sl === 'waiting' || sl === 'awaiting_response') {
                statusBadge = '<span class="status offline" style="background:#fee2e2;color:#dc2626">awaiting response</span>';
            } else if (sl === 'timed_out' || sl === 'rejected' || sl === 'cancelled') {
                statusBadge = `<span class="status offline" style="background:#fee2e2;color:#dc2626">${sl.replace('_', ' ')}</span>`;
            } else {
                statusBadge = `<span class="status">${a.status || '-'}</span>`;
            }

            const tr = document.createElement('tr');
            if (sl === 'waiting' || sl === 'awaiting_response') tr.style.background = '#fff5f5';

            const assignIdShort = doc.id.slice(0, 10).toUpperCase();
            const reqIdShort = (a.requestDocId || a.requestId || '-').slice(0, 10);
            const locationStr = a.address || a.city || a.location || '-';
            const collectorStr = a.collectorName || (a.collectorId ? a.collectorId.slice(0, 10) + '…' : '-');

            tr.innerHTML = `
                <td title="${doc.id}">${assignIdShort}&hellip;</td>
                <td title="${a.requestDocId || a.requestId || '-'}">${reqIdShort}&hellip;</td>
                <td>${locationStr}</td>
                <td>${collectorStr}</td>
                <td>${a.assignedBy || 'system'}</td>
                <td>${statusBadge}</td>
                <td>${fmt(a.assignedAt)}</td>
                <td>
                    <button class="btn btn-success" style="font-size:11px;padding:4px 8px"
                        onclick="markAssignmentComplete('${doc.id}')">
                        \u2714 Complete
                    </button>
                </td>`;

            tbody.appendChild(tr);
        });
    };

    db.collection('collectorAssign').onSnapshot(snapshot => {
        window._allAssignments = snapshot.docs;
        window.filterAssignments();
    }, err => {
        console.error('[AssignPanel]', err);
        if (tbody) tbody.innerHTML = `<tr class="loading-row"><td colspan="8">\u26A0 ${err.message}</td></tr>`;
    });
}

/** Admin manually marks an assignment as completed */
function markAssignmentComplete(assignId) {
    if (!confirm('Mark this assignment as completed? This will archive it and free the collector.')) return;
    db.collection('collectorAssign').doc(assignId).update({
        status: 'completed',
        completedAt: firebase.firestore.FieldValue.serverTimestamp()
    }).then(() => {
        showToast('\uD83D\uDCCB Assignment marked as completed');
    }).catch(err => {
        alert('\u26A0 Failed to update: ' + err.message);
    });
}


// ─── Assign Collector Modal — Full Workflow ───────────────────────────────────
const ASSIGN_TIMEOUT_MS = 10 * 60 * 1000;   // 10 minutes
// For quick testing you can lower this, e.g. 30 * 1000 for 30 seconds

let _assignTargetRow       = null;  // <tr> being assigned
let _assignDocId           = null;  // Firestore pickupRequests doc ID
let _collectorsCache       = [];    // All online collectors [{id,name,phone,city,rating}]
let _rejectedCollectors    = [];    // IDs that have already rejected/timed-out
let _currentCollectorIdx   = -1;    // Index into _collectorsCache of current assignment
let _countdownInterval     = null;  // setInterval handle for UI countdown
let _countdownExpiry       = null;  // Date object when timer expires
let _assignmentListener    = null;  // Firestore onSnapshot unsubscribe fn
let _timeoutHandle         = null;  // setTimeout handle for 10-min auto-reassign

// ── Open Modal ────────────────────────────────────────────────────────────────
async function openAssignModal(row) {
    _assignTargetRow    = row;
    _assignDocId        = row.dataset.docId || null;
    _rejectedCollectors = [];
    _currentCollectorIdx = -1;
    _stopCountdown();
    _stopAssignmentListener();

    // Populate info label
    const reqId    = row.cells[0] ? row.cells[0].textContent.trim() : '-';
    const location = row.cells[1] ? row.cells[1].textContent.trim() : '-';
    const reqBy    = row.cells[3] ? row.cells[3].textContent.trim() : '-';
    const infoEl   = document.getElementById('assignModalRequestInfo');
    if (infoEl) infoEl.textContent = `Request: ${reqId}  ·  Location: ${location}  ·  By: ${reqBy}`;

    // Reset UI
    _resetModalUI();

    document.getElementById('assignModal').classList.remove('hidden');

    const select = document.getElementById('collectorSelect');
    select.innerHTML = '<option value="">— Loading nearby online collectors… —</option>';
    select.onchange = onCollectorSelectChange;

    try {
        // Fetch the Pickup Request to get its coordinates
        const reqDoc = await db.collection('pickupRequests').doc(_assignDocId).get();
        if (!reqDoc.exists) throw new Error("Request not found");
        const reqData = reqDoc.data();
        const reqLocation = (reqData.latitude && reqData.longitude) 
            ? { lat: Number(reqData.latitude), lng: Number(reqData.longitude) } 
            : (reqData.location || null);

        // Fetch collector profiles
        const collSnap = await db.collection('collectors').get();
        const collDataMap = {};
        collSnap.forEach(doc => { collDataMap[doc.id] = doc.data(); });

        _collectorsCache = [];

        // Try to get live locations
        let activeLocationsSnap = null;
        try {
            activeLocationsSnap = await db.collection('collectorLocations').get();
        } catch (locErr) {
            console.warn('[assignModal] Could not fetch collectorLocations:', locErr);
        }

        const processedIds = new Set();

        let dbgInfo = [];
        // First pass: collectors with live locations
        if (activeLocationsSnap && activeLocationsSnap.docs.length > 0) {
            for (let doc of activeLocationsSnap.docs) {
                try {
                    const locData = doc.data();
                    const collectorId = doc.id;
                    const cProfile = collDataMap[collectorId];
                    if (!cProfile) { dbgInfo.push(`Profile missing for ${collectorId}`); continue; }
                    
                    let busyTag = '';
                    if (cProfile.isBusy === true) { 
                        dbgInfo.push(`${cProfile.name} is Busy`);
                        busyTag = ' [BUSY]';
                    }

                    processedIds.add(collectorId);
                    const cLoc = { lat: Number(locData.latitude), lng: Number(locData.longitude) };
                    let distStr = '';
                    let isWithinRange = true;
                    if (reqLocation && cLoc.lat && cLoc.lng) {
                        const dist = _haversineKm(reqLocation, cLoc);
                        if (dist > 10) { isWithinRange = false; }
                        distStr = ` (${dist.toFixed(1)} km)`;
                    }
                        _collectorsCache.push({
                            id: collectorId,
                            name: (cProfile.name || cProfile.fullName || '-') + busyTag,
                            phone: cProfile.phone || cProfile.phone_number || '-',
                            city: cProfile.city || cProfile.zone || cProfile.location || '-',
                            rating: cProfile.rating !== undefined ? cProfile.rating : '-',
                            distStr: distStr,
                            isTooFar: !isWithinRange
                        });
                } catch (innerErr) {
                    console.warn('[assignModal] Skipping collector:', doc.id, innerErr);
                }
            }
        } else {
            dbgInfo.push(`No live locations found in DB`);
        }

        window._lastDbgInfo = dbgInfo;


        populateCollectorDropdown(select);
    } catch (err) {
        select.innerHTML = '<option value="">⚠ Failed to load collectors</option>';
        console.error('[assignModal collectors]', err);
    }
}

// ── Populate dropdown ─────────────────────────────────────────────────────────
function populateCollectorDropdown(select) {
    // Filter out already-rejected collectors
    const available = _collectorsCache.filter(c => !_rejectedCollectors.includes(c.id));
    if (available.length === 0) {
        let msg = window._lastDbgInfo && window._lastDbgInfo.length > 0
            ? "⚠ Debug: " + window._lastDbgInfo.join(" | ")
            : "— No collectors available (Check if app is tracking) —";
        select.innerHTML = `<option value="">${msg}</option>`;
        return;
    }
    select.innerHTML = '<option value="">— Select an online collector —</option>';
    available.forEach(c => {
        const opt = document.createElement('option');
        opt.value = c.id;
        
        if (c.isTooFar) {
            opt.textContent = `📍 ${c.name}${c.distStr} [Too Far]`;
            opt.disabled = true;
            opt.style.color = '#9ca3af'; 
        } else {
            opt.textContent = `🟢 ${c.name}${c.distStr}`;
        }
        
        select.appendChild(opt);
    });
}

// ── Collector info preview ────────────────────────────────────────────────────
function onCollectorSelectChange() {
    const select   = document.getElementById('collectorSelect');
    const infoCard = document.getElementById('selectedCollectorInfo');
    const chosen   = _collectorsCache.find(c => c.id === select.value);
    if (!infoCard) return;
    if (!select.value || !chosen) { infoCard.classList.add('hidden'); return; }
    infoCard.innerHTML =
        `<strong>👷 ${chosen.name}</strong>
         📞 ${chosen.phone} &nbsp;|&nbsp; 📍 ${chosen.city} &nbsp;|&nbsp; ⭐ ${chosen.rating}
         <br><span style="font-size:11px;color:#15803d;font-weight:600">🟢 Currently Online</span>`;
    infoCard.classList.remove('hidden');
}

// ── Close Modal ───────────────────────────────────────────────────────────────
function closeAssignModal() {
    _stopCountdown();
    _stopAssignmentListener();
    document.getElementById('assignModal').classList.add('hidden');
    _assignTargetRow     = null;
    _assignDocId         = null;
    _rejectedCollectors  = [];
    _currentCollectorIdx = -1;
}

// ── Confirm Assignment (first or manual retry) ────────────────────────────────
function confirmAssignCollector() {
    const select = document.getElementById('collectorSelect');
    const chosen = _collectorsCache.find(c => c.id === select.value);
    if (!chosen) { alert('⚠ Please select a collector first.'); return; }

    _currentCollectorIdx = _collectorsCache.indexOf(chosen);
    _sendAssignment(chosen);
}

// ── Try Next Collector (manual button) ───────────────────────────────────────
function tryNextCollector() {
    _stopCountdown();
    _stopAssignmentListener();

    const available = _collectorsCache.filter(c => !_rejectedCollectors.includes(c.id));
    if (available.length === 0) {
        _setStatusBadge('timed-out', '❌ No More Online Collectors Available');
        document.getElementById('tryNextCollectorBtn').classList.add('hidden');
        showToast('⚠ No more online collectors are available right now.');
        return;
    }

    // Fill dropdown with remaining collectors and let admin pick
    const select = document.getElementById('collectorSelect');
    populateCollectorDropdown(select);
    select.value = '';
    document.getElementById('selectedCollectorInfo').classList.add('hidden');
    document.getElementById('assignStatusPanel').classList.add('hidden');
    document.getElementById('confirmAssignBtn').classList.remove('hidden');
    document.getElementById('tryNextCollectorBtn').classList.add('hidden');
}

// ── Core: write Firestore docs + start timer ──────────────────────────────────
function _sendAssignment(collector) {
    const btn = document.getElementById('confirmAssignBtn');
    btn.disabled  = true;
    btn.textContent = 'Saving…';

    const now       = new Date();
    const expiresAt = new Date(now.getTime() + ASSIGN_TIMEOUT_MS);
    const rowData   = _assignTargetRow;

    const reqId    = rowData && rowData.cells[0] ? rowData.cells[0].textContent.trim() : '-';
    const location = rowData && rowData.cells[1] ? rowData.cells[1].textContent.trim() : '-';
    const wasteType= rowData && rowData.cells[2] ? rowData.cells[2].textContent.trim() : '-';
    const userName  = rowData && rowData.cells[3] ? rowData.cells[3].textContent.trim() : '-';

    // 1. Update pickupRequests
    const requestUpdate = _assignDocId
        ? db.collection('pickupRequests').doc(_assignDocId).update({
            collectorId:   collector.id,
            collectorName: collector.name,
            status:        'ASSIGNED',
            assignedAt:    now.toISOString()
          })
        : Promise.resolve();

    // 2. Write collectorAssign record (same collection the collector app listens to)
    const assignmentDoc = _assignDocId
        ? db.collection('collectorAssign').doc(_assignDocId).set({
            requestId:          reqId,
            requestDocId:       _assignDocId,
            collectorId:        collector.id,
            collectorName:      collector.name,
            status:             'awaiting_response',
            assignedBy:         'admin',
            city:               _assignTargetRow && _assignTargetRow.cells[1] ? _assignTargetRow.cells[1].textContent.trim() : '',
            address:            location,
            assignedAt:         now.toISOString(),
            expiresAt:          expiresAt.toISOString(),
            rejectedCollectors: _rejectedCollectors
          })
        : Promise.resolve();

    // 3. Write collector notification (mobile app reads this)
    const notifDoc = db.collection('collector_notifications')
        .doc(collector.id)
        .collection('notifications')
        .doc(_assignDocId || ('notif_' + Date.now()))
        .set({
            type:       'pickup_assignment',
            requestId:  reqId,
            requestDocId: _assignDocId || null,
            location:   location,
            wasteType:  wasteType,
            userName:   userName,
            message:    `You have been assigned pickup request ${reqId}. Please accept or reject within 10 minutes.`,
            status:     'unread',
            assignedAt: now.toISOString(),
            expiresAt:  expiresAt.toISOString(),
            createdAt:  now.toISOString()
        });

    Promise.all([requestUpdate, assignmentDoc, notifDoc])
        .then(() => {
            btn.disabled    = false;
            btn.textContent = '✅ Confirm Assignment';
            btn.classList.add('hidden');           // hide confirm btn while waiting
            document.getElementById('tryNextCollectorBtn').classList.add('hidden');

            // Show status panel
            document.getElementById('assignStatusPanel').classList.remove('hidden');
            document.getElementById('assignCollectorNameLabel').textContent =
                `Assigned to: ${collector.name} (${collector.city})`;
            _setStatusBadge('awaiting', '⏳ Awaiting Response');

            // Start countdown + Firestore listener
            _startCountdown(expiresAt);
            _watchAssignmentResponse(_assignDocId, collector);

            // Update table row immediately
            if (_assignTargetRow) {
                if (_assignTargetRow.cells[4]) _assignTargetRow.cells[4].textContent = collector.name;
                if (_assignTargetRow.cells[5]) _assignTargetRow.cells[5].innerHTML =
                    '<span class="status pending">assigned</span>';
            }
            showToast(`📨 ${collector.name} notified — waiting for response…`);
        })
        .catch(err => {
            btn.disabled    = false;
            btn.textContent = '✅ Confirm Assignment';
            console.error('[_sendAssignment]', err);
            alert('⚠ Failed to save assignment: ' + err.message);
        });
}

// ── Countdown timer ───────────────────────────────────────────────────────────
function _startCountdown(expiresAt) {
    _countdownExpiry = expiresAt;
    const totalMs    = ASSIGN_TIMEOUT_MS;
    
    const wrap = document.querySelector('.countdown-wrap');
    if (wrap) wrap.classList.remove('hidden');

    function tick() {
        const remaining = _countdownExpiry - Date.now();
        const timerEl   = document.getElementById('assignCountdown');
        const barEl     = document.getElementById('assignCountdownBar');
        if (!timerEl) return;

        if (remaining <= 0) {
            timerEl.textContent = '00:00';
            if (barEl) { barEl.style.width = '0%'; barEl.className = 'countdown-bar-fill critical'; }
            timerEl.className = 'countdown-timer critical';
            clearInterval(_countdownInterval);
            _countdownInterval = null;
            _handleAssignmentTimeout();
            return;
        }

        const mins = Math.floor(remaining / 60000);
        const secs = Math.floor((remaining % 60000) / 1000);
        timerEl.textContent = `${String(mins).padStart(2,'0')}:${String(secs).padStart(2,'0')}`;

        const pct = (remaining / totalMs) * 100;
        if (barEl) barEl.style.width = pct + '%';

        if (remaining < 2 * 60 * 1000) {          // < 2 min
            timerEl.className = 'countdown-timer critical';
            if (barEl) barEl.className = 'countdown-bar-fill critical';
        } else if (remaining < 5 * 60 * 1000) {   // < 5 min
            timerEl.className = 'countdown-timer warning';
            if (barEl) barEl.className = 'countdown-bar-fill warning';
        }
    }

    tick();
    _countdownInterval = setInterval(tick, 1000);
}

function _stopCountdown() {
    if (_countdownInterval) { clearInterval(_countdownInterval); _countdownInterval = null; }
    if (_timeoutHandle)     { clearTimeout(_timeoutHandle);      _timeoutHandle     = null; }
    
    const wrap = document.querySelector('.countdown-wrap');
    if (wrap) wrap.classList.add('hidden');
}

// ── Watch Firestore for collector response ────────────────────────────────────
function _watchAssignmentResponse(docId, collector) {
    if (!docId) return;
    _stopAssignmentListener();

    _assignmentListener = db.collection('collectorAssign').doc(docId)
        .onSnapshot(snap => {
            if (!snap.exists) return;
            const data   = snap.data();
            const status = (data.status || '').toLowerCase();

            if (status === 'accepted') {
                _stopCountdown();
                _stopAssignmentListener();
                _setStatusBadge('accepted', '✅ Accepted');
                document.getElementById('tryNextCollectorBtn').classList.add('hidden');

                // Update pickupRequests to 'assigned'
                if (docId) {
                    db.collection('pickupRequests').doc(docId).update({
                        status: 'assigned',
                        collectorId:   collector.id,
                        collectorName: collector.name
                    }).catch(e => console.warn('[accept update]', e));
                }

                // Update table row
                if (_assignTargetRow) {
                    if (_assignTargetRow.cells[4]) _assignTargetRow.cells[4].textContent = collector.name;
                    if (_assignTargetRow.cells[5]) _assignTargetRow.cells[5].innerHTML =
                        '<span class="status online">assigned</span>';
                }

                // ── Notify Admin: Collector Accepted ──
                _showAdminNotification('accepted',
                    `✅ ${collector.name} has accepted the assignment!`,
                    `Collector <strong>${collector.name}</strong> (${collector.city}) has accepted the pickup request. The assignment is now confirmed.`);
                showToast(`✅ ${collector.name} accepted the request!`);

                // Auto-close modal after 4 seconds (enough time to read notification)
                setTimeout(() => closeAssignModal(), 4000);

            } else if (status === 'rejected') {
                _stopCountdown();
                _stopAssignmentListener();
                _setStatusBadge('rejected', '❌ Rejected');
                _rejectedCollectors.push(collector.id);

                // ── Notify Admin: Collector Rejected ──
                const remaining = _collectorsCache.filter(c => !_rejectedCollectors.includes(c.id));
                const remainingMsg = remaining.length > 0
                    ? `There are <strong>${remaining.length}</strong> other collector(s) available. Use the <em>"🔄 Try Next Collector"</em> button to assign the next one.`
                    : `<strong>No other collectors</strong> are currently available. The request will be set back to pending.`;

                _showAdminNotification('rejected',
                    `❌ ${collector.name} has rejected the assignment`,
                    `Collector <strong>${collector.name}</strong> has rejected this pickup request. ` +
                    `They have been removed from the available list for this request.<br><br>${remainingMsg}`);
                showToast(`❌ ${collector.name} rejected the assignment`);

                // Update dropdown to exclude the rejected collector
                const select = document.getElementById('collectorSelect');
                populateCollectorDropdown(select);

                // Show "Try Next Collector" button if there are remaining collectors
                if (remaining.length > 0) {
                    document.getElementById('tryNextCollectorBtn').classList.remove('hidden');
                    document.getElementById('confirmAssignBtn').classList.remove('hidden');
                } else {
                    // No collectors left — reset request to pending
                    document.getElementById('tryNextCollectorBtn').classList.add('hidden');
                    if (_assignDocId) {
                        db.collection('pickupRequests').doc(_assignDocId).update({
                            status: 'pending',
                            collectorId:   null,
                            collectorName: null
                        }).catch(e => console.warn('[reset pending]', e));
                    }
                    if (_assignTargetRow && _assignTargetRow.cells[5]) {
                        _assignTargetRow.cells[5].innerHTML = '<span class="status pending">pending</span>';
                    }
                }
            }
        }, err => console.error('[watchAssignmentResponse]', err));
}

function _stopAssignmentListener() {
    if (_assignmentListener) { _assignmentListener(); _assignmentListener = null; }
}

// ── Handle timeout — notify admin and give manual control ─────────────────────
function _handleAssignmentTimeout() {
    _stopAssignmentListener();

    // Mark assignment as expired in Firestore
    if (_assignDocId) {
        db.collection('collectorAssign').doc(_assignDocId).update({
            status: 'timed_out'
        }).catch(e => console.warn('[timeout update]', e));
    }

    const currentCollector = _currentCollectorIdx >= 0 ? _collectorsCache[_currentCollectorIdx] : null;
    if (currentCollector) _rejectedCollectors.push(currentCollector.id);

    _setStatusBadge('timed-out', '⏰ Timed Out — No Response');

    const collectorName = currentCollector ? currentCollector.name : 'The assigned collector';
    const remaining = _collectorsCache.filter(c => !_rejectedCollectors.includes(c.id));
    const remainingMsg = remaining.length > 0
        ? `There are <strong>${remaining.length}</strong> other collector(s) available. Use the <em>"🔄 Try Next Collector"</em> button to assign the next one.`
        : `<strong>No other collectors</strong> are currently available. The request will be set back to pending.`;

    _showAdminNotification('rejected',
        `⏰ ${collectorName} did not respond within 10 minutes`,
        `${collectorName} failed to respond to the assignment in time. ` +
        `They have been removed from the available list for this request.<br><br>${remainingMsg}`);
    showToast(`⏰ ${collectorName} did not respond`);

    // Update dropdown and show Try Next button
    const select = document.getElementById('collectorSelect');
    populateCollectorDropdown(select);

    if (remaining.length > 0) {
        document.getElementById('tryNextCollectorBtn').classList.remove('hidden');
        document.getElementById('confirmAssignBtn').classList.remove('hidden');
    } else {
        document.getElementById('tryNextCollectorBtn').classList.add('hidden');
        if (_assignDocId) {
            db.collection('pickupRequests').doc(_assignDocId).update({
                status: 'pending',
                collectorId:   null,
                collectorName: null
            }).catch(e => console.warn('[reset pending]', e));
        }
        if (_assignTargetRow && _assignTargetRow.cells[5]) {
            _assignTargetRow.cells[5].innerHTML = '<span class="status pending">pending</span>';
        }
    }
}

// ── Auto-reassign to next available online collector ──────────────────────────
function _autoReassign() {
    const available = _collectorsCache.filter(c => !_rejectedCollectors.includes(c.id));

    if (available.length === 0) {
        _setStatusBadge('timed-out', '❌ No More Online Collectors');
        showToast('⚠ All online collectors unavailable. Please try manually later.');
        document.getElementById('tryNextCollectorBtn').classList.add('hidden');
        // Reset request status back to pending
        if (_assignDocId) {
            db.collection('pickupRequests').doc(_assignDocId).update({
                status: 'pending',
                collectorId:   null,
                collectorName: null
            }).catch(e => console.warn('[reset pending]', e));
        }
        if (_assignTargetRow && _assignTargetRow.cells[5]) {
            _assignTargetRow.cells[5].innerHTML = '<span class="status pending">pending</span>';
        }
        return;
    }

    const next = available[0];
    _currentCollectorIdx = _collectorsCache.indexOf(next);

    // Update status panel for new collector
    document.getElementById('assignCollectorNameLabel').textContent =
        `Now trying: ${next.name} (${next.city})`;
    _setStatusBadge('awaiting', '⏳ Awaiting Response');
    document.getElementById('assignCountdown').className = 'countdown-timer';
    const barEl = document.getElementById('assignCountdownBar');
    if (barEl) { barEl.style.width = '100%'; barEl.className = 'countdown-bar-fill'; }

    showToast(`📨 Trying ${next.name}…`);
    _sendAssignment(next);
}

// ── Helper: update status badge ───────────────────────────────────────────────
function _setStatusBadge(state, text) {
    const el = document.getElementById('assignStatusLabel');
    if (!el) return;
    el.className = `assign-status-badge ${state}`;
    el.textContent = text;
}

// ── Helper: reset modal to initial state ──────────────────────────────────────
function _resetModalUI() {
    const infoCard    = document.getElementById('selectedCollectorInfo');
    const statusPanel = document.getElementById('assignStatusPanel');
    const confirmBtn  = document.getElementById('confirmAssignBtn');
    const nextBtn     = document.getElementById('tryNextCollectorBtn');

    if (infoCard)    { infoCard.innerHTML = ''; infoCard.classList.add('hidden'); }
    if (statusPanel) statusPanel.classList.add('hidden');
    if (confirmBtn)  { confirmBtn.classList.remove('hidden'); confirmBtn.disabled = false; confirmBtn.textContent = '✅ Confirm Assignment'; }
    if (nextBtn)     nextBtn.classList.add('hidden');

    const timerEl = document.getElementById('assignCountdown');
    const barEl   = document.getElementById('assignCountdownBar');
    if (timerEl) { timerEl.textContent = '10:00'; timerEl.className = 'countdown-timer'; }
    if (barEl)   { barEl.style.width = '100%'; barEl.className = 'countdown-bar-fill'; }

    // Clear any admin notification
    const notifEl = document.getElementById('adminAssignNotification');
    if (notifEl) { notifEl.innerHTML = ''; notifEl.classList.add('hidden'); }
}

// ── Admin Notification inside the Assign Modal ───────────────────────────────
function _showAdminNotification(type, title, message) {
    let notifEl = document.getElementById('adminAssignNotification');
    if (!notifEl) {
        // Create the notification element if it doesn't exist
        notifEl = document.createElement('div');
        notifEl.id = 'adminAssignNotification';
        const statusPanel = document.getElementById('assignStatusPanel');
        if (statusPanel) statusPanel.parentNode.insertBefore(notifEl, statusPanel.nextSibling);
    }

    const isAccepted = type === 'accepted';
    const bgColor    = isAccepted ? '#f0fdf4' : '#fef2f2';
    const borderColor = isAccepted ? '#10b981' : '#ef4444';
    const iconColor  = isAccepted ? '#059669' : '#dc2626';
    const icon       = isAccepted ? '🎉' : '⚠️';

    notifEl.className = 'admin-assign-notification';
    notifEl.style.cssText = [
        `background:${bgColor}`,
        `border:2px solid ${borderColor}`,
        'border-radius:12px',
        'padding:16px 18px',
        'margin-top:14px',
        'animation:slideDown 0.4s ease'
    ].join(';');

    notifEl.innerHTML = `
        <div style="display:flex;align-items:flex-start;gap:10px">
            <span style="font-size:24px">${icon}</span>
            <div>
                <div style="font-weight:700;font-size:15px;color:${iconColor};margin-bottom:4px">
                    ${title}
                </div>
                <div style="font-size:13px;color:#374151;line-height:1.5">
                    ${message}
                </div>
            </div>
        </div>`;

    notifEl.classList.remove('hidden');
}

/** Lightweight toast notification */
function showToast(msg) {
    let toast = document.getElementById('_adminToast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = '_adminToast';
        toast.style.cssText = [
            'position:fixed', 'bottom:28px', 'right:28px',
            'background:#21421e', 'color:#fff', 'padding:12px 20px',
            'border-radius:12px', 'font-size:14px', 'font-weight:600',
            'box-shadow:0 8px 24px rgba(0,0,0,.25)', 'z-index:2000',
            'transition:opacity .4s ease'
        ].join(';');
        document.body.appendChild(toast);
    }
    toast.textContent = msg;
    toast.style.opacity = '1';
    clearTimeout(toast._timer);
    toast._timer = setTimeout(() => { toast.style.opacity = '0'; }, 4000);
}