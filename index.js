const express = require("express");
const axios = require("axios");
const cron = require("node-cron"); // Cron-Bibliothek importieren
const app = express();

app.use(express.json());

const DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1369031581888413716/O-t3-Lt7iYdkgGf16ms_2pejAWJQdZtErttnBmVwg-T_C6uwU0sBlb228FILWvgA2vj4"; // <- DEIN DISCORD WEBHOOK HIER
const CHANNEL_ID = "1369031509172031589";  // Ersetze mit der ID deines Kanals, aus dem du Nachrichten löschen möchtest

// Kick-Endpoint für Webhook
app.post("/kick", async (req, res) => {
  const { playerName, reason } = req.body;

  if (!playerName || !reason) {
    return res.status(400).send("Missing data");
  }

  try {
    await axios.post(DISCORD_WEBHOOK_URL, {
      username: "VortexGuard",
      avatar_url: "https://github.com/Monsterbim/vortexguard-webhook/blob/main/g.png?raw=true",
      content: `🚨 **Kick Alert**
**Player:** \`${playerName}\`
**Reason:** \`${reason}\``
    });

    res.status(200).send("Logged to Discord");
  } catch (error) {
    console.error("Discord Webhook Error:", error);
    res.status(500).send("Failed to log");
  }
});

// Setze den Cron-Job, der alle 24 Stunden die Nachrichten löscht
cron.schedule('0 0 * * *', async () => {
  try {
    // Holen wir uns die letzten 100 Nachrichten im Kanal
    const response = await axios.get(`https://discord.com/api/v9/channels/${CHANNEL_ID}/messages`, {
      headers: {
        'Authorization': `Bot DEIN_BOT_TOKEN`  // Ersetze DEIN_BOT_TOKEN mit deinem echten Bot-Token
      }
    });

    const messages = response.data;

    // Lösche alle Nachrichten (max. 100 auf einmal)
    for (let message of messages) {
      await axios.delete(`https://discord.com/api/v9/channels/${CHANNEL_ID}/messages/${message.id}`, {
        headers: {
          'Authorization': `Bot DEIN_BOT_TOKEN`
        }
      });
    }

    console.log("Messages deleted successfully.");
  } catch (error) {
    console.error("Failed to delete messages:", error);
  }
});

// Root-Endpoint
app.get("/", (req, res) => {
  res.send("✅ VortexGuard Webhook Server is running.");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));
