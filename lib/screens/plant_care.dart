import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantCareScreen extends StatefulWidget {
  const PlantCareScreen({super.key});

  @override
  State<PlantCareScreen> createState() => _PlantCareScreenState();
}

class _PlantCareScreenState extends State<PlantCareScreen> {
  final List<CareCategory> _categories = [
   CareCategory(
  title: "Light Science",
  icon: Icons.wb_sunny,
  color: Color(0xFFFFD54F),
  topics: [
    CareTopic(
      title: "🌈 Spectral Composition",
      content: """
The spectrum and quality of light play a crucial role in plant growth and development. Fruiting crops benefit from a Daily Light Integral (DLI) of 12 to 20 mol/m²/day. Seedlings require 100–300 μmol/m²/s of PPFD, while mature vegetative plants thrive at 400–600 μmol/m²/s.

Natural light can be enhanced using reflective mulches with 85–95% reflectivity, light-diffusing fabrics, and seasonal row orientation. These practices improve light distribution across the canopy and increase photosynthetic efficiency.
""",
      expertTip: "🌸 Use far-red light in the 700–750 nm range to stimulate early flowering in photoperiod-sensitive species.",
    ),

    CareTopic(
      title: "🕓 Photoperiod Management",
      content: """
Photoperiod — the duration of light in a 24-hour cycle — affects flowering in many crops. Long-day plants like spinach require extended light, while short-day plants like chrysanthemum initiate flowering under shorter daylight hours.

In controlled environments, blackout curtains and supplemental lighting allow precise control of photoperiod. This enhances flowering synchrony, reduces variability, and aligns harvests with market demand.
""",
      expertTip: "⏱️ Use programmable timers to automate lighting cycles and avoid manual errors.",
    ),
  ],
),
CareCategory(
  title: "Soil Science",
  icon: Icons.grass,
  color: Color(0xFF81C784),
  topics: [
    CareTopic(
      title: "🧪 Soil Biochemistry",
      content: """
Soil biochemistry governs nutrient availability, organic matter breakdown, and microbial activity. Maintaining a C:N ratio around 25:1 ensures healthy decomposition without nitrogen lockout. Cation Exchange Capacity (CEC) reflects a soil’s ability to retain nutrients — clay soils typically hold 15–30 meq/100g, while sandy soils range from 1–5 meq/100g.

Enhancements like biochar application and mycorrhizal inoculation improve nutrient retention and root-zone symbiosis, boosting plant health and soil resilience.
""",
      expertTip: "🌿 Apply humic acids to enhance nutrient chelation and microbial colonization.",
    ),

    CareTopic(
      title: "⚖️ Soil pH and Buffering",
      content: """
Soil pH affects nutrient solubility and microbial activity. Most crops grow best in a pH range of 5.8 to 6.5. Soils with high buffering capacity resist drastic pH shifts and provide stable environments for plant roots.

Adjusting pH with dolomitic lime (to raise) or elemental sulfur (to lower) is a long-term strategy. Buffering can be strengthened by increasing organic matter and minimizing synthetic input spikes.
""",
      expertTip: "🧼 Use compost to gently buffer pH without disrupting microbial communities.",
    ),
  ],
),
CareCategory(
  title: "Irrigation",
  icon: Icons.water_drop,
  color: Color(0xFF4FC3F7),
  topics: [
    CareTopic(
      title: "📊 Soil Moisture Monitoring",
      content: """
Precise irrigation begins with accurate moisture data. Tools like tensiometers, digital probes, and capacitance sensors help determine water needs and root-zone saturation levels. This prevents overwatering and conserves resources.

Maintaining moisture at field capacity improves nutrient uptake and plant health. Deep but infrequent irrigation encourages deeper root growth compared to frequent, shallow watering.
""",
      expertTip: "🔍 Place sensors at multiple soil depths to track root-zone hydration accurately.",
    ),

    CareTopic(
      title: "🚿 Efficient Irrigation Techniques",
      content: """
Choosing the right irrigation method saves water and supports consistent yields. Drip irrigation delivers water directly to the roots with minimal evaporation, making it ideal for vegetables and orchards. Sprinklers provide broader coverage but increase leaf wetness, which can raise disease risks.

Automated timers and seasonal adjustments based on evapotranspiration rates improve system efficiency and plant response.
""",
      expertTip: "🌄 Irrigate early in the morning to reduce evaporation and fungal issues.",
    ),
  ],
),
CareCategory(
  title: "Pest Management",
  icon: Icons.bug_report,
  color: Color(0xFFF06292),
  topics: [
    CareTopic(
      title: "🛡️ Integrated Pest Management (IPM)",
      content: """
IPM combines biological, cultural, physical, and chemical strategies to control pests sustainably. It starts with monitoring and identification, followed by natural controls like predators or crop rotation. Chemical control is used as a last resort and based on action thresholds.

This reduces pesticide resistance, protects beneficial insects, and ensures long-term farm health.
""",
      expertTip: "🦗 Use neem oil or Bacillus thuringiensis (Bt) as selective, eco-friendly controls.",
    ),

    CareTopic(
      title: "🔬 Early Detection & Scouting",
      content: """
Frequent field scouting helps identify pest infestations early before economic damage occurs. Use colored sticky traps, pheromone lures, and leaf inspections to monitor populations.

Recording pest trends over time improves forecasting and enables timely interventions in the next growing cycle.
""",
      expertTip: "📍 Place sticky traps at crop height to accurately monitor flying insect pressure.",
    ),
  ],
),
CareCategory(
  title: "Crop Physiology",
  icon: Icons.eco,
  color: Color(0xFF9575CD),
  topics: [
    CareTopic(
      title: "☀️ Photosynthesis and Growth",
      content: """
Photosynthesis is the core of plant energy production, converting sunlight, water, and CO₂ into carbohydrates. Healthy leaves, adequate light, and optimal temperatures support this process and lead to better growth and yields.

Shading or nutrient deficiencies can reduce photosynthetic efficiency. Proper spacing and canopy management ensure all leaves receive enough light.
""",
      expertTip: "🌾 Avoid overcrowding to minimize shading and maximize light interception.",
    ),

    CareTopic(
      title: "🧬 Plant Hormones and Regulation",
      content: """
Plant hormones like auxins, gibberellins, cytokinins, and abscisic acid regulate key functions — from seed germination to flowering and stress responses. For instance, auxins promote rooting, while ethylene accelerates fruit ripening.

External hormone applications can synchronize flowering, increase fruit size, or delay aging in post-harvest stages.
""",
      expertTip: "🌺 Apply gibberellins during early flowering to increase fruit set in grapes and cucurbits.",
    ),
  ],
),
CareCategory(
  title: "Climate Adaptation",
  icon: Icons.thermostat,
  color: Color(0xFFFF8A65),
  topics: [
    CareTopic(
      title: "🔥 Heat Stress Management",
      content: """
Rising temperatures can cause physiological stress, reduce pollination, and impair fruit development. Symptoms include leaf curling, flower drop, and sunscald.

Adaptations like shade nets, heat-tolerant varieties, and evaporative cooling systems (e.g., misting) can protect crops during peak heat waves.
""",
      expertTip: "🌬️ Use 30–50% shade nets to reduce canopy temperature without halting growth.",
    ),

    CareTopic(
      title: "❄️ Cold and Frost Protection",
      content: """
Cold snaps and frost events damage sensitive tissues and delay crop cycles. Water-based protection methods like overhead irrigation can insulate buds during frost. Row covers and low tunnels also create microclimates that reduce frost risk.

Planting dates and windbreaks help mitigate exposure in frost-prone areas.
""",
      expertTip: "🔥 Use thermal blankets overnight to protect high-value crops from sudden frost drops.",
    ),
  ],
),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        title: Text('Botanical Masterclass',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E2C),
            )),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 174, 234, 176),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5D9E5E)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(_categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CareCategory category) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(category.title,
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: const Color(0xFF2C3E2C))),
        children: category.topics.map((topic) => _buildTopicTile(topic, category.color)).toList(),
      ),
    );
  }

  Widget _buildTopicTile(CareTopic topic, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topic.title,
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: accentColor)),
          const SizedBox(height: 12),
          Text(topic.content,
              style: GoogleFonts.notoSans(
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF555555))),
          if (topic.expertTip != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 20, color: accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(topic.expertTip!,
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: accentColor)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CareCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<CareTopic> topics;

  CareCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.topics,
  });
}

class CareTopic {
  final String title;
  final String content;
  final String? expertTip;

  CareTopic({
    required this.title,
    required this.content,
    this.expertTip,
  });
}