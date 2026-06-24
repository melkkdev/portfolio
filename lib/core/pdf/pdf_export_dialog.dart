import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../common/modal_styles.dart';
import '../theme/app_theme.dart';
import '../../data/portfolio_state.dart';
import 'portfolio_pdf_builder.dart';

Future<void> showPortfolioPdfPreview(
  BuildContext context,
  PortfolioState state,
) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _PortfolioPdfPreviewDialog(state: state),
  );
}

class _PortfolioPdfPreviewDialog extends StatefulWidget {
  final PortfolioState state;

  const _PortfolioPdfPreviewDialog({required this.state});

  @override
  State<_PortfolioPdfPreviewDialog> createState() =>
      _PortfolioPdfPreviewDialogState();
}

class _PortfolioPdfPreviewDialogState
    extends State<_PortfolioPdfPreviewDialog> {
  Uint8List? _pdfBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    // 다이얼로그가 첫 프레임을 렌더링하고 인디케이터가 보일 시간을 확보한다.
    // doc.addPage() / doc.save()는 동기 블로킹이므로 이 await 이후에 시작한다.
    await Future.delayed(const Duration(milliseconds: 80));
    try {
      final bytes = await PortfolioPdfBuilder.build(widget.state);
      if (mounted) setState(() => _pdfBytes = bytes);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width * 0.9).clamp(0.0, 760.0);
    final dialogHeight = (screenSize.height * 0.9).clamp(0.0, 860.0);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ModalStyles.radius),
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ModalStyles.radius),
          topRight: Radius.circular(ModalStyles.radius),
        ),
      ),
      padding: ModalStyles.headerPadding,
      child: Row(
        children: [
          const Expanded(
            child: Text('포트폴리오 PDF 미리보기', style: ModalStyles.headerTitle),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'PDF 생성에 실패했습니다.\n$_errorMessage',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_pdfBytes == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'PDF를 생성 중입니다…',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // 이미 생성된 bytes를 그대로 반환 — format 재빌드 불필요하므로 canChangePageFormat: false
    return PdfPreview(
      build: (_) => Future.value(Uint8List.fromList(_pdfBytes!)),
      pdfFileName: '${widget.state.profile.name}_portfolio.pdf',
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowSharing: !kIsWeb,
    );
  }
}
