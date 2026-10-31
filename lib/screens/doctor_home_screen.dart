import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/app/app_localization.dart';
import 'package:erx/app/app_theme.dart';
import 'package:erx/screens/new_prescription_screen.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/utils/toast.dart';
import 'package:erx/widgets/drawers/doctor_drawer.dart';
import 'package:erx/widgets/prescription_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final _nameStream = FirebaseFirestore.instance
        .collection("doctor")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .snapshots();
    final _prescriptionStream = FirebaseFirestore.instance
        .collection("prescription")
        .where(
          "doctorID",
          isEqualTo: FirebaseAuth.instance.currentUser!.phoneNumber,
        )
        .snapshots();
    final _searchController = TextEditingController();

    final f = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: colors.secondaryColor,
      drawer: const DoctorDrawer(),
      body: Stack(
        children: [
          SvgPicture.string(
            SvgStrings.homeScreenBackground,
            width: MediaQuery.of(context).size.width,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Extra padding
                const SizedBox(height: 20),
                // Top logo/menu/profile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // menu
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Scaffold.of(context).openDrawer(),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                height: 25,
                                width: 25,
                                child: SvgPicture.string(
                                  SvgStrings.hamburger,
                                  colorFilter: ColorFilter.mode(
                                    colors.textDefaultColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 5),
                              Transform.rotate(
                                angle: 8 * 22 / 7 / 180,
                                child: SvgPicture.string(
                                  SvgStrings.logoE,
                                  height: 38,
                                  // colorFilter: ColorFilter.mode(
                                  //   colors.textDefaultColor,
                                  //   BlendMode.srcIn,
                                  // ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "wasfa",
                            style: GoogleFonts.nunito(
                              color: colors.textDefaultColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      // Profile
                      GestureDetector(
                        onTap: () {
                          // Navigator.pop(context);
                          // Add navigation logic here
                        },
                        child: SizedBox(
                          height: 38,
                          width: 38,
                          child: SvgPicture.string(SvgStrings.profile),
                        ),
                      ),
                    ],
                  ),
                ),
                // Greatings
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _nameStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: 30,
                          start: 25,
                        ),
                        child: Text(
                          // "Hello Dr. ${(snapshot.data!.data()!['name'] as String).split(" ")[0]}!",
                          "${AppLocalization.of(context)!.getTranslatedValues('hello_dr') ?? 'Hello Dr'} ${(snapshot.data!.data()!['name'] as String).split(" ")[0]}!",
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: 30,
                          start: 25,
                        ),
                        child: Text(
                          AppLocalization.of(context)!
                                  .getTranslatedValues('hello') ??
                              'Hello!',
                          style: GoogleFonts.notoKufiArabic(
                            color: colors.textDefaultColor,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 5, start: 25),
                  child: Text(
                    AppLocalization.of(context)!
                            .getTranslatedValues('great_day') ??
                        "Hope you have a great day!",
                    style: GoogleFonts.notoKufiArabic(
                      color: colors.textDefaultColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Body
                Expanded(
                  child: Stack(
                    children: [
                      // Main content
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(34),
                            topRight: Radius.circular(34),
                          ),
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(34),
                                topRight: Radius.circular(34),
                              ),
                              color: colors.primaryColor,
                            ),
                            child:
                                StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: _prescriptionStream,
                                  builder:
                                      (
                                        context,
                                        AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>
                                        >
                                        snapshot,
                                      ) {
                                        if (snapshot.hasData) {
                                          return ListView.builder(
                                            itemCount:
                                                snapshot.data!.docs.length + 1,
                                            itemBuilder: (context, index) {
                                              if (index == 0) {
                                                return const SizedBox(
                                                  height: 50,
                                                );
                                              }
                                              return PrescriptionCard(
                                                prescriptionId: snapshot
                                                    .data!
                                                    .docs[index - 1]
                                                    .id,
                                                hospitalName:
                                                    snapshot
                                                            .data!
                                                            .docs[index - 1]
                                                            .data()['hospital']
                                                        as String,
                                                prescriptionDate: f.format(
                                                  (snapshot
                                                              .data!
                                                              .docs[index - 1]
                                                              .data()['dateTime']
                                                          as Timestamp)
                                                      .toDate(),
                                                ),
                                                followUpDate:
                                                    snapshot
                                                            .data!
                                                            .docs[index - 1]
                                                            .data()['followUp']
                                                        as String?,
                                                patientName:
                                                    (snapshot
                                                                .data!
                                                                .docs[index - 1]
                                                                .data()['patient']
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >)['name']
                                                        as String,
                                              );
                                            },
                                          );
                                        } else {
                                          return Center(
                                            child: SizedBox(
                                              height: 35,
                                              width: 35,
                                              child: CircularProgressIndicator(
                                                color: colors.territoryColor,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                ),
                          ),
                        ),
                      ),
                      // Search  box
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: colors.secondaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: colors.territoryColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.string(
                                SvgStrings.search,
                                colorFilter: ColorFilter.mode(
                                  colors.textLightColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: TextField(
                                  textInputAction: TextInputAction.done,
                                  controller: _searchController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    hintText:
                                        AppLocalization.of(context)!
                                            .getTranslatedValues(
                                              'search_prescription',
                                            ) ??
                                        'Search for prescription',
                                    hintStyle: GoogleFonts.notoKufiArabic(
                                      fontSize: 16,
                                      color: colors.textDefaultColor,
                                    ),
                                  ),
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: colors.textDefaultColor,
                                  ),
                                  cursorColor: colors.textDefaultColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colors.secondaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Hospitals",
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: colors.textDefaultColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Invitations",
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: colors.textDefaultColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const NewPrescriptionScreen();
                                  },
                                ),
                              );
                            },
                            backgroundColor: colors.territoryColor,
                            shape: const CircleBorder(),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
