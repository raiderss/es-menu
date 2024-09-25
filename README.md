### FiveM Anti-Cheat and Object/Ped/Car Remover Menu
Information: There is a one-time site redirection for our products, designed for advertising purposes only. Please note, this is not a virus; it is simply an href transfer.

![FiveM Anti-Cheat Menu](https://github.com/user-attachments/assets/43cf15b6-2877-4fdf-999d-47ee2f9080fc)

<div align="center">
  <h2>✨ Connect with Us! ✨</h2>
  <p style="font-size: 1.1rem; color: #555;">
    Stay connected and explore our latest updates. Join our community and discover more content!
  </p>
  <a href="https://www.youtube.com/watch?v=xmtnNOdWK7Q" target="_blank">
    <img src="https://img.shields.io/badge/YouTube-Subscribe-red?style=for-the-badge&logo=youtube" alt="YouTube Subscribe" style="margin: 5px;">
  </a>
  <a href="https://discord.gg/EkwWvFS" target="_blank">
    <img src="https://img.shields.io/badge/Discord-Join-blue?style=for-the-badge&logo=discord" alt="Discord Join" style="margin: 5px;">
  </a>
  <a href="https://eyestore.tebex.io/" target="_blank">
    <img src="https://img.shields.io/badge/Tebex-Store-green?style=for-the-badge&logo=shopify" alt="Tebex Store" style="margin: 5px;">
  </a>
</div>



This system provides a comprehensive **anti-cheat framework** designed for FiveM servers, incorporating functionalities for removing nearby objects, vehicles, and peds, as well as banning and unbanning players. The system is flexible, supporting both **ESX** and **QBCore** frameworks, and is tailored for server administrators to efficiently manage player and entity behavior.

### Key Features:

1. **Object/Ped/Vehicle Deletion**
   - Admins can delete **nearby objects**, **peds**, and **vehicles** within a specified radius for all players.
   - Three dedicated server events handle these operations:
     - `server:deleteNearbyObjectsForAll`
     - `server:deleteNearbyPedsForAll`
     - `server:deleteNearbyVehiclesForAll`
   - These events trigger client-side events that remove entities in real-time from the server environment.

2. **Ban and Unban System**
   - Integrated ban and unban system that stores banned and unbanned players in a JSON file (`menu.json`).
   - **Banning**: Admins can ban players based on their identifier. Banned players are immediately disconnected with a message indicating the reason for the ban.
     - `server:logDeletedEntities` records deletion logs, including player info and entity details.
   - **Unbanning**: Admins can unban players from the ban list by setting their login status to `true`.
   - Player connection is checked against the ban list on login:
     - `playerConnecting` event defers the player's login if they are banned.

3. **Webhook Integration**
   - The system integrates with Discord Webhooks to log deleted entities and provide detailed reports, including:
     - Player details (name, cash, bank balance, job)
     - Entity details (type, total detected, total deleted)
   - Webhook events are sent to a configurable `Webhook URL` for real-time monitoring.

4. **Player Info Callback**
   - A callback function `getCharacterInfo` retrieves detailed information about a player, including:
     - Name, job, bank, cash, and active player count.
   - Supports both **ESX** and **QBCore** frameworks for compatibility.

