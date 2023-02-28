import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/FlashAnimation.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class IqamaSubScreen extends StatefulWidget {
  const IqamaSubScreen({Key? key, this.onDone}) : super(key: key);

  final VoidCallback? onDone;

  @override
  State<IqamaSubScreen> createState() => _IqamaSubScreenState();
}

class _IqamaSubScreenState extends State<IqamaSubScreen> {
  AudioManager? audioManager;
  late final minimumDelay;

  closeIqamaScreen() async {
    await minimumDelay;
    widget.onDone?.call();
  }

  @override
  void initState() {
    final mosqueManager = context.read<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig!;

    minimumDelay = Future.delayed(
      Duration(seconds: mosqueConfig.iqamaDisplayTime ?? 30),
    );

    if (mosqueConfig.iqamaBip) {
      audioManager = context.read<AudioManager>();
      audioManager!.loadAndPlayIqamaBipVoice(
        mosqueManager.mosqueConfig,
        onDone: closeIqamaScreen,
      );
    } else {
      closeIqamaScreen();
    }
    super.initState();
  }

  @override
  void dispose() {
    audioManager?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              height: 30.vh,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 4.vw),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment(0, 0),
                  end: Alignment(0, 1),
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0),
                  ],
                ),
              ),
              child: Text(
                tr.alIqama,
                style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: kAfterAdhanTextShadow,
                    fontFamily:
                        StringManager.getFontFamilyByString(tr.alIqama)),
              ),
            ).animate().slide(begin: Offset(0, -1)).fade().addRepaintBoundary(),
          ),
        ),
        Expanded(
          child: FlashAnimation(
            child: SvgPicture.asset(R.ASSETS_SVG_NO_PHONE_SVG),
          ).animate().scale(delay: .2.seconds).addRepaintBoundary(),
        ),
        Text(
          tr.turnOfPhones,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 4.vw,
            color: Colors.white,
            fontFamily: StringManager.getFontFamilyByString(tr.turnOfPhones),
            shadows: kAfterAdhanTextShadow,
          ),
        ).animate().slide(begin: Offset(0, 1)).fade().addRepaintBoundary(),
        SizedBox(height: 50),
      ],
    );
  }
}