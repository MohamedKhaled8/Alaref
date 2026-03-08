import 'package:flutter/material.dart';
import 'package:alaref/features/auth/domain/entities/user_entity.dart';

class StageDropdown extends StatefulWidget {
  final Function(AcademicStage?) onSelected;
  final AcademicStage? selectedStage;

  const StageDropdown({
    super.key,
    required this.onSelected,
    this.selectedStage,
  });

  @override
  State<StageDropdown> createState() => _StageDropdownState();
}

class _StageDropdownState extends State<StageDropdown>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  String _getStageName(AcademicStage stage) {
    switch (stage) {
      case AcademicStage.primary:
        return 'الأبتدائية';
      case AcademicStage.preparatory:
        return 'الأعدادية';
      case AcademicStage.secondary:
        return 'الثانوية';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختار المرحلة',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1363DF),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isExpanded
                    ? const Color(0xFF1363DF)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedStage == null
                      ? 'اختر المرحلة الدراسية'
                      : _getStageName(widget.selectedStage!),
                  style: TextStyle(
                    fontSize: 15,
                    color: widget.selectedStage == null
                        ? Colors.grey[400]
                        : Colors.black87,
                    fontWeight: widget.selectedStage == null
                        ? FontWeight.w400
                        : FontWeight.w500,
                  ),
                ),
                RotationTransition(
                  turns: _rotateAnimation,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF1363DF),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: AcademicStage.values.map((stage) {
                final isSelected = widget.selectedStage == stage;
                return _StageOption(
                  label: _getStageName(stage),
                  isSelected: isSelected,
                  onTap: () {
                    widget.onSelected(stage);
                    _toggleExpanded();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _StageOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_StageOption> createState() => _StageOptionState();
}

class _StageOptionState extends State<_StageOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color(0xFF1363DF).withOpacity(0.1)
              : _isHovered
              ? Colors.grey[50]
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 4,
              height: widget.isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF1363DF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: widget.isSelected
                    ? const Color(0xFF1363DF)
                    : Colors.black87,
              ),
            ),
            const Spacer(),
            if (widget.isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1363DF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
