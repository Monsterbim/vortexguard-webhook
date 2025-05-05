const express = require("express");
const axios = require("axios");
const app = express();

app.use(express.json());

const DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1369031581888413716/O-t3-Lt7iYdkgGf16ms_2pejAWJQdZtErttnBmVwg-T_C6uwU0sBlb228FILWvgA2vj4"; // <- DEIN DISCORD WEBHOOK HIER

app.post("/kick", async (req, res) => {
  const { playerName, reason } = req.body;

  if (!playerName || !reason) {
    return res.status(400).send("Missing data");
  }

  try {
    await axios.post(DISCORD_WEBHOOK_URL, {
      username: "VortexGuard",
      avatar_url: "https://i.imgur.com/LzGmQfL.png",
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

app.get("/", (req, res) => {
  res.send("✅ VortexGuard Webhook Server is running.");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));
