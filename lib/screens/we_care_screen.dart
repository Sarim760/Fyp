import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WeCareScreen extends StatefulWidget {
  const WeCareScreen({super.key});

  @override
  State<WeCareScreen> createState() => _WeCareScreenState();
}

class _WeCareScreenState extends State<WeCareScreen> {
  final Map<String, bool> _expandedCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Plant Wiki',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 174, 234, 176),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Tap on any plant to see detailed care information',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Apple
              _buildPlantCard(
                plantId: 'apple',
                title: "Apple",
                scientificName: "Malus domestica",
                image:
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTc9TEidg9H12W_Pgo0xVJsGpH27MXy8ZtNfA&sb",
                description:
                    "Deciduous trees in the rose family (Rosaceae) cultivated for their pomaceous fruits...",
                growingInfo: {
                  'Climate': 'Temperate (USDA zones 3-8)',
                  'Soil': 'Well-drained loam, pH 6.0-6.5',
                  'Sun Exposure': 'Full sun (6+ hours daily)',
                },
                careTips: [
                  'Plant at least two compatible varieties',
                  'Prune annually in late winter',
                  'Thin fruits to 6-8" apart',
                ],
                problems: [
                  'Diseases: Apple scab, fire blight',
                  'Pests: Codling moth, aphids',
                ],
              ),

              const SizedBox(height: 15),

              // Blueberry
              _buildPlantCard(
                plantId: 'blueberry',
                title: "Blueberry",
                scientificName: "Vaccinium spp.",
                image:
                    "https://cdn.dotpe.in/longtail/store-items/7694466/fK00c558.jpeg",
                description:
                    "Perennial shrubs in the heath family (Ericaceae) producing antioxidant-rich berries...",
                growingInfo: {
                  'Climate': 'Zones 4-9 (varies by type)',
                  'Soil': 'pH 4.0-5.2, high organic matter',
                  'Sun Exposure': 'Full sun to partial shade',
                },
                careTips: [
                  'Amend soil with peat moss',
                  'Mulch with pine needles',
                  'Prune old canes annually',
                ],
                problems: [
                  'Diseases: Mummy berry, root rot',
                  'Pests: Spotted wing drosophila',
                ],
              ),

              const SizedBox(height: 15),

              // Cherry
              _buildPlantCard(
                plantId: 'cherry',
                title: "Cherry",
                scientificName: "Prunus avium/cerasus",
                image:
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRv3nYb-NnRFXlMh1oS_fVDKZ6NFw_0c4jrVQ&s",
                description:
                    "Stone fruits including sweet cherries (P. avium) and sour cherries (P. cerasus)...",
                growingInfo: {
                  'Climate': 'Zones 4-9 (sweet), 4-6 (sour)',
                  'Soil': 'Well-drained, pH 6.0-7.5',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Plant on slopes for cold air drainage',
                  'Use tree guards for protection',
                  'Net trees before harvest',
                ],
                problems: [
                  'Diseases: Brown rot, bacterial canker',
                  'Pests: Cherry fruit fly, aphids',
                ],
              ),

              const SizedBox(height: 15),

              // Corn
              _buildPlantCard(
                plantId: 'corn',
                title: "Corn",
                scientificName: "Zea mays",
                image:
                    "https://images.unsplash.com/photo-1554402100-8d1d9f3dff80?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                description:
                    "A warm-season cereal grain in the grass family (Poaceae)...",
                growingInfo: {
                  'Climate': 'Warm season (60-95°F ideal)',
                  'Soil': 'Well-drained, pH 5.8-7.0',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Plant in blocks for pollination',
                  'Side-dress with nitrogen',
                  'Control weeds early',
                ],
                problems: [
                  'Diseases: Rust, smut',
                  'Pests: Corn earworm, cutworms',
                ],
              ),

              const SizedBox(height: 15),

              // Grape
              _buildPlantCard(
                plantId: 'grape',
                title: "Grape",
                scientificName: "Vitis spp.",
                image:
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLiRbTcC3yLOUjai8Wqxd8nWf65KavGXtlSQ&s",
                description:
                    "Woody vines in the Vitaceae family, including European (V. vinifera)...",
                growingInfo: {
                  'Climate': 'Zones 4-10 (varies by type)',
                  'Soil': 'Well-drained, pH 5.5-7.0',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Prune heavily in dormancy',
                  'Train to a trellis system',
                  'Net vines when fruit colors',
                ],
                problems: [
                  'Diseases: Powdery mildew',
                  'Pests: Japanese beetles',
                ],
              ),

