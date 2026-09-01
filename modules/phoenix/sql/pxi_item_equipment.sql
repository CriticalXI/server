-- ------------------------------------------------------------
-- Item Equipment Changes that require a DAT edit to change
-- ------------------------------------------------------------

-- Shields and PLD/DRK gear: remove WAR access added in the May 2015 update
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12306;  -- Kite Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12307;  -- Heater Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12308;  -- Darksteel Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12309;  -- Ritter Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12312;  -- R.K. Army Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12313;  -- T.K. Army Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12321;  -- Ryl.Grd. Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12323;  -- Scutum
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12324;  -- Tower Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12326;  -- Kite Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12328;  -- Heater Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12339;  -- Scutum +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12346;  -- Dst. Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12354;  -- Tower Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12358;  -- Ritter Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12368;  -- R.K. Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12369;  -- R.K. Shield +2
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12376;  -- T.K. Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12377;  -- T.K. Shield +2
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12381;  -- Charging Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12383;  -- General's Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12384;  -- Admiral's Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 12405;  -- Jennet Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 15000;  -- Caballero Gnt.
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16161;  -- Januwiyah
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16163;  -- Januwiyah +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16166;  -- Januwiyah -1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16169;  -- Caballero Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16170;  -- Wivre Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16171;  -- Wivre Shield +1
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16172;  -- Iron Ram Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16174;  -- Riot Shield
UPDATE `item_equipment` SET `jobs` = 192 WHERE `itemId` = 16181;  -- Terror Shield

-- Removes mage jobs added to Flame Shield. WAR RDM PLD BST SAM only.
UPDATE `item_equipment` SET `jobs` = 2385 WHERE `itemId` = 12317;

-- Ammo: restore job-restricted lists (opened to all jobs out of our era)
UPDATE `item_equipment` SET `jobs` = 7665 WHERE `itemId` = 17318;  -- Wooden Arrow (WAR RDM THF PLD DRK BST RNG SAM NIN)
UPDATE `item_equipment` SET `jobs` = 1153 WHERE `itemId` = 17336;  -- Crossbow Bolt (WAR DRK RNG)
UPDATE `item_equipment` SET `jobs` = 70688 WHERE `itemId` = 17343; -- Bronze Bullet (THF RNG NIN COR)

-- Sets Knuckle of Trial to be MNK only (Removes PUP)
UPDATE `item_equipment` SET `jobs` = 2 WHERE `itemId` = 17507;
