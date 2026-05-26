import 'package:flutter/material.dart';

/// A premium, interactive numeric security PIN pad matching the light theme design.
/// Supports both bottom-sheet mode (with handle) and inline mode (with square boxes).
class CustomPinPad extends StatefulWidget {
  final String title;
  final String subtitle;
  final ValueChanged<String> onComplete;
  final VoidCallback? onCancel;
  final bool isInline;
  final int pinLength;

  const CustomPinPad({
    super.key,
    required this.onComplete,
    this.onCancel,
    this.title = 'Authorize Funding',
    this.subtitle = 'Enter your PIN to authorize escrow funding of ₦125,000.',
    this.isInline = false,
    this.pinLength = 4,
  });

  @override
  State<CustomPinPad> createState() => _CustomPinPadState();
}

class _CustomPinPadState extends State<CustomPinPad> {
  String _pin = '';

  void _onKeyTap(String key) {
    if (_pin.length < widget.pinLength) {
      setState(() {
        _pin += key;
      });
      if (_pin.length == widget.pinLength) {
        Future.delayed(const Duration(milliseconds: 150), () {
          widget.onComplete(_pin);
        });
      }
    }
  }

  void _onDeleteTap() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: widget.isInline ? 0 : 12, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: widget.isInline
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!widget.isInline) ...[
            // Drag Handle
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Icon Box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.black87),
                  SizedBox(width: 4),
                  Icon(Icons.person, size: 14, color: Colors.black87),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Title & Subtitle
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          if (widget.isInline) ...[
            const Text(
              'ENTER 4-DIGIT SECURE PIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Security Indicators (Dots or Squares)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pinLength, (index) {
              final isFilled = index < _pin.length;
              if (widget.isInline) {
                // Square boxes for inline
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 56,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: isFilled ? Colors.black : Colors.black12, width: 1),
                  ),
                  child: Center(
                    child: isFilled
                        ? const Text('•', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black))
                        : null,
                  ),
                );
              } else {
                // Circular dots for bottom sheet
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? Colors.black : Colors.transparent,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                );
              }
            }),
          ),
          
          if (!widget.isInline) ...[
            const SizedBox(height: 40),
            const Divider(color: Colors.black12, height: 1),
          ],
          
          const SizedBox(height: 24),

          // Numeric Layout Grid
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              children: [
                _buildRow(['1', '2', '3']),
                const SizedBox(height: 16),
                _buildRow(['4', '5', '6']),
                const SizedBox(height: 16),
                _buildRow(['7', '8', '9']),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 72, height: 72), // Empty space
                    _buildNumberButton('0'),
                    _buildActionButton(Icons.backspace_outlined, _onDeleteTap),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) => _buildNumberButton(key)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyTap(number),
        customBorder: const CircleBorder(),
        splashColor: Colors.black.withValues(alpha: 0.05),
        highlightColor: Colors.black.withValues(alpha: 0.02),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: Colors.black.withValues(alpha: 0.05),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
