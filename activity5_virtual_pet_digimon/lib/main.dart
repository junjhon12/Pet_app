import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async'; // Import for Timer

void main() {
  runApp(const Digivice());
}

// Main application widget
class Digivice extends StatelessWidget {
  const Digivice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digimon Pet', // App title
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: ThemeMode.system, // Theme based on system settings
      home: const DigiHomePage(), // Home page of the app
    );
  }
}

// Home page widget for the Digimon pet
class DigiHomePage extends StatefulWidget {
  const DigiHomePage({super.key});

  @override
  _DigiHomePageState createState() => _DigiHomePageState();
}

class _DigiHomePageState extends State<DigiHomePage> {
  // Digimon's default stats
  int mood = 50; 
  int hunger = 50; 
  int energy = 50; 
  int life = 100; 
  int maxLife = 100; 
  int maxEnergy = 100;

  // Digimon's RPG starting stats
  int str = 5; 
  int intelligence = 5; 
  int dex = 5; 
  int luck = 5; 

  // Random number generator for stat changes
  final Random random = Random();

  // Digimon's current evolution stage
  String evolutionStage = "Baby"; // Initial evolution stage
  bool hasEvolved = false; // Evolution status

  // Timer for updating stats
  Timer? timer; 
  DateTime lastUpdateTime = DateTime.now(); // To track the last update time

  // Stat change limits for random events
  static const int playMin = 1;
  static const int playMax = 3;
  static const int trainMin = 1;
  static const int trainMax = 4;
  static const int rookieMin = 2;
  static const int rookieMax = 5;
  static const int championMin = 5;
  static const int championMax = 10;

  @override
  void initState() {
    super.initState();
    startTimer(); // Start the timer when the widget is initialized
  }

