import 'package:flutter/material.dart';
import '../Service/couple_activity_service.dart';
import '../Service/blocked_users_service.dart';
// Note: blocked_users_model.dart is used internally by BlockedUsersService

class CoupleActivityScreen extends StatefulWidget {
  const CoupleActivityScreen({super.key});

  @override
  State<CoupleActivityScreen> createState() => _CoupleActivityScreenState();
}

class _CoupleActivityScreenState extends State<CoupleActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  String? _error;

  List<CoupleActivityRequest> _requests = [];
  int _requestsCurrentPage = 1;
  int _requestsLastPage = 1;
  bool _isLoadingMoreRequests = false;
  int _pendingReceivedCount = 0;

  Partnership? _partnership;
  bool _isLoadingPartnership = true;

  List<CoupleActivityHistoryItem> _history = [];
  int _historyCurrentPage = 1;
  int _historyLastPage = 1;
  bool _isLoadingMoreHistory = false;

  List<BlockedUser> _blockedUsers = [];
  int _blockedCurrentPage = 1;
  int _blockedLastPage = 1;
  bool _isLoadingMoreBlocked = false;

  bool _isPerformingAction = false;
  int? _actionRequestId;
  int? _actionUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          if (_requests.isEmpty && !_isLoading) _loadRequests();
          break;
        case 1:
          if (_partnership == null && !_isLoadingPartnership) _loadPartnership();
          break;
        case 2:
          if (_history.isEmpty) _loadHistory();
          break;
        case 3:
          if (_blockedUsers.isEmpty) _loadBlockedUsers();
          break;
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        CoupleActivityService.getRequests(page: 1),
        CoupleActivityService.getPartnership(),
      ]);

      final requestsResponse = results[0] as CoupleActivityRequestsResponse;
      final partnershipResponse = results[1] as PartnershipResponse;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingPartnership = false;

          if (requestsResponse.success) {
            _requests = requestsResponse.data;
            _requestsCurrentPage = requestsResponse.pagination?.currentPage ?? 1;
            _requestsLastPage = requestsResponse.pagination?.lastPage ?? 1;
            _updatePendingCount();
          }

          if (partnershipResponse.success) {
            _partnership = partnershipResponse.data;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingPartnership = false;
          _error = 'Failed to load data. Please try again.';
        });
      }
    }
  }

  void _updatePendingCount() {
    _pendingReceivedCount = _requests.where((r) => r.status == 'pending').length;
  }

  Future<void> _loadRequests({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMoreRequests || _requestsCurrentPage >= _requestsLastPage) return;
      setState(() => _isLoadingMoreRequests = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final page = loadMore ? _requestsCurrentPage + 1 : 1;
      final response = await CoupleActivityService.getRequests(page: page);

      if (mounted) {
        setState(() {
          if (loadMore) {
            _isLoadingMoreRequests = false;
            if (response.success) {
              _requests.addAll(response.data);
              _requestsCurrentPage = response.pagination?.currentPage ?? _requestsCurrentPage;
              _requestsLastPage = response.pagination?.lastPage ?? _requestsLastPage;
            }
          } else {
            _isLoading = false;
            if (response.success) {
              _requests = response.data;
              _requestsCurrentPage = response.pagination?.currentPage ?? 1;
              _requestsLastPage = response.pagination?.lastPage ?? 1;
              _updatePendingCount();
            } else {
              _error = response.message;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (loadMore) {
            _isLoadingMoreRequests = false;
          } else {
            _isLoading = false;
            _error = 'Failed to load requests.';
          }
        });
      }
    }
  }

  Future<void> _loadPartnership() async {
    setState(() => _isLoadingPartnership = true);

    try {
      final response = await CoupleActivityService.getPartnership();

      if (mounted) {
        setState(() {
          _isLoadingPartnership = false;
          if (response.success) {
            _partnership = response.data;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPartnership = false);
      }
    }
  }

  Future<void> _loadHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMoreHistory || _historyCurrentPage >= _historyLastPage) return;
      setState(() => _isLoadingMoreHistory = true);
    }

    try {
      final page = loadMore ? _historyCurrentPage + 1 : 1;
      final response = await CoupleActivityService.getHistory(page: page);

      if (mounted) {
        setState(() {
          _isLoadingMoreHistory = false;
          if (response.success) {
            if (loadMore) {
              _history.addAll(response.data);
            } else {
              _history = response.data;
            }
            _historyCurrentPage = response.pagination?.currentPage ?? 1;
            _historyLastPage = response.pagination?.lastPage ?? 1;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMoreHistory = false);
      }
    }
  }

  // FIX: Using BlockedUsersService.getBlockedUsers() instead of removed CoupleActivityService.getBlockedUsers()
  // API endpoint: GET /chat/blocked-users (Section 11.3)
  // Note: This API doesn't support pagination, so loadMore is ignored
  Future<void> _loadBlockedUsers({bool loadMore = false}) async {
    // Skip if already loading or trying to load more (API doesn't support pagination)
    if (_isLoadingMoreBlocked) return;
    if (loadMore) return; // API doesn't support pagination
    
    setState(() => _isLoadingMoreBlocked = true);

    try {
      final response = await BlockedUsersService.getBlockedUsers();

      if (mounted) {
        setState(() {
          _isLoadingMoreBlocked = false;
          if (response != null && response.success) {
            // Convert BlockedUsersModel.BlockedUser to CoupleActivityService.BlockedUser format
            _blockedUsers = response.data.map((blockedUserModel) {
              return BlockedUser(
                id: blockedUserModel.id,
                blockedUserId: blockedUserModel.blockedUserId,
                blockedAt: blockedUserModel.blockedOn,
                user: CoupleActivityUser(
                  id: blockedUserModel.blockedUserId,
                  name: blockedUserModel.name,
                  email: blockedUserModel.email,
                  profilePhoto: blockedUserModel.profilePicture,
                ),
              );
            }).toList();
            // No pagination from this API
            _blockedCurrentPage = 1;
            _blockedLastPage = 1;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMoreBlocked = false);
      }
    }
  }


  Future<void> _acceptRequest(CoupleActivityRequest request) async {
    setState(() {
      _isPerformingAction = true;
      _actionRequestId = request.id;
    });

    try {
      final response = await CoupleActivityService.acceptRequest(request.id);

      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionRequestId = null;
        });

        if (response.success) {
          _showSnackBar('Request accepted successfully!', isError: false);
          _loadRequests();
          _loadPartnership();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionRequestId = null;
        });
        _showSnackBar('Failed to accept request.', isError: true);
      }
    }
  }

  Future<void> _rejectRequest(CoupleActivityRequest request) async {
    final confirmed = await _showConfirmDialog(
      title: 'Reject Request',
      message: 'Are you sure you want to reject this request from ${request.sender?.name ?? 'this user'}?',
      confirmText: 'Reject',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isPerformingAction = true;
      _actionRequestId = request.id;
    });

    try {
      final response = await CoupleActivityService.rejectRequest(request.id);

      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionRequestId = null;
        });

        if (response.success) {
          _showSnackBar('Request rejected.', isError: false);
          _loadRequests();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionRequestId = null;
        });
        _showSnackBar('Failed to reject request.', isError: true);
      }
    }
  }

  Future<void> _cancelRequest(CoupleActivityRequest request) async {
    final confirmed = await _showConfirmDialog(
      title: 'Cancel Request',
      message: 'Are you sure you want to cancel your request to ${request.receiver?.name ?? 'this user'}?',
      confirmText: 'Cancel Request',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isPerformingAction = true;
      _actionRequestId = request.id;
    });

    try {
      final response = await CoupleActivityService.cancelRequest(request.id);

      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionRequestId = null;
        });

        if (response.success) {
          _showSnackBar('Request cancelled.', isError: false);
          _loadRequests();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionRequestId = null;
        });
        _showSnackBar('Failed to cancel request.', isError: true);
      }
    }
  }

  Future<void> _endPartnership() async {
    if (_partnership == null) return;

    final confirmed = await _showConfirmDialog(
      title: 'End Partnership',
      message: 'Are you sure you want to end your partnership with ${_partnership!.partner?.name ?? 'your partner'}? This action cannot be undone.',
      confirmText: 'End Partnership',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _isPerformingAction = true);

    try {
      final response = await CoupleActivityService.endPartnership();

      if (mounted) {
        setState(() => _isPerformingAction = false);

        if (response.success) {
          _showSnackBar('Partnership ended.', isError: false);
          setState(() => _partnership = null);
          _loadHistory();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPerformingAction = false);
        _showSnackBar('Failed to end partnership.', isError: true);
      }
    }
  }

  Future<void> _blockUser(CoupleActivityUser user) async {
    final confirmed = await _showConfirmDialog(
      title: 'Block User',
      message: 'Are you sure you want to block ${user.name ?? 'this user'}? They won\'t be able to send you couple activity requests.',
      confirmText: 'Block',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isPerformingAction = true;
      _actionUserId = user.id;
    });

    try {
      final response = await CoupleActivityService.blockUser(user.id);

      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionUserId = null;
        });

        if (response.success) {
          _showSnackBar('User blocked.', isError: false);
          _loadRequests();
          _loadBlockedUsers();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionUserId = null;
        });
        _showSnackBar('Failed to block user.', isError: true);
      }
    }
  }

  Future<void> _unblockUser(BlockedUser blockedUser) async {
    final confirmed = await _showConfirmDialog(
      title: 'Unblock User',
      message: 'Are you sure you want to unblock ${blockedUser.user?.name ?? 'this user'}?',
      confirmText: 'Unblock',
      isDestructive: false,
    );

    if (confirmed != true) return;

    setState(() {
      _isPerformingAction = true;
      _actionUserId = blockedUser.blockedUserId;
    });

    try {
      final response = await CoupleActivityService.unblockUser(blockedUser.blockedUserId);

      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionUserId = null;
        });

        if (response.success) {
          _showSnackBar('User unblocked.', isError: false);
          _loadBlockedUsers();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
          _actionUserId = null;
        });
        _showSnackBar('Failed to unblock user.', isError: true);
      }
    }
  }

  Future<void> _sendRequest() async {
    final userId = await _showSendRequestDialog();
    if (userId == null) return;

    setState(() => _isPerformingAction = true);

    try {
      final response = await CoupleActivityService.sendRequest(userId);

      if (mounted) {
        setState(() => _isPerformingAction = false);

        if (response.success) {
          _showSnackBar('Request sent successfully!', isError: false);
          _loadRequests();
        } else {
          _showSnackBar(response.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPerformingAction = false);
        _showSnackBar('Failed to send request.', isError: true);
      }
    }
  }


  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<int?> _showSendRequestDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Couple Activity Request'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the User ID of the person you want to send a couple activity request to.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText: 'Enter user ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a user ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, int.parse(controller.text));
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetailsDialog(CoupleActivityRequest request) {
    final isReceived = request.receiver != null;
    final otherUser = isReceived ? request.sender : request.receiver;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (otherUser != null) ...[
                _buildUserInfoSection(otherUser, isReceived ? 'From' : 'To'),
                const Divider(height: 24),
              ],

              _buildDetailRow('Request ID', '#${request.id}'),
              _buildDetailRow('Status', _getStatusText(request.status)),
              if (request.createdAt != null)
                _buildDetailRow('Sent', _formatDate(request.createdAt!)),
              if (request.updatedAt != null && request.status != 'pending')
                _buildDetailRow('Updated', _formatDate(request.updatedAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (request.status == 'pending') ...[
            if (isReceived) ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _rejectRequest(request);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _acceptRequest(request);
                },
                child: const Text('Accept'),
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelRequest(request);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Cancel Request'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(CoupleActivityUser user, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: user.profilePhoto != null
                  ? NetworkImage(user.profilePhoto!)
                  : null,
              child: user.profilePhoto == null
                  ? Text(
                      (user.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'Unknown User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (user.age != null || user.gender != null)
                    Text(
                      [
                        if (user.age != null) '${user.age} years',
                        if (user.gender != null) user.gender,
                      ].join(' • '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  if (user.city != null)
                    Text(
                      user.city!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  if (user.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          user.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getHistoryIcon(String type, String action) {
    switch (type.toLowerCase()) {
      case 'request':
        if (action == 'sent') return Icons.send;
        if (action == 'received') return Icons.inbox;
        if (action == 'accepted') return Icons.check_circle;
        if (action == 'rejected') return Icons.cancel;
        return Icons.swap_horiz;
      case 'partnership':
        if (action == 'started') return Icons.favorite;
        if (action == 'ended') return Icons.heart_broken;
        return Icons.people;
      case 'booking':
        return Icons.calendar_today;
      default:
        return Icons.history;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Couple Activity'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isSmallScreen,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Requests'),
                  if (_pendingReceivedCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_pendingReceivedCount',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Partnership'),
            const Tab(text: 'History'),
            const Tab(text: 'Blocked'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildPartnershipTab(),
          _buildHistoryTab(),
          _buildBlockedTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _isPerformingAction ? null : _sendRequest,
              icon: _isPerformingAction
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add),
              label: const Text('Send Request'),
            )
          : null,
    );
  }


  Widget _buildRequestsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Couple Activity Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a request to start a couple activity partnership',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length + (_requestsCurrentPage < _requestsLastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _requests.length) {
            return _buildLoadMoreButton(
              isLoading: _isLoadingMoreRequests,
              onPressed: () => _loadRequests(loadMore: true),
            );
          }
          return _buildRequestCard(_requests[index]);
        },
      ),
    );
  }

  Widget _buildRequestCard(CoupleActivityRequest request) {
    final isReceived = request.receiver != null;
    final otherUser = isReceived ? request.sender : request.receiver;
    final statusColor = _getStatusColor(request.status);
    final isActionInProgress = _isPerformingAction && _actionRequestId == request.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRequestDetailsDialog(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: otherUser?.profilePhoto != null
                        ? NetworkImage(otherUser!.profilePhoto!)
                        : null,
                    child: otherUser?.profilePhoto == null
                        ? Text(
                            (otherUser?.name ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 18),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isReceived ? Icons.call_received : Icons.call_made,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isReceived ? 'Received from' : 'Sent to',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          otherUser?.name ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (otherUser?.city != null)
                          Text(
                            otherUser!.city!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(request.status),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(request.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (request.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatDate(request.createdAt!),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],

              if (request.status == 'pending') ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isReceived) ...[
                      TextButton(
                        onPressed: isActionInProgress ? null : () => _rejectRequest(request),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isActionInProgress ? null : () => _acceptRequest(request),
                        child: isActionInProgress
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Accept'),
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: isActionInProgress ? null : () => _cancelRequest(request),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: isActionInProgress
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Cancel Request'),
                      ),
                    ],
                    if (otherUser != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'block') {
                            _blockUser(otherUser);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                Icon(Icons.block, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Block User'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPartnershipTab() {
    if (_isLoadingPartnership) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_partnership == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Active Partnership',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accept a couple activity request to start a partnership',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('View Requests'),
            ),
          ],
        ),
      );
    }

    final partner = _partnership!.partner;

    return RefreshIndicator(
      onRefresh: _loadPartnership,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: partner?.profilePhoto != null
                          ? NetworkImage(partner!.profilePhoto!)
                          : null,
                      child: partner?.profilePhoto == null
                          ? Text(
                              (partner?.name ?? 'P')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 36),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      partner?.name ?? 'Your Partner',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (partner != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (partner.age != null) '${partner.age} years',
                          if (partner.gender != null) partner.gender,
                          if (partner.city != null) partner.city,
                        ].join(' • '),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (partner.rating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              partner.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          icon: Icons.calendar_today,
                          value: _partnership!.startedAt != null
                              ? _formatDate(_partnership!.startedAt!)
                              : 'N/A',
                          label: 'Started',
                        ),
                        _buildStatItem(
                          icon: Icons.event_available,
                          value: '${_partnership!.totalBookings ?? 0}',
                          label: 'Bookings',
                        ),
                        _buildStatItem(
                          icon: Icons.attach_money,
                          value: '\$${(_partnership!.totalEarnings ?? 0).toStringAsFixed(0)}',
                          label: 'Earnings',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    OutlinedButton.icon(
                      onPressed: _isPerformingAction ? null : _endPartnership,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: _isPerformingAction
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(Icons.heart_broken),
                      label: const Text('End Partnership'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  Widget _buildHistoryTab() {
    if (_history.isEmpty && !_isLoadingMoreHistory) {
      _loadHistory();
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Activity History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your couple activity history will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length + (_historyCurrentPage < _historyLastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _history.length) {
            return _buildLoadMoreButton(
              isLoading: _isLoadingMoreHistory,
              onPressed: () => _loadHistory(loadMore: true),
            );
          }
          return _buildHistoryItem(_history[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(CoupleActivityHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(
            _getHistoryIcon(item.type, item.action),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          item.description ?? '${item.type} - ${item.action}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.relatedUser != null)
              Text(
                'with ${item.relatedUser!.name ?? 'Unknown User'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            if (item.createdAt != null)
              Text(
                _formatDate(item.createdAt!),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        isThreeLine: item.relatedUser != null,
      ),
    );
  }


  Widget _buildBlockedTab() {
    if (_blockedUsers.isEmpty && !_isLoadingMoreBlocked) {
      _loadBlockedUsers();
      return const Center(child: CircularProgressIndicator());
    }

    if (_blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Blocked Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Users you block will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBlockedUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blockedUsers.length + (_blockedCurrentPage < _blockedLastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _blockedUsers.length) {
            return _buildLoadMoreButton(
              isLoading: _isLoadingMoreBlocked,
              onPressed: () => _loadBlockedUsers(loadMore: true),
            );
          }
          return _buildBlockedUserCard(_blockedUsers[index]);
        },
      ),
    );
  }

  Widget _buildBlockedUserCard(BlockedUser blockedUser) {
    final user = blockedUser.user;
    final isUnblocking = _isPerformingAction && _actionUserId == blockedUser.blockedUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user?.profilePhoto != null
              ? NetworkImage(user!.profilePhoto!)
              : null,
          child: user?.profilePhoto == null
              ? Text(
                  (user?.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 18),
                )
              : null,
        ),
        title: Text(
          user?.name ?? 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: blockedUser.blockedAt != null
            ? Text(
                'Blocked ${_formatDate(blockedUser.blockedAt!)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              )
            : null,
        trailing: TextButton(
          onPressed: isUnblocking ? null : () => _unblockUser(blockedUser),
          child: isUnblocking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Unblock'),
        ),
      ),
    );
  }


  Widget _buildLoadMoreButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.expand_more),
                label: const Text('Load More'),
              ),
      ),
    );
  }
}
