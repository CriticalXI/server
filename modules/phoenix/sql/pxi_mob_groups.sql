-- Module for missing mob_groups for the ERA DATS
-- NOTE: THIS REQUIRED DAT EDITS OR IT WILL NOT WORK AND EVERYTHING WILL BE NAMED WRONG
-- https://github.com/phoenixffxi/Era-DATs

-- Bhaflau Thickets (Zone 52)
INSERT INTO `mob_groups` VALUES (200,5648,52,'Wivre',300,0,242,0,0,0,NULL);

-- Zeruhn_Mines (Zone 172)
INSERT INTO `mob_groups` VALUES (200,4053,172,'Tunnel_Worm',300,0,2496,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (201,3165,172,'Leech',300,0,963,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (202,2763,172,'Mouse_Bat',300,0,19,0,0,0,NULL);

-- Inner Horutoto Ruins (Zone 192)
INSERT INTO `mob_groups` VALUES (200,382,192,'Beady_Beetle',300,0,249,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (201,372,192,'Bat_Battalion',300,0,241,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (202,1643,192,'Goblin_Butcher',300,0,1032,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (203,1635,192,'Goblin_Ambusher',300,0,1018,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (204,1738,192,'Goblin_Tinkerer',300,0,1035,0,0,0,NULL);

-- King Ranperre's Tomb (Zone 190)
INSERT INTO `mob_groups` VALUES (200,3946,190,'Tomb_Worm',660,0,428,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (201,6456,190,'Dire_Bat',660,0,234,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (202,871,190,'Cutlass_Scorpion',660,0,549,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (203,244,190,'Armet_Beetle',660,0,670,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (204,1073,190,'Thousand_Eyes',960,0,315,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (205,1898,190,'Hati',960,0,1278,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (206,1514,190,'Lemures',960,0,1506,0,0,0,NULL);

-- Dangruf Wadi (Zone 191)
INSERT INTO `mob_groups` VALUES (200,6415,191,'Giant_Grub',300,0,2496,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (201,1666,191,'Goblin_Gambler',300,0,1082,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (202,1690,191,'Goblin_Mugger',300,0,1120,0,0,0,NULL);
INSERT INTO `mob_groups` VALUES (203,1683,191,'Goblin_Leecher',300,0,1099,0,0,0,NULL);

-- Ranguemont Pass (Zone 166)
INSERT INTO `mob_groups` VALUES (200,1715,166,'Goblin_Smithy',720,0,1162,0,0,0,NULL);

-----------------------------------
-- Dungeon respawn timers
--   Level  1-19 ->  8 minutes (480s)
--   Level 20-29 -> 10 minutes (600s)
--   Level 30-39 -> 12 minutes (720s)
--   Level 40-49 -> 14 minutes (840s)
--   Level 50+   -> 16 minutes (960s)
-----------------------------------

UPDATE `mob_groups`
INNER JOIN `zone_settings` ON `zone_settings`.zoneid = `mob_groups`.zoneid
INNER JOIN `mob_pools` ON `mob_pools`.poolid = `mob_groups`.poolid
INNER JOIN (
    SELECT
        ((mobid >> 12) & 0xFFF) AS zoneid, -- zone id is encoded in the mobid
        groupid,
        CASE
            WHEN MAX(GREATEST(minLevel, maxLevel)) <= 19 THEN 480
            WHEN MAX(GREATEST(minLevel, maxLevel)) <= 29 THEN 600
            WHEN MAX(GREATEST(minLevel, maxLevel)) <= 39 THEN 720
            WHEN MAX(GREATEST(minLevel, maxLevel)) <= 49 THEN 840
            ELSE 960
        END AS rule_respawn
    FROM mob_spawn_points
    WHERE GREATEST(minLevel, maxLevel) > 0 -- ignore the level 0 placeholder mobs
    GROUP BY ((mobid >> 12) & 0xFFF), groupid
) spawn_levels ON spawn_levels.zoneid = mob_groups.zoneid AND spawn_levels.groupid = mob_groups.groupid
SET mob_groups.respawntime = spawn_levels.rule_respawn
WHERE (zone_settings.zonetype & 0x04) > 0            -- dungeon zones only
  AND (mob_groups.spawntype & 0xE0) = 0              -- skip lottery (0x20), windowed (0x40), and scripted (0x80) spawns
  AND (mob_pools.mobType & 0x02) = 0                 -- skip notorious monsters
  AND mob_groups.respawntime > 0;                    -- skip mobs that never respawn on a timer
