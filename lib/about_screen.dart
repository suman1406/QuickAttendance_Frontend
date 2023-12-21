import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          Theme.of(context).colorScheme.brightness == Brightness.dark
              ? Colors.black
              : Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar.large(
            backgroundColor:
                Theme.of(context).colorScheme.brightness == Brightness.dark
                    ? Colors.black
                    : Theme.of(context).colorScheme.background,
            floating: false,
            pinned: true,
            snap: false,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(0, 0, 5, 10),
              centerTitle: true,
              title: Text(
                "About",
                style: GoogleFonts.raleway(
                  textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            ),
          ),

          // rest of the UI
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    // border: Border.all(color: const Color(0xffA6C8FF)),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromRGBO(27, 28, 28, 1)
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      const CircleAvatar(
                        foregroundImage: AssetImage(
                          "assets/icon.png",
                        ),
                        radius: 64.0,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Quick Attendance",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Version 1.0.0",
                        style: GoogleFonts.raleway(
                          textStyle: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  "Team",
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: () {
                    launchUrl(
                      Uri.parse("https://github.com/suman1406"),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          foregroundImage: AssetImage(
                            "assets/dev_image.jpeg",
                          ),
                          radius: 32.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Suman Panigrahi",
                              style: GoogleFonts.raleway(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                            ),
                            Text(
                              "Amrita Vishwa Vidyapeetham",
                              style: GoogleFonts.raleway(
                                textStyle: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer),
                              ),
                            ),
                            Text(
                              "Coimbatore, Tamil Nadu",
                              style: GoogleFonts.raleway(
                                textStyle: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                            ),
                            Chip(
                              padding: const EdgeInsets.all(1),
                              backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Theme.of(context).colorScheme.background,
                              elevation: 3,
                              label: Text(
                                "Full Stack Developer",
                                style: GoogleFonts.raleway(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: () {
                    launchUrl(
                      Uri.parse(
                          "https://www.linkedin.com/in/thanus-kumaar/"),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          foregroundImage: AssetImage(
                            "assets/dev2_image.jpeg",
                          ),
                          radius: 32.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Thanus Kumaara",
                              style: GoogleFonts.raleway(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                            ),
                            Text(
                              "Amrita Vishwa Vidyapeetham",
                              style: GoogleFonts.raleway(
                                textStyle: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer),
                              ),
                            ),
                            Text(
                              "Coimbatore, Tamil Nadu",
                              style: GoogleFonts.raleway(
                                textStyle: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              ),
                            ),
                            Chip(
                              padding: const EdgeInsets.all(1),
                              backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Theme.of(context).colorScheme.background,
                              elevation: 3,
                              label: Text(
                                "Backend Developer",
                                style: GoogleFonts.raleway(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