              const SizedBox(height: 15),

              // Orange
              _buildPlantCard(
                plantId: 'orange',
                title: "Orange",
                scientificName: "Citrus × sinensis",
                image:
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwgWJozD_WBqv9pJmG5DB11RrnVQ37Sv1XwqWAbGoJN0qOX2-s91Kn5uCep7pHA3bBaIY&usqp=CAU",
                description:
                    "Evergreen trees in the Rutaceae family, producing sweet citrus fruits...",
                growingInfo: {
                  'Climate': 'Zones 9-11',
                  'Soil': 'Well-drained, pH 6.0-7.5',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Plant in south-facing locations',
                  'Mulch to conserve moisture',
                  'Protect from frost',
                ],
                problems: [
                  'Diseases: Citrus greening',
                  'Pests: Asian citrus psyllid',
                ],
              ),

              const SizedBox(height: 15),

              // Peach
              _buildPlantCard(
                plantId: 'peach',
                title: "Peach",
                scientificName: "Prunus persica",
                image:
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtKibIpI79a1ZMOEWWxXHGjfYf8tnanbf5Yw&s",
                description:
                    "Deciduous stone fruit trees producing juicy, aromatic fruits...",
                growingInfo: {
                  'Climate': 'Zones 5-9',
                  'Soil': 'Well-drained, pH 6.0-7.0',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Thin fruits to 6-8" apart',
                  'Prune to open center',
                  'Harvest when color changes',
                ],
                problems: [
                  'Diseases: Peach leaf curl',
                  'Pests: Peach tree borer',
                ],
              ),

              const SizedBox(height: 15),

              // Bell Pepper
              _buildPlantCard(
                plantId: 'bell_pepper',
                title: "Bell Pepper",
                scientificName: "Capsicum annuum",
                image:
                    "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83",
                description:
                    "Warm-season vegetables in the nightshade family (Solanaceae)...",
                growingInfo: {
                  'Climate': 'Warm (70-85°F ideal)',
                  'Soil': 'Well-drained, pH 6.0-6.8',
                  'Sun Exposure': 'Full sun (6+ hours)',
                },
                careTips: [
                  'Start seeds indoors',
                  'Use black plastic mulch',
                  'Support plants with cages',
                ],
                problems: [
                  'Diseases: Bacterial spot',
                  'Pests: Aphids, flea beetles',
                ],
              ),

              const SizedBox(height: 15),

              // Potato
              _buildPlantCard(
                plantId: 'potato',
                title: "Potato",
                scientificName: "Solanum tuberosum",
                image:
                    "https://eastforkgrowing.com/wp-content/uploads/2024/12/how-to-plant-potatoes-8.jpg",
                description: "Cool-season tubers in the nightshade family...",
                growingInfo: {
                  'Climate': 'Cool (60-70°F ideal)',
                  'Soil': 'Loose, well-drained, pH 5.0-6.5',
                  'Sun Exposure': 'Full sun (6+ hours)',
                },
                careTips: [
                  'Plant certified seed potatoes',
                  'Hill soil around stems',
                  'Water evenly',
                ],
                problems: [
                  'Diseases: Late blight, scab',
                  'Pests: Colorado potato beetle',
                ],
              ),

              const SizedBox(height: 15),

              // Raspberry
              _buildPlantCard(
                plantId: 'raspberry',
                title: "Raspberry",
                scientificName: "Rubus idaeus",
                image:
                    "https://images.squarespace-cdn.com/content/v1/60ee3b567e50b2469e302668/1630138883886-TS3T3RB5OBWA2S3R2IOO/upload?format=2500w",
                description: "Perennial brambles producing aggregate fruits...",
                growingInfo: {
                  'Climate': 'Zones 3-9',
                  'Soil': 'Well-drained, pH 5.5-6.5',
                  'Sun Exposure': 'Full sun (6+ hours)',
                },
                careTips: [
                  'Plant in raised beds',
                  'Prune after fruiting',
                  'Mulch to control weeds',
                ],
                problems: [
                  'Diseases: Verticillium wilt',
                  'Pests: Japanese beetles',
                ],
              ),

              const SizedBox(height: 15),

