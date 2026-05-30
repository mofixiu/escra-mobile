import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/high_contrast_button.dart';

/// State-of-the-art high-fidelity Contact Support Hub.
/// Contains FAQs, simulated Live Chat, and dynamic Support Ticket generation.
class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inquiryCtrl = TextEditingController();
  
  String _issueType = 'Payment & Payouts';
  bool _isSubmittingTicket = false;

  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How long does escrow validation take?',
      'a': 'Escrow funds are locked instantly. Once the buyer enters the delivery confirmation code, the release executes in real-time.',
      'expanded': false
    },
    {
      'q': 'What happens if a dispute is opened?',
      'a': 'The locked transaction funds are frozen securely in the vault. The ESCRA Trust team will mediate the dispute within 24-48 hours.',
      'expanded': false
    },
    {
      'q': 'Are credit card payment methods secure?',
      'a': 'Yes, all linked cards undergo dynamic authorization checks and details are vaulted securely with bank-grade encryption.',
      'expanded': false
    },
  ];

  @override
  void dispose() {
    _inquiryCtrl.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmittingTicket = true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isSubmittingTicket = false);
      _inquiryCtrl.clear();

      final ticketId = 'ESC-SUP-${1000 + (3829 * (0.1 + (0.8 * (DateTime.now().millisecond / 1000)))).toInt()}';

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  'Ticket Created',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your support ticket has been registered in the ESCRA system successfully.',
                  style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TICKET ID:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.secondary),
                      ),
                      Text(
                        ticketId,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('DISMISS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    });
  }

  void _openLiveChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LiveChatBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contact Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // HERO CARD HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 48, color: Colors.black),
                  const SizedBox(height: 16),
                  const Text(
                    'Need help with an order?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connect with our automated terminal or live support dispatchers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  HighContrastButton(
                    text: 'START LIVE CHAT',
                    icon: Icons.chat_bubble_outline_rounded,
                    onPressed: _openLiveChat,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // SECTION 1: EXPANDABLE FAQs
            _buildSectionHeader('FREQUENTLY ASKED QUESTIONS'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(_faqs.length, (i) {
                  final faq = _faqs[i];
                  final expanded = faq['expanded'] as bool;
                  return Column(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            faq['q'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black),
                          ),
                          iconColor: Colors.black,
                          collapsedIconColor: Colors.black54,
                          trailing: Icon(
                            expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          onExpansionChanged: (val) {
                            setState(() {
                              faq['expanded'] = val;
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq['a'] as String,
                                style: const TextStyle(fontSize: 12, color: AppColors.secondary, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i != _faqs.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 28),

            // SECTION 2: DISPATCH TICKET FORM
            _buildSectionHeader('SUBMIT AN OFFICE TICKET'),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: _buildCardGroup([
                _buildLabel('INQUIRY ISSUE SECTOR'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _issueType,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      menuMaxHeight: 300,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                      items: const [
                        DropdownMenuItem(value: 'Payment & Payouts', child: Text('Payment & Payouts')),
                        DropdownMenuItem(value: 'Order Dispute', child: Text('Order Dispute Mediation')),
                        DropdownMenuItem(value: 'Identity/KYC Verification', child: Text('Identity & KYC Onboarding')),
                        DropdownMenuItem(value: 'Security / PIN reset', child: Text('Vault PIN & Security Locks')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _issueType = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('DETAILED INQUIRY DESCRIPTION'),
                TextFormField(
                  controller: _inquiryCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
                  decoration: _inputDecoration('Please describe your issue or question in detail...'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Please write your inquiry' : null,
                ),
                const SizedBox(height: 24),
                if (_isSubmittingTicket)
                  const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                else
                  HighContrastButton(
                    text: 'REGISTER SUPPORT TICKET',
                    icon: Icons.send_rounded,
                    onPressed: _submitTicket,
                  ),
              ]),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.secondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: AppColors.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
    );
  }
}

/// Simulated Live Chat terminal bottom-sheet popup.
class _LiveChatBottomSheet extends StatefulWidget {
  const _LiveChatBottomSheet();

  @override
  State<_LiveChatBottomSheet> createState() => _LiveChatBottomSheetState();
}

class _LiveChatBottomSheetState extends State<_LiveChatBottomSheet> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! Welcome to ESCRA Live Assistance. How can we secure your digital transaction experiences today?',
      'isBot': true,
      'time': 'Just now',
    }
  ];
  
  bool _isTypingResponse = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageCtrl.text.trim().isEmpty) return;

    final userMessage = _messageCtrl.text.trim();
    _messageCtrl.clear();

    setState(() {
      _messages.add({
        'text': userMessage,
        'isBot': false,
        'time': 'Just now',
      });
      _isTypingResponse = true;
    });

    _scrollToBottom();

    // Simulated Bot dynamic reply delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTypingResponse = false;
        
        String response = 'Understood. We are verifying details. A support specialist is examining your transaction logs.';
        if (userMessage.toLowerCase().contains('pay') || userMessage.toLowerCase().contains('payout') || userMessage.toLowerCase().contains('vault')) {
          response = 'ESCRA payouts are resolved immediately upon code confirmation. If access or verification delays persist, please submit an inquiry ticket.';
        } else if (userMessage.toLowerCase().contains('dispute')) {
          response = 'When disputes open, funds freeze securely. An arbitrator will mediate between parties in 24-48 hours.';
        }

        _messages.add({
          'text': response,
          'isBot': true,
          'time': 'Just now',
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Chat Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESCRA Secure Terminal Support',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Automated Assistant • Live Status',
                          style: TextStyle(fontSize: 10, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isBot = msg['isBot'] as bool;
                  return Align(
                    alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isBot ? const Color(0xFFF1F1F1) : Colors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isBot ? 0 : 16),
                          bottomRight: Radius.circular(isBot ? 16 : 0),
                        ),
                      ),
                      child: Text(
                        msg['text'] as String,
                        style: TextStyle(
                          color: isBot ? Colors.black87 : Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Typing Indicator
            if (_isTypingResponse)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'ESCRA support is typing...',
                      style: TextStyle(fontSize: 11, color: AppColors.secondary, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

            // Input Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _messageCtrl,
                          style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Enter inquiry message...',
                            hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: _sendMessage,
                      ),
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
}
