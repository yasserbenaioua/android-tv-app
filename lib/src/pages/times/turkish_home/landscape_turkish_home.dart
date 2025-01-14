import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/footer.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/times/widgets/jumua_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

class LandScapeTurkishHome extends StatelessWidget {
  const LandScapeTurkishHome({super.key});

  String salahName(int index) {
    switch (index) {
      case 0:
        return S.current.sabah;
      case 1:
        return S.current.duhr;
      case 2:
        return S.current.asr;
      case 3:
        return S.current.maghrib;
      case 4:
        return S.current.isha;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final today = mosqueManager.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();

    final times = mosqueManager.times!.dayTimesStrings(today, salahOnly: false);
    final iqamas = mosqueManager.times!.dayIqamaStrings(today);

    final isIqamaMoreImportant = mosqueManager.mosqueConfig!.iqamaMoreImportant == true;
    final iqamaEnabled = mosqueManager.mosqueConfig?.iqamaEnabled == true;

    final nextActiveSalah = mosqueManager.nextSalahIndex();

    return Column( 
      children: [
        MosqueHeader(mosque: mosqueManager.mosque!),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: SalahItemWidget(
                    title: S.of(context).sabah,
                    time: times[1],
                    removeBackground: true,
                    showIqama: iqamaEnabled,
                    withDivider: true,
                    isIqamaMoreImportant: isIqamaMoreImportant,
                    active: nextActiveSalah == 0,
                    iqama: iqamas[0],
                  ).animate().slideX().fade(),
                ),
              ),
              Expanded(child: HomeTimeWidget().animate().slideY().fade(), flex: 2), 
              Expanded(child: Center(child: JumuaWidget().animate().slideX(begin: 1).fade())),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.vw),
            child: Row(
              children: [
                /// imsak tile
                SalahItemWidget(
                  title: S.of(context).imsak,
                  time: times[0],
                  withDivider: false,
                  iqama: '',
                  showIqama: iqamaEnabled,
                  isIqamaMoreImportant: isIqamaMoreImportant,
                ),

                /// shuruk tile
                SalahItemWidget(
                  title: S.of(context).shuruk,
                  time: times[2],
                  withDivider: false,
                  iqama: '',
                  showIqama: iqamaEnabled,
                  isIqamaMoreImportant: isIqamaMoreImportant,
                ),

                /// duhr tile
                SalahItemWidget(
                  title: salahName(1),
                  time: times[3],
                  isIqamaMoreImportant: isIqamaMoreImportant,
                  active: nextActiveSalah == 1 && (!AppDateTime.isFriday || mosqueManager.times?.jumua == null),
                  iqama: iqamas[1],
                  showIqama: iqamaEnabled,
                  withDivider: false,
                ),
                for (var i = 2; i < 5; i++)
                  SalahItemWidget(
                    title: salahName(i),
                    time: times[i + 2],
                    isIqamaMoreImportant: isIqamaMoreImportant,
                    active: nextActiveSalah == i,
                    iqama: iqamas[i],
                    showIqama: iqamaEnabled,
                    withDivider: false,
                  ),
              ]
                  .mapIndexed((i, e) => Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.vw),
                        child: e.animate(delay: Duration(milliseconds: 100 * i)).slideY(begin: 1).fade(),
                      )))
                  .toList(),
            ),
          ),
        ),
        Footer().animate().slideY(begin: 1).fade(),
      ],
    );
  }
}
