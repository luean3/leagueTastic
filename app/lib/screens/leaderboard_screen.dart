import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/map_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = [
      {"name": "Nico", "time": "12:34"},
      {"name": "Lukas", "time": "13:02"},
      {"name": "Anna", "time": "13:45"},
      {"name": "Tom", "time": "14:10"},
    ];

    // only for testing!
    String polylineString = "ki{eFvqfiVqAWQIGEEKAYJgBVqDJ{BHa@jAkNJw@Pw@V{APs@^aABQAOEQGKoJ_FuJkFqAo@{A}@sH{DiAs@Q]?WVy@`@oBt@_CB]KYMMkB{AQEI@WT{BlE{@zAQPI@ICsCqA_BcAeCmAaFmCqIoEcLeG}KcG}A}@cDaBiDsByAkAuBqBi@y@_@o@o@kB}BgIoA_EUkAMcACa@BeBBq@LaAJe@b@uA`@_AdBcD`@iAPq@RgALqAB{@EqAyAoOCy@AmCBmANqBLqAZkB\\iCPiBJwCCsASiCq@iD]eA]y@[i@w@mAa@i@k@g@kAw@i@Ya@Q]EWFMLa@~BYpAFNpA`Aj@n@X`@V`AHh@JfB@xAMvAGZGHIDIAWOEQNcC@sACYK[MSOMe@QKKKYOs@UYQISCQ?Q@WNo@r@OHGAGCKOQ_BU}@MQGG]Io@@c@FYNg@d@s@d@ODQAMOMaASs@_@a@SESAQDqBn@a@RO?KK?UBU\\kA@Y?WMo@Iy@GWQ_@WSSGg@AkABQB_Ap@_A^o@b@Q@o@IS@OHi@n@OFS?OI}@iAQMQGQC}@DOIIUK{@IUOMyBo@kASOKIQCa@L[|AgATWN[He@?QKw@FOPCh@Fx@l@TDLELKl@aAHIJEX@r@ZTDV@LENQVg@RkA@c@MeA?WFOPMf@Ej@Fj@@LGHKDM?_@_@iC?a@HKRIl@NT?FCHMFW?YEYGWQa@GYBiAIq@Gq@L_BHSHK|@WJETSLQZs@z@_A~@uA^U`@G\\CRB\\Tl@p@Th@JZ^bB`@lAHLXVLDP?LGFSKiDBo@d@wBVi@R]VYVE\\@`@Lh@Fh@CzAk@RSDQA]GYe@eAGWSiBAWBWBIJORK`@KPOPSTg@h@}Ad@o@F[E_@EGMKUGmAEYGMIMYKs@?a@J}@@_BD_@HQJMx@e@LKHKHWAo@UoAAWFmAH}@?w@C[YwAAc@HSNM|Ao@rA}@zAq@`@a@j@eAxAuBXQj@MXSR[b@gAFg@?YISOGaAHi@Xw@v@_@d@WRSFqARUHQJc@d@m@`A[VSFUBcAEU@WFULUPa@v@Y~@UrBc@dBI~@?l@P~ABt@N`HEjA]zAEp@@p@TrBCl@CTQb@k@dAg@jAU^KJYLK@k@A[Js@d@a@b@]RgBl@[FMAw@[]G]?m@D_@F]P[Vu@t@[TMF_@Do@E_@@q@P]PWZUZw@vAkAlAGJOj@IlAMd@OR{@p@a@d@sBpD]v@a@`Aa@n@]TODgBVk@Pe@^cBfBc@Rs@La@RSPm@|@wCpDS^Wp@QZML{@l@qBbCYd@k@lAIVCZBZNTr@`@RRHZANIZQPKDW@e@CaASU?I@YTKRQx@@\\VmALYRQLCL?v@P|@D\\GJEFKDM@OCa@COOYIGm@YMUCM@]JYr@uAx@kAt@}@jAeAPWbAkBj@s@bAiAz@oAj@m@VQlAc@VQ~@aA`Au@p@Q`AIv@MZORUV_@p@iB|AoCh@q@dAaANUNWH[N{AJ[^m@t@_Av@wA\\a@`@W`@In@Al@B^E`@Wl@u@\\[VQ\\K`@Eb@?R@dAZP@d@CRExAs@\\Yt@{@LG\\MjAATINOXo@d@kAl@_AHYBOCe@QiBCm@Fq@\\wADo@AyGEeBWuB@YHu@Tu@Lk@VcCTo@d@aA\\WJE`@G~@FP?VI\\U~@sANO`@SfAMj@U\\WjAsAXS`@UNENALBHFFL?^Ml@Uj@]b@q@RUJSPkChEc@XcAb@sA|@]PaA\\OJKNER?TDTNj@Jn@?p@OfC@ZR`B@VCV_@n@{@l@WbACv@OlABnAPl@LNNHbBBNBLFFJ@^GLg@x@i@|AMP[X}@XOJKPET?l@LhAFXp@fBDRCd@S\\_@Ps@PQ@}A]S?QDe@V]b@MR[fAKt@ErAF~CANILYDKGIKe@{@Yy@e@sB[gA[c@e@YUCU?WBUHUNQPq@`AiArAMV[^e@Zc@JQJKNMz@?r@Bb@PfAAfA@VVbADn@E`@KHSEe@SMAKDKFM\\^dDCh@m@LoAQ_@@MFOZLfBEl@QbASd@KLQBOAaAc@QAQ@QHc@v@ONMJOBOCg@c@]O[EMBKFGL?RHv@ARERGNe@h@{@h@WVGNDt@JLNFPFz@LdBf@f@PJNHPF`ADPJJJDl@I`@B^Tp@bALJNDNALIf@i@PGPCt@DNE`@Uv@[dAw@RITGRCtAARBPJLPJRZxB?VEX_@vAAR?RDNHJJBh@UnBm@h@IRDRJNNJPNbBFRJLLBLCzAmAd@Uf@Gf@?P@PFJNHPFTH`BDTHNJJJ@LG`@m@^YPER@RDPHNNJRLn@HRLN^VNPHTFX@\\UlDFb@FHh@NP@HKPsB?}ASkCQ{@[y@q@}@cA{@KOCQDa@t@{CFGJCf@Nl@ZtA~@r@p@`@h@rAxBd@rA\\fARdAPjANrB?f@AtBCd@QfBkAjJOlBChA?rBFrBNlBdAfKFzAC~@Iz@Mz@Sv@s@jBmAxBi@hAWt@Sv@Qx@O`BA`@?dAPfBVpAd@`BfBlFf@fBdA~Cr@pAz@fApBhBjAt@H?IL?FBFJLx@^lHvDvh@~XnElCbAd@pGhDbAb@nAr@`Ad@`GhDnBbAxCbBrWhNJJDPARGP_@t@Qh@]pAUtAoA`Ny@jJApBBNFLJFJBv@Hb@HBF?\\";
    //String polylineString = "";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                "Leaderboard",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Aktuelles Segment",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 300, // Give the map a constrained height if it's inside a scrollable column
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.hardEdge, // Keeps the map corners rounded
              child: StravaMapWidget(encodedPolyline: polylineString),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "#${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(user["name"]!),
                        ),
                        Text(user["time"]!),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}