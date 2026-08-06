import 'package:flutter/widgets.dart' show Widget;

import '../bottom_sheet/mentora_bottom_sheet_host.dart';
import '../bottom_sheet/mentora_bottom_sheet_service.dart';
import '../dialog/mentora_dialog_host.dart';
import '../dialog/mentora_dialog_service.dart';
import '../snackbar/mentora_snackbar_host.dart';
import '../snackbar/mentora_snackbar_service.dart';

/// The single truth about the temporary layers of Mentora.
///
/// The official order is a meaning, not a preference: what must be
/// answered stands above what accompanies, which stands above what
/// merely passes. Every container that carries layers reads that order
/// here — it is never restated, and never reordered.
///
/// A host is mounted ONLY when its service is given. Given none, the
/// layers already installed by the application keep serving: nothing
/// is ever recreated.
Widget mountOfficialLayers({
  required Widget child,
  MentoraDialogService? dialogs,
  MentoraBottomSheetService? sheets,
  MentoraSnackbarService? messages,
}) {
  var assembled = child;
  if (messages != null) {
    assembled = MentoraSnackbarHost(service: messages, child: assembled);
  }
  if (sheets != null) {
    assembled = MentoraBottomSheetHost(service: sheets, child: assembled);
  }
  if (dialogs != null) {
    assembled = MentoraDialogHost(service: dialogs, child: assembled);
  }
  return assembled;
}