              // Soybean
              _buildPlantCard(
                plantId: 'soybean',
                title: "Soybean",
                scientificName: "Glycine max",
                image:
                    "https://static.vecteezy.com/system/resources/thumbnails/035/943/236/small_2x/soybean-pods-on-the-plant-close-up-view-close-up-of-soybean-plants-in-field-free-video.jpg",
                description: "Annual legumes grown for protein-rich beans...",
                growingInfo: {
                  'Climate': 'Warm season',
                  'Soil': 'Well-drained, pH 6.0-6.8',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Inoculate seeds',
                  'Plant when soil is warm',
                  'Rotate with non-legumes',
                ],
                problems: [
                  'Diseases: Soybean cyst nematode',
                  'Pests: Bean leaf beetle',
                ],
              ),

              const SizedBox(height: 15),

              // Squash
              _buildPlantCard(
                plantId: 'squash',
                title: "Squash",
                scientificName: "Cucurbita spp.",
                image:
                    "https://images.unsplash.com/photo-1601493700631-2b16ec4b4716",
                description:
                    "Warm-season vines including summer and winter types...",
                growingInfo: {
                  'Climate': 'Warm (70-95°F ideal)',
                  'Soil': 'Rich, well-drained, pH 6.0-6.8',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Direct seed after soil warms',
                  'Hand pollinate if needed',
                  'Harvest summer squash young',
                ],
                problems: [
                  'Diseases: Powdery mildew',
                  'Pests: Squash vine borer',
                ],
              ),

              const SizedBox(height: 15),

              // Strawberry
              _buildPlantCard(
                plantId: 'strawberry',
                title: "Strawberry",
                scientificName: "Fragaria × ananassa",
                image:
                    "https://images.unsplash.com/photo-1464965911861-746a04b4bca6",
                description:
                    "Herbaceous perennials producing aggregate fruits...",
                growingInfo: {
                  'Climate': 'Zones 3-10',
                  'Soil': 'Well-drained, pH 5.5-6.5',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Plant in raised beds',
                  'Use straw mulch',
                  'Renovate June-bearing plants',
                ],
                problems: [
                  'Diseases: Verticillium wilt',
                  'Pests: Slugs, spider mites',
                ],
              ),

              const SizedBox(height: 15),

              // Tomato
              _buildPlantCard(
                plantId: 'tomato',
                title: "Tomato",
                scientificName: "Solanum lycopersicum",
                image:
                    "https://www.dtbrownseeds.co.uk/cdn/shop/collections/DTB_Tomato_Plants_Collection.jpg?v=1744200415&width=2048",
                description: "Warm-season perennials grown as annuals...",
                growingInfo: {
                  'Climate': 'Warm (70-85°F ideal)',
                  'Soil': 'Fertile, well-drained, pH 6.0-6.8',
                  'Sun Exposure': 'Full sun (8+ hours)',
                },
                careTips: [
                  'Start seeds indoors',
                  'Harden off seedlings',
                  'Prune suckers',
                ],
                problems: [
                  'Diseases: Early blight',
                  'Pests: Tomato hornworm',
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlantCard({
    required String plantId,
    required String title,
    required String scientificName,
    required String image,
    required String description,
    required Map<String, String> growingInfo,
    required List<String> careTips,
    required List<String> problems,
  }) {
    final isExpanded = _expandedCards[plantId] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedCards[plantId] = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Image
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    height: isExpanded ? 200 : 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: isExpanded ? 200 : 120,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green[800]!),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: isExpanded ? 200 : 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: isExpanded ? 22 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (isExpanded)
                          Text(
                            scientificName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),

              // Content (only shown when expanded)
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Growing Information
                      _buildSectionHeader("Growing Conditions"),
                      const SizedBox(height: 10),
                      ...growingInfo.entries
                          .map((entry) => _buildInfoRow(entry.key, entry.value))
                          .toList(),
                      const SizedBox(height: 20),

                      // Care Tips
                      _buildSectionHeader("Essential Care Tips"),
                      const SizedBox(height: 10),
                      ...careTips
                          .map((tip) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      const SizedBox(height: 20),

                      // Problems
                      _buildSectionHeader("Potential Problems"),
                      const SizedBox(height: 10),
                      Column(
                        children: problems
                            .map((problem) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.warning_amber_rounded,
                                          size: 18, color: Colors.orange),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          problem,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.1,
          end: 0,
          curve: Curves.easeOutQuart,
        );
  }

  Widget _buildSectionHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.green[200]!,
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