  // Function to start a timer that updates stats periodically
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateStats());
  }

  // Update stats based on elapsed time since last update
  void updateStats() {
    DateTime now = DateTime.now(); // Get the current time
    Duration elapsed = now.difference(lastUpdateTime); // Calculate elapsed time
    lastUpdateTime = now; // Update last update time

    setState(() {
      // Decrease hunger and mood based on elapsed time
      hunger = (hunger - (elapsed.inSeconds * 2)).clamp(0, 100); // Hunger decreases by 2 per minute
      mood = (mood - (elapsed.inSeconds * 1)).clamp(0, 100); // Mood decreases by 1 per minute

      // Regain life over time if not at max life
      if (life < maxLife) {
        life = (life + (elapsed.inSeconds * 1)).clamp(0, maxLife); // Life regains by 1 per minute
      }

      // If hunger reaches 0, decrease life
      if (hunger == 0) {
        int lifeLoss = 10;
        if (mood == 0) {
          lifeLoss *= 2;
        }
        life = (life - (elapsed.inSeconds * lifeLoss)).clamp(0, maxLife);
      }
    });
  }

  // Helper method for random stat changes
  int randomStatChange(int min, int max) {
    return random.nextInt(max - min + 1) + min; // Returns a random value between min and max
  }

  // Helper method for clamping values between min and max
  int clampStat(int value, int min, int max) {
    return value.clamp(min, max); // Ensure value stays within specified limits
  }

  // Digimon's Evolution Function
  void evolve() {
    setState(() {
      // Evolution to Rookie
      if (evolutionStage == "Baby" && mood > 50 && energy > 50) {
        evolutionStage = "Rookie"; // Evolve to Rookie
        str += randomStatChange(rookieMin, rookieMax);
        intelligence += randomStatChange(rookieMin, rookieMax);
        dex += randomStatChange(rookieMin, rookieMax);
        luck += randomStatChange(rookieMin, rookieMax);
      }
      // Evolution to Champion, must already be a Rookie
      else if (evolutionStage == "Rookie" && mood > 80 && energy > 70) {
        evolutionStage = "Champion"; // Evolve to Champion
        str += randomStatChange(championMin, championMax);
        intelligence += randomStatChange(championMin, championMax);
        dex += randomStatChange(championMin, championMax);
        luck += randomStatChange(championMin, championMax);
        maxLife = 150; // Increase max life
      }

      // Once evolved to Champion, mark as fully evolved
      if (evolutionStage == "Champion") {
        hasEvolved = true; // Mark as fully evolved
      }
    });
  }


  void rest() {
  setState(() {
    mood = clampStat(mood + 30, 0, 100); // Increase mood by 30, clamp to 0-100
    hunger = clampStat(hunger - 5, 0, 100); // Decrease hunger by 5, clamp to 0-100
    energy = clampStat(energy + 30, 0, maxEnergy); // Increase energy by 30, clamp to 0-maxEnergy
    life = clampStat(life + 50, 0, maxLife); // Increase life by 50, clamp to 0-maxLife
  });
}


  // Play function to increase mood and decrease hunger
  void play() {
    setState(() {
      mood = clampStat(mood + 10, 0, 100); // Increase mood
      hunger = clampStat(hunger - 5, 0, 100); // Decrease hunger
      energy -= 10; // Decrease energy
      str += randomStatChange(playMin, playMax); // Increase strength
      dex += randomStatChange(playMin, playMax); // Increase dexterity
      evolve(); // Check for evolution
    });
  }

  // Feed function to increase mood and hunger
  void feed() {
    setState(() {
      if (hunger == 100) {
        life = (life - 10).clamp(0, maxLife); // Lose 10 life if hunger is max
      } else {
        mood = clampStat(mood + 5, 0, 100); // Increase mood
        hunger = clampStat(hunger + 10, 0, 100); // Increase hunger
        energy += 10; // Increase energy
      }
    });
  }

  // Train function to improve stats while decreasing mood and hunger
  void train() {
    setState(() {
        if (hunger == 0) {
          life = (life - 10).clamp(0, maxLife); // Lose 10 life if hunger is 0
        }
        mood = clampStat(mood - 10, 0, 100); // Decrease mood
        hunger = clampStat(hunger - 15, 0, 100); // Decrease hunger
        energy -= 15; // Decrease energy
        str += randomStatChange(trainMin, trainMax); // Improve strength
        intelligence += randomStatChange(trainMin, trainMax); // Improve intelligence
        dex += randomStatChange(trainMin, trainMax); // Improve dexterity
        evolve(); // Check for evolution
        if (mood < 0) {
          life -= 10;
        }
    });
  }

  // Reset function to reset all stats to their initial values
  void reset() {
    setState(() {
      mood = 50; // Reset mood
      hunger = 50; // Reset hunger
      energy = 50; // Reset energy
      life = 100; // Reset life
      maxLife = 100; // Reset max life
      str = 1; // Reset strength
      intelligence = 1; // Reset intelligence
      dex = 1; // Reset dexterity
      luck = 1; // Reset luck
      evolutionStage = "Baby"; // Reset evolution stage
      hasEvolved = false; // Reset evolution status
    });
  }

  // Change image based on evolution stage and life status
  Widget digimonImg() {
    if (life <= 0) {
      return Image.asset('assets/Death.png', height: 100, width: 100); // Death image
    } else {
      switch (evolutionStage) {
        case "Baby":
          return Image.asset('assets/Baby.webp', height: 100, width: 100); // Baby image
        case "Rookie":
          return Image.asset('assets/Rookie.webp', height: 100, width: 100); // Rookie image
        case "Champion":
          return Image.asset('assets/Champion.jfif', height: 100, width: 100); // Champion image
        default:
          return Image.asset('assets/Baby.webp', height: 100, width: 100); // Default image
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Digimon'), // App bar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            digimonImg(), // Display Digimon image
            Text('Stage: $evolutionStage', style: theme.textTheme.headlineSmall), // Display evolution stage
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mood: $mood', style: theme.textTheme.bodyLarge), // Display mood
                    Text('Hunger: $hunger', style: theme.textTheme.bodyLarge), // Display hunger
                    Text('HP: $life', style: theme.textTheme.bodyLarge), // Display health points
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Strength: $str', style: theme.textTheme.bodyLarge), // Display strength
                    Text('Intelligence: $intelligence', style: theme.textTheme.bodyLarge), // Display intelligence
                    Text('Dexterity: $dex', style: theme.textTheme.bodyLarge), // Display dexterity
                    Text('Luck: $luck', style: theme.textTheme.bodyLarge), // Display luck
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: theme.primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rest button
              Expanded(
                child: ElevatedButton(
                  onPressed: life > 0 ? rest : null, // Enable if life is above 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('😴'), // Button label
                ),
              ),
              SizedBox(width: 5),
              // Play button
              Expanded(
                child: ElevatedButton(
                  onPressed: life > 0 ? play : null, // Enable if life is above 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🏃‍♂️'), // Button label
                ),
              ),
              SizedBox(width: 5),
              // Feed button
              Expanded(
                child: ElevatedButton(
                  onPressed: life > 0 ? feed : null, // Enable if life is above 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🍽️'), // Button label
                ),
              ),
              SizedBox(width: 5),
              // Train button
              Expanded(
                child: ElevatedButton(
                  onPressed: (life > 0 && mood > 0) ? train : null, // Enable if life and mood are above 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🏋️‍♂️'), // Button label
                ),
              ),
              SizedBox(width: 5),
              // Reset button
              Expanded(
                child: ElevatedButton(
                  onPressed: reset, // Always enabled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🔄'), // Button label
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
